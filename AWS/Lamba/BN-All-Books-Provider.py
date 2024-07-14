import json
import boto3

from custom_encoder import CustomEncoder

dynamoDB = boto3.resource('dynamodb')
bookTable = dynamoDB.Table("BN-Books")


def lambda_handler(event, context):
    books = bookTable.scan()['Items']
    
    return {
        'statusCode': 200,
        'headers': {
            'content-type': 'application/json'
        },
        'body': json.dumps({'searchResult': books[:]}, cls=CustomEncoder)
    }
