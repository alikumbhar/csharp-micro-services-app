# ================================
# Build stage
# ================================
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

LABEL maintainer="Ali Ahmed"
LABEL org.opencontainers.image.authors="Ali Ahmed"

WORKDIR /src

# Copy project file and restore dependencies
COPY OrderProcessingWorker.csproj .
RUN dotnet restore

# Copy source code
COPY . .

# Publish as trimmed, single-file output
RUN dotnet publish OrderProcessingWorker.csproj \
    -c Release \
    -o /publish \
    --no-restore \
    /p:PublishSingleFile=true \
    /p:PublishTrimmed=true \
    /p:InvariantGlobalization=true

# ================================
# Runtime stage (VERY SMALL IMAGE)
# ================================
FROM mcr.microsoft.com/dotnet/runtime-deps:5.0 AS final

LABEL maintainer="Ali Ahmed"
LABEL org.opencontainers.image.authors="Ali Ahmed"

WORKDIR /app

# Copy only the published binary
COPY --from=build /publish .

# Run the worker
ENTRYPOINT ["./OrderProcessingWorker"]

