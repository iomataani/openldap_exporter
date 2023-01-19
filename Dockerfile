# STAGE 1: Build binaries
FROM golang:latest as build
WORKDIR /go/src/
COPY . .
RUN go mod tidy
RUN go mod vendor
RUN make

# STAGE 2: Build final image with minimal content
FROM alpine
RUN apk --no-cache add libc6-compat
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