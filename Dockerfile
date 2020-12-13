ARG ARG_SOURCE_DOCKER_VERSION

FROM nginx:${ARG_SOURCE_DOCKER_VERSION}

ARG ARG_APPL_NAME
ARG ARG_DOCKER_TAG
ARG ARG_GIT_URL
ARG ARG_GIT_BRANCH
ARG ARG_COMMIT_HASH
ARG ARG_SERVICE_PORT
ARG ARG_EXPOSE_PORT

LABEL org.label-schema.maintainer="vadim Zenin" \
  org.label-schema.docker.schema-version="1.0" \
  org.label-schema.name="${ARG_APPL_NAME}" \
  org.label-schema.version="${ARG_DOCKER_TAG}" \
  org.label-schema.description="${ARG_APPL_NAME} docker image" \
  org.label-schema.docker.cmd="docker run -d --rm --name ${PROJECT_NAME} --hostname ${PROJECT_NAME} -p ${ARG_EXPOSE_PORT}:${ARG_SERVICE_PORT} ${PROJECT_NAME}:${ARTIFACT_VERSION}" 

ENV SERVICE_NAME ${ARG_APPL_NAME}
ENV SERVICE_HOSTNAME ${SERVICE_NAME}
ENV SERVICE_PORT ${ARG_SERVICE_PORT}
ENV EXPOSE_PORT ${ARG_EXPOSE_PORT}
ENV APP_HOME /usr/share/nginx

ENV DOCKER_TAG ${ARG_DOCKER_TAG}
ENV GIT_BRANCH ${ARG_GIT_BRANCH}
ENV COMMIT_HASH ${ARG_COMMIT_HASH}
ENV ENV_NAME dev
ENV ENV_SPACE local

RUN apk upgrade --update --no-cache && \
	apk add --no-cache wget git && \
	rm -rf /var/lib/apt/lists/*
RUN	rm -fr ${APP_HOME}/html && \
	cd /tmp/ && \
	git clone --single-branch --depth 1 ${ARG_GIT_URL}/${ARG_APPL_NAME}.git && \
	mv /tmp/${ARG_APPL_NAME}/html ${APP_HOME} && \
	rm -fr /tmp/${ARG_APPL_NAME} && \
	ls -l ${APP_HOME}/html/*

COPY ./html/info.* ${APP_HOME}/html/

WORKDIR ${APP_HOME}

HEALTHCHECK --interval=20s --timeout=10s CMD wget --quiet --tries=1 --spider http://localhost:${SERVICE_PORT}/monitor.html || exit 4

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE ${EXPOSE_PORT}

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
