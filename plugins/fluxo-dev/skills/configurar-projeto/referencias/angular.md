# Angular — referência para o wizard

## Sinais de detecção
- `angular.json`, `package.json` com `@angular/core` (versão define padrões: ≥17 → standalone + control flow `@if`, signals)
- Gerenciador de pacotes pelo lockfile: `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn)
- Runner de testes em `devDependencies`/`angular.json`: `karma` + `jasmine`, `jest`, `vitest`, `@angular/build:unit-test`
- E2E: `cypress`, `@playwright/test`
- Lint: `@angular-eslint`, `.eslintrc*` / `eslint.config.*`; format: `.prettierrc*`
- Proxy para API: `proxy.conf.json` (indica porta do backend)

## Comandos padrão (prefira os `scripts` do `package.json`)
| Uso | Comando |
|---|---|
| Instalar | `npm ci` |
| Build | `npm run build` (ou `npx ng build`) |
| Testes | `npx ng test --watch=false` (Karma: adicione `--browsers=ChromeHeadless`) ou `npm test -- --watch=false` |
| Teste único | Karma: `npx ng test --watch=false --include=src/app/x/x.component.spec.ts`; Jest/Vitest: `npx jest x.component` |
| Rodar | `npm start` (ou `npx ng serve`), geralmente http://localhost:4200 |
| Lint | `npx ng lint` |
| Format | `npx prettier --check .` |

Troque `npm`/`npx` por `pnpm`/`yarn` conforme o lockfile. Em monorepo, prefixe com `cd <pasta-front> &&`.

## Checagem automática após edição (`CHECAR_ts`, `CHECAR_html`, `CHECAR_scss`)
1. **Recomendado para `.ts`**: `cd <pasta> && npx tsc --noEmit -p tsconfig.app.json` — checa tipos em poucos segundos.
2. Lint do arquivo: `cd <pasta> && npx eslint --max-warnings=0 src` (mais lento em projetos grandes).
3. Nada para `.html`/`.scss` (erros de template aparecem no build/teste; deixe vazio para não deixar lento).

## Arquivos sensíveis comuns
`src/environments/environment.local.ts`, `.env`, `.npmrc` (pode ter token)

## Observações
- Karma precisa de Chrome; em CI/containers use ChromeHeadless.
- `ng serve` é processo longo: rode em background e não use como checagem.
