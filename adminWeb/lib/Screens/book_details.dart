import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:http/http.dart' as http;

class BookDetailPage extends StatefulWidget {
  final Book book;
  void Function({required Book book}) removeBook;

  BookDetailPage({super.key, required this.book, required this.removeBook});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool isBorrowed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromRGBO(80, 160, 171, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.book.coverPhoto,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.book.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Author: ${widget.book.authorName}', style: const TextStyle(fontSize: 18)),
              Text('ISBN: ${widget.book.isbn}', style: const TextStyle(fontSize: 16)),
              Text('Publisher: ${widget.book.publisher}', style: const TextStyle(fontSize: 16)),
              Text('Year: ${widget.book.publishingYear}', style: const TextStyle(fontSize: 16)),
              Text('Genre: ${widget.book.genre}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text('Price: ${widget.book.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Weekly Borrow rate: ${widget.book.borrowRate}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.book.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isBorrowed ? null : () {
                      _borrowBook();
                    },
                    child: Text(isBorrowed ? 'Borrowed' : 'Borrow'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _buyBook();
                    },
                    child: const Text('Buy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _borrowBook() async {
    await http.get(
        Uri.parse('https://wccgslv831.execute-api.ap-south-1.amazonaws.com/prod/borrow-book?ISBN=${widget.book.isbn}')
    );
    setState(() {
      isBorrowed = true; // Update the state to reflect the book is borrowed
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Borrowed Successfully')),
    );
    widget.removeBook(book: widget.book);
    Navigator.pop(context);
  }

  void _buyBook() async {
    await http.get(
        Uri.parse('https://wccgslv831.execute-api.ap-south-1.amazonaws.com/prod/buy-book?ISBN=${widget.book.isbn}')
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bought Successfully')),
    );
    widget.removeBook(book: widget.book);
    Navigator.pop(context);
  }
}
