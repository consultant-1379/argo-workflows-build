
# Deprecated
# Argo v3.5.1 requires nodejs20 and npm20
# It also requires --openssl-legacy-provider flag to be set
# This is not supported by nodejs20 CBO rpm

ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles

# CBO PRA version
ARG CBO_VERSION

FROM ${CBO_IMAGE_URL}:${CBO_VERSION} 
ARG CBO_VERSION
ARG CBO_NODE_VERSION
ARG CBO_NPM_VERSION
ARG YARN_VERSION


# CBO ARM BASE URL
ARG ARM_URL="https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local"
ARG CBO_REPO="$ARM_URL/common_base_os/sles/$CBO_VERSION"
ARG DEV_REPO="$ARM_URL/adp-dev/adp-build-env/$CBO_VERSION"

ARG NPM_REGISTRY=https://arm.seli.gic.ericsson.se/artifactory/api/npm/npm-remote/

RUN zypper addrepo --gpgcheck-strict -f $CBO_REPO COMMON_BASE_OS_SLES_REPO  \
    && zypper addrepo --gpgcheck-strict -f $DEV_REPO ADP_DEV_BUILD_ENV_REPO \
    && zypper --gpg-auto-import-keys refresh -f \
    && zypper install -l -y wget xz git nodejs18=${CBO_NODE_VERSION}* npm18=${CBO_NPM_VERSION}* \
    && npm install -g yarn@"${YARN_VERSION}" --registry "${NPM_REGISTRY}" \
    && zypper rm -y wget xz \
    && zypper clean --all \
    && zypper rr COMMON_BASE_OS_SLES_REPO ADP_DEV_BUILD_ENV_REPO 