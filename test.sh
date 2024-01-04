#!/bin/sh
DOCKER_IMAGE=$1
DOCKER_RUN="docker run --rm -i -v $(pwd):/local -w /local ${DOCKER_IMAGE}"

CMD="BeefBuild -new -workspace=hello_world 1>&2 && \
    cp hello_world.bf hello_world/src/Program.bf && \
    BeefBuild -run -workspace=hello_world -config=Release && \
    rm -rf hello_world"
RESULT="$(${DOCKER_RUN} sh -c "${CMD}")"
echo "${RESULT}"
if [ "${RESULT}" = "Hello, world!" ]
then
    echo "PASSED"
else
    echo "FAILED"
    exit 1
fi
