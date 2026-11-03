FROM docker.io/library/busybox:1.37.0
WORKDIR /www
RUN echo "image-version=v1" > index.html
ENTRYPOINT ["httpd", "-f", "-h", "/www"]
CMD ["-p", "8080"]
