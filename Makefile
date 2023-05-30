redeployed-at:=$(shell date +%s)

# This target installs the necessary tools for the project
.PHONY: init
init:
    go install google.golang.org/protobuf/cmd/protoc-gen-go
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
    go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
    go install github.com/golang/mock/mockgen@latest
    @echo "Installing protoc-gen-validate (PGV) can currently only be done from source. See: https://github.com/envoyproxy/protoc-gen-validate#installation"

# This target updates the dependencies of the project
.PHONY: update
update:
    go get -u ./...
    go mod tidy

# This target generates Go code from the protobuf files
.PHONY: protoc
protoc:
    for file in $$(find api -name '*.proto'); do \
        protoc \
        -I $$(dirname $$file) \
        -I ./third_party \
        --go_out=:$$(dirname $$file) --go_opt=paths=source_relative \
        --go-grpc_out=:$$(dirname $$file) --go-grpc_opt=paths=source_relative \
        --validate_out="lang=go:$$(dirname $$file)" --validate_opt=paths=source_relative \
        --grpc-gateway_out=:$$(dirname $$file) --grpc-gateway_opt=paths=source_relative \
        $$file; \
    done

# This target runs linters on the project
.PHONY: lint
lint:
    golangci-lint run --timeout=5m

# This target runs tests on the project
.PHONY: test
test:
    go test -cover -race -covermode=atomic -coverprofile=coverage.txt ./...

# This target builds Docker images for the project
.PHONY: docker-build
docker-build:
    docker build -t uber-eats/uber-eats-server:latest -f ./docker/uber-eats/Dockerfile .
    docker build -t uber-eats/user-server:latest -f ./docker/user/Dockerfile .
    docker build -t uber-eats/auth-server:latest -f ./docker/auth/Dockerfile .
    docker build -t uber-eats/restaurant-server:latest -f ./docker/restaurant/Dockerfile .
    docker build -t uber-eats/order-server:latest -f ./docker/order/Dockerfile .
    docker build -t uber-eats/payment-server:latest -f ./docker/payment/Dockerfile .
    docker build -t uber-eats/delivery-server:latest -f ./docker/delivery/Dockerfile .

# This target deploys the project to Kubernetes
.PHONY: kube-deploy
kube-deploy:
    kubectl apply -f ./deployments/
    kubectl apply -f ./deployments/uber-eats/
    kubectl apply -f ./deployments/user/
    kubectl apply -f ./deployments/auth/
    kubectl apply -f ./deployments/restaurant/
    kubectl apply -f ./deployments/order/
    kubectl apply -f ./deployments/payment/
    kubectl apply -f ./deployments/delivery/
    kubectl apply -f ./deployments/addons/

# This target deletes the project from Kubernetes
.PHONY: kube-delete
kube-delete:
    kubectl delete -f ./deployments/
    kubectl delete -f ./deployments/uber-eats/
    kubectl delete -f ./deployments/user/
    kubectl delete -f ./deployments/auth/
    kubectl delete -f ./deployments/restaurant/
    kubectl delete -f ./deployments/order/
    kubectl delete -f ./deployments/payment/
    kubectl delete -f ./deployments/delivery/
    kubectl delete -f ./deployments/addons/