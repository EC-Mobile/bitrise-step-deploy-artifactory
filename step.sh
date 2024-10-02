#!/bin/bash
set -e

TOKEN=$(curl -u "$JFROG_USERNAME:$JFROG_APIKEY" -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        $JFROG_BASEURL/api/security/token \
        -d "username=$JFROG_USERNAME" | jq -r '.access_token')

VERSION=$PRODUCT_VERSION

GIT_TAG=$(git describe --exact-match --tags 2> /dev/null || true)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null || true)

if [ "$PRODUCT_VERSION" = "" ]; then
  if [ ! -z $GIT_TAG ]; then
    VERSION=$GIT_TAG
  elif [ ! -z $GIT_BRANCH ]; then
    VERSION=$GIT_BRANCH
  else
    VERSION="nightly"
  fi
fi

curl --request PUT \
    --url $JFROG_BASEURL/${JFROG_REPO_KEY}/${JFROG_PATH}/${VERSION}/ \
    --header "Authorization: Bearer $TOKEN" \
    --header 'Content-Type: application/octed-stream' \
    -T $PRODUCT_PATH

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
