FROM golang:1.22 AS builder

WORKDIR /workspace
COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/cnfs-csi-driver ./main.go

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /bin/cnfs-csi-driver /cnfs-csi-driver
ENTRYPOINT ["/cnfs-csi-driver"]
