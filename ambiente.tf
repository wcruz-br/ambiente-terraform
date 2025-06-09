# Configuração do provedor AWS
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}
provider "aws" {
    profile = "wcruz-ipecode"
    region  = "us-east-1"
}

# Criação de uma VPC (Virtual Private Cloud)
resource "aws_vpc" "ipecode_dev_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Projeto = "ipecode-abnmo"
        Ambiente = "dev/qa"
    }
}

# Criação de uma Subnet dentro da VPC
resource "aws_subnet" "ipecode_dev_subnet" {
    vpc_id            = aws_vpc.ipecode_dev_vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "abnmo-subnet"
    }
}

# Criação de um Security Group para permitir tráfego específico
resource "aws_security_group" "allow_traffic" {
    name        = "allow_traffic"
    description = "Allow SSH, HTTP, and HTTPS traffic"
    vpc_id      = aws_vpc.ipecode_dev_vpc.id

    # Regras de entrada (ingress) para permitir tráfego SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Regras de entrada (ingress) para permitir tráfego para o MySQL
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Regra de saída (egress) para permitir tráfego para qualquer destino
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "abnmo-sg-allow-traffic"
    }
}

# Cria o Internet Gateway
resource "aws_internet_gateway" "ipecode_dev_igw" {
  vpc_id = aws_vpc.ipecode_dev_vpc.id

  tags = {
    Name = "abnmo-internet-gateway"
  }
}

# Cria a tabela de rotas
resource "aws_route_table" "ipecode_dev_route_table" {
  vpc_id = aws_vpc.ipecode_dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Tráfego para qualquer destino
    gateway_id = aws_internet_gateway.ipecode_dev_igw.id # Envia para o IGW
  }

  tags = {
    Name = "abnmo-route-table"
  }
}

# Associa a tabela de rotas à sub-rede
resource "aws_route_table_association" "ipecode_dev_route_table_association" {
  subnet_id      = aws_subnet.ipecode_dev_subnet.id
  route_table_id = aws_route_table.ipecode_dev_route_table.id
}

# Cria o perfil de IAM
resource "aws_iam_role" "ssm_instance_role" {
  name = "abnmo-SSMInstanceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Anexa a política AmazonSSMManagedInstanceCore ao perfil de IAM
resource "aws_iam_role_policy_attachment" "ssm_instance_role_policy_attachment" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Cria o Instance Profile
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "abnmo-SSMInstanceProfile"  # Nome do instance profile
  role = aws_iam_role.ssm_instance_role.name # Associa o role ao instance profile
}

# Sobe a instância
resource "aws_instance" "ipecode-dev" {
    depends_on             = [aws_key_pair.my_key]
    ami                    = "ami-0c614dee691cbbf37"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.allow_traffic.id]
    subnet_id              = aws_subnet.ipecode_dev_subnet.id
    associate_public_ip_address = true
    iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name # Usa o NOME do instance profile
    key_name      = aws_key_pair.my_key.key_name

    tags = {
        Name = "abnmo-ec2-instance"
    }
}

# Informa a chave que será utilizada para acessar a instância
resource "aws_key_pair" "my_key" {
  key_name   = "wcruz-ipecode"
  public_key = file("~/.ssh/wcruz-ipecode.pub")
}

# Cria o Elastic IP com o endereço específico
resource "aws_eip" "ipecode_dev_eip" {
  domain = "vpc"
  instance = aws_instance.ipecode-dev.id
  tags = {
    Name = "abnmo-dev-eip"
    Description = "Elastic IP para ambiente dev da ABNMO"
    Projeto = "ipecode-abnmo"
    Ambiente = "dev/qa"
  }
}

resource "null_resource" "ansible_instala_mysql" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command = <<EOT
    ansible-playbook -i "${aws_eip.ipecode_dev_eip.public_ip}," -u ec2-user --private-key ~/.ssh/wcruz-ipecode --ssh-extra-args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" install_mysql.ansible.yml
    EOT
  }
}

resource "null_resource" "ansible_cria_tabelas" {
  depends_on = [null_resource.ansible_instala_mysql]

  provisioner "local-exec" {
    command = <<EOT
    ansible-playbook -i "${aws_eip.ipecode_dev_eip.public_ip}," -u ec2-user --private-key ~/.ssh/wcruz-ipecode --ssh-extra-args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" create_tables.ansible.yml
    EOT
  }
}

resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.ipecode-dev]

  provisioner "local-exec" {
    command = <<EOT
    while ! nc -z ${aws_eip.ipecode_dev_eip.public_ip} 22; do
      echo "Esperando o SSH estar disponível..."
      sleep 3
    done
    EOT
  }
}

# Mostra o IP público da instância
output "instance_ip" {
    description = "IP público da instância EC2"
    value       = aws_eip.ipecode_dev_eip.public_ip
}
