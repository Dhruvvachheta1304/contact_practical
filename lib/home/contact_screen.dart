import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;

  final _scrollController = ScrollController();
  double itemHeight = 80.0;

  final _contactBox = Hive.box('contact_box');

  //kEy
  GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Declare GlobalKey outside the class

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _contactBox.keys.map((key) {
      final item = _contactBox.get(key);
      return {"key": key, "name": item["name"], "number": item["number"], "birthdate": item["birthdate"]};
    }).toList();

    setState(() {
      _items = data.toList()..sort((a, b) => a['name'].compareTo(b['name'])); // Sort items
      print(_items);
      _filteredItems = _items; // Initialize filtered list with all items
    });
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredItems = _items.where((contact) {
        final String name = contact['name'].toString().toLowerCase();
        final String number = contact['number'].toString().toLowerCase();
        final String lowercaseQuery = query.toLowerCase();

        return name.contains(lowercaseQuery) || number.contains(lowercaseQuery);
      }).toList();
    });
  }

  //Sorting
  void _sortContacts() {
    setState(() {
      if (_isAscending) {
        _filteredItems.sort((a, b) => a['name'].compareTo(b['name']));
      } else {
        _filteredItems.sort((a, b) => b['name'].compareTo(a['name']));
      }
      _isAscending = !_isAscending;
    });
  }

  //Create new contact
  Future<void> _createContact(Map<String, dynamic> newContact) async {
    await _contactBox.add(newContact);
    print('amount data is ${_contactBox.length}');
    _refreshItems();

    final String newContactName = newContact['name'];
    final String newContactSection = _getFirstLetter(newContactName);
    for (int i = 0; i < _filteredItems.length; i++) {
      final String currentItemName = _filteredItems[i]['name'];
      final String currentSection = _getFirstLetter(currentItemName);
      if (currentSection == newContactSection) {
        _scrollController.animateTo(i.toDouble() * itemHeight,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        break;
      }
    }
  }

  //Update contact
  Future<void> _updateContact(int itemKey, Map<String, dynamic> item) async {
    await _contactBox.put(itemKey, item);
    _refreshItems();
  }

  //Remove contact
  Future<void> _deleteContact(int itemKey) async {
    await _contactBox.delete(itemKey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact Has been Deleted Successfully'),
      ),
    );
  }

  // Show DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthdateController.text = pickedDate.toString();
      });
    }
  }

  //
  void _showUp(BuildContext ctx, int? itemKey) {
    if (itemKey != null) {
      final existingItem = _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _numberController.text = existingItem['number'];
      _birthdateController.text = existingItem['birthdate'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              // height: 100,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _numberController,
                      decoration: const InputDecoration(hintText: 'Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        } else if (value.length < 10) {
                          return 'Number should be at least 10 digits';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: _birthdateController,
                      readOnly: true,
                      onTap: () => _selectDate(ctx),
                      decoration: const InputDecoration(
                        hintText: 'Birthdate',
                        suffixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a birthdate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          if (itemKey == null) {
                            _createContact({
                              'name': _nameController.text,
                              'number': _numberController.text,
                              'birthdate': _birthdateController.text,
                            });
                          } else {
                            _updateContact(itemKey, {
                              'name': _nameController.text.trim(),
                              'number': _numberController.text.trim(),
                              'birthdate': _birthdateController.text.trim(),
                            });
                          }

                          _nameController.clear();
                          _numberController.clear();
                          _birthdateController.clear();

                          Navigator.pop(context);
                        }
                      },
                      child: Text(itemKey == null ? 'Create Contact' : 'Update'),
                    ),
                  ],
                ),
              ),
            ));
  }

  //section methodd
  String _getFirstLetter(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  //by bday
//by bday
  void _filterContactsByDateRange(DateTime startDate, DateTime endDate) {
    print('Start Date: $startDate'); // Add this line
    print('End Date: $endDate'); // Add this line

    setState(() {
      _filteredItems = _items.where((contact) {
        final DateTime birthdate = DateTime.parse(contact['birthdate']);

        // Check if the contact's birthdate falls within the specified range
        final bool matchesDateRange =
            (startDate == null || birthdate.isAfter(startDate)) && (endDate == null || birthdate.isBefore(endDate));

        return matchesDateRange;
      }).toList();

      print('Filtered Items Count: ${_filteredItems.length}'); // Add this line
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
            0.3,
            6,
          ],
          colors: [
            Colors.black87,
            Colors.indigo.shade900.withGreen(3),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Contact Screen',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 10),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Search by name or number',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 9.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70), borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                onChanged: _filterContacts,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    DateTime? startDate;
                    DateTime? endDate;
                    final List<DateTime?> pickedDates = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: const Text('Select Date Range'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Start Date: ${startDate != null ? _dateFormat.format(startDate!) : 'Not Selected'}'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: startDate ?? DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          startDate = pickedDate;
                                        });
                                      }
                                      print('Start Date: $startDate'); // Add this line
                                    },
                                    child: const Text('Select Start Date'),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text('End Date: ${endDate != null ? _dateFormat.format(endDate!) : 'Not Selected'}'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: endDate ?? DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          endDate = pickedDate;
                                        });
                                      }
                                      print('End Date: $endDate'); // Add this line
                                    },
                                    child: const Text('Select End Date'),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop([startDate, endDate]);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                    if (pickedDates != null) {
                      print('Selected Dates: $pickedDates'); // Add this line
                      _filterContactsByDateRange(pickedDates[0]!, pickedDates[1]!);
                    }
                  },
                  icon: const Icon(
                    Icons.date_range,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: _sortContacts,
                  icon: Icon(
                    _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (_, index) {
                  final currentItem = _filteredItems[index];
                  final String section = _getFirstLetter(currentItem['name']);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0 || _getFirstLetter(_filteredItems[index - 1]['name']) != section)
                        Padding(
                          padding: const EdgeInsets.only(left: 13, top: 13),
                          child: Text(
                            section,
                            style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo.shade700, width: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.indigo.shade900, Colors.black87],
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // tileColor: Colors.indigo.shade700,
                          iconColor: Colors.white,
                          dense: true,
                          title: Text(
                            currentItem['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                          ),
                          textColor: Colors.white,
                          trailing: Row(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _showUp(context, currentItem['key']);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 22,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    _deleteContact(currentItem['key']);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 22,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigo.shade700, width: 0.5),
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade600, Colors.black12],
            ),
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            onPressed: () {
              _showUp(context, null);
            },
            tooltip: 'Add Contact',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
