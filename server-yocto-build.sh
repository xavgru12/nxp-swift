#!/bin/bash
# This script will run into container

# source the common variables

. env.sh

#

mkdir -p ${YOCTO_DIR}
cd ${YOCTO_DIR}
rm -rf sources

# Init
echo repo init
repo init \
    -u ${REMOTE} \
    -b ${BRANCH} \
    -m ${MANIFEST}

repo sync -j`nproc`

# source the yocto env
echo imx setup release
EULA=1 MACHINE="${MACHINE}" DISTRO="${DISTRO}" source imx-setup-release.sh -b remote_updated_nxp

# Build
echo bitbake ${IMAGES} 
export BB_VERBOSE=2
bitbake ${IMAGES}

