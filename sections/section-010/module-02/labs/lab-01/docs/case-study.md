---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Build image `localhost/ckad-probe:v1` from a Dockerfile based on Python 3.13 Alpine. Serve an index page containing `image-version=v1` on port 8000 as user 1000. Load the image into this lab cluster. Create Pod `image-probe` with container `web`, that image and `imagePullPolicy: Never`. It must run as user 1000 and serve the page. The grader checks the loaded image and running behavior; it does not inspect the local Dockerfile.
