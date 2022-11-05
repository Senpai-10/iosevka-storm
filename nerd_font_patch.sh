#!/bin/env bash

set -eu

if ! command -v fontforge &> /dev/null
then
    echo "Please install fontforge first!"
    exit 1
fi

if [ ! -d ./dist/iosevka-storm/ ]
then
    echo "Please build font first!"
    exit 1
fi

log() {
    local message="$1"

    echo "[INFO] $message"
}

MAIN_DIR="patch_with_nerd"
FONTS_DIR="${MAIN_DIR}/fonts"
DIST_DIR="${MAIN_DIR}/dist/iosevka-storm"

if [ -d ${FONTS_DIR}/ ]
then
    rm -rf ${FONTS_DIR}
fi

if [ -d ${DIST_DIR}/ ]
then
    rm -rf ${DIST_DIR}
fi

mkdir -pv ${MAIN_DIR}/
mkdir -pv ${FONTS_DIR}
mkdir -pv ${DIST_DIR}

log "Copying font files from dist/iosevka-storm/ttf into ${FONTS_DIR}/"
cp -r ./dist/iosevka-storm/ttf/* ${FONTS_DIR}/

cd ${MAIN_DIR} || :

if [ -d ./nerd-fonts/ ]
then
    log "Nerd-font dir found!"
    log "Pulling latest changes from 'https://github.com/ryanoasis/nerd-fonts'"
    cd nerd-fonts/
    git pull
    cd ..
else
    log "Nerd-font dir not found!"
    log "Git cloning from 'https://github.com/ryanoasis/nerd-fonts'"
    git clone --depth 1 "https://github.com/ryanoasis/nerd-fonts.git"
fi

log "Copying nerd-fonts/src into $MAIN_DIR"
cp -r nerd-fonts/src .

log "Copying the font-patcher script into $MAIN_DIR"
cp nerd-fonts/font-patcher .

log "Patching all fonts inside of ${FONTS_DIR} dir and output to ${DIST_DIR}"
find fonts -type f \
    -exec fontforge -script font-patcher -c --careful {} -out "dist/iosevka-storm/" \;

log "Done"
