#!/bin/bash

DEFAULT_REGION=europe-west1-b
GCLOUD_CFG_REGION=$(gcloud config get-value compute/region)

if [[ $LAB_REGION ]]
then
    gcloud config set compute/region $LAB_REGION
elif [[ $GCLOUD_CFG_REGION ]]
then 
    echo "Compute Region not explicitly configured, using gcloud config: ${GCLOUD_CFG_REGION}"
else
    echo "No Compute Region set, using Arista Dojo default: ${DEFAULT_REGION}"
    gcloud config set compute/region ${DEFAULT_REGION}
fi

COMP_ENG_API_STATE=$(gcloud services list --filter='NAME:compute.googleapis.com' --format=json | jq '.[0].state')

if [[ $COMP_ENG_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable compute engine api, wait 1 min"
    gcloud services enable compute.googleapis.com
    sleep 60
fi

echo "Starting the EVE NG instance"
gcloud beta compute instances create eve-ng \
    --machine-type=n1-standard-2 \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --image=https://www.googleapis.com/compute/v1/projects/aristadojo/global/images/aristadojo-eveng-v1 \
    --image-project=${GOOGLE_CLOUD_PROJECT} \
    --boot-disk-size=32GB \
    --boot-disk-type=pd-balanced \
    --boot-disk-device-name=eve-ng \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --min-cpu-platform="Intel Haswell" \
    --enable-nested-virtualization
    --tags=eve-ng

if [[ $MY_IP_SUBNET ]]
then
    echo "Access will be restricted to src subnet: ${MY_IP_SUBNET} "
else
    MY_IP_SUBNET="0.0.0.0/0"
    echo "WARNING: Any IP address / subnet can access the labs exposed port!!!!"
fi

gcloud compute --project=aristalab firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=$MY_IP_SUBNET \
    --target-tags=eve-ng

gcloud compute --project=aristalab firewall-rules create eve-ng-telnet \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:32769-33280 \
    --source-ranges=$MY_IP_SUBNET \
    --target-tags=eve-ng