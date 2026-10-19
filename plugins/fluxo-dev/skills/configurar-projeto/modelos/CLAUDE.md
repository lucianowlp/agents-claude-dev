<!-- fluxo-dev:inicio -->
<!-- Bloco gerado por /fluxo-dev:configurar-projeto. Edite à vontade ou rode o wizard de novo. -->
# <Nome do projeto>

<Uma ou duas frases: o que o sistema faz e para quem.>

## Stack e estrutura
| Stack | Pasta | Versão | Observações |
|---|---|---|---|
| .NET | `backend/` | net9.0 | API + EF Core (SQL Server) |
| Angular | `frontend/` | 19 | standalone, signals, Karma |

## Ambiente local
- Como roda: <Docker Compose | nativo | misto — detalhes>
- Dependências: <ex.: `docker compose up -d db redis`>
- URLs: <API http://localhost:5000 · Front http://localhost:4200>

## Comandos
<!-- Os subagentes usam SOMENTE estes comandos. Mantenha-os testados. -->
| Stack | Build | Testes | Teste único | Rodar | Lint/Format |
|---|---|---|---|---|---|
| .NET | `…` | `…` | `…` | `…` | `…` |
| Angular | `…` | `…` | `…` | `…` | `…` |

Migrations/seed: <comandos, apenas banco local>

## Convenções
- Idioma do código e commits: <pt|en>
- Commits: <Conventional Commits | livre>; branches: <feature/…>
- <padrões do time relevantes que não estão óbvios no código>

## Regras
- Nunca ler/exibir: <lista de arquivos sensíveis>
- Proibido: <ex.: aplicar migrations fora do banco local, git push, instalar dependências sem perguntar>
- Conhecido quebrado: <comandos que falharam na validação, se houver>

## Fluxo de desenvolvimento
Mudanças não triviais: `/fluxo-dev:nova-feature <descrição>` → `planejador` → aprovação <sempre|só mudanças grandes> → `implementador` → `testador` → `revisor`.
Após cada edição, o hook roda a checagem de `.claude/fluxo-dev.env`; se falhar, corrija antes de seguir.
<!-- fluxo-dev:fim -->
