# Prod Automation Lab — GitHub Actions -> GHCR -> AWS EC2 (SSM + OIDC)

Minimal HTTP service with /health, deployed in a production-like way:

- CI: tests on every push/PR
- Build: Docker build + push to GHCR
- Deploy: GitHub Actions assumes AWS role via OIDC and deploys via SSM Run Command
- Runtime: container binds to localhost only and is exposed publicly via Nginx gateway (separate repo)

Live demo (current EC2 via Nginx gateway):
- https://cicd-github.18.198.208.36.nip.io/health

Note: this app guarantees /health. Root / may return 404 (expected).

## Recruiter highlights
- No SSH keys in CI: AWS OIDC -> AssumeRole -> SSM Run Command
- Deterministic deploy: image tag == commit SHA
- HEALTHCHECK enabled; container restarts and health visible
- Smoke tests with retries after deploy
- Designed to run behind a reverse proxy (ports not exposed publicly)

## Endpoints
- GET /health -> {"status":"ok"}

## Local run (venv)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
python app/main.py
curl -s http://127.0.0.1:8000/health

## Docker
docker compose up --build
curl -s http://127.0.0.1:8000/health

## EC2 runtime (behind Nginx)
The service is bound to localhost only (security):
- 127.0.0.1:8081 -> container:8000

Verify on EC2:
curl -sS http://127.0.0.1:8081/health

## CI/CD overview (GitHub Actions)
- ci.yml: run tests
- build-push.yml: build and push image to GHCR (latest + sha tag)
- deploy-ec2.yml: assume role (OIDC), run SSM command, restart container, smoke test

## Related repo (gateway)
Public HTTPS entrypoint + Let's Encrypt:
- cicd-infra-lab
