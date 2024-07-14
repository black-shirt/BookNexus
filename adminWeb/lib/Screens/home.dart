import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../widgets/individual_book.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key,});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen>
{
  bool _isLoading = false;
  bool _isSearchOver = false;
  List<Book> searchedBooks = [];

  void removeBook({required Book book})
  {
    searchedBooks.remove(book);
  }
  @override
  void initState() {
    _searchBooks();
    super.initState();
  }

  void _searchBooks() async
  {
    setState(() {
      _isLoading = true;
      _isSearchOver = false;
    });
    searchedBooks = [];
    final response = await http.post(
      Uri.parse(
          'https://wccgslv831.execute-api.ap-south-1.amazonaws.com/prod/get-all-books'),
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
        appBar: AppBar(title: const Text('Books', style: TextStyle(color: Colors.white),), backgroundColor: const Color.fromRGBO(80, 160, 171, 1),),
        body: _isLoading?
        const Center(child: CircularProgressIndicator(color: Color.fromRGBO(80, 160, 171, 1),),)
            :
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
