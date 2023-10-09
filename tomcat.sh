#!/bin/bash

# Create a Tomcat User and Directory
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Update package list and install default JDK
sudo apt update
sudo apt install default-jdk -y

# Check Java version
java -version

# Download and extract Tomcat
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.13/bin/apache-tomcat-10.1.13.tar.gz
sudo tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1

# Set permissions for Tomcat
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin

# Update Java alternatives
sudo update-java-alternatives -l

# Create systemd service for Tomcat
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOL
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start Tomcat
sudo systemctl daemon-reload
sudo systemctl start tomcat

# Check Tomcat status
sudo systemctl status tomcat

# Enable Tomcat to start on boot
sudo systemctl enable tomcat
