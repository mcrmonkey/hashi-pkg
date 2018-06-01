#!/bin/bash

if [ ! -z $H_TOOL ]; then
	TOOL=$H_TOOL
else
	echo -e "[w] Tool name not set Use Envvar 'H_TOOL'\n Defaulting to: Terraform"
	TOOL="terraform"
fi


if [ ! -z $H_VERSION ]; then
	VERSION=$H_VERSION
else
	echo -e "[w] No version set, use Envvar 'H_VERSION'\n [i] Getting latest version for ${TOOL}"
	VERSION=$(curl --fail --silent --location "https://api.github.com/repos/hashicorp/${TOOL}/tags"|grep '"name":'|sed -E 's/.*"([^"]+)".*/\1/'|head -n 1|tr -d 'v')
fi


PLATF=${1:-linux}
ARCH=${2:-amd64}

URL="https://releases.hashicorp.com/${TOOL}/${VERSION}/${TOOL}_${VERSION}_${PLATF}_${ARCH}.zip"
CHANGELOGURL="https://raw.githubusercontent.com/hashicorp/${TOOL}/v${VERSION}/CHANGELOG.md"
EXPATH="/tf/${VERSION}/${ARCH}"

OUTPATH="/output/${TOOL}"

echo "[i] Doing $TOOL version: $VERSION "


mkdir -p ${EXPATH} ${OUTPATH}/{deb,rpm}

wget -O ${VERSION}.zip $URL && unzip -o -qq ${VERSION}.zip -d ${EXPATH} && rm -Rf ${VERSION}.zip

wget -O "/tf/${VERSION}/changelog.md" ${CHANGELOGURL}



fpm -s dir -t deb -n ${TOOL} -v ${VERSION} -a ${ARCH} --deb-changelog /tf/${VERSION}/changelog.md -p ${OUTPATH}/deb ${EXPATH}/=/usr/bin

# Changelog omitted from RPM because not correct format

fpm -s dir -t rpm -n ${TOOL} -v ${VERSION} -a ${ARCH} -p ${OUTPATH}/rpm ${EXPATH}/=/usr/bin
