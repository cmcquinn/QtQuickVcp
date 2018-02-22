#!/bin/bash

# Push AppImages and related metadata to Bintray (https://bintray.com/docs/api/)
# Adapted from: https://github.com/probonopd/AppImages/blob/master/bintray.sh

# The MIT License (MIT)
#
# Copyright (c) 2004-15 Simon Peter
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

trap 'exit 1' ERR

which curl || exit 1
which bsdtar || exit 1 # https://github.com/libarchive/libarchive/wiki/ManPageBsdtar1 ; isoinfo cannot read zisofs
which grep || exit 1

# Do not upload artefacts generated as part of a pull request
if [[ "$(env | grep TRAVIS_PULL_REQUEST )" ]] ; then
  if [ "$TRAVIS_PULL_REQUEST" != "false" ] ; then
    echo "Not uploading AppImage since this is a pull request."
    exit 0
  fi
fi

BINTRAY_USER="${BINTRAY_USER:?Environment variable missing/empty!}" # env
BINTRAY_API_KEY="${BINTRAY_API_KEY:?Environment variable missing/empty!}" # env

BINTRAY_REPO_OWNER="${BINTRAY_REPO_OWNER:-$BINTRAY_USER}" # env, or use BINTRAY_USER as default
[ "${BINTRAY_REPO_OWNER}" == "cmcquinn" ] && TRUSTED="true" || TRUSTED="false"

WEBSITE_URL="https://github.com/cmcquinn/QtQuickVcp"
ISSUE_TRACKER_URL="https://github.com/cmcquinn/QtQuickVcp/issues"
GITHUB_REPO="cmcquinn/QtQuickVcp"
VCS_URL="https://github.com/${GITHUB_REPO}.git" # Mandatory for packages in free Bintray repos
LICENSE="LGPL-2.1"

API="https://api.bintray.com"

FILE="$1"
[ -f "$FILE" ] || { echo "$0: Please provide a valid path to a file" >&2 ; exit 1 ;}

# GENERAL NAMING SCHEME FOR APPIMAGES:
# File: <appName>-<version>-<arch>.AppImage
#
# QTQUICKVCP NAMING SCHEME:
# File:    QtQuickVcp-X.Y.Z-<arch>.AppImage (e.g. QtQuickVcp-2.0.3-x64.AppImage)
# Version: X.Y.Z
# Package: QtQuickVcp-Linux-<arch>
#
# NIGHTLY NAMING SCHEME: (For developer builds replace "Nightly" with "Dev")
# File:    QtQuickVcp-Nightly-<datetime>-<branch>-<commit>-<arch>.AppImage
#    (e.g. QtQuickVcp-Nightly-201601151332-master-f53w6dg-x64.AppImage)
# Version: <datetime>-<branch>-<commit> (e.g. 201601151332-master-f53w6dg)
# Package: QtQuickVcp-Nightly-Linux-<branch>-<arch> (e.g. QtQuickVcp-Nightly-master-x64)

# Read app name from file name (get characters before first dash)
APPNAME="$(basename "$FILE" | sed -r 's|^([^-]*)-.*$|\1|')"

# Read version from the file name (get characters between first and almost last dash)
VERSION="$(basename "$FILE" | sed -r 's|^[^-]*-(.*)-[^-]*-[^-]*$|\1|')"

# Read architecture from file name (characters between last dash and .tar.gz)
ARCH="$(basename "$FILE" | sed -r 's|^.*-([^-]*)\.tar.gz$|\1|')"

case "${ARCH}" in
  x86_64|x64|amd64 )
    SYSTEM="${ARCH} (64-bit Intel/AMD)"
    ;;
  i686|i386|i[345678]86 )
    SYSTEM="${ARCH} (32-bit Intel/AMD)"
    ;;
  armel )
    SYSTEM="${ARCH} (old 32-bit ARM)"
    ;;
  armhf )
    SYSTEM="${ARCH} (new 32-bit ARM)"
    ;;
  aarch64 )
    SYSTEM="${ARCH} (64-bit ARM)"
    ;;
  * )
    echo "Error: unrecognised architecture '${ARCH}'" >&2
    exit 1
    ;;
esac

FILE_UPLOAD_PATH="$(basename "${FILE}")"

if [ "${APPNAME}" == "QtQuickVcp" ]; then
  # Upload a new version but don't publish it (invisible until published)
  url_query="" # Don't publish, don't overwrite existing files with same name
  PCK_NAME="$APPNAME-Linux-$ARCH"
  BINTRAY_REPO="${BINTRAY_REPO:-QtQuickVcp}" # env, or use "QtQuickVcp"
  LABELS="[\"machinekit\", \"machine control\", \"VCP\", \"AppImage\"]"
  [ "${TRUSTED}" == "true" ] && MATURITY="Official" || MATURITY="Stable"
else
  # Upload and publish a new development/nightly build (visible to users immediately)
  url_query="publish=1&override=1" # Automatically publish, overwrite existing

  # Get Git branch from $VERSION (get characters between first and last dash)
  BRANCH="$(echo $VERSION | sed -r 's|^[^-]*-(.*)-[^-]*$|\1|')"

  # Get Git commit from $VERSION (get characters after last dash)
  COMMIT="$(echo $VERSION | sed -r 's|^.*-([^-]*)$|\1|')"

  PCK_NAME="$APPNAME-Linux-$BRANCH-$ARCH"
  BINTRAY_REPO="${BINTRAY_REPO:-QtQuickVcp-Development}" # env, or use "QtQuickVcp-Development"
  LABELS="unofficial"

  if [ "${APPNAME}" == "QtQuickVcp-Nightly" ]; then
    BINTRAY_REPO="nightlies-linux" # nightlies use a different repo
    LABELS="nightly"
  fi

  LABELS="[\"${LABELS}\", \"unstable\", \"testing\"]"
  [ "${TRUSTED}" == "true" ] && MATURITY="Development" || MATURITY="Experimental"
fi

CURL="curl -u${BINTRAY_USER}:${BINTRAY_API_KEY} -H Content-Type:application/json -H Accept:application/json"

#exit 0

# Get metadata from the desktop file inside the AppImage
DESKTOP=$(bsdtar -tf "${FILE}" | grep ^./[^/]*.desktop$ | head -n 1)
# Extract the description from the desktop file

echo "* DESKTOP $DESKTOP"

#PCK_NAME=$(bsdtar -f "${FILE}" -O -x ./"${DESKTOP}" | grep -e "^Name=" | head -n 1 | sed s/Name=//g | cut -d " " -f 1 | xargs)
#if [ "$PCK_NAME" == "" ] ; then
#  bsdtar -f "${FILE}" -O -x ./"${DESKTOP}"
#  echo "PCK_NAME missing in ${DESKTOP}, exiting"
#  exit 1
#else
#  echo "* PCK_NAME $PCK_NAME"
#fi

if [ "${APPNAME}" == "QtQuickVcp" ]; then
  # Get description from desktop file (source file: build/Linux+BSD/mscore.desktop.in)
  DESCRIPTION="QtQuickVcp - Qt Quick Virtual Control Panel for Machinekit"
else
  # Use custom description for nightly/development builds
  DESCRIPTION="Automated builds of the $BRANCH development branch. FOR TESTING PURPOSES ONLY!"
fi
# Add installation instructions to the description (same for all types of build)
DESCRIPTION="${APPNAME} modules for $SYSTEM Linux systems.

${DESCRIPTION}

Extract the contents of the archive to your Qt installation folder to use it"

if [ "$VERSION" == "" ] ; then
  echo "* VERSION missing, exiting"
  exit 1
else
  echo "* VERSION $VERSION"
fi

# exit 0
##########

echo ""
echo "Creating package ${PCK_NAME}..."
  data="{
    \"name\": \"${PCK_NAME}\",
    \"desc\": \"${DESCRIPTION}\",
    \"desc_url\": \"auto\",
    \"website_url\": [\"${WEBSITE_URL}\"],
    \"vcs_url\": [\"${VCS_URL}\"],
    \"issue_tracker_url\": [\"${ISSUE_TRACKER_URL}\"],
    \"licenses\": [\"${LICENSE}\"],
    \"labels\": ${LABELS},
    \"maturity\": \"${MATURITY}\"
    }"
  ATTRIBUTES="[
    {\"name\": \"Platform\", \"values\": [\"Linux\"], \"type\": \"string\"},
    {\"name\": \"Architecture\", \"values\": [\"${SYSTEM}\"], \"type\": \"string\"}
    ]"
${CURL} -X POST -d "${data}" ${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO} && new_package="true"
if [ "$new_package" == "true" ]; then
  # Only set package attributes if a new package was created
  echo ""
  echo "Setting attributes for package ${PCK_NAME}..."
  ${CURL} -X POST -d "${ATTRIBUTES}" ${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/attributes
fi

echo ""

if [ $(which zsyncmake) ] ; then
  echo ""
  echo "Embedding update information into ${FILE}..."
  # Clear ISO 9660 Volume Descriptor #1 field "Application Used"
  # (contents not defined by ISO 9660) and write URL there
  dd if=/dev/zero of="${FILE}" bs=1 seek=33651 count=512 conv=notrunc
  # Example for next line: Subsurface-_latestVersion-x86_64.AppImage
  NAMELATESTVERSION=$(echo "${FILE_UPLOAD_PATH}" | sed -e "s|${VERSION}|_latestVersion|g")
  # Example for next line: bintray-zsync|probono|AppImages|Subsurface|Subsurface-_latestVersion-x86_64.AppImage.zsync
  LINE="bintray-zsync|${BINTRAY_REPO_OWNER}|${BINTRAY_REPO}|${PCK_NAME}|${NAMELATESTVERSION}.zsync"
  echo "${LINE}" | dd of="${FILE}" bs=1 seek=33651 count=512 conv=notrunc
  echo ""
  echo "Uploading zsync file for ${FILE}..."
  # Workaround for:
  # https://github.com/probonopd/zsync-curl/issues/1
  zsyncmake -u "http://dl.bintray.com/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${FILE_UPLOAD_PATH}" ${FILE} -o ${FILE}.zsync
  ${CURL} -T ${FILE}.zsync "${API}/content/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${VERSION}/${FILE_UPLOAD_PATH}.zsync?${url_query}"
else
  echo "zsyncmake not found, skipping zsync file generation and upload"
fi

echo ""
echo "Uploading ${FILE}..."
${CURL} -T ${FILE} "${API}/content/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${VERSION}/${FILE_UPLOAD_PATH}?${url_query}" \
  || { echo "$0: Error: Binary upload failed!" >&2 ; exit 1 ;}

# Update version information *after* AppImage upload (don't want to create an empty version if upload fails)
echo ""
echo "Updating version information for ${VERSION}..."
    data="{
    \"desc\": \"${DESCRIPTION}\",
    \"vcs_tag\": \"${COMMIT:-v$VERSION}\"
    }"
${CURL} -X PATCH -d "${data}" ${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/versions/${VERSION}
echo ""
echo "Setting attributes for package ${PCK_NAME}..."
${CURL} -X POST -d "${ATTRIBUTES}" ${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/versions/${VERSION}/attributes

if [ "${APPNAME}" != "QtQuickVcp" ]; then
  echo ""

  if [ $(env | grep TRAVIS_JOB_ID ) ]; then
  echo "Adding Travis CI log to release notes..."
  BUILD_LOG="https://api.travis-ci.org/jobs/${TRAVIS_JOB_ID}/log.txt?deansi=true"
      data='{
    "bintray": {
      "syntax": "markdown",
      "content": "'${BUILD_LOG}'"
    }
  }'
  ${CURL} -X POST -d "${data}" ${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/versions/${VERSION}/release_notes
  echo ""
  fi

  # Delete older versions of non-release packages (nightlies and dev. builds)
  HERE="$(dirname "$(readlink -f "${0}")")"
  "${HERE}/bintray-tidy.sh" archive "${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}" || true
fi



# Seemingly this works only after the second time running this script - thus disabling for now (FIXME)
# echo ""
# echo "Adding ${FILE} to download list..."
# sleep 5 # Seemingly needed
#     data="{
#     \"list_in_downloads\": true
#     }"
# ${CURL} -X PUT -d "${data}" ${API}/file_metadata	/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/"${FILE_UPLOAD_PATH}"
# echo "TODO: Remove earlier versions of the same architecture from the download list"

# echo ""
# echo "TODO: Uploading screenshot for ${FILE}..."
