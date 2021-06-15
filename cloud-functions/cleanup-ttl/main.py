import base64
import os
from json import loads
from pprint import pprint

from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

def ttl_label_cleanup(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.

    Looks for all instance in all zones with a ttl label that is equal
    to the ttl values recieved in the pub/sub event.

    The pub/sub message is triggered by a gcloud scheduler job
    """
    print(
        "Func was triggered by messageId {} published at {}".format(
            context.event_id, context.timestamp
        )
    )
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print('pubsub_message: {}'.format(pubsub_message))
    message = loads(pubsub_message)
    label_filter = 'labels.ttl:{}'.format(message['ttl'])

    credentials = GoogleCredentials.get_application_default()
    service = discovery.build(
        'compute', 'v1', credentials=credentials
    )
    project = os.environ.get('GCP_PROJECT', None)

    request = service.zones().list(project=project)
    zones = []
    while request is not None:
        response = request.execute()
        for zone in response['items']:
            zones.append(zone['name'])
        request = service.zones().list_next(previous_request=request, previous_response=response)

    for zone in zones:
        instances = []
        request = service.instances().list(project=project, zone=zone, filter=label_filter)
        while request is not None:
            response = request.execute()
            try:
                for instance in response['items']:
                    instances.append(instance['name'])
            except KeyError:
                pass
            request = service.instances().list_next(previous_request=request, previous_response=response)

        for instance in instances:
            print('Attempting to delete instance: {}'.format(instance))
            request = service.instances().delete(project=project, zone=zone, instance=instance)
            response = request.execute()
            print(response)
