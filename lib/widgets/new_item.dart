import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/modals/category.dart';
import 'package:shopping_list/modals/grocerry_item.dart';

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

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      //this will call the validator function of the form and also we know it wont be null because we create the key inside the build function
      _formKey.currentState!
          .save(); //this will call the save function of the form and another special function will be triggered - (onSaved)
      Navigator.of(context).pop(GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory));
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
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: _saveItem, child: const Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
