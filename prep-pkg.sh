#!/usr/bin/env bash
set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'if [ $? -ne 0 ]; then echo "\"${last_command}\" command filed with exit code $?."; fi' EXIT


if [ ! -z $TOOL ]; then
	TOOL=$TOOL
else
	echo -e "[w] Tool name not set Use Envvar 'TOOL' Defaulting to: terraform"
	TOOL="terraform"
fi


if [ ! -z $VERSION ]; then
	VERSION=$VERSION
else
	echo -e "[w] No version set, use Envvar 'VERSION' Defaulting to latest version for ${TOOL}"
	VERSION=$(curl --fail --silent --location "https://api.github.com/repos/hashicorp/${TOOL}/tags"|grep '"name":'|sed -E 's/.*"([^"]+)".*/\1/'|head -n 1|tr -d 'v')
fi


PLATF=${1:-linux}
ARCH=${2:-amd64}

URL="https://releases.hashicorp.com/${TOOL}/${VERSION}/${TOOL}_${VERSION}_${PLATF}_${ARCH}.zip"
SHASUM="https://releases.hashicorp.com/${TOOL}/${VERSION}/${TOOL}_${VERSION}_SHA256SUMS"
SHASUMSIG="${SHASUM}.sig"
HASHIGPG="https://keybase.io/hashicorp/key.asc"
CHANGELOGURL="https://raw.githubusercontent.com/hashicorp/${TOOL}/v${VERSION}/CHANGELOG.md"
EXPATH="/tf/${VERSION}/${ARCH}"

OUTPATH="/output/${TOOL}"

mkdir -p ${EXPATH} ${OUTPATH}/{deb,rpm}

echo -ne "Importing Hashicorp GPG key from keybase: "
curl -s ${HASHIGPG} |gpg --import - > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

echo -ne "Getting ${TOOL} ${VERSION}: "
wget $URL > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

echo -ne "Getting changelog for ${VERSION}: "
wget -O "/tf/${VERSION}/changelog.md" ${CHANGELOGURL} > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

echo -ne "Getting SHASUM file for ${TOOL}: "
wget ${SHASUM} > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

echo -ne "Getting SHASUM sig file for ${TOOL}: "
wget ${SHASUMSIG} > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

echo -ne "Verify GPG signature for SHA256SUM file: "
gpg --verify ${TOOL}_${VERSION}_SHA256SUMS.sig ${TOOL}_${VERSION}_SHA256SUMS > /dev/null 2>&1 && echo "[OK]"

echo -ne "Verifying SHA256SUM for ${TOOL}: "
sha256sum --ignore-missing -c ${TOOL}_${VERSION}_SHA256SUMS

echo -ne "Unzipping ${TOOL} ${VERSION}: "
unzip -o -qq ${TOOL}_${VERSION}_${PLATF}_${ARCH}.zip -d ${EXPATH} && rm -Rf ${VERSION}.zip > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

echo -ne "Creating deb Package: "
fpm -s dir -t deb -n ${TOOL} -v ${VERSION} -a ${ARCH} --deb-changelog /tf/${VERSION}/changelog.md -p ${OUTPATH}/deb ${EXPATH}/=/usr/bin > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"

# Changelog omitted from RPM because not correct format
echo -ne "Creating RPM Package: "
fpm -s dir -t rpm -n ${TOOL} -v ${VERSION} -a ${ARCH} -p ${OUTPATH}/rpm ${EXPATH}/=/usr/bin > /dev/null 2>&1 && echo "[OK]" || echo " ERROR"


