#!/usr/bin/env bash

# NOTE: This script has been automatically generated by github.com/conda-forge/conda-smithy/...

FEEDSTOCK_ROOT=$(cd "$(dirname "$0")/.."; pwd;)
RECIPE_ROOT=$FEEDSTOCK_ROOT/recipe

UPLOAD_OWNER="[]"
UPLOAD_CHANNEL="main"

docker info

config=$(cat <<CONDARC

channels:

 - defaults # As we need conda-build

conda-build:
 root-dir: /feedstock_root/build_artefacts

show_channel_urls: True

CONDARC
)

cat << EOF | docker run -i \
                        -v ${RECIPE_ROOT}:/recipe_root \
                        -v ${FEEDSTOCK_ROOT}:/feedstock_root \
                        -a stdin -a stdout -a stderr \
                        pelson/conda64_obvious_ci \
                        bash || exit $?

export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc
# A lock sometimes occurs with incomplete builds. The lock file is stored in build_artefacts.
conda clean --lock

conda info


conda build --no-test /recipe_root || exit 1

EOF


# In a separate docker, run the test...
cat << EOF | docker run -i \
                        -v ${RECIPE_ROOT}:/recipe_root \
                        -v ${FEEDSTOCK_ROOT}:/feedstock_root \
                        -a stdin -a stdout -a stderr \
                        pelson/conda64_obvious_ci \
                        bash || exit $?

export BINSTAR_TOKEN=${BINSTAR_TOKEN}
export PYTHONUNBUFFERED=1
echo "$config" > ~/.condarc

conda info


conda build --test /recipe_root || exit 1
/feedstock_root/ci_support/upload_or_check_non_existence.py /recipe_root $UPLOAD_OWNER --channel=$UPLOAD_CHANNEL || exit 1


EOF
