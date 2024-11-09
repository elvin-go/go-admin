FROM golang:1.23 AS builder

WORKDIR /build

ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ENV TZ=Asia/Yerevan
ENV CONTAINER_TIMEZONE=Asia/Yerevan

COPY go.mod .
COPY go.sum .
RUN go mod tidy && go mod download

COPY . .
RUN GOOS=linux go build -a -o go-admin-team .

FROM alpine:3.10 AS final

WORKDIR /app
COPY --from=builder /build/go-admin-team /app/
COPY --from=builder /build/config /app/config

ENTRYPOINT ["/app/go-admin-team", "server" ,"-c", "/app/config/settings.yml"]