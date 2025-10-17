# 🌎 Terragrunt Multi-Ambiente (Dev/Prod) com GitHub Actions e Backend Remoto AWS

Este projeto demonstra uma **infraestrutura multi-ambiente (Dev e Prod)** provisionada via **Terraform + Terragrunt**, com **backend remoto em S3 e DynamoDB** e **pipeline GitHub Actions** totalmente automatizado, incluindo suporte a **assunção de roles via OIDC** e **seleção de ambiente por região** (`us-east-1` → Dev, `us-east-2` → Prod).

---

## 🧱 Estrutura de Diretórios

```bash
.
├── modules/                  # Módulos reutilizáveis (ex: VPC, IAM, S3, etc)
│   └── vpc/
│       ├── main.tf
│       └── variables.tf
│
├── live/
│   ├── dev/
│   │   ├── terragrunt.hcl    # Ambiente DEV (us-east-1)
│   │   └── network/
│   │       └── vpc/
│   │           └── terragrunt.hcl
│   │
│   └── prod/
│       ├── terragrunt.hcl    # Ambiente PROD (us-east-2)
│       └── network/
│           └── vpc/
│               └── terragrunt.hcl
│
├── root.hcl                  # Configuração global do Terragrunt
├── .github/
│   └── workflows/
│       └── terragrunt.yaml   # Pipeline CI/CD com input de região
└── README.md
