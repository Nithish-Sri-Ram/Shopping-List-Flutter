import 'package:flutter/material.dart';
import 'package:shopping_list/modals/grocerry_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GrocerryList extends StatefulWidget {
  const GrocerryList({super.key});

  @override
  State<GrocerryList> createState() => _GrocerryListState();
}

class _GrocerryListState extends State<GrocerryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(//we mention which kind of data we'll yield
            MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No items added yet'),
    );
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems
            .length, //we Assign this so that it will show the number of items in the list view
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            setState(() {
              _groceryItems.removeAt(index);
            });
          },
          key: ValueKey(_groceryItems[index].name),  //DIsmissible widget needs a unique key to identify the item
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
