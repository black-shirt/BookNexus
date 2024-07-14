import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odoo_combat/widgets/individual_book.dart';

import '../models/book.dart';

class HomeScreen extends StatefulWidget{
  final String userEmail;
  const HomeScreen({super.key, required this.userEmail});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen>
{
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearchOver = false;
  List<Book> searchedBooks = [];

  void removeBook({required Book book})
  {
    searchedBooks.remove(book);
  }

  void _searchBooks() async
  {
    setState(() {
      _isLoading = true;
      _isSearchOver = false;
    });
    searchedBooks = [];
    String query = _searchController.text.toLowerCase();
    final response = await http.post(
      body: json.encode({
        "query": query,
        "userEmail": widget.userEmail
      }),
      Uri.parse(
          'https://wccgslv831.execute-api.ap-south-1.amazonaws.com/prod/search-books'),
    );
    final responseBody = await jsonDecode(response.body);
    final searchResults = await responseBody['searchResult'];
    if (searchResults != null)
      {
        for (final book in searchResults)
        {
          var response = await http.get(
              Uri.parse('https://wccgslv831.execute-api.ap-south-1.amazonaws.com/prod/get-book-coverpage?ISBN=${book['ISBN']}')
          );
          final responseBodyBytes = response.bodyBytes;
          final coverPhoto = Image.memory(Uint8List.fromList(responseBodyBytes)).image;
          searchedBooks.add(
              Book(
                  title: book['title'],
                  authorName: book['authorName'],
                  binding: book['binding'],
                  borrowRate: book['borrowRate'].toInt(),
                  description: book['description'],
                  edition: book['edition'],
                  genre: book['genre'],
                  isbn: book['ISBN'],
                  numberOfPages: book['numberOfPages'].toInt(),
                  price: book['price'].toInt(),
                  publisher: book['publisher'],
                  publishingYear: book['publishingYear'],
                  rating: book['rating'].toInt(),
                  coverPhoto: coverPhoto,
                  status: book['status'].toInt()
              )
          );
        }
      }
    else
      {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opps! No such books found")));
      }
    setState(() {
      _isLoading = false;
      _isSearchOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Books', style: TextStyle(color: Colors.white),), backgroundColor: const Color.fromRGBO(80, 160, 171, 1),),
      body: _isLoading?
      const Center(child: CircularProgressIndicator(color: Color.fromRGBO(80, 160, 171, 1),),)
          :
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _searchBooks();
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 2, 10, 2),
                labelText: 'Enter Book title or relevant details',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          if(_isSearchOver && searchedBooks.isNotEmpty) Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                childAspectRatio: 0.7, // Adjust this ratio as needed
              ),
              itemCount: searchedBooks.length,
              itemBuilder: (context, index) {
                return BookWidget(book: searchedBooks[index], removeBook: removeBook,);
              },
            ),
          ),
        ],
      )
    );
  }

}
