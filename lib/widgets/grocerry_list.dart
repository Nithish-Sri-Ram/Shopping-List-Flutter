import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/modals/category.dart';
import 'package:shopping_list/modals/grocerry_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GrocerryList extends StatefulWidget {
  const GrocerryList({super.key});

  @override
  State<GrocerryList> createState() => _GrocerryListState();
}

class _GrocerryListState extends State<GrocerryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading =
      true; //The screen will initially show that no item is added when it is loading which won't be the case after the items are loaded
  //and will be set to false once it is loaded
  String? _error;

  @override //When the app starts or restarts we want to load the items from the database
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'shopping-list-flutter-2ede3-default-rtdb.firebaseio.com',
        'Shopping-List.json');
  try{
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later.';
      });
    }

    if(response.body=='null') //If the response is null we will set the list to empty if there is no data available in the backand
    {
      setState(() {
        _isLoading=false;
      });
      return;
    }

    // print(response.body);
    final Map<String, dynamic> listData =
        json.decode(response.body); //Decode json text format to a map
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((element) => element.value.name == item.value['category'])
          .value; //We are finding the category from the categories list
      loadedItems.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading =
          false; //once the items are loaded we set the loading to false
    });
  } catch(error){
    setState(() {
      _error='Something went wrong! Please try again later.';
    });
  }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(//we mention which kind of data we'll yield
            MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) //If the user cancels the dialog box
    {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    //Here the above process adds the data to the screen instantly but we need to add it to the database too
    // _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final index=_groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'shopping-list-flutter-2ede3-default-rtdb.firebaseio.com',
        'Shopping-List/${item.id}.json');

    final response = await http.delete(url);

    if(response.statusCode>=400)    //if any error occurs we will add the item back to the list
    {
      //optional: show an error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems
            .length, //we Assign this so that it will show the number of items in the list view
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index]
              .name), //DIsmissible widget needs a unique key to identify the item
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
