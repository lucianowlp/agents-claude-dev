#!/usr/bin/env bash
# Hook PostToolUse do plugin fluxo-dev.
# Lê .claude/fluxo-dev.env do projeto e roda CHECAR_<extensão> para o arquivo editado.
#   exit 0 -> segue normalmente (sem config, extensão sem checagem ou checagem ok)
#   exit 2 -> checagem falhou; a saída (stderr) volta para o Claude corrigir
#
# Onde procura a config:
#   1. $CLAUDE_PROJECT_DIR/.claude/fluxo-dev.env (a pasta da sessão);
#   2. senão, sobe a partir da pasta do arquivo editado até a raiz do git
#      (pasta com .git) ou a raiz do disco.
# O comando roda a partir da pasta onde a config foi encontrada.

entrada="$(cat)"
arquivo="$(printf '%s' "$entrada" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -n "$arquivo" ] || exit 0

# Converte o caminho do JSON (C:\\proj\\a.cs ou /c/proj/a.cs) para o formato do bash.
caminho_bash() {
  local p
  p="$(printf '%s' "$1" | tr '\\' '/' | tr -s '/')"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$p" 2>/dev/null || printf '%s' "$p"
  else
    case "$p" in
      [A-Za-z]:/*) printf '/%s%s' "$(printf '%s' "${p:0:1}" | tr '[:upper:]' '[:lower:]')" "${p:2}" ;;
      *) printf '%s' "$p" ;;
    esac
  fi
}

projeto="${CLAUDE_PROJECT_DIR:-$PWD}"
config="$projeto/.claude/fluxo-dev.env"
if [ ! -f "$config" ]; then
  config=""
  pasta="$(caminho_bash "$arquivo")"
  case "$pasta" in /*) ;; *) pasta="$projeto/$pasta" ;; esac
  pasta="${pasta%/*}"
  while [ -n "$pasta" ]; do
    if [ -f "$pasta/.claude/fluxo-dev.env" ]; then
      projeto="$pasta"; config="$pasta/.claude/fluxo-dev.env"; break
    fi
    [ -e "$pasta/.git" ] && break
    pasta="${pasta%/*}"
  done
  [ -n "$config" ] || exit 0
fi

# Lê o valor de uma chave do arquivo de config SEM executá-lo (não usa `source`).
ler_config() {
  local linha
  linha="$(grep -E "^[[:space:]]*$1=" "$config" | tail -1)" || return 0
  linha="${linha#*=}"
  linha="${linha%$'\r'}"
  case "$linha" in
    \"*\") linha="${linha:1:${#linha}-2}" ;;
    \'*\') linha="${linha:1:${#linha}-2}" ;;
  esac
  printf '%s' "$linha"
}

[ "$(ler_config ATIVO)" = "0" ] && exit 0

nome="${arquivo##*[/\\]}"
case "$nome" in
  *.*) extensao="${nome##*.}" ;;
  *) exit 0 ;;
esac
extensao="$(printf '%s' "$extensao" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')"
[ -n "$extensao" ] || exit 0

comando="$(ler_config "CHECAR_$extensao")"
[ -n "$comando" ] || exit 0

tempo="$(ler_config TEMPO_MAXIMO)"
case "$tempo" in ''|*[!0-9]*) tempo=170 ;; esac

cd "$projeto" || exit 0
if command -v timeout >/dev/null 2>&1; then
  saida="$(timeout "$tempo" bash -c "$comando" 2>&1)"; status=$?
else
  saida="$(bash -c "$comando" 2>&1)"; status=$?
fi

[ "$status" -eq 0 ] && exit 0

if [ "$status" -eq 124 ]; then
  echo "fluxo-dev: checagem de .$extensao passou de ${tempo}s e foi interrompida (\`$comando\`). Considere um comando mais rápido em $config." >&2
  exit 0
fi

{
  echo "fluxo-dev: a checagem falhou após editar $nome"
  echo "Comando: $comando (em $projeto)"
  echo "---"
  printf '%s\n' "$saida" | tail -40
} >&2
exit 2
