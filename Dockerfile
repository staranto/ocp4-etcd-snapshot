FROM alpine

RUN apk add rsync

ENTRYPOINT ["top"]
