#!/bin/bash

MY_UID=${MY_UID:-1000}
echo "----------------------------------------"
echo "Start COPY artifacte to project"
rm -rf /opt/bin
cp /root/.pulumi/bin/* /opt/bin/
rm -Rf /opt/node_modules
cp -R ./node_modules/* /opt/node_modules/
echo "----------------------------------------"
echo "Set permission UID=${MY_UID}"
chown -R ${MY_UID}:${MY_UID} /opt/