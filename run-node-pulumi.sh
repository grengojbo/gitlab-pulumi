#!/bin/bash

echo "Start run-pulumi.sh"
echo "----------------------------------------"
CURRENT_DIR=$(pwd)
echo "CURRENT DIR: ${CURRENT_DIR}"
echo "----------------------------------------"
# env
# echo "----------------------------------------"
echo " "

export PATH=${CURRENT}/bin:$PATH

unset AWS_ACCESS_KEY
unset AWS_SECRET_ACCESS_KEY
unset AWS_SECRET_KEY
unset AWS_CREDENTIAL_FILE

PULUMI_BARANCH=${PULUMI_BARANCH:-dev}
SRC_REPO=${SRC_REPO:-none}
# Это для сценария только посмотреть что будет менятся
PULUMI_PREVIEW=${PULUMI_PREVIEW:-yes}
# Удалять репозиторий если мы его клонировали, неудаляем только для отладки
REPO_REMOVE=${REPO_REMOVE:-yes}

if [[ -z ${PULUMI_STACK_SELECT} ]]; then
  echo "[ERROR] is not set \$PULUMI_STACK_SELECT"
  echo "[EXAMPLE] PULUMI_STACK_SELECT=dev"
  exit 1;
fi

# env
# cd /src
if [[ ! -d "${CURRENT_DIR}/.deploy" ]]; then
  echo "[ERROR] IS NOT project dir: .deploy"
  exit 1;
fi

ln -s /pulumi/projects/node_modules ${CURRENT_DIR}/.deploy/

echo "----------------------------------------"
echo "Run pulumi stack ${PULUMI_STACK_SELECT}"
echo "----------------------------------------"
if [[ ! -f "Dockerfile" ]]; then
  echo "[ERROR] IS NOT file Dockerfile"
  exit 1;
fi

if [[ ! -z ${PULUMI_NPM} ]]; then
  echo "Install npm..."
  cd ${CURRENT_DIR}/.deploy
  npm ci --no-progress
  cd ${CURRENT_DIR}
fi
  # echo "----------------------------------------"
  # echo $PATH
  # echo "----------------------------------------"
  # ls -l ./bin
  # echo "----------------------------------------"

  pulumi login
  pulumi stack -C .deploy select ${PULUMI_STACK_SELECT}

echo "----------------------------------------"
if [[ "${PULUMI_PREVIEW}" == "yes" ]]; then
  echo "Start preview..."
  pulumi preview -C .deploy
else
  pulumi up -C .deploy --yes
  # pulumi up --yes
  # pulumi up
  echo "----------------------------------------"
  # ls -l ./
fi
rm -rf ${CURRENT_DIR}/.deploy/node_modules