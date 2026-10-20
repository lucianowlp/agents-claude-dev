# Angular — referência para o wizard

## Sinais de detecção
- `angular.json`, `package.json` com `@angular/core` (versão define padrões: ≥17 → standalone + control flow `@if`, signals)
- Gerenciador de pacotes pelo lockfile: `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn)
- Runner de testes: o `builder` de `projects.<app>.architect.test` em `angular.json` e as `devDependencies`:
  - `@angular/build:unit-test` → Vitest (padrão nos projetos novos), **sempre rodado via `ng test`**;
  - `@angular-devkit/build-angular:karma` / `@angular/build:karma` → Karma + Jasmine;
  - `jest` com `jest.config.*` e sem builder de teste do Angular → Jest direto;
  - `vitest` com `vitest.config.*` próprio (ex.: Analog) e sem `@angular/build:unit-test` → Vitest direto.
- E2E: `cypress`, `@playwright/test`
- Lint: `@angular-eslint`, `.eslintrc*` / `eslint.config.*`; format: `.prettierrc*`
- Proxy para API: `proxy.conf.json` (indica porta do backend)

## Comandos padrão (prefira os `scripts` do `package.json`)
| Uso | Comando |
|---|---|
| Instalar | `npm ci` |
| Build | `npm run build` (ou `npx ng build`) |
| Testes | `npx ng test --watch=false` ou `npm test -- --watch=false` (Karma: adicione `--browsers=ChromeHeadless`) |
| Teste único | `npx ng test --watch=false --include=src/app/x/x.component.spec.ts` (Karma e `@angular/build:unit-test`); Jest direto: `npx jest x.component`; Vitest direto (config própria): `npx vitest run x.component` |
| Rodar | `npm start` (ou `npx ng serve`), geralmente http://localhost:4200 |
| Lint | `npx ng lint` |
| Format | `npx prettier --check .` |

Troque `npm`/`npx` por `pnpm`/`yarn` conforme o lockfile. Em monorepo, prefixe com `cd <pasta-front> &&`.

**Vitest via `@angular/build:unit-test`**: o builder do Angular compila os testes e só então chama o Vitest. Chamar `npx vitest` direto falha (não há `vitest.config` nem compilação Angular). Use sempre `ng test` / `npm test`, inclusive para teste único (`--include`).

**`npm test` com flags**: passe as flags depois de `--` (`npm test -- --watch=false`). Sem o `--`, o npm consome a flag e ela não chega ao `ng test`.

## Checagem automática após edição (`CHECAR_ts`, `CHECAR_html`, `CHECAR_scss`)
1. **Recomendado para `.ts`**: `cd <pasta> && npx tsc --noEmit -p tsconfig.app.json` — checa tipos em poucos segundos.
2. Lint do arquivo: `cd <pasta> && npx eslint --max-warnings=0 src` (mais lento em projetos grandes).
3. Nada para `.html`/`.scss` (erros de template aparecem no build/teste; deixe vazio para não deixar lento).

## Arquivos sensíveis comuns
`src/environments/environment.local.ts`, `.env`, `.npmrc` (pode ter token)

## Observações
- Karma precisa de Chrome; em CI/containers use ChromeHeadless.
- `ng serve` é processo longo: na validação, rode em background, espere http://localhost:4200 responder e encerre (veja a etapa 5 do wizard). Não use como checagem.
- `prettier --check` / `ng lint` acusando muitos arquivos legados: registre como "conhecido quebrado" e não use como checagem automática.
- Budget de bundle estourado (`exceeded maximum budget`) como aviso: registre em "Avisos conhecidos".
