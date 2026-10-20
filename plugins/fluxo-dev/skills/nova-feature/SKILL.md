---
name: nova-feature
description: Fluxo completo para desenvolver uma feature ou corrigir um bug — planejar, aprovar, implementar, testar e revisar com os subagentes do fluxo-dev. Use quando o usuário pedir uma nova funcionalidade, mudança de comportamento ou correção não trivial.
argument-hint: <descrição da feature ou do bug>
---

# Fluxo de nova feature / correção

Pedido do usuário: $ARGUMENTS

**Idioma: todo texto para o usuário sai em português** — o plano resumido, perguntas de aprovação, relatos de falha, tabelas e o resumo final —, mesmo que os subagentes, logs ou ferramentas respondam em inglês. Nomes de comandos, arquivos e a mensagem de commit seguem o padrão do projeto (`CLAUDE.md`).

## Pré-requisito
Se o `CLAUDE.md` não tem a seção `## Comandos` (ou o bloco `<!-- fluxo-dev:inicio -->`), avise que o projeto ainda não foi configurado e ofereça rodar `/fluxo-dev:configurar-projeto` antes. Só continue sem configuração se o usuário insistir.

## Etapas — em ordem, sem pular
1. **Planejar** — chame o subagente `planejador` com o pedido completo (e, para bug, os sintomas/erro). Mostre o plano ao usuário de forma resumida.
2. **Aprovar** — siga a regra de aprovação do `CLAUDE.md` (padrão: sempre pedir). **Não continue sem aprovação.** Se houver ajustes, volte à etapa 1 com o feedback.
3. **Implementar** — chame o subagente `implementador` com o plano aprovado na íntegra.
4. **Testar** — chame o subagente `testador` com a lista de arquivos alterados e as stacks afetadas. Se algo falhar, volte ao `implementador` com a falha exata (no máximo 2 voltas; depois, pare e reporte ao usuário).
5. **Revisar** — chame o subagente `revisor`. Se houver apontamento `crítico` ou `importante`, volte ao `implementador` com eles e repita testar/revisar uma vez.
6. **Resumo** — informe: o que mudou (arquivos), resultado de build/testes por stack, apontamentos do revisor não resolvidos e o que **não** foi verificado. Sugira a mensagem de commit seguindo a convenção do `CLAUDE.md`, mas **não faça commit nem push** sem o usuário pedir.
