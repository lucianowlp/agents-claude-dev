<!-- fluxo-dev:inicio -->
<!-- Bloco gerado por /fluxo-dev:configurar-projeto. Edite à vontade ou rode o wizard de novo. -->
# <nome do projeto>

<uma ou duas frases: o que o sistema faz e para quem>

## Stack e estrutura
| Stack | Pasta | Versão | Observações |
|---|---|---|---|
| <stack> | `<pasta>/` | <versão do framework/SDK> | <ponto de entrada do build, banco, runner de testes...> |

## Instruções existentes
<!-- Aponte para os arquivos do projeto em vez de copiar o conteúdo. Apague a seção se não houver nenhum. -->
- `<arquivo>` — <o que ele cobre>

## Ambiente local
- Como roda: <Docker Compose | nativo | misto — detalhes>
- Dependências: <comando para subir e parar banco/cache, ou "nenhuma">
- URLs: <URL de cada aplicação e rota de health>

## Comandos
<!-- Os subagentes usam SOMENTE estes comandos. Mantenha-os testados. Uma linha por stack. -->
| Stack | Build | Testes | Teste único | Rodar | Lint/Format |
|---|---|---|---|---|---|
| <stack> | `<build>` | `<testes>` | `<teste único>` | `<rodar>` | `<lint ou "nenhum">` |

Migrations/seed: <comandos, apenas banco local>

## Convenções
- Idioma do código e commits: <pt | en>
- Commits: <padrão visto no git log>; branches: <padrão de nomes>
- <padrões do time relevantes que não estão óbvios no código>

## Regras
- Nunca ler/exibir: <lista de arquivos sensíveis>
- Proibido: <ações proibidas escolhidas>
- Conhecido quebrado: <comando — o que falha e desde quando; não usar como checagem automática>
- Avisos conhecidos: <vulnerabilidades, warnings ou budgets que não quebram e não devem ser corrigidos sem pedido>

## Fluxo de desenvolvimento
Mudanças não triviais: `/fluxo-dev:nova-feature <descrição>` → `planejador` → aprovação <sempre | só mudanças grandes> → `implementador` → `testador` → `revisor`.
Após cada edição, o hook roda a checagem de `.claude/fluxo-dev.env`; se falhar, corrija antes de seguir.
Abra as sessões do Claude Code na raiz do git deste projeto.
<!-- fluxo-dev:fim -->
