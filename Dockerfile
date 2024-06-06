FROM alpine:latest

RUN apk update \
	&& apk upgrade \
	&& apk add --no-cache rsync openssh-client \
	&& rm -rf /var/cache/apk/*

COPY entrypoint.sh /script/entrypoint.sh

RUN chmod +x /script/entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/bin/sh", "/script/entrypoint.sh"]

