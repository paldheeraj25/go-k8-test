FROM golang:latest

WORKDIR /app

COPY simple-service .

RUN go build -o main

EXPOSE 8000
CMD ["./main"]
