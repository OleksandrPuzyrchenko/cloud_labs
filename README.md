# Cloud Deployment Lab 1

REST API на Node.js (Express + PostgreSQL), контейнеризоване за допомогою Docker та розгорнуте в AWS через Terraform. 
CI/CD реалізовано за допомогою GitHub Actions з безпарольною OIDC автентифікацією.

## Реалізовані бонусні завдання:
1. **OpenAPI / Swagger UI**: інтерактивна документація на `/api-docs`.
2. **Моніторинг та алерти**: CloudWatch Dashboard з KPI-картками, графіками латентності p50/p90/p99, метриками RDS PostgreSQL та SNS-алертами на email при 5xx помилках та високому CPU.

## Структура проєкту
- `app/` - вихідний код API, Dockerfile та package.json
  - `compose.yaml` - локальна оркестрація (API + PostgreSQL з healthcheck)
  - `terraform/` - інфраструктура як код (VPC, ALB, ECR, ECS Fargate, RDS PostgreSQL, Budgets, Monitoring, OIDC)
- `.github/workflows/` - пайплайн автоматичного розгортання в AWS через GitHub Actions

---

## Публічні адреси та демонстрація
- **API Health**: `http://<ALB_DNS>/health`
- **Документація (Swagger UI)**: `http://<ALB_DNS>/api-docs`
- **Симуляція 500 помилки (тест алерту)**: `http://<ALB_DNS>/api/simulate-error`
- **CloudWatch Dashboard**: `cloudlab-operational-dashboard`

### Як перевірити:
1. **Health Check**:
   ```bash
   curl -i http://<ALB_DNS>/health
   ```
2. **Створення нотатки (CRUD)**:
   ```bash
   curl -X POST http://<ALB_DNS>/api/notes \
     -H "Content-Type: application/json" \
     -d '{"title": "Перша хмарна нотатка"}'
   ```
3. **Отримання списку нотаток**:
   ```bash
   curl http://<ALB_DNS>/api/notes
   ```
4. **Тест алерту 5xx помилки**:
   ```bash
   curl http://<ALB_DNS>/api/simulate-error
   ```
   *(Через 1-2 хвилини на дашборді зафіксується помилка, а на email прийде сповіщення від AWS SNS).*

---

## Локальний запуск
```bash
cd app
docker compose up -d
```

## Розгортання інфраструктури (Terraform)
```bash
cd app/terraform
terraform init
terraform apply
```
Після завершення `terraform apply` у терміналі буде виведено готові блоки з адресами: `application_endpoints`, `observability`, `database`, `ci_cd_deployment`.