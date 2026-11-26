# California Housing Estimator

A Streamlit interface for the registered California Housing champion model.
The model files are packaged with the app, so the running container does not
need access to the local MLflow database or tracking server.

## Run with Docker

For a direct deployment on the Docker host, run this from PowerShell:

```powershell
.\deploy.ps1
```

The script builds the image first, then replaces the existing
`house-container` with the updated application. It waits up to 120 seconds for
the new container's health check before reporting success. This direct
replacement can briefly interrupt requests to the app. It requires Docker
Compose v2.20 or newer for `--wait`.

Open [http://localhost:8501](http://localhost:8501). To deploy manually, run
the equivalent commands:

```powershell
docker compose build
$existing = docker container ls --all --quiet --filter "name=^/house-container$"
if ($existing) { docker container rm --force house-container }
docker compose up --detach --force-recreate --no-build --wait --wait-timeout 120
```

Stop the app with `docker compose down`.

To build and run without Compose:

```powershell
docker build -t california-housing-ui .
docker run --rm -p 8501:8501 california-housing-ui
```

## Build and validate with GitHub Actions

Two independent workflows build and validate the image:

- `.github/workflows/docker-image.yml` builds and runs the image directly.
- `.github/workflows/compose-ml-image-ci.yml` uses Docker Compose and runs
  `scripts/validate_container.sh`.

Both run on every push, pull request, and manual dispatch from the **Actions**
tab. They check the Streamlit health endpoint and page, and verify that the
packaged model can produce a finite prediction. Neither workflow publishes
the image or requires Docker Hub secrets.

## Model input features

The form accepts median income, median house age, average rooms, average
bedrooms, population, average occupancy, latitude, and longitude. The displayed
estimate is the model prediction converted from units of $100,000 to US dollars.
It is a district-level estimate, not an appraisal of an individual property.

The image contains a snapshot of the `champion` model available when it was
packaged. After promoting a new champion, update the `model` directory from
that model's MLflow artifact and rebuild the image.
