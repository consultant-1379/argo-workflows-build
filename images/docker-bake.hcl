group "default" {
    targets = [ "workflow-controller", "workflow-executor", "argo-server", "init" ]
}

#################################################################################################################################################################
# Common Variables 
#################################################################################################################################################################
variable "CBO_VERSION" {
    default = "notset"
}

variable "VERSION" {
    default = "notset"
}

variable "BUILD_DATE" {
    default = "notset"
}

variable "COMMIT" {
    default = "notset"
}

variable "RSTATE" {
    default = "notset"
}

variable "PWD" {
    default = "notset"
}

variable "ARGO_WORKFLOW_VERSION" {
    default = "notset"
}

variable "ARGO_WORKFLOW_BUILD_CONTEXT" {
    default = "notset"
}

variable "GIT_COMMIT" {
    default = "notset"
}

variable "GIT_TAG" {
    default = "notset"
}

variable "GIT_TREE_STATE" {
    default = "notset"
}

#################################################################################################################################################################
# GO Build Environment
#################################################################################################################################################################

target "go-build-env" {
    context = "${PWD}/build/"
    dockerfile = "${PWD}/images/build_env/go/Dockerfile"
    tags = ["go-build-env:${VERSION}"]
    args = {
        VERSION = VERSION
        CBO_VERSION = CBO_VERSION
    }
}

#################################################################################################################################################################
# NPM Build Environment
# deprecated
#################################################################################################################################################################

variable "NODE_VERSION" {
    default = "notset"
}

variable "NPM_VERSION" {
    default = "notset"
}

variable "YARN_VERSION" {
    default = "notset"
}

target "node-build-env" {
    context = "images/build_env/node"
    dockerfile = "Dockerfile"
    tags = ["go-build-env:${VERSION}"]
    args = {
        VERSION = VERSION
        CBO_VERSION = CBO_VERSION
        CBO_NODE_VERSION = NODE_VERSION
        CBO_NPM_VERSION = NPM_VERSION
        CBO_YARN_VERSION = YARN_VERSION
    }
}

#################################################################################################################################################################
# Argo Workflow Controller
#################################################################################################################################################################

variable "WORKFLOW_CONTROLLER_IMAGE_NAME" {
    default = "notset"
}

variable "WORKFLOW_CONTROLLER_IMAGE_NAME_INTERNAL" {
    default = "notset"
}

variable "WORKFLOW_CONTROLLER_IMAGE_PRODUCT_NUMBER" {
    default = "notset"
}

variable "WORKFLOW_CONTROLLER_IMAGE_PRODUCT_TITLE" {
    default = "notset"
}

variable "WORKFLOW_CONTROLLER_USER_ID" {
    default = "notset"
}

target "workflow-controller" {
    context = "${ARGO_WORKFLOW_BUILD_CONTEXT}"
    contexts = {
        go-build-env="target:go-build-env"
    }
    dockerfile = "${PWD}/images/argo-workflows/Dockerfile"
    target = "workflow-controller"
    tags = ["${WORKFLOW_CONTROLLER_IMAGE_NAME_INTERNAL}", "${WORKFLOW_CONTROLLER_IMAGE_NAME}"]
    args = {
        GIT_COMMIT = GIT_COMMIT
        GIT_TAG = GIT_TAG
        GIT_TREE_STATE = GIT_TREE_STATE
        CBO_VERSION = CBO_VERSION
        BUILD_DATE = BUILD_DATE
        COMMIT = COMMIT
        APP_VERSION = VERSION
        RSTATE = RSTATE
        IMAGE_PRODUCT_NUMBER = WORKFLOW_CONTROLLER_IMAGE_PRODUCT_NUMBER
        IMAGE_PRODUCT_TITLE = WORKFLOW_CONTROLLER_IMAGE_PRODUCT_TITLE
        ARGO_WORKFLOW_VERSION  = ARGO_WORKFLOW_VERSION
        CONTROLLER_USER_ID = WORKFLOW_CONTROLLER_USER_ID
    }
}

#################################################################################################################################################################
# Argo Workflow Executor
#################################################################################################################################################################

variable "WORKFLOW_EXECUTOR_IMAGE_NAME" {
    default = "notset"
}

variable "WORKFLOW_EXECUTOR_IMAGE_NAME_INTERNAL" {
    default = "notset"
}

variable "WORKFLOW_EXECUTOR_IMAGE_PRODUCT_NUMBER" {
    default = "notset"
}

variable "WORKFLOW_EXECUTOR_IMAGE_PRODUCT_TITLE" {
    default = "notset"
}

variable "WORKFLOW_EXECUTOR_USER_ID" {
    default = "notset"
}

target "workflow-executor" {
    context = "${ARGO_WORKFLOW_BUILD_CONTEXT}"
    contexts = {
        go-build-env="target:go-build-env"
    }
    dockerfile = "${PWD}/images/argo-workflows/Dockerfile"
    target = "argoexec"
    tags = ["${WORKFLOW_EXECUTOR_IMAGE_NAME_INTERNAL}", "${WORKFLOW_EXECUTOR_IMAGE_NAME}"]
    args = {
        GIT_COMMIT = GIT_COMMIT
        GIT_TAG = GIT_TAG
        GIT_TREE_STATE = GIT_TREE_STATE
        CBO_VERSION = CBO_VERSION
        BUILD_DATE = BUILD_DATE
        COMMIT = COMMIT
        APP_VERSION = VERSION
        RSTATE = RSTATE
        IMAGE_PRODUCT_NUMBER = WORKFLOW_EXECUTOR_IMAGE_PRODUCT_NUMBER
        IMAGE_PRODUCT_TITLE = WORKFLOW_EXECUTOR_IMAGE_PRODUCT_TITLE
        ARGO_WORKFLOW_VERSION  = ARGO_WORKFLOW_VERSION
        EXEC_USER_ID = WORKFLOW_EXECUTOR_USER_ID
    }
}

#################################################################################################################################################################
# Argo Workflow CLI (Server Image)
#################################################################################################################################################################

variable "ARGO_CLI_IMAGE_NAME" {
    default = "notset"
}

variable "ARGO_CLI_IMAGE_NAME_INTERNAL" {
    default = "notset"
}

variable "ARGO_CLI_IMAGE_PRODUCT_NUMBER" {
    default = "notset"
}

variable "ARGO_CLI_IMAGE_PRODUCT_TITLE" {
    default = "notset"
}

variable "ARGO_CLI_USER_ID" {
    default = "notset"
}

target "argo-server" {
    context = "${ARGO_WORKFLOW_BUILD_CONTEXT}"
    contexts = {
        go-build-env="target:go-build-env"
    }
    dockerfile = "${PWD}/images/argo-workflows/Dockerfile"
    target = "argocli"
    tags = ["${ARGO_CLI_IMAGE_NAME_INTERNAL}", "${ARGO_CLI_IMAGE_NAME}"]
    args = {
        GIT_COMMIT = GIT_COMMIT
        GIT_TAG = GIT_TAG
        GIT_TREE_STATE = GIT_TREE_STATE
        CBO_VERSION = CBO_VERSION
        BUILD_DATE = BUILD_DATE
        COMMIT = COMMIT
        APP_VERSION = VERSION
        RSTATE = RSTATE
        IMAGE_PRODUCT_NUMBER = ARGO_CLI_IMAGE_PRODUCT_NUMBER
        IMAGE_PRODUCT_TITLE = ARGO_CLI_IMAGE_PRODUCT_TITLE
        ARGO_WORKFLOW_VERSION  = ARGO_WORKFLOW_VERSION
        CLI_USER_ID = ARGO_CLI_USER_ID
    }
}

#################################################################################################################################################################
# ML Pipeline Init Image
#################################################################################################################################################################

variable "ML_PIPELINE_INIT_IMAGE_NAME" {
    default = "notset"
}

variable "ML_PIPELINE_INIT_IMAGE_NAME_INTERNAL" {
    default = "notset"
}

variable "ML_PIPELINE_INIT_IMAGE_PRODUCT_NUMBER" {
    default = "notset"
}

variable "ML_PIPELINE_INIT_IMAGE_PRODUCT_TITLE" {
    default = "notset"
}

variable "ML_PIPELINE_INIT_USER_ID" {
    default = "notset"
}

variable "MC_VERSION" {
    default = "notset"
}

target "init" {
    context = "${PWD}/images/init"
    contexts = {
        go-build-env="target:go-build-env"
    }
    dockerfile = "Dockerfile"
    tags = ["${ML_PIPELINE_INIT_IMAGE_NAME_INTERNAL}", "${ML_PIPELINE_INIT_IMAGE_NAME}"]
    args = {
        CBO_VERSION = CBO_VERSION
        MC_USER_ID = ML_PIPELINE_INIT_USER_ID
        BUILD_DATE = BUILD_DATE
        APP_VERSION = VERSION
        COMMIT = COMMIT
        RSTATE = RSTATE
        IMAGE_PRODUCT_NUMBER = ML_PIPELINE_INIT_IMAGE_PRODUCT_NUMBER
        IMAGE_PRODUCT_TITLE = ML_PIPELINE_INIT_IMAGE_PRODUCT_TITLE
        MC_VERSION = MC_VERSION
    }
}

#################################################################################################################################################################