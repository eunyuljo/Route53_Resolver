# 출력 값 설정
output "AWSWEBServer1IP" {
  description = "Public IP assigned to AWS WEBSRV1 Instance eth0 interface"
  value       = aws_instance.instance1.public_ip
}
output "AWSWEBServer2IP" {
  description = "Public IP assigned to AWS WEBSRV2 Instance eth0 interface"
  value       = aws_instance.instance2.public_ip
}
output "IDCDNSSRVInstanceEIP" {
  description = "Elastic IP assigned to IDC DNSSRV Instance eth0 interface"
  value       = aws_eip.eip3.public_ip
}
output "IDCWEBServerIP" {
  description = "Public IP assigned to IDC WEBSRV Instance eth0 interface"
  value       = aws_instance.instance4.public_ip
}