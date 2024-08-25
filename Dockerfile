# Step 1: Use a Gradle image to build the application
FROM gradle:8.2-jdk17 AS builder

# Set environment variables
ENV USE_PROFILE=local
ENV SPRING_CONFIG_ACTIVATE_ON_PROFILE=local

# Set the working directory
WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradlew ./
COPY gradle/ gradle/
COPY build.gradle settings.gradle ./

# Download dependencies (cacheable step)
RUN gradle dependencies --no-daemon

# Copy source code
COPY src/ src/

# Build the application
RUN gradle clean build --no-daemon

# Step 2: Use a smaller base image for running the application
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Expose the port the application will run on
EXPOSE 8888

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
