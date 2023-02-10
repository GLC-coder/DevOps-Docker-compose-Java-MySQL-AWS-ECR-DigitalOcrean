# DevOps-Build Java app image and use Docker-Compose

Create a Droplet server on DigitalOcrean, build and push Java application docker image to AWS ECR and use run Java app, MySql and MySql UI containers on server by docker-compose

1- [Java App](159.89.124.249:8080)
2- [MySQL - phpmyadmin](159.89.124.249:8081)

### Technologies used:

Java, Gradle, Docker, Docker Compose, DigitalOcean, Nexus, MySql, phpmyadmin

### Description:

1-Configure the Environment Variables for MySql and start MySql container.

2-Start MySql GUI container from docker hub official image.

3-Set Volume for MySql DB and use docker-compose for MySql and MySql GUI.

4- Dockerized the Java application and build, push the java docker image on AWS ECR.

5- Create a Droplet server on DigitalOcean, and run the java app, mysql and phpmyadmin containers on server with docker-compose

### Part 1: Create and run MySql container

###### Step 1: Pull MySql with the latest version from docker hub

```
docker pull mysql
```

###### Step2 :Create and start MySql container

```
docker run -p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
-e MYSQL_DATABASE=${DB_NAME} \
-e MYSQL_USER=${DB_USER} \
-e MYSQL_PASSWORD=${DB_PWD} \
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
export DB_USER=xxxx \
> export DB_PWD=xxxxx \
> DB_SERVER=xxxx \
> DB_NAME=xxxx
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
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
      - MYSQL_USER=${DB_USER}
      - MYSQL_PASSWORD=${DB_PWD}
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
      - PMA_ARBITRARY=${PMA_ARBITRARY}
      - PMA_HOST=${PMA_HOST}
      - PMA_PORT=${PMA_PORT}
    container_name: phpmyadmin
volumes:
  mysql-data:
    driver:
      local
```

###### Set ENV variables for docker-compose.yaml file into terminal

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

###### Step 6: Pull java app docker image to AWS ECR from local server

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
export DB_USER=xxx
export DB_PWD=xxx
export DB_SERVER=xxx
export DB_NAME=xxxx

export MYSQL_ROOT_PASSWORD=xxxx

export PMA_HOST=xxx
export PMA_PORT=xxx
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

######1-non-user name: java

```
sudo adduser java
```

######2-Add non-user:java into "sudo" group

```
usermod -aG sudo java
```

######3-Switch to non-root user: java

```
su - java
```

![image](images/Screenshot%202023-02-09%20at%2011.24.54%20pm.png?raw=true)
######4-Add ssh public key to .ssh directory under non-root user folder

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

######5-Copy and paste root user's .ssh public key value to non-root user's authorized_keys file
![image](images/Screenshot%202023-02-09%20at%2011.32.35%20pm.png?raw=true)
######6-Exit from terminal and sign in with non-root user: java

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

######1-Install aws cli on Droplet server

```
sudo apt  install awscli
```

######2-Configure aws cli with aws admin user access key and secret key

```
aws configure
```

![image](images/Screenshot%202023-02-10%20at%2012.02.12%20am.png)

###### Step 5: Docker login to AWS ECR on Droplet server

![image](images/Screenshot%202023-02-10%20at%2012.24.49%20am.png)
######1-If met error when do docker login aws ecr, run:

```
sudo chmod 666 /var/run/docker.sock
```

###### Step 6.1:Change hardcode and Re-build java jar.file by ./gradlew build

######1- change hardcoded HOST env var of java app in src/main/resources/static/index.html file, line 48, set the env var with the server public ip address

```
 const HOST = "159.89.124.249";
```

######2-Clean and rebuild jar file by ./gradlew locally

```
./gradlew clean
```

```
./gradlew build
```

######3-Rebuild Java app docker image and push it to AWS ECR with new version

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

######4-Update docker-compose.yaml file
![image](images/Screenshot%202023-02-10%20at%2012.45.14%20am.png)
######5-Copy docker-compose.yaml file to the current user dir of Droplet server from local

```
 scp -i ~/.ssh/id_rsa docker-compose.yaml java@159.89.124.249:~/
```

![image](images/Screenshot%202023-02-10%20at%2012.55.22%20am.png)

###### Step 6.2: As the architecture of droplet server is x86_64,arm64 or intel64, if you computer architecture is ARM64,please build the java docker image to amd64

######1-Change the experimental to true in docker engine of docker desktop app
![image](images/Screenshot%202023-02-10%20at%202.48.09%20pm.png)
######2-build the java image by docker

```
docker buildx build -t java-app:3.0 --platform=linux/amd64 .
```

![image](images/Screenshot%202023-02-10%20at%202.29.25%20pm.png)

```
docker tag java-app:3.0 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:3.0-amd64
```

![image](images/Screenshot%202023-02-10%20at%202.29.11%20pm.png)

```
docker push 118381122830.dkr.ecr.ap-southeast-2.amazonaws.com/java-app:3.0-amd64
```

######3-update the docker-compose.yaml file with new java app docker image version

######4-Build the java.jar file

```
./gradlew build
```

######5-Copy docker-compose.yaml file to the current user dir of Droplet server from local

```
 scp -i ~/.ssh/id_rsa docker-compose.yaml java@159.89.124.249:~/
```

![image](images/Screenshot%202023-02-10%20at%2012.55.22%20am.png)
######Check the copied docker-compose.yaml file under the current user dir

```
ls
```

![image](images/Screenshot%202023-02-10%20at%2012.55.42%20am.png)

###### Step 7: Set all Environment variables into terminal of Droplet server

```
# set all needed environment variables
export DB_USER=xxx
export DB_PWD=xxx
export DB_SERVER=xxx
export DB_NAME=xxx

export MYSQL_ROOT_PASSWORD=xxx

export PMA_HOST=xxx
export PMA_PORT=xxx
export PMA_ARBITRARY=x
```

###### Step 10: Check docker-compose version and install docker-compose

```
docker-compose --version
```

```
sudo apt  install docker-compose
```

###### Step 11: Start Java app with docker-compose

###### docker-compose is under version 2

```
docker-compose up
```

or

###### docker-compose is above version 2

```
docker compose up
```

###### Step 12: Update firewall with port 8080, 8081 for all traffic to get access

###### Step 13: open java app web and phpmyadmin on browser

###### For Java app web

```
159.89.124.249:8080
```

![image](images/Screenshot%202023-02-10%20at%202.58.46%20pm.png)

###### For phpmyadmin

```
159.89.124.249:8081
```

![image](images/Screenshot%202023-02-10%20at%202.59.31%20pm.png)
