#!/bin/bash

read imagetag < image.txt
read imagepath tag <<<$(IFS=":"; echo $imagetag)
image=${imagepath##*/}
 
localimage="${DOCKER_REGISTRY}/$image"
localimagetag="${DOCKER_REGISTRY}/${image}:${tag}"

echo "image: $imagetag, local image: $localimagetag"

docker pull $imagetag
docker tag $imagetag $localimagetag
docker push $localimagetag

digest_val=$(./scripts/get-digest.sh "$localimage" "$tag")

outdir="$1"
mkdir -p $outdir

cp image.txt $outdir/.
cp *.yml $outdir/.

echo $digest_val > $outdir/digest.txt
export digest="@$digest_val"

./scripts/replace-values.sh -r -l "$outdir" -p '*.yml'
