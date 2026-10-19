---
name: configurar-projeto
description: Wizard que configura o fluxo de desenvolvimento no projeto atual — detecta a stack (.NET, Angular, Python), faz perguntas ao usuário sobre como rodar, testar e quais regras seguir, valida os comandos e gera o CLAUDE.md e a checagem automática. Use na primeira vez em um projeto, ou quando o usuário pedir para configurar, reconfigurar ou atualizar os comandos do projeto.
---

# Wizard de configuração do projeto

Objetivo: deixar na raiz do projeto tudo o que os subagentes `planejador`, `implementador`, `testador` e `revisor` precisam para trabalhar sozinhos:
- `CLAUDE.md` com stack, comandos, convenções e regras (bloco gerenciado entre marcadores);
- `.claude/fluxo-dev.env` com as checagens rápidas que o hook roda após cada edição;
- `.claude/settings.json` com permissões (bloquear leitura de segredos, liberar comandos de teste).

Arquivos de apoio nesta pasta da skill: `referencias/dotnet.md`, `referencias/angular.md`, `referencias/python.md` (sinais de detecção e comandos padrão) e `modelos/CLAUDE.md`, `modelos/fluxo-dev.env` (formato de saída). Leia as referências das stacks detectadas antes da etapa 3.

Fale com o usuário em português, de forma curta. Use a ferramenta **AskUserQuestion** para cada rodada de perguntas (até 4 perguntas por chamada), sempre com opções pré-preenchidas a partir do que foi detectado e a recomendada em primeiro, marcada com "(Recomendado)". O usuário sempre pode responder "Outro" com texto livre. **Não pergunte o que dá para descobrir lendo o repositório.**

## Etapa 0 — Já configurado?
Se o `CLAUDE.md` contém `<!-- fluxo-dev:inicio -->` ou existe `.claude/fluxo-dev.env`, leia-os e pergunte: reconfigurar tudo, atualizar só uma parte (comandos / checagem automática / regras) ou cancelar. Em atualização parcial, pule direto para a etapa correspondente e preserve o resto.

## Etapa 1 — Detecção (somente leitura)
Investigue sem alterar nada:
- **Stacks**: sinais listados em cada arquivo de `referencias/`. Anote a pasta de cada stack (monorepos são comuns: ex. `backend/` .NET + `frontend/` Angular).
- **Fonte da verdade dos comandos**, nesta ordem de confiança: pipelines de CI (`.github/workflows/*.yml`, `azure-pipelines.yml`, `.gitlab-ci.yml`), `Makefile`/`justfile`/`scripts/`, `package.json` (scripts), `docker-compose*.yml`, `README`.
- **Infra local**: `docker-compose*.yml`, `Dockerfile`, bancos/serviços usados (SQL Server, Postgres, Redis...), arquivos de segredo (`.env*`, `appsettings.Development.json`, `secrets.json`, `*.pfx`) — só registre os caminhos, **nunca leia o conteúdo**.
- **Ferramentas instaladas**: `dotnet --version`, `node --version`, `npm --version`, `python --version` / `py --version`, `docker version --format '{{.Server.Version}}'`. Isso decide se dá para rodar nativo ou só via Docker.
- **CLAUDE.md existente**: preserve todo conteúdo fora dos marcadores.

Mostre um resumo curto em tabela: stack | pasta | versão | build | testes | rodar — marcando o que foi **detectado** e o que ficou **sem resposta**.

## Etapa 2 — Rodada 1: visão geral
Pergunte (uma chamada AskUserQuestion):
1. **Stacks** do projeto (multiSelect, pré-marcadas as detectadas).
2. **Como o ambiente local roda**: tudo em Docker Compose / tudo nativo / misto (infra em Docker, apps nativas) / outro.
3. **Idioma** do código e dos commits (pt / en) — só se não for óbvio pelo código.
4. **Objetivo do fluxo**: apenas features no código existente / também criar projetos e módulos novos — só se o repositório estiver quase vazio.

## Etapa 3 — Rodada 2: comandos por stack
Para cada stack confirmada, uma chamada AskUserQuestion com até 4 perguntas, usando como opções o que foi detectado + os padrões de `referencias/<stack>.md`:
- comando de **build**;
- comando de **testes** (suíte completa);
- comando para **rodar a aplicação** localmente (e a URL/porta);
- comando de **lint/format** (ou "nenhum").
Se o ambiente for Docker, ofereça também as variantes via `docker compose run/exec`.
Depois, uma pergunta extra se houver infra: como **subir e parar** dependências (ex.: `docker compose up -d db`) e se há **migrations/seed** a rodar.

## Etapa 4 — Rodada 3: checagem automática após edição
Explique em uma frase: a cada arquivo editado pelo Claude, um comando rápido roda e, se falhar, o Claude corrige na hora. Para cada stack pergunte o que rodar (opções de `referencias/<stack>.md`, na ordem: checagem rápida recomendada, testes rápidos, nada). Avise que algo acima de ~30 s deixa o fluxo lento.

## Etapa 5 — Rodada 4: regras do time
Uma chamada AskUserQuestion com:
1. **Convenção de commits** (Conventional Commits / livre / outra) e **branches** (ex.: `feature/…`).
2. **Arquivos sensíveis** que o Claude nunca deve ler (multiSelect, pré-marcados os detectados).
3. **Ações proibidas** (multiSelect): rodar migrations fora do banco local, `git push`, instalar dependências sem perguntar, alterar arquivos de CI.
4. **Aprovação do plano** antes de implementar: sempre / só para mudanças grandes.

## Etapa 6 — Validação
Rode cada comando de build e de testes uma vez (e a checagem automática de cada stack). Comandos que sobem serviços, aplicam migrations ou demoram mais de ~2 min: **pergunte antes**. Mostre o resultado em tabela (✅ / ❌ + resumo do erro). Se algo falhar, ofereça corrigir a resposta (voltar à pergunta) ou registrar como "conhecido quebrado" no `CLAUDE.md`.

## Etapa 7 — Gerar arquivos
Mostre um resumo do que será escrito e peça confirmação. Então:
1. **`CLAUDE.md`**: preencha `modelos/CLAUDE.md`. Se o arquivo já existe, substitua apenas o bloco entre `<!-- fluxo-dev:inicio -->` e `<!-- fluxo-dev:fim -->` (ou acrescente o bloco no fim) — nunca apague conteúdo do usuário. Mantenha-o curto: só fatos úteis, sem repetir o que o código já diz.
2. **`.claude/fluxo-dev.env`**: preencha `modelos/fluxo-dev.env` com as checagens escolhidas. Comandos rodam a partir da raiz do projeto; use `cd pasta && …` para subpastas.
3. **`.claude/settings.json`**: faça merge (preserve o que existe) adicionando:
   - `permissions.deny`: `Read(<caminho>)` para cada arquivo sensível;
   - `permissions.allow`: `Bash(<comando>:*)` para os comandos de build/teste/lint validados;
   - opcional, se o usuário quiser que o time receba o plugin automaticamente ao abrir o projeto:
     `"extraKnownMarketplaces": {"agents-claude-dev": {"source": {"source": "github", "repo": "lucianowlp/agents-claude-dev"}}}` e `"enabledPlugins": {"fluxo-dev@agents-claude-dev": true}`.
4. Sugira adicionar `.claude/settings.local.json` ao `.gitignore` se ainda não estiver.

## Etapa 8 — Encerrar
Liste os arquivos criados/alterados, o que foi validado e o que ficou pendente. Explique o próximo passo:
`/fluxo-dev:nova-feature <descrição>` para desenvolver, `/fluxo-dev:subir-ambiente` para rodar e `/fluxo-dev:configurar-projeto` de novo para ajustar. Não faça commit sem o usuário pedir.
