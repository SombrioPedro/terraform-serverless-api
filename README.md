# Products API — Serverless com Terraform na AWS

## 1. Objetivo

API REST para gerenciamento de produtos (criar, listar, consultar e excluir), construída com arquitetura **serverless** na AWS. Toda a infraestrutura é provisionada com **Terraform** (Infrastructure as Code); nenhum recurso é criado manualmente pelo console.

## 2. Arquitetura

```text
Client
  ↓  HTTP
API Gateway (HTTP API)
  ↓  invoke (autorizado pelo aws_lambda_permission)
Lambda (Python 3.12)
  ↓  read/write (autorizado pela IAM Role)
DynamoDB
  
Lambda → CloudWatch Logs
```

| Recurso | Função |
|---|---|
| API Gateway | Recebe as requisições HTTP e encaminha para a Lambda |
| Lambda | Executa a lógica da API (uma função, quatro rotas) |
| DynamoDB | Armazena os produtos (partition key `id`, String) |
| IAM Role + Policy | Permissões mínimas da Lambda (logs + 4 ações no DynamoDB) |
| Lambda Permission | Autoriza somente esta API Gateway a invocar a Lambda |
| CloudWatch Log Group | Logs da Lambda, com retenção de 7 dias |

Todos os recursos recebem o prefixo `<owner>-<project_name>-<environment>` e tags (`Owner`, `Project`, `Environment`, `ManagedBy`).

### Endpoints

| Método | Endpoint | Descrição | Sucesso | Erros |
|---|---|---|---|---|
| POST | `/products` | Cria produto | 201 | 400 |
| GET | `/products` | Lista produtos | 200 | — |
| GET | `/products/{id}` | Consulta produto | 200 | 404 |
| DELETE | `/products/{id}` | Exclui produto | 200 | 404 |

## 3. Pré-requisitos

- AWS CLI v2
- Terraform >= 1.5
- Git
- Python 3.12 (apenas para testes locais; o empacotamento é feito pelo Terraform)

## 4. Configuração AWS

```bash
aws configure
# AWS Access Key ID, AWS Secret Access Key, região (us-east-1), formato (json)

aws sts get-caller-identity   # confirma que as credenciais funcionam
```

As credenciais ficam em `~/.aws/credentials` e **nunca** devem ser colocadas no código ou no Git.

## 5. Deploy

```bash
cp terraform.tfvars.example terraform.tfvars   # edite o campo owner
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Outputs gerados: `api_url`, `lambda_arn`, `lambda_function_name`, `dynamodb_table_name`.

## 6. Testes

```bash
export API_URL=$(terraform output -raw api_url)

# Criar produtos
curl -i -X POST "$API_URL/products" -H "Content-Type: application/json" \
  -d '{"name": "Notebook", "price": 4500}'
curl -i -X POST "$API_URL/products" -H "Content-Type: application/json" \
  -d '{"name": "Mouse", "price": 100}'

# Listar
curl -i "$API_URL/products"

# Consultar (substitua ID pelo id retornado no POST)
curl -i "$API_URL/products/ID"

# Excluir
curl -i -X DELETE "$API_URL/products/ID"

# Confirmar exclusão (deve retornar 404)
curl -i "$API_URL/products/ID"
```

Logs da Lambda:

```bash
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_name) --since 10m
```

## 7. Destroy

```bash
terraform destroy
```

Remove todos os recursos criados pelo Terraform, inclusive os dados da tabela e os logs.

## Estrutura do projeto

```text
terraform-serverless-api/
├── main.tf                    # DynamoDB, CloudWatch, IAM, Lambda, API Gateway
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── data.tf                    # policies IAM e empacotamento da Lambda
├── terraform.tfvars.example
├── lambda/
│   └── lambda_function.py
├── .gitignore
└── README.md
```