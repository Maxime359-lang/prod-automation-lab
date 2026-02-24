# SSM Deploy Runbook (AWS EC2)

## Purpose
Verification and troubleshooting steps for deploy flow:
GitHub Actions -> OIDC -> AssumeRole -> SSM Run Command -> EC2

---

## 1) Verify container is running on EC2
Use:
- `docker ps`
- `docker compose -f docker-compose.yml -f docker-compose.prod.yml ps`

---

## 2) Verify local health endpoint
Use:
- `curl -sS http://127.0.0.1:8081/health`

Expected:
- `{"status":"ok"}`

---

## 3) Check container logs
Use:
- `docker logs --tail=100 <container_name>`

If container name unknown:
- `docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'`

---

## 4) Check image tag (commit SHA)
Use:
- `docker images | head`
- `docker inspect <container_name> --format='{{.Config.Image}}'`

Expected:
- image tag includes commit SHA from CI build

---

## 5) Common failure scenarios

### A) SSM command executed, app not healthy
Checks:
- `docker logs`
- `docker ps`
- `curl 127.0.0.1:8081/health`

### B) Image pull failed
Checks:
- GHCR image exists
- EC2 host can pull image
- target SHA tag exists

### C) Port mismatch
Use:
- `ss -tulpn | grep 8081`
- `docker compose -f docker-compose.yml -f docker-compose.prod.yml config`

---

## 6) Post-deploy smoke via gateway (optional)
Use:
- `PUB_IP="<EC2_IP>"`
- `curl -sS "https://cicd-github.${PUB_IP}.nip.io/health"; echo`

