---
name: subir-ambiente
description: Sobe (ou reinicia/para) o ambiente local do projeto usando os comandos registrados no CLAUDE.md — dependências, migrations locais e aplicações. Use quando o usuário pedir para rodar, subir, reiniciar ou parar a aplicação.
argument-hint: "[parar | reiniciar | <stack específica>]"
---

# Subir ambiente local

Pedido: $ARGUMENTS (vazio = subir tudo)

1. Leia as seções `## Ambiente local` e `## Comandos` do `CLAUDE.md`. Se não existirem, ofereça `/fluxo-dev:configurar-projeto` e pare.
2. Verifique pré-requisitos citados ali (ex.: `docker version`, `dotnet --version`, `node --version`). Se o Docker não estiver rodando, peça ao usuário para abrir o Docker Desktop.
3. Confirme que os arquivos de configuração exigidos existem (ex.: `.env`) **sem ler o conteúdo**. Se faltar, aponte o arquivo de exemplo (`.env.example`) e peça ao usuário para criá-lo.
4. Suba na ordem: dependências (banco, cache) → migrations/seed **somente no banco local** → aplicações. Processos longos (`dotnet watch`, `ng serve`, `uvicorn --reload`) rodam em background.
5. Aguarde cada URL responder (`curl -s -o /dev/null -w '%{http_code}' <url>`). Se falhar, mostre as últimas linhas do log do processo/container.
6. Informe as URLs e como parar tudo.

Para `parar`: encerre os processos em background iniciados e rode o comando de parada das dependências (ex.: `docker compose down`, **sem** `-v`, a menos que o usuário peça para apagar os dados).
