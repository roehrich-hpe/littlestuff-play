FROM alpine as certs
RUN apk update && apk add ca-certificates && apk add curl

FROM busybox
COPY --from=certs /etc/ssl/certs /etc/ssl/certs
COPY --from=certs /usr/bin/curl /usr/bin/curl


