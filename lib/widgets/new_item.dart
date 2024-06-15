import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/modals/category.dart';
import 'package:shopping_list/modals/grocerry_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<
      FormState>(); //global key creates a global key object then used as value of key below
  //global key gives easy access to the underlying widget
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.other]!;
  var _isSending =
      false; //This will be used to show the loading spinner when an objcet is added so the user might not click the button again

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      //this will call the validator function of the form and also we know it wont be null because we create the key inside the build function
      _formKey.currentState!
          .save(); //this will call the save function of the form and another special function will be triggered - (onSaved)
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'shopping-list-flutter-2ede3-default-rtdb.firebaseio.com',
          'Shopping-List.json'); //This second argument createas a node in the mentioned name, we can give any name and we can create multipe nodes as required by the app
      //In the rules section of the firebase we can set the rules for the database set read and write as true so it will allow all the users to read and write the data - it will aloow all incoming requests
      final response = await http.post(
          url, //the post method gives us a future object, by adding the await method dart indirectly access the then method of the future object - we could alternatively use the then method too
          headers: {
            //The keys are header identifiers and the values are settings for those headers, here we are having only one headeer
            'Content-type':
                'application/json', //Rhis will help firebase understand how the data is formatted - which we are sending to it
          },
          body: json.encode({
            //Here the body needs that is formatted as json so we need to convert the data into json format
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.name,
          }));

      //Since we get the key value here we can use it to update the item in the list
      final Map<String, dynamic> responseData = json.decode(response.body);

      //context - should't be used after async await
      if (!context
          .mounted) //if the context is not mounted - if the widget is not on the screen it will return
      {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
        id: responseData['name'],
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _selectedCategory,
      )); //flutter doesnt know with certainity that this context was same as the one for which we awaited the response - for eg: we could have navigated away from this widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key:
              _formKey, //this should be the key of the form we should create as a property of the state
          child: Column(
            children: [
              TextFormField(
                //INstead of textfield we can use TextFormField inside a form widget - it is same as the later one but gives extra features like the validator function
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Name'),
                //with this function we can tell flutter when to validate this form
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    //this will take the whole width of the screen and the other will take the remaining space
                    child: TextFormField(
                      //textfield is also unconstrained horizontally as the row widget
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          //we add exclaimation to tell dart that we are sure that the value is not null
                          return 'Must be valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      items: [
                        for (final category in categories
                            .entries) //the .entries will comvert the map into list a function provided by dart
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.name),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory =
                              value!; //The currently changed value is reflected on screen so we have to use setstate and other places it is not reqiured
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
