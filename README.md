# BookNexus
BookNexus is a comprehensive Library Management System that allows users to efficiently manage book inventories and transactions. It has two types of users:

Library User:

Can issue and purchase books.
Can search for books and receive recommendations based on previously issued books.
Can view brief descriptions of books, including author names, genres, publication years, publisher names, ratings, etc.
Admin:

Can view a list of all books and their details.
The text data is stored in an AWS DynamoDB database. User authorization and authentication are handled through Firebase. The mobile app is developed using Flutter.
The REST APIs are built using AWS API Gateway.
The image data is stored on AWS S3.
