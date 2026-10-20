#!/usr/bin/env bash
# Testes do hook checar-apos-edicao.sh. Uso: bash tests/hook.test.sh
set -u

raiz="$(cd "$(dirname "$0")/.." && pwd)"
hook="$raiz/plugins/fluxo-dev/hooks/checar-apos-edicao.sh"
projeto="$(mktemp -d)"
base="$(mktemp -d)"
trap 'rm -rf "$projeto" "$base"' EXIT
mkdir -p "$projeto/.claude"
export CLAUDE_PROJECT_DIR="$projeto"

falhas=0
caso() { # caso <descrição> <exit esperado> <file_path já escapado para JSON>
  local saida status
  saida="$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$3" | bash "$hook" 2>&1)"; status=$?
  if [ "$status" -eq "$2" ]; then echo "ok   - $1"; else echo "FALHA - $1 (esperado $2, veio $status)"; echo "$saida" | sed 's/^/       /'; falhas=$((falhas+1)); fi
}

caso "sem config não faz nada" 0 'C:\\proj\\src\\A.cs'

cat > "$projeto/.claude/fluxo-dev.env" <<'EOF'
CHECAR_cs="echo compilando && true"
CHECAR_ts="echo 'erro TS2322' && exit 1"
CHECAR_py=""
TEMPO_MAXIMO=5
EOF

caso "checagem .cs passa"                 0 'C:\\proj\\src\\Program.cs'
caso "extensão em maiúscula (.CS) passa"  0 '/proj/src/Program.CS'
caso "checagem .ts falha -> exit 2"       2 '/proj/frontend/src/app/app.component.ts'
caso "extensão vazia (.py) é ignorada"    0 '/proj/app/main.py'
caso "extensão sem config (.md) ignorada" 0 '/proj/README.md'
caso "arquivo sem extensão ignorado"      0 '/proj/Makefile'

printf 'CHECAR_cs="sleep 3"\nTEMPO_MAXIMO=1\n' > "$projeto/.claude/fluxo-dev.env"
caso "timeout não bloqueia o Claude"      0 '/proj/A.cs'

printf 'CHECAR_ts="exit 1"\nATIVO=0\n' > "$projeto/.claude/fluxo-dev.env"
caso "ATIVO=0 desliga o hook"             0 '/proj/a.ts'

printf 'CHECAR_ts="exit 1"\r\nATIVO=1\r\n' > "$projeto/.claude/fluxo-dev.env"
caso "config com CRLF funciona"           2 '/proj/a.ts'

# --- Sessão aberta numa pasta acima da raiz do git (busca a partir do arquivo) ---
# $base/sessao        <- CLAUDE_PROJECT_DIR, sem config
# $base/site/.git     <- raiz do git, com .claude/fluxo-dev.env
# $base/outro/.git    <- raiz do git, sem config
# $base/.claude/...   <- config ACIMA das raízes do git (não deve ser usada)
mkdir -p "$base/sessao" "$base/site/.git" "$base/site/.claude" "$base/site/src/app" \
         "$base/outro/.git" "$base/outro/src" "$base/.claude"
export CLAUDE_PROJECT_DIR="$base/sessao"
printf 'CHECAR_ts="exit 1"\nCHECAR_cs="test -f marcador.txt"\n' > "$base/site/.claude/fluxo-dev.env"
printf 'CHECAR_ts="exit 1"\n' > "$base/.claude/fluxo-dev.env"

caso "config só na subpasta-raiz do git é encontrada"   2 "$base/site/src/app/a.ts"
caso "comando sem marcador na pasta da config falha"    2 "$base/site/src/Program.cs"
touch "$base/site/marcador.txt"
caso "comando roda a partir da pasta da config"         0 "$base/site/src/Program.cs"
caso "config não encontrada até a raiz do git -> nada"  0 "$base/outro/src/a.ts"

if command -v cygpath >/dev/null 2>&1; then
  windows="$(cygpath -w "$base/site/src/app/a.ts" | sed 's/\\/\\\\/g')"
  caso "busca funciona com caminho Windows (C:\\...)"   2 "$windows"
fi

echo
[ "$falhas" -eq 0 ] && echo "Todos os testes passaram." || { echo "$falhas teste(s) falharam."; exit 1; }
