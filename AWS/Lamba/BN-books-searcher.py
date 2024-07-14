import json
import boto3

from custom_encoder import CustomEncoder

dynamoDB = boto3.resource('dynamodb')
bookTable = dynamoDB.Table("BN-Books")
usersTable = dynamoDB.Table("BN-Users")


def lambda_handler(event, context):
    reqBody = json.loads(event['body'])
    query = reqBody['query']
    userEmail = reqBody['userEmail']
    queryTokens = query.split()
    books = bookTable.scan()['Items']
    toBeReturned = []
    
    for book in books:
        for token in queryTokens:
            if token in book['authorName'].lower() or token in book['title'].lower() or token in book['publisher'].lower() or token in book['ISBN'].lower() or token in book['description'].lower() or token in book['genre'].lower():
                toBeReturned.append(book)
    
    recentlySearchedTitle = toBeReturned[0]['title']
    recentlySearchedGenre = toBeReturned[0]['genre']
    
    usersTable.update_item(
        Key={'userEmail': userEmail},
        UpdateExpression="set recentlySearchedTitle=:a, recentlySearchedGenre=:b",
        ExpressionAttributeValues={
            ':a': recentlySearchedTitle,
            ':b': recentlySearchedGenre,
        },
        ReturnValues="UPDATED_NEW")
    
    return {
        'statusCode': 200,
        'headers': {
            'content-type': 'application/json'
        },
        'body': json.dumps({'searchResult': toBeReturned}, cls=CustomEncoder)
    }
