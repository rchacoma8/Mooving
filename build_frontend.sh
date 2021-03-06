#!/bin/bash
set -e
#Script to build the frontend
#Variable FRONTEND must exist and Vue must be installed
if [[ -z "$FRONTEND" ]]; then
    echo "No frontend defined, it won't work..."
    exit 1
fi
cd $FRONTEND
#build specification depending on branch pushed
case $BRANCH in
    DEVOPS)
        ./node_modules/.bin/vue-cli-service build --mode devops
        ;;
    STAGING)
        ./node_modules/.bin/vue-cli-service build --mode staging --fix
        ;;
    PRODUCTION)
        ./node_modules/.bin/vue-cli-service build --mode production --fix
        ;;
    *)
        ./node_modules/.bin/vue-cli-service build --mode personal
        ;;
esac

