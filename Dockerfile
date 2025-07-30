# Use OpenJDK 17 base image
FROM openjdk:17-jdk-slim

# Set environment
VOLUME /tmp

# Copy the JAR file into the container
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "/app.jar"]
