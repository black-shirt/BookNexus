import 'package:flutter/material.dart';
import '../Screens/book_details.dart';
import '../models/book.dart';

class BookWidget extends StatelessWidget {
  final Book book;
  void Function({required Book book}) removeBook;

  BookWidget({super.key, required this.book, required this.removeBook});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(book.status == 1)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailPage(book: book, removeBook: removeBook,),
              ),
            );
          }
      },
      child: Card(
        elevation: 6.0,
        margin: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: 210, // A4 width in pixels (approx)
                height: 297, // Adjust height as needed
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: book.coverPhoto,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.title,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Author: ${book.authorName}',
                maxLines: 1,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'ISBN: ${book.isbn}',
                maxLines: 1,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Rating: ${book.rating}★', // Displaying the rating with a star
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                book.status == 1 ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 12,
                  color: book.status == 1 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
