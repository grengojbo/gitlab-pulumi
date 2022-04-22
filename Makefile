# Использовать bash с опцией pipefail
# pipefail - фейлит выполнение пайпа, если команда выполнилась с ошибкой
#SHELL=/bin/bash -o pipefail
# SHELL = /bin/bash

# Примеры
# https://github.com/FuzzyMonkeyCo/monkey/blob/master/Makefile

CURRENT_DIR = $$(pwd)

# Подготовка Makefile
# https://habr.com/ru/post/449910/#makefile_preparation

UNAME := $(shell uname)
BUILD_DATE := $(shell date +%Y%m%d-%H%M)

# envrioments from .env file
ifeq (,$(wildcard .env))
  $(shell test ! -f example.env || cp example.env .env)
endif

ifeq (,$(wildcard .env))
  $(shell exit 1)
else
	include .env
	export $(shell sed 's/=.*//' .env)
	# export
endif

os ?= $(shell uname|tr A-Z a-z)
ifeq ($(shell uname -m),x86_64)
  arch   ?= "amd64"
endif
ifeq ($(shell uname -m),i686)
  arch   ?= "386"
endif
ifeq ($(shell uname -m),aarch64)
  arch   ?= "arm"
endif
ifeq ($(shell uname -s),Darwin)
  arch   ?= "darwin"
endif

AUTO_APPROVE :=

COMPOSE_PROJECT_NAME ?= "noname"

# Если переменная CI_JOB_ID не определена
ifeq ($(CI_JOB_ID),)
	# присваиваем значение local
	CI_JOB_ID := local
else
	AUTO_APPROVE := "-auto-approve"
endif

ifeq ($(TAG),)
  TAG := latest
endif

ifeq ($(CI_PROJECT_DIR),)
  CI_PROJECT_DIR := $(PWD)
endif

ifeq ($(MODE),)
  MODE := prod
endif

ifeq ($(APP_NAME),)
  APP_NAME := noname
endif

ifeq ($(AWS_ECR_NAME),)
  AWS_ECR_NAME := "docker.io"
endif

ifeq ($(AWS_REPO_NAME),)
  AWS_REPO_NAME := "ubuntu"
endif

# ifeq ($(CI_JWERF_IMAGES_REPOOB_ID),)
#   WERF_IMAGES_REPO := "${AWS_ECR_NAME}/${AWS_REPO_NAME}/${APP_NAME}"
# endif

ifeq ($(K8S_NAMESPACE),)
  K8S_NAMESPACE := default
endif

ifeq ($(DEPLOY_MODE),)
  DEPLOY_MODE := "none"
endif

ifeq ($(CLUSTER_NAME),)
  CLUSTER_NAME := "my-claster"
endif

ifeq ($(AWS_PROFILE),)
  AWS_PROFILE := "default"
endif

ifeq ($(REGION),)
  REGION := eu-west-2
endif

export COMPOSE_HTTP_TIMEOUT=120

# Read all subsquent tasks as arguments of the first task
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(args) $(RUN_ARGS):;@:)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
landscape   := $(shell command -v landscape 2> /dev/null)
# terraform   := $(shell command -v terraform 2> /dev/null)
debug       :=
# Defaulting to level: TRACE. Valid levels are: [TRACE DEBUG INFO WARN ERROR]
export TF_LOG=
# export TF_LOG=ERROR

.ONESHELL:
.SHELL := /bin/bash

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

ifneq ($(DOCKER_COMPOSE_CMD),"docker")
DOCKER_COMPOSE_COMMANDS := ""
else
DOCKER_COMPOSE_COMMANDS := "compose "
endif

# TODO: add atomic and dry-run to HELM
# --atomic
# --dry-run

IS_K3D := $(shell command -v k3d 2> /dev/null)
IS_NONAME := $(shell command -v noname 2> /dev/null)


# ifneq ("$(wildcard $(PATH_TO_FILE))","")
# FILE_EXISTS = 1
# else
# FILE_EXISTS = 0
# endif
# WERF_PATH=$(shell trdl bin-path 1.2 ea)
WERF_PATH="$(shell trdl bin-path werf 1.2 ea)/werf"
# trdl add werf https://tuf.werf.io 1 b7ff6bcbe598e072a86d595a3621924c8612c7e6dc6a82e919abe89707d7e3f468e616b5635630680dd1e98fc362ae5051728406700e6274c5ed1ad92bea52a2
# WERF_PATH=$(shell trdl add werf https://tuf.werf.io 1 b7ff6bcbe598e072a86d595a3621924c8612c7e6dc6a82e919abe89707d7e3f468e616b5635630680dd1e98fc362ae5051728406700e6274c5ed1ad92bea52a2 && trdl use werf 1.2 ea)
SHOW_WERF_VERSION := $(shell $(WERF_PATH) version)

.PHONY: help
.DEFAULT_GOAL := help
help:
	@echo "\n$(GREEN)Available commands$(RESET)"
	@echo "---------------------------------------------------------------------"
	@grep -h -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "---------------------------------------------------------------------"
	@#echo "$(YELLOW)Example argument to install Packer:$(RESET) make install packer=true"
	@#echo "$(YELLOW)Example for auto-approve:$(RESET) make globalvars-apply auto=yes"
	@#echo "$(YELLOW)Debug mode show command not run:$(RESET) make vpc-apply debug=yes"
	@#echo "$(YELLOW)Output json format:$(RESET) make output c=vpc-aws f=json \n"


# init: ## File initialization and structure
# 	@echo "TODO: добавить загрузку из git"
# 	@#curl -L https://raw.githubusercontent.com/flant/multiwerf/master/get.sh | bash
# 	@#.stack/scripts/init-mysql.sh ${NEW_UID} ${NEW_GID} ${BASE_DATA_DIR}

# stunnel:
# 	@sudo systemctl start stunnel.service

# app-init: ## Initialization k3d cluster and structure
# ifdef IS_K3D
# 	@echo "$(GREEN)Create k3d cluster$(RESET)"
# 	@k3d cluster create -c ./cluster.yml
# endif
# 	@.stack/ingress.sh
# ifdef MOCO_MYSQL
# 	@#echo "$(RED)TODO: move .stack/mysql.sh$(RESET)"
# 	@#.stack/mysql.sh
# else
# 	@echo "TODO: disabled ./scripts/init-mysql.sh"
# 	@#./scripts/init-mysql.sh ${USER} ${BASE_DATA_DIR}
# endif

major:  ## Set major version
	@git tag $$(svu major)
	@git push --tags
	@#goreleaser --rm-dist

minor:  ##  Set minor version
	@git tag $$(svu minor)
	@git push --tags
	@#goreleaser --rm-dist

patch:  ##  Set patch version
	@git tag $$(svu patch)
	@git push --tags
	@#goreleaser --rm-dist


build:  ## Local Build сборка проекта
	@.stack/build.sh

release:  ## Build and publish Release
	@#echo "Start Build and publish Release ${WERF_IMAGES_REPO}:${TAG}"
	@#werf build-and-publish --stages-storage :local --images-repo=${WERF_IMAGES_REPO} --tag-custom=${TAG}
	@#$(RUN_COMMAND) build-and-publish --stages-storage :local --images-repo=${WERF_IMAGES_REPO} --tag-custom=${TAG}
	@docker run -it --rm -e PULUMI_ACCESS_TOKEN=${PULUMI_ACCESS_TOKEN} -e PULUMI_STACK_SELECT=${PULUMI_STACK_SELECT} -v $(shell pwd):/app ${PULUMI_IMG} run-pulumi.sh

shell-pulumi: ## позключаемся к контейнеру с установленым Pulumi
	@#echo "set export PULUMI_ACCESS_TOKEN=***"
	@docker run -it --rm -v ${PWD}:/app -e PULUMI_ACCESS_TOKEN=${PULUMI_ACCESS_TOKEN} -e PULUMI_STACK_SELECT=${PULUMI_STACK_SELECT} ${PULUMI_IMG} bash