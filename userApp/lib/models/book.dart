import 'package:flutter/cupertino.dart';

class Book
{
  String isbn;
  String authorName;
  String title;
  String genre;
  String description;
  String publisher;
  String binding;
  String edition;
  int price;
  int borrowRate;
  String publishingYear;
  int rating;
  int numberOfPages;
  ImageProvider coverPhoto;
  int status;

   Book({
    required this.isbn,
    required this.authorName,
    required this.title,
    required this.genre,
    required this.description,
    required this.publishingYear,
    required this.rating,
    required this.numberOfPages,
    required this.publisher,
    required this.binding,
    required this.borrowRate,
    required this.edition,
    required this.price,
    required this.coverPhoto,
    required this.status
   }
  );
}