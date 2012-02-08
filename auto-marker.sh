#!/bin/bash

set -e

base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function usage {
    echo "$0 <exercise-name> \"<tutee>+\""
}

exercise=$1
if [ "x${exercise}" = "x" ]; then
    usage
    exit 1
fi

tutees=$2
if [ "x$2" = "x" ]; then
    usage
    exit 1
fi

## get_repo PictureProcessing dd1711
function get_repo {
    if [ -d $1/$2 ]; then
        wd=$(pwd)
        cd $1/$2 && git pull --all && OK=true || OK=false
        cd ${wd}
        ${OK}
    else
        git clone -q "doc:/vol/lab/firstyear/Repositories/2011-2012/161/$2/$1.git" $1/$2 || \
        git clone -q "doc:/vol/lab/firstyear/Repositories/2011-2012/161/$2/$1" $1/$2
    fi
    wd=$(pwd)
    cd $1/$2 && git checkout part2 || git checkout part1
    cd ${wd}
}

echo "Getting repos..."

mkdir -p ${exercise}
for tutee in ${tutees} Masters; do
    echo "  * Getting repo for ${tutee}"
    get_repo ${exercise} ${tutee}
done

skelhash=$(git --git-dir ${exercise}/Masters/.git log --format=%h | tail -n1)

echo "Comparing with skeleton solution (${skelhash})"

for tutee in ${tutees}; do
    echo "  * Repo for ${tutee}"
    changedFiles=$(git --git-dir ${exercise}/${tutee}/.git diff --raw --stat ${skelhash}..HEAD | grep ':' | cut -d'	' -f2 | grep -v '.metadata' | grep '.java')
    rm -f ${exercise}/${tutee}.changedfiles
    changedFilesAbs=""
    for f in ${changedFiles}; do
        if [ ! -f "${exercise}/${tutee}/$f" ]; then
            echo "Skipping ${f}"
            continue
        fi
        echo "$f" >> ${exercise}/${tutee}.changedfiles
        changedFilesAbs="${changedFilesAbs} ${exercise}/${tutee}/${f}"
    done
    enscript -b "${tutee} - Code - ${exercise}" -o ${exercise}/${tutee}-code.ps --color -Ejava -G -f Courier8 -2r -C ${changedFilesAbs}
done

echo "Generating printable checkstyle reports"

for tutee in ${tutees}; do
    echo "  * Checking for ${tutee}"
    checkstyle -c "${base_dir}/almost_sun_checks.xml" $(find "${exercise}/${tutee}" -name '*.java') > ${exercise}/${tutee}.checkstyle || true
    grep -f ${exercise}/${tutee}.changedfiles ${exercise}/${tutee}.checkstyle > ${exercise}/${tutee}.checkstyle2
    enscript -b "${tutee} - Style - ${exercise}" -o ${exercise}/${tutee}-style.ps -G -f Courier8 ${exercise}/${tutee}.checkstyle2
done

echo "Combining reports"

for tutee in ${tutees}; do
    echo "  * Combining ${tutee}'s reports"
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=${exercise}/${tutee}-combinded.pdf ${exercise}/${tutee}-*.ps
done
