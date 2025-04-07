# Infraestrutura de Banco de Dados da IpêCode, com Terraform e Ansible

Automatização da criação e configuração de uma EC2 na AWS rodando MySQL, utilizando Terraform e Ansible. Cria VPC, sub-rede, grupo de segurança, instância EC2 e configura o MySQL na instância utilizando um playbook Ansible.

## Estrutura do Projeto

- `ambiente.tf`: Arquivo de configuração do Terraform que define os recursos da AWS, incluindo VPC, sub-rede, grupo de segurança, instância EC2 e outros.
- `lambda-backend.tf`: Arquivo de configuração do Terraform que define as funções Lambda do projeto.
- `install_mysql.ansible.yml`: Playbook Ansible que instala e configura o MySQL na instância EC2.
- `requirements/ansible-requirements.yml`: Arquivo que lista as coleções Ansible necessárias para o playbook.
- `ABNMO-create-tables.sql`: Arquivo SQL que contém os comandos para criar as tabelas no banco de dados.

## Recursos Criados

### Terraform

1. **VPC (Virtual Private Cloud)**: Cria uma VPC para isolar a rede.
2. **Sub-rede**: Cria uma sub-rede dentro da VPC.
3. **Grupo de Segurança**: Define regras de segurança para permitir tráfego SSH e MySQL.
4. **Internet Gateway**: Permite que a VPC se comunique com a internet.
5. **Tabela de Rotas**: Define rotas para o tráfego de rede.
6. **Perfil de IAM**: Cria um perfil de IAM para permitir que a instância EC2 use o SSM (AWS Systems Manager).
7. **Instância EC2**: Cria uma instância EC2 e associa o perfil de IAM e o grupo de segurança.
8. **Chave SSH**: Define a chave SSH para acessar a instância EC2.
9. **Funções Lambda**: Cria três funções Lambda (`main`, `dev`, `qa`) com URLs públicas e permissões CORS.
10. **Provisionamento com Ansible**: Utiliza o Ansible para configurar a instância EC2 após a criação.

### Ansible

1. **Ambiente Virtual Python**: Configura um ambiente virtual Python para o Ansible, tanto localmente como no servidor.
2. **Instalação de Pacotes Locais**: Instala requisitos locais do Ansible.
3. **Instalação e Configuração do MySQL**: Instala e configura o MySQL na instância EC2.
4. **Criação de Tabelas no Banco de Dados**: Cria as tabelas necessárias no banco de dados MySQL.

## Como Usar

### Pré-requisitos

- Terraform instalado
- Ansible instalado
- AWS CLI configurado com as credenciais apropriadas
- Chave SSH configurada localmente

### Passos

1. Clone o repositório:
   ```sh
   git clone https://github.com/wcruz-br/ambiente-terraform.git
   cd ambiente-terraform
   ```

2. Crie os arquivos contendo as senhas para os bancos de dados. O Terraform irá buscar esses arquivos para criar os bancos de dados e usuários no MySQL. Os arquivos devem ser criados na pasta `secrets` com os seguintes nomes e conteúdos:
   - `abnmo_admin_pwd.txt`: Senha do usuário admin
   - `abnmo_dev_pwd.txt`: Senha do usuário dev
   - `abnmo_qa_pwd.txt`: Senha do usuário qa
   - `root_pwd.txt`: Senha do usuário root

3. Altere os dados de conexão (profile local AWS CLI e chave SSH). Busque por `wcruz-ipecode` e substitua conforme sua configuração.

4. Inicialize o Terraform:
    ```sh
    terraform init
    ```

5. Aplique a configuração do Terraform:
    ```sh
    terraform apply
    ```

6. O Terraform criará a infraestrutura e executará o playbook Ansible para configurar o MySQL na instância EC2.

#### Outputs
Após a execução do Terraform, o IP público da instância EC2 será exibido como output.

## Estrutura de Diretórios
```
.
├── ambiente.tf
├── install_mysql.ansible.yml
├── requirements
│   └── ansible-requirements.yml
├── ABNMO-create-tables.sql
└── README.md
```

# Ambiente Terraform - Lambda Backend

Este projeto configura três versões de uma função Lambda usando Terraform: `main`, `dev` e `qa`.

## Estrutura

- **main**: Versão principal da função Lambda.
- **dev**: Versão de desenvolvimento da função Lambda.
- **qa**: Versão de qualidade (quality assurance) da função Lambda.

Cada versão possui:
- Um nome único (`ipecode-abnmo-lambda-backend-main`, `ipecode-abnmo-lambda-backend-dev`, `ipecode-abnmo-lambda-backend-qa`).
- Uma URL pública configurada com permissões CORS.
- Um arquivo de código-fonte vazio (`placeholder.zip`)

Estamos subindo um arquivo vazio porque o objetivo nesse momento é apenas criar as funções Lambda. Elas serão atualizadas posteriormente, via pipeline do GitHub Actions.

## Saídas

Após aplicar o Terraform, as URLs das funções Lambda serão exibidas como saída:
- `lambda_url_main`: URL da versão `main`.
- `lambda_url_dev`: URL da versão `dev`.
- `lambda_url_qa`: URL da versão `qa`.

## Requisitos

- Terraform v1.3.0 ou superior.
- AWS CLI configurado com permissões adequadas.

## Contribuições
Sugestões e contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.
