---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Building An Image With A Clear Runtime Contract

A container image is a packaged filesystem and configuration used to start a container process. Building an image turns source files and dependencies into that package. The build must produce an artifact that runs with the command, files, architecture and permissions expected by the application. A successful build does not establish that the resulting process serves requests correctly.

## Reading The Build Definition

A Dockerfile is a sequence of instructions understood by a compatible image builder. `FROM` selects the base image. `WORKDIR` selects the working directory for following instructions. `COPY` transfers files from the build context, which is the set of files made available to the builder. `RUN` executes a build-time command whose filesystem changes can become image content.

The build context matters as much as the file. A source file outside that context cannot be copied through an ordinary context-relative path. An ignore file can exclude temporary output, local credentials and dependency folders that should not enter the build. Excluding required source accidentally is a different failure from using an incorrect path inside the image.

For a `scout` application, imagine a build stage that compiles source and a runtime stage that receives only the compiled program and its necessary libraries. A multi-stage build uses separate stages to keep compilers and intermediate artifacts out of the final image. Copying a program into a smaller runtime image works only when its operating-system and library requirements are also satisfied.

## Separate Build Time From Startup

`RUN` happens during the build. `CMD` supplies a default startup command or arguments, and `ENTRYPOINT` identifies the configured entry process. The exact combination depends on the instruction forms and on overrides made when the container starts. A build instruction that starts a web server does not make that server remain running in containers created later.

The executable form of an entry command identifies the process and arguments directly. A shell form introduces a shell with its own parsing and signal behavior. The application must receive termination signals and shut down within the allowed time. A shell wrapper that fails to forward signals can leave shutdown behavior different from the author's intention.

Kubernetes `command` and `args` override image startup configuration according to their respective roles. They are not ordinary shell lines unless a shell is explicitly selected. A command argument containing a pipe does not automatically create a pipeline. Diagnose the effective process invocation before concluding that the image is broken.

## Identity, Ownership And Dependencies

A `USER` instruction selects the default process identity inside the container. File ownership and access permissions must allow that identity to read its executable and configuration and write only where necessary. Kubernetes security settings can choose another identity, so an image that runs as its default user might fail under a required non-root identity.

An image can declare a port with `EXPOSE`, but that declaration does not create a Kubernetes Service, publish a host port or change the address on which the application listens. A web process listening only on the container's loopback address remains inaccessible through ordinary Pod-address traffic even when a port is declared in the image.

Architecture is another part of the contract. A program built for one processor architecture cannot be assumed to run on every node. A multi-platform image reference may select a compatible artifact, but each referenced artifact must still contain a usable program and its required dependencies.

## Reasoning About A Failed Modification

Suppose a team switches the base image to reduce size. The build succeeds, but startup fails because a shared library is absent. The relevant evidence concerns the executable and runtime files, rather than Service labels or replica count. A corrected runtime stage includes compatible dependencies or a program built to avoid that requirement.

If a new image is pushed under an existing mutable tag, the tag alone does not prove which bytes a running container uses. Record an immutable digest when exact artifact identity matters. Build the artifact first, identify it clearly, and distinguish changes to source, build instructions and deployment configuration when reviewing a release.

## Common pitfalls

> [!WARNING]
> Build success, an exposed port and a smaller base image do not prove application startup or reachability. Check the runtime command, compatible files, process identity and exact artifact before diagnosing higher-level networking.
