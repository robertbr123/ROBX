FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache build-base git

COPY backend/go.mod ./

RUN go mod download

COPY backend/internal ./internal
COPY backend/main.go ./main.go

RUN CGO_ENABLED=1 GOOS=linux go build -ldflags "-s -w" -o robx ./main.go

FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/robx ./robx

ENV ROBX_SERVER_PORT=8000

EXPOSE 8000

CMD ["./robx"]
