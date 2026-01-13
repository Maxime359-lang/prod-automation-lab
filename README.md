# Prod Automation Lab (GitHub Actions → GHCR → AWS SSM Deploy)

Minimal HTTP service with `/health`, built and deployed in a production-like way:
- **CI**: tests on every push
- **Build**: build + push image to **GHCR**
- **Deploy**: GitHub Actions assumes AWS role via **OIDC** and deploys to EC2 via **SSM Run Command**
- **Runtime**: app is bound to localhost and served via Nginx reverse proxy

## Live demo (current EC2)
- https://cicd-github.18.198.208.36.nip.io/health

## Local run (dev)
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
python app/main.py
curl -s http://localhost:8000/health
```

## Docker Compose (dev)
```bash
docker compose up --build
curl -s http://localhost:8000/health
```

## Production-like Compose (EC2 behind Nginx)
This binds the container to localhost only:
```bash
export IMAGE_TAG=<sha-or-latest>
docker compose -f docker-compose.prod.yml up -d
curl -s http://127.0.0.1:8081/health
```

## CI/CD (GitHub Actions)
Workflows:
- `ci.yml` – tests
- `build-push.yml` – build and push `ghcr.io/maxime359-lang/prod-automation-lab:<sha>`
- `deploy-ec2.yml` – deploy via SSM + OIDC (no SSH keys in CI)

Required secrets:
- `AWS_DEPLOY_ROLE_ARN`
- `AWS_EC2_INSTANCE_ID`
