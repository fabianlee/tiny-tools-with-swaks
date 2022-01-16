FROM giantswarm/tiny-tools:3.12

# latest certs
RUN apk --no-cache add \
  swaks --repository=http://dl-3.alpinelinux.org/alpine/edge/testing

#ENTRYPOINT ["/bin/ash"]
