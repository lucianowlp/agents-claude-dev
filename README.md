# agents-claude-dev

Marketplace de plugins do Claude Code com o **fluxo-dev**: um fluxo de desenvolvimento local com subagentes, pensado para projetos **.NET**, **Angular** e **Python** (sozinhos ou juntos no mesmo repositório).

```
/fluxo-dev:configurar-projeto   →  wizard: detecta a stack, pergunta como rodar/testar, valida e gera o CLAUDE.md
/fluxo-dev:nova-feature <pedido> →  planejador → (você aprova) → implementador → testador → revisor
/fluxo-dev:subir-ambiente        →  sobe dependências e aplicações com os comandos do CLAUDE.md
```

## O que vem no plugin

| Tipo | Nome | Função |
|---|---|---|
| Skill | `configurar-projeto` | Wizard por projeto: detecção automática + perguntas + validação dos comandos + geração de `CLAUDE.md`, `.claude/fluxo-dev.env` e permissões |
| Skill | `nova-feature` | Orquestra os 4 subagentes, com aprovação do plano e no máx. 2 voltas de correção |
| Skill | `subir-ambiente` | Sobe/para o ambiente local seguindo o `CLAUDE.md` |
| Subagente | `planejador` | Lê o código e entrega um plano. Não edita |
| Subagente | `implementador` | Implementa só o plano aprovado, com testes |
| Subagente | `testador` | Roda build/testes, escreve testes faltantes. Não mexe em código de produção |
| Subagente | `revisor` | Revisa correção, segurança e convenções. Não edita |
| Hook | `checar-apos-edicao` | Após cada edição, roda a checagem rápida da extensão do arquivo (`CHECAR_cs`, `CHECAR_ts`, `CHECAR_py`…) e devolve erros ao Claude |

Os agentes não têm comandos fixos: eles usam a seção `## Comandos` do `CLAUDE.md` de cada projeto, que o wizard gera.

## Instalação

No terminal interativo do Claude Code:

```
/plugin marketplace add lucianowlp/agents-claude-dev
/plugin install fluxo-dev@agents-claude-dev
```

Se você declarar o marketplace direto no `~/.claude/settings.json`, as skills só aparecem depois que o app baixa o plugin para o cache — aguarde um pouco ou reabra a sessão.

Depois, dentro de cada projeto (com a sessão aberta na raiz do git):

```
/fluxo-dev:configurar-projeto
```

### Instalar automaticamente para o time
O wizard oferece adicionar ao `.claude/settings.json` do projeto (versionado):

```json
{
  "extraKnownMarketplaces": {
    "agents-claude-dev": { "source": { "source": "github", "repo": "lucianowlp/agents-claude-dev" } }
  },
  "enabledPlugins": { "fluxo-dev@agents-claude-dev": true }
}
```

Quem abrir o projeto no Claude Code é convidado a instalar o plugin.

## O que o wizard gera no projeto

```
CLAUDE.md                  ← bloco entre <!-- fluxo-dev:inicio --> e <!-- fluxo-dev:fim -->
                             (o resto do arquivo é preservado)
.claude/fluxo-dev.env      ← checagens rápidas por extensão, usadas pelo hook
.claude/settings.json      ← deny de leitura para segredos, allow para comandos de build/teste
```

Exemplo de `.claude/fluxo-dev.env`:

```bash
CHECAR_cs="dotnet build src/Api/Api.csproj --nologo -v q -clp:ErrorsOnly"   # ou a .sln/.slnx
CHECAR_ts="cd frontend && npx tsc --noEmit -p tsconfig.app.json"
CHECAR_py="ruff check ."
TEMPO_MAXIMO=170
ATIVO=1
```

O arquivo é lido como texto (não é executado com `source`); só o comando da extensão editada roda. Se passar do `TEMPO_MAXIMO`, a checagem é interrompida sem bloquear o Claude.

O hook procura a config primeiro em `$CLAUDE_PROJECT_DIR/.claude/fluxo-dev.env` (a pasta da sessão). Se não achar, sobe a partir da pasta do arquivo editado até a raiz do git (ou a raiz do disco), e roda o comando a partir da pasta onde a config foi encontrada. Isso cobre sessões abertas numa pasta acima do repositório, mas o recomendado é **abrir as sessões na raiz do git**: o `CLAUDE.md`, o `.claude/settings.json` e as skills do projeto são carregados a partir da pasta da sessão.

### O que o wizard aproveita do projeto
- Comandos do CI, `AGENTS.md`, regras do Cursor (`.cursor/rules`, `.cursorrules`), skills do projeto em `.claude/skills`, `.claude/launch.json` e scripts `run-dev.*` / `start.*` — o `CLAUDE.md` gerado aponta para eles em vez de duplicar.
- A convenção de commits vista no `git log`: o wizard só pede confirmação.
- Comandos que já falham em código legado (ex.: `prettier --check` em centenas de arquivos) ficam como "conhecido quebrado" e não viram checagem automática.

No caso típico são no máximo 3 rodadas de perguntas, mesmo com duas stacks.

## Requisitos
- Claude Code (CLI, desktop ou IDE).
- `bash` disponível para o hook — no Windows, o Git Bash que acompanha o Git for Windows.

## Desenvolvimento do plugin

```
.claude-plugin/marketplace.json     ← catálogo (aponta para plugins/fluxo-dev)
plugins/fluxo-dev/
├── .claude-plugin/plugin.json
├── agents/                         ← subagentes
├── skills/                         ← configurar-projeto (com referencias/ e modelos/), nova-feature, subir-ambiente
└── hooks/                          ← hooks.json + checar-apos-edicao.sh
tests/hook.test.sh                  ← testes do hook
```

Testar o hook: `bash tests/hook.test.sh`

Testar o plugin localmente sem publicar: `claude --plugin-dir ./plugins/fluxo-dev`

Ao mudar o comportamento, suba a `version` em `plugin.json` e em `marketplace.json`.
