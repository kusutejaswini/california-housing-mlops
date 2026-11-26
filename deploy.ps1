$ErrorActionPreference = "Stop"

$composeFile = Join-Path $PSScriptRoot "compose.yaml"
$containerName = "house-container"
if (-not (Test-Path $composeFile)) {
    throw "Compose file not found: $composeFile"
}

& docker compose version
if ($LASTEXITCODE -ne 0) {
    throw "Docker Compose is required to deploy this application."
}

& docker compose -f $composeFile build
if ($LASTEXITCODE -ne 0) {
    throw "Image build failed. The existing container was left unchanged."
}

$existingContainerId = & docker container ls --all --quiet --filter "name=^/$containerName$"
if ($LASTEXITCODE -ne 0) {
    throw "Could not check for the existing $containerName container."
}

if ($existingContainerId) {
    & docker container rm --force $containerName
    if ($LASTEXITCODE -ne 0) {
        throw "Could not remove the existing $containerName container."
    }
}

& docker compose -f $composeFile up --detach --force-recreate --no-build --wait --wait-timeout 120
if ($LASTEXITCODE -ne 0) {
    throw "Deployment failed. Check the Docker Compose output and container logs."
}

& docker compose -f $composeFile ps
if ($LASTEXITCODE -ne 0) {
    throw "Deployment completed, but the container status could not be read."
}
