# STAGE 1: Build binaries
FROM golang:1 as build
WORKDIR /go/src/
COPY . .
RUN go mod vendor
RUN go install golang.org/x/tools/cmd/goimports@latest
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.52.2

RUN make

# STAGE 2: Build final image with minimal content
FROM alpine:3
RUN apk --no-cache add libc6-compat gcompat
RUN ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2
COPY --from=build /go/src/target/openldap_exporter /openldap_exporter

# Environment Variables
ENV PROM_ADDR=":9330"
ENV METRICS_PATH="/metrics"
ENV LDAP_NET="tcp"
ENV LDAP_ADDR="localhost:389"
ENV LDAP_USER=""
ENV LDAP_PASS=""
ENV INTERVAL="30s"
ENV WEB_CFG_FILE=""
ENV JSON_LOG="false"

EXPOSE 9330
ENTRYPOINT [ "/openldap_exporter" ]