# Prod Automation Lab (GitHub Actions → GHCR → AWS SSM Deploy)

Minimal Python (Flask) HTTP service, built and deployed in a production-like way:
- **CI**: tests on every push
- **Build**: Docker build + push image to **GHCR**
- **Deploy**: GitHub Actions assumes AWS role via **OIDC** and deploys to EC2 via **SSM Run Command**
- **Runtime**: service bound to localhost and served via Nginx reverse proxy

## Live demo
Replace `<EC2_IP>` with your EC2 public IPv4:
- https://cicd-github.<EC2_IP>.nip.io/health

Example:
- https://cicd-github.18.198.208.36.nip.io/health

## Endpoints
- `GET /health` → `{"status":"ok"}`
- `GET /` (optional) → basic info (if implemented)

## Local run (venv)
~~~bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
python app/main.py
curl -s http://localhost:8000/health
~~~

## Docker Compose (dev)
~~~bash
docker compose up --build
curl -s http://localhost:8000/health
~~~

## Production-like Compose (EC2 behind Nginx)
This binds the container to localhost only:
~~~bash
export IMAGE_TAG=<sha-or-latest>
docker compose -f docker-compose.prod.yml up -d
curl -s http://127.0.0.1:8081/health
~~~

## CI/CD (GitHub Actions)
Workflows:
- `ci.yml` – tests
- `build-push.yml` – build and push image to GHCR
- `deploy-ec2.yml` – deploy via SSM + OIDC (no SSH keys in CI)

Required secrets:
- `AWS_DEPLOY_ROLE_ARN`
- `AWS_EC2_INSTANCE_ID`

EC2 requirements:
- Amazon Linux 2023
- SSM agent working
- Security Group: allow **80/443** (nginx), do not expose **8081** publicly
- EC2 instance tagged for SSM target:
  - `SSMDeploy=prod-automation`

## Verify on EC2
~~~bash
docker ps
curl -sS http://127.0.0.1:8081/health
sudo tail -n 50 /var/log/nginx/error.log
~~~

## Notes
- No secrets are stored in the repository.
- AWS auth uses GitHub OIDC (recommended baseline).
