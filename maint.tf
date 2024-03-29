# ------------------------
# Define el provider de AWS
# ------------------------
provider "aws" {
  region = local.region
}

# Uso de variables locales
locals {
  region = "us-east-1"
  ami    = var.ubuntu_ami[local.region]
}

# Data Source: Subnet
# Obtenemos el id de la subnet que se crea por defecto en dicha AZ
# ------------------------
# Data source que obtiene el id del AZ us-east-1a
# ------------------------
data "aws_subnet" "az_a" {
  availability_zone = "${local.region}a"
}

# ------------------------
# Data source que obtiene el id del AZ us-east-1b
# ------------------------
# Data Source: Subnet
# Obtenemos el id de la subnet que se crea por defecto en dicha AZ
data "aws_subnet" "az_b" {
  availability_zone = "${local.region}b"
}

# Instancia EC2
# Usar _
# ------------------------
# Define una instancia EC2 con AMI Ubuntu
# ------------------------
resource "aws_instance" "servidor_1" {
  ami                    = local.ami
  instance_type          = var.tipo_instancia
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id] # Asocia el segurity group a la instancia
  subnet_id              = data.aws_subnet.az_a.id                       # Se agrega el ID de la subnet a la cual queremos desplegar nuestra instancia.

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola mundo!, soy servidor 1" > index.html
              nohup busybox httpd -f -p ${var.puerto_servidor} &
              EOF

  tags = {
    Name = "Servidor 1"
  }
}

# ------------------------
# Define una instancia EC2 con AMI Ubuntu
# ------------------------
resource "aws_instance" "servidor_2" {
  ami                    = local.ami
  instance_type          = var.tipo_instancia
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id] # Asocia el segurity group a la instancia
  subnet_id              = data.aws_subnet.az_b.id

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola mundo!, soy servidor 2" > index.html
              nohup busybox httpd -f -p ${var.puerto_servidor} &
              EOF

  tags = {
    Name = "Servidor 2"
  }
}

# En lugar de que tengamos acceso todos a estas instancias,
# vamos a restringirlo y vamos a decirle que solamente el
# security group del load balancer pueda acceder a estas instancias.
# De esta forma ya nadie mas podria acceder directamente
# al puerto 8080 de nuestras instancias y tendriamos mas seguridad.
# Para ello se modifica el cidr_blocks por el de security group del lb
resource "aws_security_group" "mi_grupo_de_seguridad" {
  name = "primer-servidor-sg"

  ingress {
    # cidr_blocks = ["0.0.0.0/0"] # Todas las IPs
    security_groups = [aws_security_group.alb.id]
    description     = "Acceso al puerto 8080 desde el exterior"
    from_port       = var.puerto_servidor
    to_port         = var.puerto_servidor
    protocol        = "TCP"
  }
}

resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "terraformers-alb"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

# El firewall del lb tiene una ingress rule desde todas las Ips,
# pero no tiene ninguna egress rule, por lo cual este LB de ninguna manera
# puede llamar a nuestras instancias, por lo cual se va a poner una egress rule, y
# le vamos a decir que pueda salir desde el puerto 8080, de esta forma dejamos que
# acceda a nuestras instancias.
resource "aws_security_group" "alb" {
  name = "alb-sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    from_port   = var.puerto_lb
    to_port     = var.puerto_lb
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 8080 de nuestros servidores"
    from_port   = var.puerto_servidor
    to_port     = var.puerto_servidor
    protocol    = "TCP"
  }
}

data "aws_vpc" "default" {
  # Nos va a traer la vpc que tenemos por defecto en AWS
  default = true
}

# Una practica común en Terraform, si no se tiene ningun tipo de este recurso, se
# puede poner de nombre como this
resource "aws_lb_target_group" "this" {
  name = "terraformers-alb-target-group"
  # Puerto al que va a escuchar
  port = var.puerto_lb
  # Id de la VPC
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled = true
    # En el path raiz por defecto si contesta con un status code 200, significa que la instancia esta health si
    # En caso de que no contesta, la instancia esta rota o caida.
    matcher = "200"
    path    = "/"
    # Tener en cuenta que este escuchando en el puerto 8080 nuestra instancia.
    port     = var.puerto_servidor
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "servidor_1" {
  # Cual es el target group que vamos a asociar este attachment
  target_group_arn = aws_lb_target_group.this.arn
  # Target id es nuestra instancia
  target_id = aws_instance.servidor_1.id
  port      = var.puerto_servidor
}

resource "aws_lb_target_group_attachment" "servidor_2" {
  # Cual es el target group que vamos a asociar este attachment
  target_group_arn = aws_lb_target_group.this.arn
  # Target id es nuestra instancia
  target_id = aws_instance.servidor_2.id
  port      = var.puerto_servidor
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.puerto_lb
  protocol          = "HTTP"

  # Que acción vamos a tomar? Vamos a hacer forward de todas las peticiones que nos entren,
  # hacia el target group.
  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
