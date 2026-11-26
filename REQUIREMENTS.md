# Requirements: Learn Docker with a Spring Boot App

## Goal

Learn Docker hands-on by containerizing a simple Spring Boot application and working through image building, multi-stage builds, running and inspecting containers, resource limits, and layer caching.

## Tasks

### 1. Create the application

- Create a simple Spring Boot app.
- Build tool: Maven.
- Dependencies: Spring Web, Actuator.

### 2. Single-stage image (baseline)

- Write a short Dockerfile of your own that copies the built jar into a JDK image.
- Build the image.
- Note the image size with `docker images` to use as a comparison point.

### 3. Multi-stage Dockerfile

- Write a multi-stage Dockerfile and switch to it.
- Build it with Docker and compare its size to the single-stage image.
- Be able to explain:
  - Why the multi-stage image is smaller (build tools stay in the first stage and are not copied into the final image).
  - Why the container runs as a non-root user.

### 4. Run and inspect the container

Run and inspect the image:

```sh
docker run -d -p 8080:8080 --name demo demo-app:1.0
curl localhost:8080/actuator/health
docker logs demo
docker exec -it demo sh
```

Then try resource limits and observe how the container behaves:

```sh
docker run -m 512m --cpus 1 ...
```

### 5. Layer caching

- Change one line in `src`, rebuild, and confirm the dependency step is reused from cache.
- Change `pom.xml`, rebuild, and confirm the dependency step runs again.
- Be able to explain why the Dockerfile copies `pom.xml` before the source code.

### 6. GitHub Actions

1. **Push to GitHub.** Create a repo (public is fine for the lab), keep the `.gitignore`, and push the app plus `.github/workflows/ci.yml`.

2. **Read the workflow before running it.** It has two jobs:
   - `build-test` runs `mvn verify` on every push and pull request.
   - `docker` runs only after tests pass, on pushes. It builds the image and pushes it to GitHub Container Registry (GHCR), tagged with the commit SHA.

   It uses the built-in `GITHUB_TOKEN`, so no password is stored. The `packages: write` permission allows the push. GHCR requires lowercase image names, so the workflow has a step that lowercases the name. Check the current major version of each action in its README, since they may have changed.

3. **Break it on purpose.** Make a test fail and confirm the `docker` job does not run. Fix the test and confirm the pipeline passes. This demonstrates the "gate" idea.

4. **Simulate deploy.** Pull the image GitHub built and run it locally:

   ```sh
   docker pull ghcr.io/<your-user>/<repo>:<sha>
   docker run -d -p 8080:8080 ghcr.io/<your-user>/<repo>:<sha>
   ```

   Packages are private by default. Log in to GHCR or make the package public. On Friday, the same image can be used in the local kind cluster.

Be able to explain:
- The difference between CI and CD
- What triggers a workflow
- Jobs vs. steps
- Secrets and permissions
- Why tests gate the image build
- Tagging by commit SHA, so you can trace and roll back
- How to extend the workflow to deploy, using `kubectl set image` or GitOps with Argo CD

## Concepts to Be Able to Explain

- Image vs. container
- Layers and caching
- Multi-stage builds
- Why not to use the `latest` tag in production
- Ports
- Volumes and networks
- Health checks
