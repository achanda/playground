#!/bin/bash

set -x

#pass the Google Compute Engine Project as parameter

NUM_NODES=${NUM_NODES:-3}
ETCD_DISCOVERY_URL=$(curl --silent https://discovery.etcd.io/new?size=$NUM_NODES)
IMAGE="https://www.googleapis.com/compute/v1/projects/coreos-cloud/global/images/coreos-stable-607-0-0-v20150317"
METADATA="http://metadata/computeMetadata/v1"

for N in `seq 1 $NUM_NODES`
do
        gcloud compute instances create core-$N \
        --project $1 \
        --image $IMAGE \
        --zone us-central1-a \
        --machine-type n1-standard-4 \
        --metadata-from-file startup-script=cloud-config.yaml
        echo "Created instance core-$N"
done
