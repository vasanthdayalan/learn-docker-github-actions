# Learn Docker with Spring Boot

A small Spring Boot app (Spring Web and Actuator) used to learn Docker: building images, multi-stage builds, running and inspecting containers, and a GitHub Actions pipeline. See [REQUIREMENTS.md](REQUIREMENTS.md) for the full exercise.

## Prerequisites

- Java 21
- Maven
- Docker

## Run the app locally (without Docker)

```sh
mvn spring-boot:run
```

Stop it with `Ctrl+C`.

## Build and run with Docker

Build the single-stage image (requires the jar in `target/`, so run `mvn package -DskipTests` first):

```sh
docker build -f Dockerfile.single -t demo-app:single .
```

Build the multi-stage image (builds the jar inside Docker, no local Maven needed):

```sh
docker build -t demo-app:1.0 .
```

Compare the sizes:

```sh
docker images demo-app
```

Start the container in the background:

```sh
docker run -d -p 8080:8080 --name demo demo-app:1.0
```

If port 8080 is already in use on your machine, map a different host port, for example `-p 8081:8080`.

Check that it's healthy:

```sh
curl localhost:8080/actuator/health
```

## Stop and clean up

```sh
docker stop demo
docker rm demo
```

## Tests

```sh
mvn verify
```

## CI

GitHub Actions runs `mvn verify` on every push and pull request. On pushes, if the tests pass, it builds the image and pushes it to GitHub Container Registry as `ghcr.io/<owner>/<repo>:<commit-sha>`. See [ci.yml](.github/workflows/ci.yml).
