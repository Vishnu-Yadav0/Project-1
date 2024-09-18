
output "public_ip" {
  value = aws_instance.jenkins.public_ip
}
output "private_ip" {
  value = aws_instance.jenkins.private_ip
}

output "sonar_public_ip" {
  value = aws_instance.sonarqube.public_ip
}
output "sonar_private_ip" {
  value = aws_instance.sonarqube.private_ip
}

output "jfrog_public_ip" {
  value = aws_instance.jfrog.public_ip
}
output "jfrog_private_ip" {
  value = aws_instance.jfrog.private_ip
}

output "tomcat_public_ip" {
  value = aws_instance.tomcat.public_ip
}
output "tomcat_private_ip" {
  value = aws_instance.tomcat.private_ip
}
