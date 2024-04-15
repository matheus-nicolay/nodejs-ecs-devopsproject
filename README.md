# nodejs-ecs-devopsproject

Projeto desenvolvido para efetuar deploy automatizado de uma aplicação NodeJS para a AWS utilizando Github Actions e Infraestrutura como código com Terraform.

Aplicação NodeJS consiste em uma busca básica na API da Wikipédia (baseada em: https://github.com/rat9615/simple-nodejs-app).

## Tecnologias utilizadas

    - NodeJS
    - Docker
    - Terraform
    - Github Actions
    - Trivy
    - AWS:
        - VPC (Virtual Private Cloud)
        - ECR (Elastic Container Registry)
        - ECS (Elastic Container Service)
        - ALB (Application Load Balancer)
        - ADOT (AWS Distro OpenTelemetry)
        - X-Ray
        - Amazon Managed Service for Prometheus
        - Amazon Managed Service for Grafana

## Infraestrutura

Para implantação, foi utilizado serviços e melhores práticas na AWS para garantir segurança, confiabilidade, alta disponibilidade e menor sobrecarga operacional. 

![Diagrama de Infraestrutura](./aws-diagram.jpeg)

### Processo de CI/CD
Ao acontecer commits/PRs na branch main, os worflows aplicam todos os códigos Terraform (para o caso de alteração na infraestrutura) e efetuam o build/deploy da aplicação no ECS.

- Dockerfile na raiz do projeto para construção do container com base na aplicação contida no diretório `src`
- Deploy:
    - Build e Push da imagem para repositório ECR;
    - Análise de vulnerabilidades da imagem com Trivy;
    - Deploy da imagem no ECS.

- Terraform Check:
    - Validação de sintaxe dos manifestos Terraform.

- Terraform Plan:
    - Efetua o Plan e coloca um comentário na Pull Request com o arquivo.

- Terraform Apply:
    - Validação de sintaxe dos manifestos Terraform




