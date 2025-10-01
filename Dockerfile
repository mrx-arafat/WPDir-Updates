# Frontend Build
FROM node:22-alpine AS node-env
ADD web/. /web/
WORKDIR /web/
RUN npm install && npm run build

# Build Stage
FROM golang:1.24-alpine AS go-env
RUN apk add --no-cache git
ADD . /go/src/github.com/wpdirectory/wpdir
WORKDIR /go/src/github.com/wpdirectory/wpdir
RUN go mod download

# Embed Static Files Into Go
COPY --from=node-env /web /go/src/github.com/wpdirectory/wpdir/web
WORKDIR /go/src/github.com/wpdirectory/wpdir/scripts/assets/
RUN go run -tags=dev assets_generate.go

# Compile Binary
WORKDIR /go/src/github.com/wpdirectory/wpdir
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags='-w -s' -o wpdir .

# Final Stage
FROM alpine:3.21
LABEL maintainer="Peter Booker <mail@peterbooker.com>"

RUN apk --no-cache add ca-certificates tzdata
COPY --from=go-env /go/src/github.com/wpdirectory/wpdir/wpdir /usr/local/bin/wpdir
WORKDIR /etc/wpdir

ENTRYPOINT ["wpdir"]