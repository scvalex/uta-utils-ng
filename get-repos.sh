#!/bin/sh

set -e

function usage {
    echo "$0 <exercise-name> [<tutee>]"
}

exercise=$1
if [ "x${exercise}" = "x" ]; then
    usage
    exit 1
fi

if [ "x$2" = "x" ]; then
    tutees="dd1711 tod11 jdl11 omm11 mpn10 jr1611 pjr11 yx2411 td1011"
else
    tutees=$2
fi

## get_repo PictureProcessing dd1711
function get_repo {
    git clone -q "doc:/vol/lab/firstyear/Repositories/2011-2012/161/$2/$1.git" $1/$2 || \
    git clone -q "doc:/vol/lab/firstyear/Repositories/2011-2012/161/$2/$1" $1/$2
}

echo "Getting repos..."

mkdir -p ${exercise}
for tutee in ${tutees} Masters; do
    [ -d "${exercise}/${tutee}" ] && rm -rf "${exercise}/${tutee}"
    get_repo ${exercise} ${tutee}
done

skelhash=$(git --git-dir ${exercise}/Masters/.git log --format=%h | tail -n1)

echo "Comparing with skeleton solution (${skelhash})"

for tutee in ${tutees}; do
    git --git-dir ${exercise}/${tutee}/.git diff ${skelhash}..master > ${exercise}/${tutee}.diff
    echo "${tutee} changed $(wc -l ${exercise}/${tutee}.diff | cut -d' ' -f1) lines"
done

echo "Generating printable differences"

for tutee in ${tutees}; do
    enscript -b "${tutee} - ${exercise}" -o ${exercise}/${tutee}.ps --color --style=diffs -f Courier8 -2r ${exercise}/${tutee}.diff
done
