#!/bin/bash
set -e -x -o pipefail

REPO=github.com/boeing-ai-gateway/tools
REPO_DIR=/boeing-tools/tools
REPO_NAME=$(basename $REPO_DIR)

if [[ -x "${REPO_DIR}/scripts/build.sh" ]]; then
    (
        echo "Running build script for ${REPO}..."
        cd "${REPO_DIR}"
        ./scripts/build.sh
        echo "Build script for ${REPO} complete!"
    )
else
    echo "No build script found in ${REPO}"
fi

BOEING_SERVER_VERSIONS="$(
    cat <<VERSIONS
${REPO}=$(cd /boeing-tools/tools && git rev-parse --short HEAD),${BOEING_SERVER_VERSIONS}
VERSIONS
)"
BOEING_SERVER_VERSIONS="${BOEING_SERVER_VERSIONS%,}"

cd /
for pj in $(find boeing-tools -name package.json | grep -v node_modules); do
    if [ $(basename $(dirname $pj)) == common ]; then
        continue
    fi
    (
        cd $(dirname $pj)
        echo Building $PWD
        pnpm i
    )

done

if ! command -v uv; then
    pip install uv
fi

if [ ! -e boeing-tools/venv ]; then
    uv venv /boeing-tools/venv
fi

source /boeing-tools/venv/bin/activate
uv pip install -r /boeing-tools/tools/requirements.txt

cd /boeing-tools
cat <<EOF >.envrc.tools.${REPO_NAME}
export GPTSCRIPT_SYSTEM_TOOLS_DIR=/boeing-tools/
export GPTSCRIPT_TOOL_REMAP="${REPO}=${REPO_DIR}"
export BOEING_SERVER_TOOL_REGISTRIES="github.com/boeing-ai-gateway/tools"
export BOEING_SERVER_VERSIONS="${BOEING_SERVER_VERSIONS}"
export TOOLS_VENV_BIN=/boeing-tools/venv/bin
EOF
