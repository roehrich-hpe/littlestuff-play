#!/bin/bash

set -e
new_ver=$1
echo "new version: $new_ver"
docker tag nginx:1.23.4 deanhpe/nginx2:$new_ver

docker push deanhpe/nginx2:$new_ver

tmp_dir=$(mktemp -d)
echo $tmp_dir

git clone git@github.com:roehrich-hpe/lesson-158.git $tmp_dir

sed -i '' -e "s/deanhpe\/nginx2:.*/deanhpe\/nginx2:$new_ver/" $tmp_dir/my-app/1-deployment.yaml

(cd $tmp_dir
git add .
git commit -m "Update image to $new_ver"
git push
)

rm -rf $tmp_dir
