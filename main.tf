data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# values.tf latest_ami_al2_ssm_parameter
data "aws_ssm_parameter" "latest_ami" {
  name = var.latest_ami_al2_ssm_parameter
}


# IAM 역할 생성
resource "aws_iam_role" "ssm_role" {
  name = "ssm-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# SSM 관리에 필요한 정책 연결
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}



# 보안 그룹 설정
# SG1: VPC1-AWS-WEBSRV-SG
resource "aws_security_group" "sg1" {
  name        = "VPC1-AWS-WEBSRV-SG"
  description = "VPC1-AWS-WEBSRV-SG"
  vpc_id      = aws_vpc.vpc1.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "VPC1-AWS-WEBSRV-SG"
  }
}
# SG2: VPC1-Route53-Resolver-SG
resource "aws_security_group" "sg2" {
  name        = "VPC1-Route53-Resolver-SG"
  description = "VPC1-Route53-Resolver-SG"
  vpc_id      = aws_vpc.vpc1.id
  ingress {
    description = "TCP DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "UDP DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "VPC1-Route53-Resolver-SG"
  }
}
# SG3: VPC2-IDC-DNSSRV-SG
resource "aws_security_group" "sg3" {
  name        = "VPC2-IDC-DNSSRV-SG"
  description = "VPC2-IDC-DNSSRV-SG"
  vpc_id      = aws_vpc.vpc2.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "UDP DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "TCP DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "VPC2-IDC-DNSSRV-SG"
  }
}
# SG4: VPC2-IDC-WEBSRV-SG
resource "aws_security_group" "sg4" {
  name        = "VPC2-IDC-WEBSRV-SG"
  description = "VPC2-IDC-WEBSRV-SG"
  vpc_id      = aws_vpc.vpc2.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "VPC2-IDC-WEBSRV-SG"
  }
}
# ENI 생성 (Instance3의 eth0)
resource "aws_network_interface" "instance3_eni_eth0" {
  subnet_id       = aws_subnet.subnet3.id
  private_ips     = ["10.80.1.200"]
  security_groups = [aws_security_group.sg3.id]
  description     = "Instance3 eth0"
  tags = {
    Name = "IDC-DNSSRV eth0"
  }
}
# EIP 생성 및 ENI에 할당
resource "aws_eip" "eip3" {
  domain = "vpc"
  tags = {
    Name = "Instance3 EIP"
  }
}

resource "aws_eip_association" "eip_assoc3" {
  allocation_id        = aws_eip.eip3.id
  network_interface_id = aws_network_interface.instance3_eni_eth0.id
}


# EC2 인스턴스 생성
# Instance1: AWS-WEBSRV1
resource "aws_instance" "instance1" {
  ami                         = data.aws_ssm_parameter.latest_ami.value
  instance_type               = "t3.small"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet1.id
  private_ip                  = "10.70.1.100"
  vpc_security_group_ids      = [aws_security_group.sg1.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  user_data = base64encode(<<-EOF
    #!/bin/bash
    hostnamectl --static set-hostname WEBSRV1
    sed -i "s/localhost4.localdomain4/localhost4.localdomain4 WEBSRV1/g" /etc/hosts
    yum -y install tcpdump httpd
    systemctl start httpd && systemctl enable httpd
    echo "<h1>AWS Web Server 1 - 10.70.1.100</h1>" > /var/www/html/index.html
  EOF
  )
  tags = {
    Name = "AWS-WEBSRV1"
  }
}
# Instance2: AWS-WEBSRV2
resource "aws_instance" "instance2" {
  ami                         = data.aws_ssm_parameter.latest_ami.value
  instance_type               = "t3.small"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet2.id
  private_ip                  = "10.70.2.100"
  vpc_security_group_ids      = [aws_security_group.sg1.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  user_data = base64encode(<<-EOF
    #!/bin/bash
    hostnamectl --static set-hostname WEBSRV2
    sed -i "s/localhost4.localdomain4/localhost4.localdomain4 WEBSRV2/g" /etc/hosts
    yum -y install tcpdump httpd
    systemctl start httpd && systemctl enable httpd
    echo "<h1>AWS Web Server 2 - 10.70.2.100 </h1>" > /var/www/html/index.html
  EOF
  )
  tags = {
    Name = "AWS-WEBSRV2"
  }
}

resource "aws_instance" "instance3" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  key_name                    = var.key_name_ed25519
  network_interface {
    network_interface_id = aws_network_interface.instance3_eni_eth0.id
    device_index         = 0
  }
user_data = base64encode(<<EOF
#!/bin/bash
# 네트워크가 준비될 때까지 대기
until ping -c 1 8.8.8.8 &> /dev/null; do sleep 3; done

# 호스트 이름 설정
hostnamectl --static set-hostname DNSSRV
echo "127.0.0.1 localhost DNSSRV" > /etc/hosts

# DNS 설정
echo "[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=1.1.1.1
Domains=~.
Cache=yes
DNSStubListener=yes" > /etc/systemd/resolved.conf
systemctl restart systemd-resolved

# 패키지 설치
apt-get update -y
apt-get install -y bind9 bind9-doc language-pack-ko

# 설정 파일 백업
[ -f /etc/bind/named.conf.options ] && mv /etc/bind/named.conf.options /etc/bind/named.conf.options.bak

# 설정 파일 생성 - 단일 명령으로
echo 'options {
   directory "/var/cache/bind";
   recursion yes;
   allow-query { any; };
   forwarders {
         8.8.8.8;
          };
    forward only;
    auth-nxdomain no;
};
zone "eyjo.internal" {
    type forward;
    forward only;
    forwarders { 10.70.1.250; 10.70.2.250; };
};
zone "ap-northeast-2.compute.internal" {
    type forward;
    forward only;
    forwarders { 10.70.1.250; 10.70.2.250; };
};' > /etc/bind/named.conf.options

echo 'zone "idcneta.internal" {
    type master;
    file "/etc/bind/db.idcneta.internal";
};
zone "80.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.80";
};' > /etc/bind/named.conf.local

echo '$TTL 30
@ IN SOA idcneta.internal. root.idcneta.internal. (
  2019122114 ; serial
  3600       ; refresh
  900        ; retry
  604800     ; expire
  86400      ; minimum ttl
)
; dns server
@      IN NS ns1.idcneta.internal.
; ip address of dns server
ns1    IN A  10.80.1.200
; Hosts
websrv   IN A  10.80.1.100
dnssrv   IN A  10.80.1.200' > /etc/bind/db.idcneta.internal

echo '$TTL 30
@ IN SOA idcneta.internal. root.idcneta.internal. (
  2019122114 ; serial
  3600       ; refresh
  900        ; retry
  604800     ; expire
  86400      ; minimum ttl
)
; dns server
@      IN NS ns1.idcneta.internal.
; ip address of dns server
3      IN PTR  ns1.idcneta.internal.
; A Record list
100.1    IN PTR  websrv.idcneta.internal.
200.1    IN PTR  dnssrv.idcneta.internal.' > /etc/bind/db.10.80

# 권한 설정 및 서비스 시작
chown -R bind:bind /etc/bind
chmod -R 644 /etc/bind
find /etc/bind -type d -exec chmod 755 {} \;
systemctl restart bind9
systemctl enable bind9
EOF
)
  tags = {
    Name = "IDC-DNSSRV"
  }
}


# Instance4: IDC-WEBSRV
resource "aws_instance" "instance4" {
  ami                         = data.aws_ssm_parameter.latest_ami.value
  instance_type               = "t3.small"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet3.id
  private_ip                  = "10.80.1.100"
  vpc_security_group_ids      = [aws_security_group.sg4.id]
  associate_public_ip_address = true
  user_data = base64encode(<<-EOF
    #!/bin/bash
    hostnamectl --static set-hostname WEBSRV
    sed -i "s/localhost4.localdomain4/localhost4.localdomain4 WEBSRV/g" /etc/hosts
    yum -y install tcpdump httpd
    systemctl start httpd && systemctl enable httpd
    echo "<h1>IDC Web Server - 10.80.1.100 </h1>" > /var/www/html/index.html
  EOF
  )
  tags = {
    Name = "IDC-WEBSRV"
  }
}
