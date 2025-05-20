# Route53 프라이빗 호스티드 존 생성
resource "aws_route53_zone" "private_dns1" {
  name = "eyjo.internal"
  vpc {
    vpc_id = aws_vpc.vpc1.id
  }
  tags = {
    Name = "eyjodomain"
  }
}
# DNS 레코드 설정
resource "aws_route53_record" "dns_record_instance1" {
  zone_id = aws_route53_zone.private_dns1.zone_id
  name    = "websrv1.eyjo.internal"
  type    = "A"
  ttl     = 60
  records = [aws_instance.instance1.private_ip]
}
resource "aws_route53_record" "dns_record_instance2" {
  zone_id = aws_route53_zone.private_dns1.zone_id
  name    = "websrv2.eyjo.internal"
  type    = "A"
  ttl     = 60
  records = [aws_instance.instance2.private_ip]
}
