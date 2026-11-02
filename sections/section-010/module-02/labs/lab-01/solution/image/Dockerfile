FROM docker.io/library/python:3.13-alpine
WORKDIR /site
COPY index.html .
USER 1000:1000
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]
