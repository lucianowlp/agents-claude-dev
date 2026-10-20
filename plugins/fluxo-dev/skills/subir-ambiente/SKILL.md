---
name: subir-ambiente
description: Sobe (ou reinicia/para) o ambiente local do projeto usando os comandos registrados no CLAUDE.md — dependências, migrations locais e aplicações. Use quando o usuário pedir para rodar, subir, reiniciar ou parar a aplicação.
argument-hint: "[parar | reiniciar | <stack específica>]"
---

# Subir ambiente local

Pedido: $ARGUMENTS (vazio = subir tudo)

**Idioma: todo texto para o usuário sai em português** — avisos, status de cada serviço, tabelas, erros explicados e o resumo final —, mesmo que os logs estejam em inglês.

1. Leia as seções `## Ambiente local`, `## Comandos` e `## Instruções existentes` do `CLAUDE.md`. Se não existirem, ofereça `/fluxo-dev:configurar-projeto` e pare. Se o comando "Rodar" for um script ou skill do projeto (ex.: `run-dev.bat`), use-o em vez de subir as partes separadamente; só suba manualmente se o script falhar.
2. Verifique pré-requisitos citados ali (ex.: `dotnet --version`, `node --version`). Para Docker, distinga:
   - `docker --version` falha → Docker **não instalado**: diga que é preciso instalar o Docker Desktop (ou rodar nativo, se o `CLAUDE.md` permitir) e pare;
   - `docker --version` funciona, mas `docker info` falha → Docker **instalado, mas parado**: peça ao usuário para abrir o Docker Desktop (ou rodar `Start-Process "Docker Desktop"` no PowerShell), espere o `docker info` responder e continue.
3. Confirme que os arquivos de configuração exigidos existem (ex.: `.env`) **sem ler o conteúdo**. Se faltar, aponte o arquivo de exemplo (`.env.example`) e peça ao usuário para criá-lo.
4. Suba na ordem: dependências (banco, cache) → migrations/seed **somente no banco local** → aplicações. Processos longos (`dotnet watch`, `ng serve`, `uvicorn --reload`, scripts de subida) rodam em background.
5. Aguarde cada URL ou rota de health responder, com limite de tempo (ex.: até 2 min, testando `curl -s -o /dev/null -w '%{http_code}' <url>` a cada 2 s). Se não responder, mostre as últimas linhas do log do processo/container.
6. Informe, em uma tabela curta, cada serviço com URL e status, quais processos ficaram rodando em background e como parar tudo.

Para `parar`: encerre os processos em background iniciados e rode o comando de parada das dependências (ex.: `docker compose down`, **sem** `-v`, a menos que o usuário peça para apagar os dados).
