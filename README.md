# Cloud Deployment Lab 1

REST API на Node.js (Express + PostgreSQL), контейнеризоване за допомогою Docker та розгорнуте в AWS через Terraform. 
CI/CD реалізовано за допомогою GitHub Actions з безпарольною OIDC автентифікацією.

## Структура проєкту
- `app/` - вихідний код API, Dockerfile та package.json
- `terraform/` - інфраструктура як код (VPC, ALB, ECR, ECS, RDS, IAM)
- `.github/workflows/` - пайплайн для автоматичного розгортання в AWS
- `compose.yaml` - локальна оркестрація (API + PostgreSQL)

## Публічна адреса (ALB)
- API: `http://cloud-lab-alb-1430452967.eu-central-1.elb.amazonaws.com`
- Документація: `http://cloud-lab-alb-1430452967.eu-central-1.elb.amazonaws.com/api-docs`

## Локальний запуск
```bash
docker compose up -d