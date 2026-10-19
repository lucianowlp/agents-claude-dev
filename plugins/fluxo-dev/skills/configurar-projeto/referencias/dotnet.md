# .NET — referência para o wizard

## Sinais de detecção
- `*.sln`, `*.slnx`, `*.csproj`, `global.json`, `Directory.Build.props`, `Directory.Packages.props`
- Projetos de teste: `*.Tests.csproj` / `*Test*.csproj` com `xunit`, `NUnit`, `MSTest`, `Microsoft.NET.Test.Sdk`
- Web/API: `Program.cs` com `WebApplication`, `appsettings*.json`, `Properties/launchSettings.json` (portas)
- EF Core: pacote `Microsoft.EntityFrameworkCore*`, pasta `Migrations/`
- Versão do SDK: `global.json` ou `<TargetFramework>` nos `.csproj`

## Comandos padrão (ajuste ao caminho da solution)
| Uso | Comando |
|---|---|
| Restore | `dotnet restore <Solution>.sln` |
| Build | `dotnet build <Solution>.sln --nologo` |
| Testes | `dotnet test <Solution>.sln --nologo` |
| Teste único | `dotnet test --filter "FullyQualifiedName~Classe.Metodo"` |
| Rodar API | `dotnet run --project src/<Api>/<Api>.csproj` (ou `dotnet watch --project …`) |
| Format | `dotnet format <Solution>.sln --verify-no-changes` |
| Migration | `dotnet ef migrations add <Nome> --project <Infra> --startup-project <Api>` |
| Aplicar migrations (local) | `dotnet ef database update --project <Infra> --startup-project <Api>` |

## Checagem automática após edição (`CHECAR_cs`)
1. **Recomendado**: `dotnet build <Solution>.sln --nologo -v q -clp:ErrorsOnly` — pega erro de compilação em segundos (após o primeiro build).
2. Testes rápidos: `dotnet test <ProjetoDeTestesUnitarios>.csproj --nologo -v q` — só se a suíte unitária for rápida.
3. Nada.
Também se aplica a `.razor` (`CHECAR_razor`) e `.cshtml` se o projeto usar.

## Arquivos sensíveis comuns
`appsettings.Development.json`, `appsettings.Local.json`, `secrets.json` (user-secrets), `*.pfx`, `.env`

## Observações
- Testes de integração com banco (Testcontainers/SQL Server) costumam exigir Docker rodando.
- Em Docker: `docker compose run --rm <servico> dotnet test`.
