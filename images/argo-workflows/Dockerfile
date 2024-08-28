ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles
ARG MICROCBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_micro_release/sles
# CBO PRA version
ARG CBO_VERSION
ARG NODE_BASE_IMAGE=armdockerhub.rnd.ericsson.se/node:20-alpine
ARG NODE_BUILD_ENV_IMG=ml-pipeline-node-build-env
ARG GO_BUILD_ENV_IMG=ml-pipeline-go-build-env
ARG APP_VERSION

ARG EXEC_USER_ID
ARG CLI_USER_ID 
ARG CONTROLLER_USER_ID

####################################################################################################

FROM ${CBO_IMAGE_URL}:${CBO_VERSION} as cbo_base
ARG CBO_VERSION

####################################################################################################

FROM ${MICROCBO_IMAGE_URL}:${CBO_VERSION} as microcbo_base
ARG CBO_VERSION

####################################################################################################

FROM ${NODE_BASE_IMAGE} as ml-pipeline-node-build-env
RUN apk update && apk add --no-cache git 

###################################################################################################
FROM ${GO_BUILD_ENV_IMG}:${APP_VERSION} as go-build-env

####################################################################################################

FROM go-build-env as go-builder
ARG APP_VERSION

WORKDIR /tmp

# https://blog.container-solutions.com/faster-builds-in-docker-with-go-1-11
WORKDIR /go/src/github.com/argoproj/argo-workflows
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

####################################################################################################

FROM ml-pipeline-node-build-env as argo-ui
ARG APP_VERSION

WORKDIR /

COPY ui/package.json ui/yarn.lock ui/

RUN --mount=type=cache,target=/root/.yarn \
  YARN_CACHE_FOLDER=/root/.yarn JOBS=max \
  yarn --cwd ui install --network-timeout 1000000

COPY ui ui
COPY api api

RUN --mount=type=cache,target=/root/.yarn \
  YARN_CACHE_FOLDER=/root/.yarn JOBS=max \
  NODE_OPTIONS="--openssl-legacy-provider --max-old-space-size=2048" JOBS=max yarn --cwd ui build

####################################################################################################

FROM go-builder as argoexec-build

ARG GIT_COMMIT
ARG GIT_TAG
ARG GIT_TREE_STATE

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build make dist/argoexec GIT_COMMIT=${GIT_COMMIT} GIT_TAG=${GIT_TAG} GIT_TREE_STATE=${GIT_TREE_STATE}

####################################################################################################

FROM go-builder as workflow-controller-build
ARG GIT_COMMIT
ARG GIT_TAG
ARG GIT_TREE_STATE

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build make dist/workflow-controller GIT_COMMIT=${GIT_COMMIT} GIT_TAG=${GIT_TAG} GIT_TREE_STATE=${GIT_TREE_STATE}

####################################################################################################

FROM go-builder as argocli-build
ARG GIT_COMMIT
ARG GIT_TAG
ARG GIT_TREE_STATE

RUN mkdir -p ui/dist
COPY --from=argo-ui ui/dist/app ui/dist/app

# update timestamp so that `make` doesn't try to rebuild this -- it was already built in the previous stage
RUN touch ui/dist/app/index.html

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build STATIC_FILES=true make dist/argo GIT_COMMIT=${GIT_COMMIT} GIT_TAG=${GIT_TAG} GIT_TREE_STATE=${GIT_TREE_STATE}


####################################################################################################

FROM microcbo_base as argoexec

ARG EXEC_USER_ID=8737
ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
ARG IMAGE_PRODUCT_TITLE
ARG ARGO_WORKFLOW_VERSION
ARG EXEC_CONTAINER_NAME=eric-aiml-pipeline-argoexec

LABEL \
    org.opencontainers.image.title=$IMAGE_PRODUCT_TITLE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision=$RSTATE \
    com.ericsson.product-number=$IMAGE_PRODUCT_NUMBER \
    com.ericsson.product-3pp-name="argo-workflows" \
    com.ericsson.product-3pp-version=${ARGO_WORKFLOW_VERSION}

COPY --from=argoexec-build /go/src/github.com/argoproj/argo-workflows/dist/argoexec /bin/
COPY --from=argoexec-build /etc/mime.types /etc/mime.types
COPY hack/ssh_known_hosts /etc/ssh/
COPY hack/nsswitch.conf /etc/
COPY --chown=$EXEC_USER_ID --from=go-builder /opt/stdout-redirect /opt/stdout-redirect

RUN echo "$EXEC_USER_ID:!::0:::::" >>/etc/shadow \
    && echo "$EXEC_USER_ID:x:$EXEC_USER_ID:0:An Identity for $EXEC_CONTAINER_NAME:/nonexistent:/bin/false" >>/etc/passwd

USER $EXEC_USER_ID

ENTRYPOINT [ "argoexec" ]

####################################################################################################

FROM microcbo_base as workflow-controller

ARG CONTROLLER_USER_ID=8737 
ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
ARG IMAGE_PRODUCT_TITLE
ARG ARGO_WORKFLOW_VERSION
ARG CONTROLLER_CONTAINER_NAME=eric-aiml-pipeline-workflow-controller

LABEL \
    org.opencontainers.image.title=$IMAGE_PRODUCT_TITLE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision=$RSTATE \
    com.ericsson.product-number=$IMAGE_PRODUCT_NUMBER \
    com.ericsson.product-3pp-name="argo-workflows" \
    com.ericsson.product-3pp-version=${ARGO_WORKFLOW_VERSION}

RUN echo "$CONTROLLER_USER_ID:!::0:::::" >>/etc/shadow \
    && echo "$CONTROLLER_USER_ID:x:$CONTROLLER_USER_ID:0:An Identity for $CONTROLLER_CONTAINER_NAME:/nonexistent:/bin/false" >>/etc/passwd

USER $CONTROLLER_USER_ID

COPY hack/ssh_known_hosts /etc/ssh/
COPY hack/nsswitch.conf /etc/
COPY --chown=$CONTROLLER_USER_ID --from=workflow-controller-build /go/src/github.com/argoproj/argo-workflows/dist/workflow-controller /bin/
COPY --chown=$CONTROLLER_USER_ID --from=go-builder /opt/stdout-redirect /opt/stdout-redirect

ENTRYPOINT [ "workflow-controller" ]

####################################################################################################

FROM microcbo_base as argocli

ARG CLI_USER_ID=8737 
ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
ARG IMAGE_PRODUCT_TITLE
ARG ARGO_WORKFLOW_VERSION
ARG CLI_CONTAINER_NAME=eric-aiml-pipeline-argocli

LABEL \
    org.opencontainers.image.title=$IMAGE_PRODUCT_TITLE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision=$RSTATE \
    com.ericsson.product-number=$IMAGE_PRODUCT_NUMBER \
    com.ericsson.product-3pp-name="argo-workflows" \
    com.ericsson.product-3pp-version=${ARGO_WORKFLOW_VERSION}

RUN echo "$CLI_USER_ID:!::0:::::" >>/etc/shadow \
    && echo "$CLI_USER_ID:x:$CLI_USER_ID:0:An Identity for $CLI_CONTAINER_NAME:/nonexistent:/bin/false" >>/etc/passwd

USER $CLI_USER_ID

WORKDIR /home/argo

COPY hack/ssh_known_hosts /etc/ssh/
COPY hack/nsswitch.conf /etc/
COPY --chown=$CLI_USER_ID --from=argocli-build /go/src/github.com/argoproj/argo-workflows/dist/argo /bin/
COPY --chown=$CLI_USER_ID --from=go-builder /opt/stdout-redirect /opt/stdout-redirect

ENTRYPOINT [ "argo" ]

####################################################################################################