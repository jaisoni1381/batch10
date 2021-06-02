FROM java:8-jdk-alpine
RUN mkdir /usr/app
COPY ./target/bootcamp-0.0.1-SNAPSHOT.jar /usr/app
WORKDIR /usr/app
RUN sh -c 'touch bootcamp-0.0.1-SNAPSHOT.jar'
EXPOSE 8888
ENTRYPOINT ["java","-jar","bootcamp-0.0.1-SNAPSHOT.jar"]
