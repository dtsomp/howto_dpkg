#!/bin/bash 


#
# Defaults
#

VERSION="0.1"
BASE_DIR="BASE"

#
# Functions
#

cleanup() {
    if [ -d ${BASE_DIR} ]; then
        echo "Removing existing ${BASE_DIR}"
        rm -rf ${BASE_DIR}
    fi
}


#
# Find my dir and make sure I change to it
#

MY_DIR=`dirname "$(readlink -f "$0")"`
cd "${MY_DIR}"


#
### Pre-flight checks
#

[[ ! -d "./DEBIAN" ]] && echo "ERROR: No DEBIAN folder found" && exit 5
[[ ! -a "./DEBIAN/control" ]] && echo "No DEBIAN/control file found" &&  exit 5
[[ ! -a "./DEBIAN/postinst" ]] && echo "No DEBIAN/postinst file found" && exit 5
[[ ! -a "./DEBIAN/prerm" ]] && echo "No DEBIAN/prerm file found" && exit 5
[[ ! -d "./DOC" ]] && echo "ERROR: No DOC folder found" && exit 5
[[ ! -a "./DOC/copyright" ]] && echo "ERROR: copyright file not found" && exit 5
[[ ! -a "./DOC/man" ]] && echo "ERROR: manpage file not found" && exit 5

#
# Read package name from control file
#

PACKAGE_NAME=` grep "^Package:" ./DEBIAN/control | awk '{print $2}' `
echo "PACKAGE_NAME=${PACKAGE_NAME}"

#
# Arg handling
#

if [ $# -eq 0 ]; then
    echo "No arguments provided, exiting"
    exit 1
fi
while [ $# -gt 0 ]; do
    case $1 in
        "-d"|"--debug") set -x;;
        "-v"|"--version") VERSION="$2"; shift 1;;
        "--clean-target") rm ./target/*.deb;;   # Remove pre-existing package files
    esac
    shift 1
done

#
# Cleanup existing build dir before we start
#

cleanup

#
# Build directory structure
#

echo "Creating dir structure"
# Required for all packages
mkdir -p ${BASE_DIR}/DEBIAN
mkdir -p ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}
mkdir -p ${BASE_DIR}/usr/share/man/man1
# Package-specific 
cp -r ROOT/* ${BASE_DIR}/

#
# Metafiles
#

echo "Creating metafiles"
cp ./DEBIAN/* ${BASE_DIR}/DEBIAN/
sed -i "s/^Version:.*$/Version: ${VERSION}/" ${BASE_DIR}/DEBIAN/control

#
# Create documentation
#

cp ./DOC/copyright ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}/
cp ./DOC/man ${BASE_DIR}/usr/share/man/man1/${PACKAGE_NAME}.1

# changelog
# uncomment to use your changelog 
#cp ./DOC/changelog ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}/

# changelog.Debian
# Lazy changelog creation. Use the second line instead to use your version
git log --oneline  -- . > ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}/changelog.Debian
#cp ./DOC/changelog.Debian ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}/

#
# Some files need to be compressed
#

gzip --best ${BASE_DIR}/usr/share/man/man1/${PACKAGE_NAME}.1
gzip --best ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}/changelog.Debian
[[ -e "${BASE_DIR}/usr/share/doc/{$PACKAGE_NAME}/changelog" ]] && gzip --best ${BASE_DIR}/usr/share/doc/${PACKAGE_NAME}/changelog

#
# Permissions
#

echo "Fixing permissions"
find ${BASE_DIR} -type d -exec chmod 0755 {} \;
find ${BASE_DIR} -type f -exec chmod 0644 {} \;
# All exes need to be 0755
# Non-exes need to be 0644
chmod 0755 ${BASE_DIR}/DEBIAN/postinst
chmod 0755 ${BASE_DIR}/DEBIAN/prerm
# TODO: fix extra permissions here

#
# Build
#

echo "Building package"
DEBFILE="${PACKAGE_NAME}-${VERSION}.deb"
{ fakeroot dpkg -b ${BASE_DIR} ./target/${DEBFILE}; } || { echo "ERROR: package creation failed."; exit 1; }

#
# Finished. Let's cleanup and exit
#

cleanup
exit 0
