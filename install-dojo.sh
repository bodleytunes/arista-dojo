#!/bin/bash

# Set the following env vars to override defaults
#  LAB_REGION=europe-west1|europe-west2|us-central-2/etc
#  MACHINE_TYPE=n1-standard-8|etc
#  MY_IP_SUBNET=1.2.3.4/32

DEFAULT_LAB_REGION=europe-west1
DEFAULT_MACHINE_TYPE=n2-standard-4

EVE_IMG=aristadojo-eveng-v2
EVE_IMG_PRJ=aristadojo
GCLOUD_CFG_REGION=$(gcloud config get-value compute/region)

if [[ -z $MACHINE_TYPE ]]
then
    MACHINE_TYPE=DEFAULT_MACHINE_TYPE
fi

if [[ $LAB_REGION ]]
then
    gcloud config set compute/region $LAB_REGION
elif [[ $GCLOUD_CFG_REGION ]]
then 
    echo "Compute Region not explicitly configured, using gcloud config: ${GCLOUD_CFG_REGION}"
    export LAB_REGION=${GCLOUD_CFG_REGION}
else
    echo "No Compute Region set, using Arista Dojo default: ${DEFAULT_LAB_REGION}"
    gcloud config set compute/region ${DEFAULT_LAB_REGION}
    export LAB_REGION=${DEFAULT_LAB_REGION}
fi


export ZONE=$(
    gcloud compute zones list \
        --filter="region:(${LAB_REGION}) AND status:(UP)" \
        --format=json \
        | jq -r '.[0].name'
)
gcloud config set compute/zone $ZONE

COMP_ENG_API_STATE=$(
    gcloud services list \
        --filter='NAME:compute.googleapis.com' \
        --format=json \
        | jq -r '.[0].state'
)

if [[ $COMP_ENG_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable compute engine api"
    gcloud services enable compute.googleapis.com
    WAIT_FOR_API=true
fi
if [[ $WAIT_FOR_API ]]
then
    echo "Waiting 1 min for API to enable"
    sleep 60
fi

echo "Starting the EVE NG instance"
gcloud beta compute instances create eve-ng \
    --machine-type=${MACHINE_TYPE} \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --image=https://www.googleapis.com/compute/v1/projects/${EVE_IMG_PRJ}/global/images/${EVE_IMG} \
    --image-project=${GOOGLE_CLOUD_PROJECT} \
    --boot-disk-size=32GB \
    --boot-disk-type=pd-balanced \
    --boot-disk-device-name=eve-ng \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any \
    --enable-nested-virtualization \
    --tags=eve-ng \
    --zone=${ZONE} \
    --labels=ttl=24h

if [[ $MY_IP_SUBNET ]]
then
    echo "Access will be restricted to src subnet: ${MY_IP_SUBNET} "
else
    MY_IP_SUBNET="0.0.0.0/0"
    echo "WARNING: Any IP address / subnet can access the labs exposed port!!!!"
fi

gcloud compute firewall-rules create eve-ng-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=$MY_IP_SUBNET \
    --target-tags=eve-ng

gcloud compute firewall-rules create eve-ng-telnet \
    --direction=INGRESS \
    --priority=2000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:32769-33280 \
    --source-ranges=$MY_IP_SUBNET \
    --target-tags=eve-ng
