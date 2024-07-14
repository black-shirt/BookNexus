import json
import boto3

dynamoDB = boto3.resource('dynamodb')
bookTable = dynamoDB.Table("BN-Books")

def lambda_handler(event, context):
    ISBN = event['queryStringParameters']['ISBN']
    
    book = bookTable.get_item(Key={"ISBN": ISBN})["Item"]
    available = book['available']
    borrowed = book['issued']
    available -= 1
    borrowed += 1
    
    bookTable.update_item(
        Key={'ISBN': ISBN},
        UpdateExpression="set available=:a, issued=:b",
        ExpressionAttributeValues={
            ':a': available,
            ':b': borrowed
        },
        ReturnValues="UPDATED_NEW")
        
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
