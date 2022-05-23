from botocore.exceptions import ClientError
import boto3
import logging, os

# Instantiate logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instantiate boto3 client
client = boto3.client('ec2')

# List of AWS Accounts ID's
PROD = os.environ.get('PROD')
DEV = os.environ.get('DEV')

AccountList = [
    PROD,
    DEV
]

def lambda_handler(event, context):
    logger.info(f'event: {event}')
    ImageID = event['ImageID']

    try:
        for account in AccountList:
            response = client.modify_image_attribute(
                ImageId='{}'.format(ImageID),
                LaunchPermission={
                    'Add': [
                        {
                            'UserId': '{}'.format(account),
                        },
                    ],
                },
            )
            logger.info("Launch Permission to Account {} added".format(account))
            logger.info(response)

    except ClientError as error:
        logger.error(error)
        return {
            'statusCode': 500,
            'response_from': 'Lambda',
            'body': error,
			'moreInfo': {
                'Lambda Request ID': '{}'.format(context.aws_request_id),
                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                'CloudWatch log group name': '{}'.format(context.log_group_name)
			}
        }