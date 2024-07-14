import json
import boto3

dynamoDB = boto3.resource('dynamodb')

table = dynamoDB.Table("BN-Users") 

def lambda_handler(event, context):
    
    requestBody = json.loads(event['body'])
    table.put_item(Item=requestBody)
    
    return {
        'statusCode': 200,
        'body': json.dumps('USER ADDED')
    }
