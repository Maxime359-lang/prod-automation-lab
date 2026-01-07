# Prod Automation Lab
Production-like automation lab (CI/CD, IaC, monitoring, testing)

## What it is
Minimal HTTP service with `/health` endpoint and tests. This repo will evolve into a full CI/CD + Docker + AWS EC2 deployment lab.

## Why `/health`
Health endpoints are used by monitoring and deployment platforms to detect if the service is alive and responding correctly. A failing health check should block deployment.

## Run locally
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
python app/main.py
curl -s http://localhost:8000/health
