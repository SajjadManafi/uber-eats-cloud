# Use the latest version of the Dockerfile syntax
# and the golang:1.20-alpine base image as the builder stage
FROM --platform=$TARGETPLATFORM golang:1.20-alpine as builder

# Define the build arguments for the target architecture and OS
ARG TARGETARCH
ARG TARGETOS

# Set the working directory to /workspace
WORKDIR /workspace

# Install the latest version of the grpc-health-probe binary
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go install github.com/grpc-ecosystem/grpc-health-probe@latest

# Copy the go.mod and go.sum files to the working directory
COPY go.mod go.mod
COPY go.sum go.sum

# Download the Go module dependencies
RUN go mod download

# Copy the api/, cmd/, and internal/ directories to the working directory
COPY api/ api/
COPY cmd/ cmd/
COPY internal/ internal/

# Build the app binary for the target architecture and OS
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -o app ./cmd/user/

# Use the alpine base image for the final stage
FROM --platform=$TARGETPLATFORM alpine

# Set the working directory to /
WORKDIR /

# Copy the configs/ directory to the working directory
COPY configs/ configs/

# Copy the app binary and grpc-health-probe binary from the builder stage
COPY --from=builder /workspace/app .
COPY --from=builder /go/bin/grpc-health-probe .

# Expose ports 50051, 8051, and 9051
EXPOSE 50051
EXPOSE 8051
EXPOSE 9051

# Set the entrypoint to /app
ENTRYPOINT ["/app"]