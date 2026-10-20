# .NET — referência para o wizard

## Sinais de detecção
- `*.sln`, `*.slnx`, `*.csproj`, `global.json`, `Directory.Build.props`, `Directory.Packages.props`
- Projetos de teste: `*.Tests.csproj` / `*Test*.csproj` com `xunit`, `NUnit`, `MSTest`, `Microsoft.NET.Test.Sdk`
- Web/API: `Program.cs` com `WebApplication`, `Sdk="Microsoft.NET.Sdk.Web"`, `appsettings*.json`, `Properties/launchSettings.json` (portas)
- EF Core: pacote `Microsoft.EntityFrameworkCore*`, pasta `Migrations/`
- Versão do SDK: `global.json` ou `<TargetFramework>` nos `.csproj`

## Ponto de entrada do build
Os comandos abaixo usam `<entrada>`. Escolha nesta ordem:
1. **O que o CI usa** (`dotnet build …` no workflow) — é o que o time garante que funciona.
2. **`.slnx`** na raiz ou na pasta do backend. Exige SDK 9.0.200 ou mais novo; com SDK mais antigo, `dotnet build` não reconhece o arquivo — avise e caia para o item 3.
3. **`.sln`** na raiz ou na pasta do backend.
4. **Sem solution, só `.csproj`**: use o projeto de entrada — o que tem `Sdk="Microsoft.NET.Sdk.Web"` / `Program.cs` e referencia os outros (ex.: `src/Api/Api.csproj`). Buildar ele compila as dependências por `ProjectReference`. Projetos soltos, que ninguém referencia, ficam de fora: liste-os no resumo.
   - Testes sem solution: `dotnet test` precisa de um projeto de teste ou de uma solution. Use `dotnet test <Projeto>.Tests.csproj`, um comando por projeto de teste (junte com `&&`). Se não houver projeto de teste, registre "sem testes .NET" em vez de inventar comando.
   - Não crie uma `.sln` sem o usuário pedir.

Cuidado: `dotnet build` sem argumento numa pasta com mais de um `.sln`/`.slnx`/`.csproj` falha com `MSB1011`. Sempre passe `<entrada>` explicitamente.

## Comandos padrão (troque `<entrada>` pelo ponto de entrada escolhido)
| Uso | Comando |
|---|---|
| Restore | `dotnet restore <entrada>` |
| Build | `dotnet build <entrada> --nologo` |
| Testes | `dotnet test <entrada> --nologo` (sem solution: um `dotnet test` por projeto de teste) |
| Teste único | `dotnet test <ProjetoDeTestes>.csproj --filter "FullyQualifiedName~Classe.Metodo"` |
| Rodar API | `dotnet run --project src/<Api>/<Api>.csproj` (ou `dotnet watch --project …`) |
| Format | `dotnet format <entrada> --verify-no-changes` |
| Migration | `dotnet ef migrations add <Nome> --project <Infra> --startup-project <Api>` |
| Aplicar migrations (local) | `dotnet ef database update --project <Infra> --startup-project <Api>` |

## Checagem automática após edição (`CHECAR_cs`)
1. **Recomendado**: `dotnet build <entrada> --nologo -v q -clp:ErrorsOnly` — pega erro de compilação em segundos (após o primeiro build).
2. Testes rápidos: `dotnet test <ProjetoDeTestesUnitarios>.csproj --nologo -v q` — só se a suíte unitária for rápida.
3. Nada.
Também se aplica a `.razor` (`CHECAR_razor`) e `.cshtml` se o projeto usar.

## Arquivos sensíveis comuns
`appsettings.Development.json`, `appsettings.Local.json`, `secrets.json` (user-secrets), `*.pfx`, `.env`, `dataprotection-keys/`

## Observações
- Testes de integração com banco (Testcontainers/SQL Server) costumam exigir Docker rodando — veja na etapa 1 se o daemon responde, não só se o Docker está instalado.
- Em Docker: `docker compose run --rm <servico> dotnet test`.
- `dotnet format --verify-no-changes` em código legado costuma acusar muitos arquivos: registre como "conhecido quebrado" e não use como checagem automática.
- Avisos de vulnerabilidade em pacotes NuGet (`NU1902`/`NU1903`) não quebram o build: registre em "Avisos conhecidos".
