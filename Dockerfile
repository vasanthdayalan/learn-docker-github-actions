# Stage 1: build the jar with Maven and the full JDK.
# Build tools and the local Maven cache stay in this stage only.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# Copy pom.xml and download dependencies first so this layer is cached
# until pom.xml changes.
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Source changes only invalidate the layers from here down.
COPY src ./src
RUN mvn -B package -DskipTests

# Stage 2: runtime image with a JRE only and no build tools.
FROM eclipse-temurin:21-jre

# Run as an unprivileged user instead of root.
RUN groupadd --system app && useradd --system --gid app --no-create-home app

WORKDIR /app
COPY --from=build --chown=app:app /build/target/demo-1.0.0.jar app.jar

USER app
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
