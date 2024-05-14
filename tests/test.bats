setup() {
  set -eu -o pipefail

  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-template
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-template
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config \
    --project-name=${PROJNAME} \
    --web-environment-add=MITTWALD_API_TOKEN=${MITTWALD_API_TOKEN} \
    --web-environment-add=MITTWALD_APP_INSTALLATION_ID=${MITTWALD_APP_INSTALLATION_ID} \
    --web-environment-add=MITTWALD_SSH_USER=${MITTWALD_SSH_USER} \
    --web-environment-add=DEBUG=mw:api:*
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

setup_ssh_in_ddev() {
  echo "${MITTWALD_SSH_PRIVATE_KEY}" | docker exec -i ddev-ssh-agent ssh-add -
}

setup_addon_from_dir() {
  export MITTWALD_SKIP_CONFIG=yes

  ddev get ${DIR}
  ddev restart >/dev/null
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}

  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  setup_addon_from_dir
}

@test "can pull code from remote" {
  set -eu -o pipefail

  cd ${TESTDIR}

  setup_addon_from_dir
  setup_ssh_in_ddev
  
  echo "# ddev pull with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev pull mittwald >&3

  sha256sum -c <<- EOF
  8c97bcaed289bbf584bf661550579f3225045e7d07dbb7f16ddc3d0522751095  assertion_file
EOF
}

@test "can run mw shell in web container" {
  set -eu -o pipefail

  cd ${TESTDIR}

  setup_addon_from_dir

  ddev mw context set --installation-id ${MITTWALD_APP_INSTALLATION_ID}
  ddev mw context get
  ddev mw app get
}

@test "install from release" {
  set -eu -o pipefail

  if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]] ; then
    skip "skipping 'install from release' in pull request pipelines"
  fi

  export MITTWALD_SKIP_CONFIG=yes

  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get mittwald/ddev with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get mittwald/ddev
  ddev restart >/dev/null
}

