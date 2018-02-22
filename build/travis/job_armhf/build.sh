#!/bin/bash
# Run this script from QtQuickVcp's root directory

# Build QtQuickVcp libraries for Linux armhf and upload them to Bintray. Libraries will
# always be uploaded unless a list of specific branches is passed in. e.g.:
#    $   build.sh  --upload-branches  master  my-branch-1  my-branch-2

set -e # exit on error
set -x # echo commands

# create a full clone
git fetch --unshallow

# find out version number
release=1
git describe --exact-match HEAD 2> /dev/null || release=0
if [ $release -eq 0 ]; then
    date="$(date -u +%Y%m%d%H%M)"

    branch="$TRAVIS_BRANCH"
    [ "$branch" ] || branch="$(git rev-parse --abbrev-ref HEAD)"

    revision="$(echo "$TRAVIS_COMMIT" | cut -c 1-7)"
    [ "$revision" ] || revision="$(git rev-parse --short HEAD)"
    version="${date}-${branch}-${revision}"
else
    version="$(git describe --tags)"
    upload=true
fi

echo "#define REVISION \"${version}\"" > ./src/application/revision.h

# build QtQuickVcp inside debian armhf docker container using qemu
docker run -i -v "${PWD}:/QtQuickVcp" cmcquinn/qtquickvcp-docker-linux-armhf:latest \
       /bin/bash -c "cd QtQuickVcp; ./build/Linux/armhf/Recipe"
platform="armhf"

# upload is already on release
if [ "${upload}" != "true" ]; then
    if [ "$1" == "--upload-branches" ] && [ "$2" != "ALL" ]; then
        # User passed in a list of zero or more branches so only upload those listed
        shift
        for upload_branch in "$@" ; do
            [ "$branch" == "$upload_branch" ] && upload=true || true # bypass `set -e`
        done
    else
        # No list passed in (or specified "ALL"), so upload on every branch
        upload=true
    fi
    # skip pull requests
    if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
        upload=
    fi
fi

if [ "${upload}" ]; then
    # rename binaries
    # and upload to Bintray
    if [ $release -eq 1 ]; then
        target="QtQuickVcp"
    else
        target="QtQuickVcp_Development"
    fi
	zipfile=${target}-${version}-Linux-${platform}.tar.gz
    mv build.release/QtQuickVcp.tar.gz $zipfile
	# Print the contents of the zipfile to check it's integrity
	echo "Created zipfile $zipfile:"
	tar tzf $zipfile
    ./build/travis/job_armhf/bintray_lib.sh ${target}-${version}*.tar.gz
else
  echo "On branch '$branch' so binaries will not be uploaded." >&2
fi
