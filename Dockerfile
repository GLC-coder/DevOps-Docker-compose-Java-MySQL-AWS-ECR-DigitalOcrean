
FROM openjdk:8-jdk-alpine
EXPOSE 8080
RUN mkdir /opt/app
COPY ./build/libs/devops-java-mysql-project-1.0-SNAPSHOT.jar /opt/app
WORKDIR /opt/app
CMD ["java", "-jar","devops-java-mysql-project-1.0-SNAPSHOT.jar"]