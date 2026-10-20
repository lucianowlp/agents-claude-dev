---
name: configurar-projeto
description: Wizard que configura o fluxo de desenvolvimento no projeto atual — detecta a stack (.NET, Angular, Python), faz perguntas ao usuário sobre como rodar, testar e quais regras seguir, valida os comandos e gera o CLAUDE.md e a checagem automática. Use na primeira vez em um projeto, ou quando o usuário pedir para configurar, reconfigurar ou atualizar os comandos do projeto.
---

# Wizard de configuração do projeto

Objetivo: deixar na raiz do projeto (a raiz do git) tudo o que os subagentes `planejador`, `implementador`, `testador` e `revisor` precisam para trabalhar sozinhos:
- `CLAUDE.md` com stack, comandos, convenções e regras (bloco gerenciado entre marcadores);
- `.claude/fluxo-dev.env` com as checagens rápidas que o hook roda após cada edição;
- `.claude/settings.json` com permissões (bloquear leitura de segredos, liberar comandos de teste).

Arquivos de apoio nesta pasta da skill: `referencias/dotnet.md`, `referencias/angular.md`, `referencias/python.md` (sinais de detecção, comandos padrão e armadilhas) e `modelos/CLAUDE.md`, `modelos/fluxo-dev.env` (formato de saída). Leia as referências das stacks detectadas logo após a etapa 1.

## Regras de conversa
- **Idioma: todo texto para o usuário sai em português** — perguntas, opções, resumos, tabelas, mensagens de erro explicadas, o relatório de validação e o relatório final. Isso vale mesmo que o código, os logs ou estas instruções tragam termos em inglês; nomes de comandos e arquivos ficam como são.
- Seja curto. Use a ferramenta **AskUserQuestion** para as perguntas, com opções pré-preenchidas a partir do que foi detectado e a recomendada em primeiro, marcada com "(Recomendado)". O usuário sempre pode responder "Outro" com texto livre.
- **Não pergunte o que dá para descobrir.** O que a detecção respondeu com segurança (comando do CI ou de um `AGENTS.md`, convenção de commits vista no `git log`, gerenciador de pacotes pelo lockfile...) é apresentado como **inferido** no resumo da etapa 1, e o usuário só confirma ou corrige. Pergunte apenas o que ficou ambíguo ou sem resposta.
- **No máximo 3 rodadas de perguntas no caso típico** (etapas 2, 3 e 4). Cada chamada aceita até 4 perguntas: junte perguntas de stacks diferentes na mesma chamada (ex.: "testes .NET" e "testes Angular" lado a lado) e pule perguntas cujas respostas já foram inferidas. Se uma rodada ficar vazia, pule-a. Rodadas extras só para resolver falhas da validação (etapa 5).

## Etapa 0 — Já configurado?
Se o `CLAUDE.md` contém `<!-- fluxo-dev:inicio -->` ou existe `.claude/fluxo-dev.env`, leia-os e pergunte: reconfigurar tudo, atualizar só uma parte (comandos / checagem automática / regras) ou cancelar. Em atualização parcial, pule direto para a etapa correspondente e preserve o resto.

## Etapa 1 — Detecção (somente leitura)
Investigue sem alterar nada:
- **Raiz do git**: rode `git rev-parse --show-toplevel` na pasta da sessão.
  - Se falhar, procure subpastas com `.git` (até 2 níveis). Achou uma: ela é a raiz do projeto. Achou várias: pergunte qual na rodada 1. Achou nenhuma: use a pasta da sessão.
  - Se a raiz do git **não** for a pasta da sessão, avise já no resumo: os arquivos serão gravados na raiz do git, e as próximas sessões devem ser abertas lá (`claude` dentro de `<raiz do git>` ou abrir essa pasta no app). Motivo: o `CLAUDE.md`, o `.claude/settings.json` e as skills do projeto são carregados a partir da pasta da sessão. O hook do fluxo-dev se vira (procura a config subindo a partir do arquivo editado), mas o resto não.
  - Todos os caminhos e comandos daqui em diante são relativos à raiz do git.
- **Stacks**: sinais listados em cada arquivo de `referencias/`. Anote a pasta de cada stack (monorepos são comuns: ex. `backend/` .NET + `frontend/` Angular). Em .NET, anote o **ponto de entrada** do build (`.slnx`, `.sln` ou o `.csproj` de entrada — veja `referencias/dotnet.md`).
- **Instruções que já existem no projeto** — leia todas e use como fonte de comandos e regras:
  `AGENTS.md` (raiz e subpastas), `CLAUDE.md` e `CLAUDE.local.md` existentes, regras do Cursor (`.cursor/rules/*.mdc`, `.cursorrules`), `.github/copilot-instructions.md`, skills e comandos do projeto (`.claude/skills/*/SKILL.md`, `.claude/commands/*.md`), `.claude/launch.json` (servidores de dev, portas) e scripts de subida (`run-dev.*`, `start.*`, `dev.*` na raiz ou em `scripts/`).
  - No `CLAUDE.md` gerado, **aponte** para esses arquivos (seção "Instruções existentes") em vez de copiar o conteúdo deles; registre só o que os subagentes precisam ter à mão (os comandos).
  - Se uma skill do projeto ou um script já sobe o app (ex.: skill `run-dev` + `run-dev.bat`), sinalize a sobreposição com `/fluxo-dev:subir-ambiente` e registre o script como o comando "Rodar", para as duas coisas fazerem o mesmo.
  - Se essas instruções contradizem o CI ou entre si, mostre a divergência e pergunte qual vale.
- **Fonte da verdade dos comandos**, nesta ordem de confiança: pipelines de CI (`.github/workflows/*.yml`, `azure-pipelines.yml`, `.gitlab-ci.yml`), instruções existentes (item acima), `Makefile`/`justfile`/`scripts/`, `package.json` (scripts), `docker-compose*.yml`, `README`.
- **Convenções pelo histórico**: `git log --oneline -30` (padrão das mensagens: Conventional Commits ou livre, idioma, prefixo de ticket) e `git branch -a` (padrão de nomes de branch). Registre como inferido.
- **Infra local**: `docker-compose*.yml`, `Dockerfile`, bancos/serviços usados (SQL Server, Postgres, Redis...), arquivos de segredo (`.env*`, `appsettings.Development.json`, `secrets.json`, `*.pfx`, `dataprotection-keys/`) — só registre os caminhos, **nunca leia o conteúdo**.
- **Ferramentas instaladas**: `dotnet --version`, `node --version`, `npm --version`, `python --version` / `py --version`. Isso decide se dá para rodar nativo ou só via Docker.
- **Docker** — distinga os três casos, porque o tratamento é diferente:
  1. `docker --version` falha → **não instalado**. Diga ao usuário: instalar o Docker Desktop, ou rodar tudo nativo se as stacks permitirem. Comandos que dependem de Docker ficam "não validados".
  2. `docker --version` funciona, mas `docker info --format '{{.ServerVersion}}'` falha → **instalado, mas parado** (o daemon não responde). Diga ao usuário: abrir o Docker Desktop e esperar o ícone ficar estável (ou rodar `Start-Process "Docker Desktop"` no PowerShell), e avise **antes da validação**, para os comandos com Docker não falharem por isso. Não registre o Docker como ausente.
  3. Os dois funcionam → disponível.

Mostre um resumo curto em tabela: stack | pasta | versão | build | testes | teste único | rodar | lint — marcando cada célula como **inferido** (com a fonte: CI, AGENTS.md, package.json...) ou **sem resposta**. Logo abaixo, em uma lista curta: raiz do git, instruções existentes encontradas, convenção de commits inferida, estado do Docker.

## Etapa 2 — Rodada 1: confirmar o inferido e a visão geral
Uma chamada AskUserQuestion com até 4 perguntas, só as que fizerem sentido:
1. **O inferido está certo?** — "Sim, está tudo certo (Recomendado)" / "Quero corrigir algo" (o usuário diz o quê em "Outro"). Cobre stacks, comandos inferidos e a convenção de commits/branches vista no `git log`.
2. **Como o ambiente local roda**: tudo em Docker Compose / tudo nativo / misto (infra em Docker, apps nativas) — pule se o script de subida ou as instruções existentes já dizem.
3. **Raiz do projeto**, se houver mais de um repositório git abaixo da pasta da sessão.
4. **Objetivo do fluxo**: apenas features no código existente / também criar projetos e módulos novos — só se o repositório estiver quase vazio.

Idioma do código e dos commits não é pergunta: infira pelo código e pelo `git log`.

## Etapa 3 — Rodada 2: comandos que faltam e checagem automática
Uma chamada AskUserQuestion (duas no máximo, se houver 3 stacks) com **todas as stacks juntas**, perguntando só o que ficou **sem resposta** ou ambíguo, com as opções detectadas + os padrões de `referencias/<stack>.md`:
- comando de **build**, **testes** (suíte completa), **teste único**, **rodar a aplicação** (e a URL/porta ou rota de health), **lint/format** (ou "nenhum");
- **checagem automática após edição** de cada stack. Explique em uma frase: a cada arquivo editado pelo Claude, um comando rápido roda e, se falhar, o Claude corrige na hora. Opções na ordem de `referencias/<stack>.md` (checagem rápida recomendada, testes rápidos, nada). Avise que algo acima de ~30 s deixa o fluxo lento.
- se houver infra: como **subir e parar** as dependências (ex.: `docker compose up -d db`) e se há **migrations/seed** a rodar.

Se o ambiente for Docker, ofereça também as variantes via `docker compose run/exec`. Se tudo já foi inferido e confirmado na rodada 1, pergunte só a checagem automática.

## Etapa 4 — Rodada 3: regras do time
Uma chamada AskUserQuestion com:
1. **Arquivos sensíveis** que o Claude nunca deve ler (multiSelect, pré-marcados os detectados).
2. **Ações proibidas** (multiSelect): rodar migrations fora do banco local, `git push`, instalar dependências sem perguntar, alterar arquivos de CI.
3. **Aprovação do plano** antes de implementar: sempre / só para mudanças grandes.
4. **Convenção de commits/branches** — só se o `git log` não mostrou padrão (repositório novo ou mensagens sem padrão).

## Etapa 5 — Validação
Rode cada comando de build, testes e teste único uma vez, e a checagem automática de cada stack (meça o tempo). Comandos que sobem serviços, aplicam migrations ou demoram mais de ~2 min: **pergunte antes**. Se o Docker está parado (etapa 1), lembre o usuário antes de começar.

- **Comando de "rodar" (processo longo)**: com a permissão do usuário, rode em background (Bash com `run_in_background`), espere a URL ou o health responder com um limite de tempo — ex.: `for i in $(seq 1 60); do curl -s -o /dev/null -w '%{http_code}' http://localhost:4200 | grep -q 200 && break; sleep 2; done` — e registre o tempo que levou. Depois **encerre o processo** que você iniciou (e o `docker compose down` correspondente, sem `-v`) ou, se o usuário preferir deixar rodando, **avise que ele continua rodando** e como parar. Nunca use esse comando como checagem automática.
- **Lint/format já falhando em código legado** (ex.: `prettier --check` acusando centenas de arquivos que ninguém tocou): não é erro de configuração. Registre como **conhecido quebrado** no `CLAUDE.md`, com o número de arquivos, e **não** use esse comando como checagem automática. Ofereça como alternativa rodar o lint só nos arquivos alterados (ex.: `npx prettier --check <arquivo>`), sem bloquear o fluxo.
- **Avisos que não quebram** (vulnerabilidade em pacote, budget de bundle estourado, warnings em massa): registre em "Avisos conhecidos" para os subagentes não tentarem consertar sem pedido.

Mostre o resultado em tabela, em português: comando | resultado (✅ / ❌ / ⚠️ conhecido quebrado / não validado) | tempo | resumo do erro. Para cada ❌ que não seja legado, ofereça corrigir a resposta (uma rodada extra) ou registrar como "conhecido quebrado".

## Etapa 6 — Gerar arquivos
Mostre um resumo do que será escrito (em português) e peça confirmação. Então, na raiz do git:
1. **`CLAUDE.md`**: preencha `modelos/CLAUDE.md`. Se o arquivo já existe, substitua apenas o bloco entre `<!-- fluxo-dev:inicio -->` e `<!-- fluxo-dev:fim -->` (ou acrescente o bloco no fim) — nunca apague conteúdo do usuário. Mantenha-o curto: só fatos úteis, sem repetir o que o código ou as instruções existentes já dizem. Linhas e seções que não se aplicam (ex.: "Migrations" num projeto sem banco) são **apagadas**, não deixadas com placeholder.
2. **`.claude/fluxo-dev.env`**: preencha `modelos/fluxo-dev.env` com as checagens escolhidas. Os comandos rodam a partir da pasta que contém `.claude/` (a raiz do git); use `cd pasta && …` para subpastas.
3. **`.claude/settings.json`**: faça merge (preserve o que existe) adicionando:
   - `permissions.deny`: `Read(<caminho>)` para cada arquivo sensível;
   - `permissions.allow`: `Bash(<comando>:*)` para os comandos de build/teste/lint validados;
   - opcional, se o usuário quiser que o time receba o plugin automaticamente ao abrir o projeto:
     `"extraKnownMarketplaces": {"agents-claude-dev": {"source": {"source": "github", "repo": "lucianowlp/agents-claude-dev"}}}` e `"enabledPlugins": {"fluxo-dev@agents-claude-dev": true}`.
4. Sugira adicionar `.claude/settings.local.json` ao `.gitignore` se ainda não estiver.

## Etapa 7 — Conferir o que foi gerado
1. **Nenhum placeholder do modelo pode sobrar.**
   - `CLAUDE.md`: rode `grep -nE '<[^!>][^>]*>' CLAUDE.md` e olhe as ocorrências dentro do bloco fluxo-dev. Cada uma fora de código (`` `…` ``) é sobra do modelo: preencha com o valor real ou apague a linha. Dentro de um comando só é aceitável quando é argumento que quem roda escolhe na hora (ex.: o nome em `dotnet ef migrations add <Nome>`, `<descrição>` em `/fluxo-dev:nova-feature`).
   - `.claude/fluxo-dev.env`: `grep -nE '^[^#].*<[^>]*>' .claude/fluxo-dev.env` tem de voltar vazio — nas linhas de configuração nenhum `<…>` é aceitável, o hook executaria o texto literal.
2. Rode a checagem automática de cada stack mais uma vez a partir da raiz do git, como o hook fará.
3. Confira que o `.claude/settings.json` continua JSON válido.

## Etapa 8 — Encerrar
Escreva o relatório final **em português**: arquivos criados/alterados, o que foi validado (com a tabela da etapa 5), o que ficou pendente ou "conhecido quebrado", processos que ficaram rodando em background e, se a pasta da sessão não é a raiz do git, o lembrete de abrir as próximas sessões na raiz. Explique o próximo passo:
`/fluxo-dev:nova-feature <descrição>` para desenvolver, `/fluxo-dev:subir-ambiente` para rodar e `/fluxo-dev:configurar-projeto` de novo para ajustar. Não faça commit sem o usuário pedir.
