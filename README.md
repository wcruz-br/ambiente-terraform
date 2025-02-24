# Infraestrutura de Banco de Dados da IpêCode, com Terraform e Ansible

Automatização da criação e configuração de uma EC2 na AWS rodando MySQL, utilizando Terraform e Ansible. Cria VPC, sub-rede, grupo de segurança, instância EC2 e configura o MySQL na instância utilizando um playbook Ansible.

## Estrutura do Projeto

- `ambiente.tf`: Arquivo de configuração do Terraform que define os recursos da AWS, incluindo VPC, sub-rede, grupo de segurança, instância EC2 e outros.
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
9. **Provisionamento com Ansible**: Utiliza o Ansible para configurar a instância EC2 após a criação.

### Ansible

1. **Ambiente Virtual Python**: Configura um ambiente virtual Python para o Ansible, tanto localmente como no servidor.
2. **Instalação de Pacotes Locais**: Instala requisitos locais do Ansible.
3. **Instalação e Configuração do MySQL**: Instala e configura o MySQL na instância EC2.
4. **Atualização de DNS Dinâmico**: Atualiza o DNS dinâmico usando o serviço [FreeDNS](https://freedns.afraid.org).
5. **Criação de Tabelas no Banco de Dados**: Cria as tabelas necessárias no banco de dados MySQL.

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

2. Crie os arquivos contendo as senhas e a URL de atualização de seu DNS Dinâmico (use o [FreeDNS](https://freedns.afraid.org))
   ```
    .
    └── secrets
        ├── abnmo_admin_pwd.txt
        ├── abnmo_dev_pwd.txt
        ├── abnmo_qa_pwd.txt
        ├── root_pwd.txt
        └── freedns_update_url.txt
   ```

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
## Contribuições
Sugestões e contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.
