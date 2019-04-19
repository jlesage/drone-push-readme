FROM alpine:3.9
RUN apk --no-cache add bash curl jq
ADD script.sh /bin/
ENTRYPOINT /bin/script.sh
