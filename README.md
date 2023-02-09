# DevOps-Build Java app image and use Docker-Compose
Build Java application docker image and use docker-compose to run Java app, MySql and MySql UI container on server
### Technologies used:
Java, Gradle, Docker, Docker Compose, DigitalOcean, Nexus, MySql, MySql UI
### Description:
1-Configure the Environment Variables for MySql and start MySql container.

2-Start MySql GUI container from docker hub official image.

3-Set Volume for MySql DB and use docker-compose for MySql and MySql GUI.

4- Dockerized the Java application and build, push the java docker image on AWS ECR.

5-Add application configuration command to docker-compose and run the java application on server with docker-compose

### Part 1: Create and run MySql container  

###### Step 1: Pull MySql with the latest version from docker hub
```
docker pull mysql
```
###### Step2 :Create and start MySql container
```
docker run -p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=rootpass \
-e MYSQL_DATABASE=team-member-projects \
-e MYSQL_USER=admin \
-e MYSQL_PASSWORD=adminpass \
--name mysql \
-d mysql --default-authentication-plugin=mysql_native_password
```
###### Step 3:Check the current running docker container
```
docker ps
```
![image](images/Screenshot%202023-02-09%20at%203.24.59%20pm.png?raw=true)
###### Step 4: Build the java jar file
```
./gradlew build
```
###### Step 5: Set ENV variables for mysql database into terminal
```
export DB_USER=admin \
> export DB_PWD=adminpass \
> DB_SERVER=localhost \
> DB_NAME=team-member-projects
```
###### Step 6:Check set ENV variables related to DB
```
printenv | grep DB
```
![image](images/Screenshot%202023-02-09%20at%203.37.18%20pm.png?raw=true)
###### Step 6: Start the application locally
```
java -jar build/libs/devops-java-mysql-project-1.0-SNAPSHOT.jar
```
![image](images/Screenshot%202023-02-09%20at%203.44.52%20pm.png?raw=true)

### Part 2: Start MySql UI container: phpmyadmin
###### Step1: Pull mysql UI: phpmyadmin from docker hub
```
docker pull phpmyadmin
```
###### Step 2: Start the phpmyadmin container from phpmyadmin image and link it to mysql server
```
docker run -p 8081:80 --name phpmyadmin --link mysql:db -d phpmyadmin
```
###### Step 3: Check current running containers
```
docker ps
```
![image](images/Screenshot%202023-02-09%20at%204.05.39%20pm.png?raw=true)
###### Step 4: Open browser with localhost:8081 and login phpmyadmin with set username and password
```
localhost:8081
```
![image](images/Screenshot%202023-02-09%20at%204.12.19%20pm.png)

![image](images/Screenshot%202023-02-09%20at%205.57.05%20pm.png?raw=true)

### Part 3: Run MySql and phpmyadmin container by docker-compose

###### Configure mysql and phpmyadmin in the docker-compose.yaml file
```
version: '3'
services:
  mysql:
    image: mysql
    ports:
      - 3306:3306
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=rootpass
      - MYSQL_DATABASE=team-member-projects
      - MYSQL_USER=admin
      - MYSQL_PASSWORD=adminpass
    volumes:
      - mysql-data:/var/lib/mysql
    container_name: mysql
    command: --default-authentication-plugin=mysql_native_password
  phpmyadmin:
    image: phpmyadmin
    ports:
      - 8081:80
    restart: always
    links:
      - mysql
    environment:
      - PMA_ARBITRARY=1
      - PMA_HOST=mysql
      - PMA_PORT=8081
    container_name: phpmyadmin
volumes:
  mysql-data:
    driver:
      local
```
[Docker-compose for MySql and phpmyadmin (1)](https://dev.to/devkiran/mysql-phpmyadmin-docker-compose-54h7)

[Docker-compose for MySql and phpmyadmin (2)](https://tecadmin.net/docker-compose-for-mysql-with-phpmyadmin)
###### Create and run MySql container and phpmyadmin container
```
docker compose up
```
![image](images/Screenshot%202023-02-09%20at%207.07.53%20pm.png?raw=true)

###### Check the created network 
```
docker network ls
```
![image](images/Screenshot%202023-02-09%20at%207.08.06%20pm.png?raw=true)
###### Check the two created containers are running 
```
docker ps
```
![image](images/Screenshot%202023-02-09%20at%207.08.11%20pm.png?raw=true)

![image](images/Screenshot%202023-02-09%20at%207.29.39%20pm.png?raw=true)
###### Stop MySql container and phpmyadmin container
```
docker compose down
```

### Part 4: Dockerize the Java application
###### Create a Dockerfile for the Java application
```
FROM openjdk:8-jdk-alpine
EXPOSE 8080
RUN mkdir /opt/app
COPY ./build/libs/devops-java-mysql-project-1.0-SNAPSHOT.jar /opt/app
WORKDIR /opt/app
CMD ["java", "-jar","build/libs/devops-java-mysql-project-1.0-SNAPSHOT.jar"]
```
### Part 5: Build Java application docker image and push it to AWS ECR
###### Step 1: Create a Java app docker image repository on AWS ECR
![image](images/Screenshot%202023-02-09%20at%208.33.06%20pm.png?raw=true)
###### Step 2: Docker login to AWS ECR with AWS Cli
#For macOS / Linux
![image](images/Screenshot%202023-02-09%20at%208.35.27%20pm.png?raw=true)
#For Windows
![image](images/Screenshot%202023-02-09%20at%208.39.16%20pm.png?raw=true)
###### Step 3: Re-build java jar file by Gradle
```
./gradlew clean
```
```
./gradlew build
```
###### Step 4: Build java app docker image locally
```
docker build -t my-java-app:1.0 .
```
![image](images/Screenshot%202023-02-09%20at%208.57.25%20pm.png?raw=true)
###### Step 5: Re-tag java app image
```
docker tag my-java-app:1.0 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:1.0
```
![image](images/Screenshot%202023-02-09%20at%209.17.56%20pm.png?raw=true)
###### Step 6: Pull java app docker image to AWS ECR
```
docker push 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:1.0
```
### Part 6: Add Java application to docker-compose
###### Step 1: Configure docker-compose.yaml with port, environment and volume
```
version: '3'
services:
  my_java_app:
    image: 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:1.0
    ports:
      - "8080:8080"
    environment:
      - DB_USER=${DB_USER}
      - DB_PWD=${DB_PWD}
      - DB_SERVER=${DB_SERVER}
      - DB_NAME={DB_NAME}
    container_name: my_java_app
    depends_on:
      - mysql
  mysql:
    image: mysql
    ports:
      - "3306:3306"
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE_NAME}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_ADMIN_PASSWORD}
    volumes:
      - mysql-data:/var/lib/mysql
    container_name: mysql
    command: --default-authentication-plugin=mysql_native_password
  phpmyadmin:
    image: phpmyadmin
    ports:
      - "8081:80"
    restart: always
    environment:
      - PMA_ARBITRARY=1
      - PMA_HOST=${PMA_HOST}
      - PMA_PORT=${PMA_PORT}
    container_name: phpmyadmin
    depends_on:
      - mysql
volumes:
  mysql-data:
    driver:
      local
```

###### Step 2:export all ENV Variables into terminal of current user on server locally
```
# set all needed environment variables
export DB_USER=admin
export DB_PWD=adminpass
export DB_SERVER=mysql
export DB_NAME=team-member-projects

export MYSQL_ROOT_PASSWORD=rootpass

export PMA_HOST=mysql
export PMA_PORT=3306
```
###### Step 3:Check all Env variables in the os system
```
printenv 
```
###### Step 4: Run application, MySql, phpmyadmin containers locally by docker compose 
```
docker compose up
```
### Run Java app, MySql and phpmyadmin containers on Droplet server with docker compose
###### Step 1: Create a virtual Droplet server on Toronto region with ssh authentication method

![image](images/Screenshot%202023-02-09%20at%2010.57.49%20pm.png?raw=true)

![image](images/Screenshot%202023-02-09%20at%2010.58.19%20pm.png?raw=true)

###### Step 2: Login Drop server with root user and install Docker
```
ssh root@159.89.124.249
```
```
apt update
```
```
apt  install docker.io
```
###### Step 3: Create a non-root user to manage the Droplet server 
#non-user name: java,  password:javajava
```
sudo adduser java
```
#Add non-user:java into "sudo" group
```
usermod -aG sudo java
```
#Switch to non-root user: java
```
su - java
```
![image](images/Screenshot%202023-02-09%20at%2011.24.54%20pm.png?raw=true)
#Add ssh public key to .ssh directory under non-root user folder
```
pwd
```
```
ls -a
```
```
mkdir .ssh
```
```
sudo vim .ssh/authorized_keys
```
#Copy and paste root user's .ssh public key value to non-root user's authorized_keys file
![image](images/Screenshot%202023-02-09%20at%2011.32.35%20pm.png?raw=true)
#Exit from terminal and sign in with non-root user: java
```
exit
```
```
exit
```
```
ssh java@159.89.124.249
```
![image](images/Screenshot%202023-02-09%20at%2011.35.20%20pm.png?raw=true)
###### Step 4: Install AWS Cli and configure AWS on Droplet server
#Install aws cli on Droplet server
```
sudo apt  install awscli
```
#Configure aws cli with aws admin user access key and secret key

![image](images/Screenshot%202023-02-10%20at%2012.02.12%20am.png)
```
aws configure
```
###### Step 5: Docker login to AWS ECR on Droplet server
![image](images/Screenshot%202023-02-10%20at%2012.24.49%20am.png)
#If met error when do docker login aws ecr, run:
```
sudo chmod 666 /var/run/docker.sock
```
###### Step 6:Change hardcode and Re-build java jar.file by ./gradlew build
## change hardcoded HOST env var in src/main/resources/static/index.html file, line 48
```
 const HOST = "159.89.124.249";
```
#Clean and rebuild jar file by ./gradlew locally
```
./gradlew clean
```
```
./gradlew build
```
###### Step 7: rebuild Java app docker image and push it to AWS ECR with new version 
```
 docker build -t my-java-app:2.0 .
```
```
docker tag my-java-app:2.0 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:2.0
```
```
docker push 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:2.0
```
![image](images/Screenshot%202023-02-10%20at%2012.47.45%20am.png)
###### Step 8: Update docker-compose.yaml with new java app image and copy docker-compose file to remote server
#Update docker-compose.yaml file
![image](images/Screenshot%202023-02-10%20at%2012.45.14%20am.png)
#Copy docker-compose.yaml file to the current user dir of Droplet server from local
```
 scp -i ~/.ssh/id_rsa docker-compose.yaml java@159.89.124.249:~/
```
![image](images/Screenshot%202023-02-10%20at%2012.55.22%20am.png)
#Check the copied docker-compose.yaml file under the current user dir
```
ls
```
![image](images/Screenshot%202023-02-10%20at%2012.55.42%20am.png)
###### Step 9: Set all Environment variables into terminal of Droplet server
```
# set all needed environment variables
export DB_USER=admin
export DB_PWD=adminpass
export DB_SERVER=mysql
export DB_NAME=team-member-projects

export MYSQL_ROOT_PASSWORD=rootpass

export PMA_HOST=mysql
export PMA_PORT=3306
export PMA_ARBITRARY=1
```
![image](images/Screenshot%202023-02-10%20at%201.10.10%20am.png)
![image](images/Screenshot%202023-02-10%20at%201.10.18%20am.png)
###### Step 10: Check docker-compose version and install docker-compose
```
docker-compose --version
```
```
sudo apt  install docker-compose
```
###### Step 11: Start Java app with docker-compose
```
docker-compose up
```
or
```
docker compose up
```