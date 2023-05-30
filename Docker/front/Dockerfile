# Use the official Golang 1.20-alpine image as the base image for the builder stage
FROM --platform=$TARGETPLATFORM golang:1.20-alpine as builder

# Set the build arguments for the target architecture and OS
ARG TARGETARCH
ARG TARGETOS

# Set the working directory to /workspace
WORKDIR /workspace

# Install the grpc-health-probe binary
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go install github.com/grpc-ecosystem/grpc-health-probe@latest

# Copy the go.mod and go.sum files to the container
COPY go.mod go.mod
COPY go.sum go.sum

# Download the Go module dependencies
RUN go mod download

# Copy the api/, cmd/, and internal/ directories to the container
COPY api/ api/
COPY cmd/ cmd/
COPY internal/ internal/

# Build the app binary with CGO disabled
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -o app ./cmd/uber-eats/

# Use the alpine image as the base image for the final stage
FROM --platform=$TARGETPLATFORM alpine

# Set the working directory to /
WORKDIR /

# Copy the configs/ directory to the container
COPY configs/ configs/

# Copy the app binary and grpc-health-probe binary from the builder stage to the container
COPY --from=builder /workspace/app .
COPY --from=builder /go/bin/grpc-health-probe .

# Expose ports 50050, 8050, and 9050
EXPOSE 50050
EXPOSE 8050
EXPOSE 9050

# Set the entrypoint to /app
ENTRYPOINT ["/app"]