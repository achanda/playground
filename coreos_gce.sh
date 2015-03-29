#!/bin/bash

set -x

#pass the Google Compute Engine Project as parameter

NUM_NODES=${NUM_NODES:-3}
ETCD_DISCOVERY_URL=$(curl --silent https://discovery.etcd.io/new?size=$NUM_NODES)
IMAGE=$(gcloud compute images list | grep 'coreos-stable*' | cut -d" " -f 1)
METADATA="http://metadata/computeMetadata/v1/"

for N in `seq 1 $NUM_NODES`
do
        gcloud compute instances create core-$N \
        --project $1 \
        --image $IMAGE \
        --zone "us-central1-a" \
        --machine-type "n1-standard-4" \
        --metadata startup-script="#!/bin/sh
        ETCD_DISCOVERY_URL=$ETCD_DISCOVERY_URL
        HOSTNAME=\$(curl $METADATA/hostname)
        IPADDR=\$(ifconfig eth0| grep 'inet ' | cut -dt -f2 | awk '{ print \$1}')
        sudo systemctl start fleet
        etcd -name \$HOSTNAME -peer-addr \$IPADDR:7001 -addr \$IPADDR:4001 -discovery \$ETCD_DISCOVERY_URL
        "
        echo "Created instance core-$N"
done
