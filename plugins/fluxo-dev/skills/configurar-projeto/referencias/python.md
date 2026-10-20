# Python — referência para o wizard

## Sinais de detecção
- `pyproject.toml`, `requirements*.txt`, `setup.py`/`setup.cfg`, `Pipfile`
- Gerenciador: `uv.lock` (uv), `poetry.lock` (poetry), `Pipfile.lock` (pipenv), senão pip + venv
- Framework: `manage.py` (Django), `fastapi`/`uvicorn`, `flask` nas dependências
- Testes: `pytest.ini`, `[tool.pytest.ini_options]`, `conftest.py`, pasta `tests/`; ou `unittest`
- Qualidade: `ruff`, `black`, `flake8`, `mypy`, `pyright` nas dependências/config
- Venv local: `.venv/`

## Comandos padrão (prefixe com `uv run` / `poetry run` conforme o gerenciador)
| Uso | Comando |
|---|---|
| Instalar | `uv sync` / `poetry install` / `pip install -r requirements.txt` |
| Testes | `pytest -q` |
| Teste único | `pytest -q tests/test_x.py::test_y` ou `pytest -k nome` |
| Rodar (FastAPI) | `uvicorn app.main:app --reload` |
| Rodar (Django) | `python manage.py runserver` |
| Lint | `ruff check .` |
| Format | `ruff format --check .` (ou `black --check .`) |
| Tipos | `mypy .` / `pyright` |
| Migrations (Django) | `python manage.py makemigrations` / `migrate` (local) |

No Windows, o Python pode estar como `py` em vez de `python`. Se não houver Python no host, use `docker compose run --rm <servico> pytest -q`.

## Checagem automática após edição (`CHECAR_py`)
1. **Recomendado**: `ruff check <arquivos/pasta>` (instantâneo) — se o projeto usa ruff.
2. Testes rápidos: `pytest -q -x` — se a suíte roda em poucos segundos.
3. Nada.

## Arquivos sensíveis comuns
`.env`, `.env.*` (exceto `.env.example`), `secrets.*`, `credentials*.json`, `*.pem`

## Observações
- `ruff check .` / `black --check .` acusando muitos arquivos legados: registre como "conhecido quebrado" e não use como checagem automática (ou limite a checagem às pastas novas).
- `uvicorn --reload` e `runserver` são processos longos: na validação, rode em background, espere a URL responder e encerre (veja a etapa 5 do wizard).
