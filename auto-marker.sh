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
        cd $1/$2 && git pull && OK=true || OK=false
        cd ${wd}
        ${OK}
    else
        git clone -q "doc:/vol/lab/firstyear/Repositories/2011-2012/161/$2/$1.git" $1/$2 || \
        git clone -q "doc:/vol/lab/firstyear/Repositories/2011-2012/161/$2/$1" $1/$2
    fi
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
    git --git-dir ${exercise}/${tutee}/.git diff -U1000 ${skelhash}..master > ${exercise}/${tutee}.diff
    echo "  * ${tutee} changed $(wc -l ${exercise}/${tutee}.diff | cut -d' ' -f1) lines"
    enscript -b "${tutee} - Diff - ${exercise}" -o ${exercise}/${tutee}-diff.ps --color -Ediffu -G -f Courier8 -2r ${exercise}/${tutee}.diff
done

echo "Generating printable checkstyle reports"

for tutee in ${tutees}; do
    checkstyle -c "${base_dir}/almost_sun_checks.xml" $(find "${exercise}/${tutee}" -name '*.java') > ${exercise}/${tutee}.checkstyle || true
    enscript -b "${tutee} - Style - ${exercise}" -o ${exercise}/${tutee}-style.ps -G -f Courier8 ${exercise}/${tutee}.checkstyle
done
