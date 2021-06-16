#!/bin/bash

SERVICE_ACCOUNT_ID=cf-cleanup-ttl
CLEANUP_ROLE=cleanupttl
TOPIC_NAME=CleanupTTL
SA_EMAIL=${SERVICE_ACCOUNT_ID}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
DEFAULT_LAB_CF_REGION=europe-west1

if [[ -z $LAB_CF_REGION ]]
then
    export LAB_CF_REGION=$DEFAULT_LAB_CF_REGION
fi

CLOUD_BUILD_API_STATE=$(
    gcloud services list \
        --filter='NAME:cloudbuild.googleapis.com' \
        --format=json \
        | jq -r '.[0].state'
)
CLOUD_FUNC_API_STATE=$(
    gcloud services list \
        --filter='NAME:cloudfunctions.googleapis.com' \
        --format=json \
        | jq -r '.[0].state'
)
CLOUD_SCHED_API_STATE=$(
    gcloud services list \
        --filter='NAME:cloudscheduler.googleapis.com' \
        --format=json \
        | jq -r '.[0].state'
)
CLOUD_APPENG_API_STATE=$(
    gcloud services list \
        --filter='NAME:appengine.googleapis.com' \
        --format=json \
        | jq -r '.[0].state'
)
CLOUD_PUBSUB_API_STATE=$(
    gcloud services list \
        --filter='NAME:pubsub.googleapis.com ' \
        --format=json \
        | jq -r '.[0].state'
)




if [[ $CLOUD_FUNC_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable cloud function api"
    gcloud services enable cloudfunctions.googleapis.com
    WAIT_FOR_API=true
fi
if [[ $CLOUD_BUILD_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable cloud build api"
    gcloud services enable cloudbuild.googleapis.com
    WAIT_FOR_API=true
fi
if [[ $CLOUD_SCHED_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable cloud schedule api"
    gcloud services enable cloudscheduler.googleapis.com
    WAIT_FOR_API=true
fi
if [[ $CLOUD_APPENG_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable app engine api"
    gcloud services enable appengine.googleapis.com
    WAIT_FOR_API=true
fi
if [[ $CLOUD_PUBSUB_API_STATE != 'ENABLED' ]]
then
    echo "Trying to enable pubsub api"
    gcloud services enable pubsub.googleapis.com
    WAIT_FOR_API=true
fi


if [[ $WAIT_FOR_API ]]
then
    echo "Waiting 1 min for API to enable"
    sleep 60
fi

# Create a role and service account for cleanup ttl cloud
# functions.
gcloud iam roles create $CLEANUP_ROLE \
    --project=${GOOGLE_CLOUD_PROJECT} \
    --file=CleanupTTL.yml

gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
    --description="Service Acc for Cleanup TTL Cloud Func" \
    --display-name="CleanupTTL"

# Grant the service account the cleanup role within the
# the project.
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member=serviceAccount:$SA_EMAIL \
    --role=projects/${GOOGLE_CLOUD_PROJECT}/roles/$CLEANUP_ROLE

# Create the pub/sub topic to trigger the cloud function from
gcloud pubsub topics create $TOPIC_NAME

gcloud functions deploy CleanupTTL \
    --region $LAB_CF_REGION \

    --trigger-topic $TOPIC_NAME \
    --runtime python37 \
    --entry-point=ttl_label_cleanup \
    --memory=128MB \
    --service-account=$SA_EMAIL \
    --source=cloud-functions/cleanup-ttl \
    --timeout=120

# GCP scheduler need an app end to exist to support it
gcloud app create --region=europe-west2
gcloud scheduler jobs create pubsub ttl_cleanup_24h \
    --schedule "* 23 * * *" \
    --topic $TOPIC_NAME \
    --message-body-from-file=ttl-24h-message.json
