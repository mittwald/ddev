setup() {
  set -eu -o pipefail

  setup_ssh

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
    --web-environment-add=MITTWALD_SSH_USER=${MITTWALD_SSH_USER}
  ddev start -y >/dev/null
}

setup_ssh() {
  mkdir -p ~/.ssh
  echo "${MITTWALD_SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
}

health_checks() {
  # Do something useful here that verifies the add-on
  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
  ddev exec "curl -s https://localhost:443/" | grep "Hello world"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

setup_ssh_in_ddev() {
  ddev exec 'mkdir -p $HOME/.ssh'
  echo "${MITTWALD_SSH_PRIVATE_KEY}" | ddev exec --raw -- bash -c 'cat > $HOME/.ssh/id_rsa'
  ddev exec 'chmod 600 $HOME/.ssh/id_rsa'
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}

  export MITTWALD_SKIP_CONFIG=yes

  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
}

@test "can pull code from remote" {
  set -eu -o pipefail

  cd ${TESTDIR}

  export MITTWALD_SKIP_CONFIG=yes

  ddev get ${DIR}
  ddev restart

  echo "${MITTWALD_SSH_PRIVATE_KEY}" | docker exec -i ddev-ssh-agent ssh-add -
  #setup_ssh_in_ddev
  
  echo "# ddev pull with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev pull mittwald >&3

  ls -al . >&3
  
  test -e assertion_file
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
  health_checks
}

