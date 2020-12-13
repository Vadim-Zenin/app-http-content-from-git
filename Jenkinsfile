#!/usr/bin/env groovy

def PROJECT_NAME = "app-http-content-from-git"
def MAJOR_RELEASE_NUMBER = '0'
def MINOR_RELEASE_NUMBER = '0'
def DOCKER_SERVICE_FILE_PATH = 'Dockerfile'
def SOURCE_DOCKER_VERSION = '1-alpine'
def AWS_ECR_ACCOUNT_ID = "123456789011"
def AWS_DEFAULT_REGION = "eu-west-1"
def AWS_ECR_REPOSITORY = "${AWS_ECR_ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com"
def ARTIFACT_VERSION
def FEATURE_BRANCH_PUBLISH_KEYWORD = "publish=true"
def FEATURE_BRANCH_PUBLISH = false
def GIT_BRANCH_ARG
def GIT_URL_ARG ="https://github.com/Vadim-Zenin"

pipeline {
	agent {
		ecs {
			inheritFrom 'jenkins-agent-custom'
		}
	}
	environment {
		PROJECT_NAME = "${PROJECT_NAME}"
		AWS_DEFAULT_REGION = "${AWS_DEFAULT_REGION}"
		AWS_ECR_ACCOUNT_ID = "${AWS_ECR_ACCOUNT_ID}"
		AWS_ECR_REPOSITORY = "${AWS_ECR_REPOSITORY}"
	}
	options {
		gitLabConnection('gitlab')
		gitlabBuilds(builds: ['Checkout Code', 'Build App', 'Build Docker', 'Publish Docker'])
		disableConcurrentBuilds()
		timeout(time: 15, unit: 'MINUTES')
		buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
	}
	stages {
		stage("Checkout Code") {
			steps {
				gitlabCommitStatus(name: 'Checkout Code') {
					checkout scm
					script {
						echo "INFO: Jenkins Agent instance private IP address"
						sh "curl -s http://169.254.169.254/latest/meta-data/local-ipv4"
						sh "free -mh"
						sh "grep 'cpu cores' /proc/cpuinfo | uniq"
						echo "Checking branch and version"
						ARTIFACT_VERSION = "${MAJOR_RELEASE_NUMBER}.${MINOR_RELEASE_NUMBER}.${env.BUILD_NUMBER}"
						if (env.BRANCH_NAME == "master"){
							GIT_BRANCH_ARG = env.BRANCH_NAME
						} else {
							def FEATURE_PREFIX = (env.BRANCH_NAME =~ /^(TEST)-(\d*)(.*)/)[0][0]
							if(FEATURE_PREFIX?.trim()) {
								ARTIFACT_VERSION = "${FEATURE_PREFIX}.${MAJOR_RELEASE_NUMBER}.${MINOR_RELEASE_NUMBER}.${env.BUILD_NUMBER}"
								GIT_BRANCH_ARG = FEATURE_PREFIX
							}
							def GIT_COMMIT_MSG = sh(script: "git log -n 1 --format=%B ${GIT_COMMIT}", returnStdout: true).trim()
							if (GIT_COMMIT_MSG.contains(FEATURE_BRANCH_PUBLISH_KEYWORD)) {
								FEATURE_BRANCH_PUBLISH = true
							}
						}
					}
				}
			}
		}
		stage('Build App') {
			environment {
				ARTIFACT_VERSION = "${ARTIFACT_VERSION}"
				ARTIFACT_NAME = "${ARTIFACT_NAME}"
			}
			steps {
				gitlabCommitStatus(name: 'Build App') {
					script {
						echo "INFO: Build App"
						echo "INFO: Creating info.json"
						sh """#!/usr/bin/env /bin/bash
						if [[ ! -f "./html/index.html" ]]; then
							printf "ERROR: ./html/index.html does not exists.\n"
							exit 8
						fi
						eval "cat <<EOF
\$(<./templates/info.json)
EOF
" 2> /dev/null | tee ./html/info.json
						"""
						echo "INFO: ./html/info.json"
						sh "ls -l ./html/info.json"
						sh "cat ./html/info.json"
						sh "ls -l ./html/"
					}
				}
			}
		}
		stage("Build Docker") {
			steps {
				gitlabCommitStatus(name: 'Build Docker') {
					script {
						echo "Build docker ${PROJECT_NAME}:${ARTIFACT_VERSION}"
						sh "docker build --no-cache=true --compress --rm -t ${PROJECT_NAME}:${ARTIFACT_VERSION} \
							--build-arg ARG_SOURCE_DOCKER_VERSION=${SOURCE_DOCKER_VERSION} \
							--build-arg ARG_APPL_NAME=${PROJECT_NAME} \
							--build-arg ARG_DOCKER_TAG=${ARTIFACT_VERSION} \
							--build-arg ARG_GIT_URL=${GIT_URL_ARG} \
							--build-arg ARG_GIT_BRANCH=${GIT_BRANCH_ARG} \
							--build-arg ARG_COMMIT_HASH=${GIT_COMMIT} \
							-f ${DOCKER_SERVICE_FILE_PATH} ."
						sh "docker images ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}"
					}
				}
			}
		}
		stage("Publish Docker") {
			when {
				expression {
					if (env.BRANCH_NAME == 'master' || FEATURE_BRANCH_PUBLISH) {
						return true
					}
					updateGitlabCommitStatus(name: 'Publish Docker', state: 'success')
					return false;
				}
			}
			steps {
				gitlabCommitStatus(name: 'Publish Docker') {
					script {
						echo "Logging into AWS Docker Registry"
						sh "aws sts get-caller-identity"
						sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}"
						sh "docker tag ${PROJECT_NAME}:${ARTIFACT_VERSION} ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:${ARTIFACT_VERSION}"
						sh "docker push ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:${ARTIFACT_VERSION}"
						if (env.BRANCH_NAME == 'master') {
							sh "docker tag ${PROJECT_NAME}:${ARTIFACT_VERSION} ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:latest"
							sh "docker push ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:latest"
							sh "docker images ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:latest"
							sh "docker rmi -f ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:latest"
						}
						sh "docker images ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:${ARTIFACT_VERSION}"
						sh "docker rmi -f ${AWS_ECR_REPOSITORY}/${PROJECT_NAME}:${ARTIFACT_VERSION}"
						sh "docker rmi -f ${PROJECT_NAME}:${ARTIFACT_VERSION}"
					}
				}
			}
		}
	}
	post {
		always {
			script {
				sh "docker system prune -f"
			}
			deleteDir()
		}
		failure {
			updateGitlabCommitStatus name: 'build', state: 'failed'
		}
		success {
			updateGitlabCommitStatus name: 'build', state: 'success'
		}
	}
}
