#Resource
#Jenkins - To Automate CI/CD Pipeline
resource "aws_instance" "jenkins" {
  ami                    = var.ami
  instance_type          = var.medium
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.iam_instance_profile
  user_data              = <<-EOF
    #!/bin/bash
    sudo hostnamectl set-hostname "jenkins.server.io"
    echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts
    sudo apt-get update
    sudo apt-get install git wget unzip curl tree -y
    sudo apt-get install openjdk-17-jdk -y
    sudo apt-get install maven -y
    sudo cp -pvr /etc/environment "/etc/environment_$(date +%F_%R)"
    echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/" >> /etc/environment
    echo "MAVEN_HOME=/usr/share/maven" >> /etc/environment
    source /etc/environment
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    EOF

  tags = {
    Name        = "Jenkins"
    Environment = "Dev"
    ProjectName = "JavaProject"
    ProjectID   = "2024"
    CreatedBy   = "IaC Terraform"
  }
}


#Sonarqube -- Code Quality Check
resource "aws_instance" "sonarqube" {
  ami                    = var.ami
  instance_type          = var.medium
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.iam_instance_profile
  user_data              = <<-EOF
    #!/bin/bash
    sudo hostnamectl set-hostname "sonarqube.server.io"
    echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts
    sudo apt-get update
    sudo apt-get install git wget unzip zip curl tree -y
    sudo apt-get install docker.io -y
    sudo usermod -aG docker ubuntu
    sudo chmod 777 /var/run/docker.sock
    sudo systemctl enable docker
    sudo systemctl restart docker
    sudo docker pull sonarqube
    sudo docker images
    docker volume create sonarqube-conf
    docker volume create sonarqube-data
    docker volume create sonarqube-logs
    docker volume create sonarqube-extensions
    docker volume inspect sonarqube-conf
    docker volume inspect sonarqube-data
    docker volume inspect sonarqube-logs
    docker volume inspect sonarqube-extensions
    mkdir /sonarqube
    ln -s /var/lib/docker/volumes/sonarqube-conf/_data /sonarqube/conf
    ln -s /var/lib/docker/volumes/sonarqube-data/_data /sonarqube/data
    ln -s /var/lib/docker/volumes/sonarqube-logs/_data /sonarqube/logs
    ln -s /var/lib/docker/volumes/sonarqube-extensions/_data /sonarqube/extensions
    docker run -d --name c3opssonarqube -p 9000:9000 -p 9092:9092 -v sonarqube-conf:/sonarqube/conf -v sonarqube-data:/sonarqube/data -v sonarqube-logs:/sonarqube/logs -v sonarqube-extensions:/sonarqube/extensions sonarqube
    EOF

  tags = {
    Name        = "SonarQube"
    Environment = "Dev"
    ProjectName = "JavaProject"
    ProjectID   = "2024"
    CreatedBy   = "IaC Terraform"
  }
}

# Jfrog -- Artifactory Management
resource "aws_instance" "jfrog" {
  ami                    = var.ami
  instance_type          = var.medium
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.iam_instance_profile
  user_data              = <<-EOF
  #!/bin/bash
  sudo hostnamectl set-hostname "jfrog.server.io"
  echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts
  sudo apt-get update
  sudo apt-get install vim curl elinks unzip wget tree git -y
  sudo apt-get install openjdk-17-jdk -y
  sudo cp -pvr /etc/environment "/etc/environment_$(date +%F_%R)"
  echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/" >> /etc/environment
  source /etc/environment

  cd /opt/
  
  #sudo wget https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/[RELEASE]/jfrog-artifactory-oss-[RELEASE]-linux.tar.gz
  
  sudo wget https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/7.71.3/jfrog-artifactory-oss-7.71.3-linux.tar.gz
  
  tar xvzf jfrog-artifactory-oss-7.71.3-linux.tar.gz
  
  mv artifactory-oss-* jfrog
  
  sudo cp -pvr /etc/environment "/etc/environment_$(date +%F_%R)"
  
  echo "JFROG_HOME=/opt/jfrog" >> /etc/environment
  
  #cd /opt/jfrog/app/bin/
  
  #./artifactory.sh status
  
  # Configure INIT Scripts for JFrog Artifactory
  # sudo vi /etc/systemd/system/artifactory.service

  echo "[Unit]" > /etc/systemd/system/artifactory.service
  echo "Description=JFrog artifactory service" >> /etc/systemd/system/artifactory.service
  echo "After=syslog.target network.target" >> /etc/systemd/system/artifactory.service
  echo "[Service]" >> /etc/systemd/system/artifactory.service
  echo "Type=forking" >> /etc/systemd/system/artifactory.service
  echo "ExecStart=/opt/jfrog/app/bin/artifactory.sh start" >> /etc/systemd/system/artifactory.service
  echo "ExecStop=/opt/jfrog/app/bin/artifactory.sh stop" >> /etc/systemd/system/artifactory.service
  echo "User=root" >> /etc/systemd/system/artifactory.service
  echo "Group=root" >> /etc/systemd/system/artifactory.service 
  echo "Restart=always" >> /etc/systemd/system/artifactory.service
  echo "[Install]" >> /etc/systemd/system/artifactory.service
  echo "WantedBy=multi-user.target" >> /etc/systemd/system/artifactory.service

  sudo systemctl daemon-reload
  sudo systemctl enable artifactory.service
  sudo systemctl restart artifactory.service

  #Sonar admin & admin | Jfrog admin & password 

  EOF

  tags = {
    Name        = "JFrog"
    Environment = "Dev"
    ProjectName = "JavaProject"
    ProjectID   = "2024"
    CreatedBy   = "IaC Terraform"
  }
}


#Tomcat - Deployment Server
resource "aws_instance" "tomcat" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.iam_instance_profile
  user_data              = <<-EOF
  #!/bin/bash
  sudo hostnamectl set-hostname "tomcat.cloudbinary.io"
  echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts
  sudo apt-get update
  sudo apt-get install vim curl elinks unzip wget tree git -y
  sudo apt-get install openjdk-17-jdk -y
  sudo cp -pvr /etc/environment "/etc/environment_$(date +%F_%R)"
  echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/" >> /etc/environment
  source /etc/environment
  cd /opt/
  sudo wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.95/bin/apache-tomcat-9.0.95.tar.gz
  tar xvzf apache-tomcat-9.0.95.tar.gz
  mv apache-tomcat-9.0.95 tomcat
  sudo cp -pvr /opt/tomcat/conf/tomcat-users.xml "/opt/tomcat/conf/tomcat-users.xml_$(date +%F_%R)"
  sed -i '$d' /opt/tomcat/conf/tomcat-users.xml

  echo '<role rolename="manager-gui"/>'  >> /opt/tomcat/conf/tomcat-users.xml
  echo '<role rolename="manager-script"/>' >> /opt/tomcat/conf/tomcat-users.xml
  echo '<role rolename="manager-jmx"/>'    >> /opt/tomcat/conf/tomcat-users.xml
  echo '<role rolename="manager-status"/>' >> /opt/tomcat/conf/tomcat-users.xml
  
  echo '<role rolename="admin-gui"/>'     >> /opt/tomcat/conf/tomcat-users.xml
  echo '<role rolename="admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml

  echo '<user username="admin" password="linux@123" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml
  
  echo "</tomcat-users>" >> /opt/tomcat/conf/tomcat-users.xml

  sudo cp -pvr /opt/tomcat/webapps/host-manager/META-INF/context.xml "/opt/tomcat/webapps/host-manager/META-INF/context.xml_$(date +%F_%R)"

  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > /opt/tomcat/webapps/host-manager/META-INF/context.xml
  echo "<Context antiResourceLocking=\"false\" privileged=\"true\" >" >> /opt/tomcat/webapps/host-manager/META-INF/context.xml

  echo "</Context>  " >> /opt/tomcat/webapps/host-manager/META-INF/context.xml

  sudo cp -pvr /opt/tomcat/webapps/host-manager/META-INF/context.xml "/opt/tomcat/webapps/host-manager/META-INF/context.xml_$(date +%F_%R)"
  
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > /opt/tomcat/webapps/host-manager/META-INF/context.xml
  echo "<Context antiResourceLocking=\"false\" privileged=\"true\" >" >> /opt/tomcat/webapps/host-manager/META-INF/context.xml

  echo "</Context>  " >> /opt/tomcat/webapps/host-manager/META-INF/context.xml

  
  sudo cp -pvr /opt/tomcat/webapps/manager/META-INF/context.xml "/opt/tomcat/webapps/manager/META-INF/context.xml_$(date +%F_%R)"
  
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > /opt/tomcat/webapps/manager/META-INF/context.xml
  echo "<Context antiResourceLocking=\"false\" privileged=\"true\" >" >> /opt/tomcat/webapps/manager/META-INF/context.xml

  echo "</Context>  " >> /opt/tomcat/webapps/manager/META-INF/context.xml



  cd /opt/tomcat/bin/

  ./startup.sh

  EOF

  tags = {
    Name        = "tomcat"
    Environment = "Dev"
    ProjectName = "JavaProject"
    ProjectID   = "2024"
    CreatedBy   = "IaC Terraform"
  }
}

