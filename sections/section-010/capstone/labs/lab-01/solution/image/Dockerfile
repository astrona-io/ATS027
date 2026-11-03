FROM docker.io/library/python:3.13-alpine AS build
WORKDIR /src
COPY catalog.txt build-notes.txt render.sh ./
RUN sh render.sh

FROM docker.io/library/busybox:1.37.0
RUN adduser -D -u 10001 scout
WORKDIR /www
COPY --from=build /out/index.html .
USER 10001
EXPOSE 8080
ENTRYPOINT ["httpd", "-f", "-h", "/www"]
CMD ["-p", "8080"]
