#!/usr/bin/env bash
# Author: Diego Valle-Jones
# Web: http://www.diegovalle.net
# Script to download shapefiles from 2020 Mexican census (including demographic data)
# tested on ubuntu 20.04

# Exit on error, undefined and prevent pipeline errors
set -euo pipefail
IFS=$'\n\t'

readonly OUT_DIR="${OUT_DIR:-./scince_2020}"
echo OUT_DIR="$OUT_DIR"

TEMP_DIR="$(mktemp -d)"
echo TEMP_DIR="$TEMP_DIR"

# index starts at zero
declare -a states=(
    "national"
    "ags"
    "bc"
    "bcs"
    "camp"
    "coah"
    "col"
    "chis"
    "chih"
    "cdmx"
    "dgo"
    "gto"
    "gro"
    "hgo"
    "jal"
    "mex"
    "mich"
    "mor"
    "nay"
    "nl"
    "oax"
    "pue"
    "qro"
    "qroo"
    "slp"
    "sin"
    "son"
    "tab"
    "tamps"
    "tlax"
    "ver"
    "yuc"
    "zac"
    );
echo states="${states[@]}"

download_geo_states() {
    mkdir -p "$OUT_DIR"
    for i in {0..32}
    do
        echo "Downloading ${states[$i]}..."

        # INEGI uses a leading zero for all one digit numbers
        if [ "$i" -lt 10 ]
        then
            FILENUM="0$i"
        else
            FILENUM="$i"
        fi

        # download file
        curl -sLo "$TEMP_DIR"/scince_$FILENUM.exe https://gaia.inegi.org.mx/scince2020desktop/$FILENUM/SCINCE2020_DATOS_$FILENUM.exe

        # extract files
        echo "Extracting ${states[$i]}..."
        cd "$TEMP_DIR" && innoextract --lowercase --silent "$TEMP_DIR"/scince_$FILENUM.exe

        # move shapefiles and related only
        echo "Coping geometries ${states[$i]}..."
        find "$TEMP_DIR"/app -depth -type f -regextype posix-extended \
             -regex '.*\.(dbf|cpg|prj|shp|rtree|shx)' \
             -execdir sh -c 'mv $1 "$2"_$(basename $1)' _ {} "${states[$i]}" \;
        DIR=$(find "$TEMP_DIR"/app -mindepth 1 -maxdepth 1 -type d -name '[0-9]*' -print)
        mv "$DIR" "$OUT_DIR/${states[$i]}"
        echo "$OUT_DIR/${states[$i]}"

        rm -rf "$TEMP_DIR"/app "$TEMP_DIR"/tmp

     done
}

main() {
    # Download innoextract 1.9
    # curl -sLo "$TEMP_DIR"/inno.tar.xz https://github.com/dscharrer/innoextract/releases/download/1.9/innoextract-1.9-linux.tar.xz
    # tar -xf "$TEMP_DIR"/inno.tar.xz --directory "$TEMP_DIR"
    # Download shapefiles
    download_geo_states
    rm -rf "$TEMP_DIR"
}

main
# -6 Datos reservados por confidencialidad
# -7 No disponible (cuando toda el área tiene viviendas pendientes)
# -8 No disponible (Cuando toda el área tiene sólo viviendas deshabitadas o de uso temporal)
# -9 No aplica (Cuando no es calculable)
