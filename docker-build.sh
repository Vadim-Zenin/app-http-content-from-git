GIT_BRANCH_ARG="local"
GIT_COMMIT="none"
DOCKER_SERVICE_FILE_PATH="./Dockerfile"
DOCKER_BILD_NO_CACHE="${DOCKER_BILD_NO_CACHE:-true}"
source .env
cmd="docker build --no-cache=${DOCKER_BILD_NO_CACHE} --compress --rm -t ${PROJECT_NAME}:${ARTIFACT_VERSION} \
--build-arg ARG_SOURCE_DOCKER_VERSION=${SOURCE_DOCKER_VERSION} \
--build-arg ARG_APPL_NAME=${PROJECT_NAME} \
--build-arg ARG_DOCKER_TAG=${ARTIFACT_VERSION} \
--build-arg ARG_GIT_BRANCH=${GIT_BRANCH_ARG} \
--build-arg ARG_COMMIT_HASH=${GIT_COMMIT} \
-f ${DOCKER_SERVICE_FILE_PATH} ."

printf "INFO: Executing:" "$cmd\n"
/bin/bash -c "$cmd"
