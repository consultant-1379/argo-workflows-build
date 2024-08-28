ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles
ARG MICROCBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_micro_release/sles
# CBO PRA version
ARG CBO_VERSION

ARG GO_BUILD_ENV_IMG=ml-pipeline-go-build-env
ARG APP_VERSION

####################################################################################################

FROM ${CBO_IMAGE_URL}:${CBO_VERSION} as cbo_base
ARG CBO_VERSION

####################################################################################################

FROM ${MICROCBO_IMAGE_URL}:${CBO_VERSION} as microcbo_base
ARG CBO_VERSION

####################################################################################################
FROM $GO_BUILD_ENV_IMG:$APP_VERSION as go-build-env

####################################################################################################

FROM go-build-env as builder
ARG APP_VERSION
ARG MC_VERSION

WORKDIR /tmp

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build go install github.com/minio/mc@$MC_VERSION

####################################################################################################

FROM $MICROCBO_IMAGE_URL:$CBO_VERSION as init
ARG CBO_VERSION

ARG MC_USER_ID=8737
ARG MC_VERSION 
ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
ARG IMAGE_PRODUCT_TITLE
ARG ARGO_WORKFLOW_VERSION
ARG MC_CONTAINER_NAME=eric-aiml-pipeline-init

LABEL \
    org.opencontainers.image.title=$IMAGE_PRODUCT_TITLE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision=$RSTATE \
    com.ericsson.product-number=$IMAGE_PRODUCT_NUMBER \
    com.ericsson.product-3pp-name="minio/mc" \
    com.ericsson.product-3pp-version=${MC_VERSION}

COPY --chown=$MC_USER_ID --from=builder /go/bin/mc /bin/

RUN echo "$MC_USER_ID:!::0:::::" >>/etc/shadow \
    && echo "$MC_USER_ID:x:$MC_USER_ID:0:An Identity for $MC_CONTAINER_NAME:/nonexistent:/bin/false" >>/etc/passwd

USER $MC_USER_ID

ENTRYPOINT [ "mc" ]
