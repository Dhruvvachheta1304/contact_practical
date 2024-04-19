// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:task13/home/contact_screen.dart';
//
// void main() async {
//   // WidgetsFlutterBinding.ensureInitialized();
//   // await Hive.initFlutter();
//   // await Hive.openBox('contact_box');
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   Hive.registerAdapter(ContactAdapter());
//   await Hive.openBox<Contact>('contacts');
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         debugShowCheckedModeBanner: false,
//         home: const ContactScreen());
//   }
// }

//////////////////////////////////

////
///
/// ////
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
//
// class Contact {
//   late String name;
//   late String phoneNumber;
//   late DateTime birthDate;
//
//   Contact(this.name, this.phoneNumber, this.birthDate);
// }
//
// class ContactAdapter extends TypeAdapter<Contact> {
//   @override
//   final int typeId = 0;
//
//   @override
//   Contact read(BinaryReader reader) {
//     return Contact(
//       reader.read() as String,
//       reader.read() as String,
//       reader.read() as DateTime,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Contact obj) {
//     writer.write(obj.name);
//     writer.write(obj.phoneNumber);
//     writer.write(obj.birthDate);
//   }
// }
//
// class ContactScreen extends StatefulWidget {
//   const ContactScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ContactScreen> createState() => _ContactScreenState();
// }
//
// class _ContactScreenState extends State<ContactScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _birthdateController = TextEditingController();
//
//   late Box<Contact> _contactsBox;
//
//   @override
//   void initState() {
//     super.initState();
//     _contactsBox = Hive.box<Contact>('contacts');
//   }
//
//   Future<void> _createContact() async {
//     final newContact = Contact(
//       _nameController.text,
//       _phoneController.text,
//       DateTime.parse(_birthdateController.text),
//     );
//     await _contactsBox.add(newContact);
//     _nameController.clear();
//     _phoneController.clear();
//     _birthdateController.clear();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Contact Screen'),
//         centerTitle: true,
//       ),
//       body: ListView(
//         children: [
//           ValueListenableBuilder<Box<Contact>>(
//             valueListenable: _contactsBox.listenable(),
//             builder: (_, box, __) {
//               return ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: box.length,
//                 itemBuilder: (_, index) {
//                   final contact = box.getAt(index)!;
//                   return ListTile(
//                     title: Text(contact.name),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(contact.phoneNumber),
//                         Text('Birthdate: ${contact.birthDate.toString()}'),
//                       ],
//                     ),
//                     onLongPress: () {
//                       box.deleteAt(index);
//                       setState(() {});
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: 'Name'),
//                 ),
//                 TextField(
//                   keyboardType: TextInputType.number,
//                   controller: _phoneController,
//                   decoration: const InputDecoration(labelText: 'Phone Number'),
//                 ),
//                 TextField(
//                   controller: _birthdateController,
//                   decoration: const InputDecoration(labelText: 'Birthdate (YYYY-MM-DD)'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _createContact,
//                   child: const Text('Add Contact'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   Hive.registerAdapter(ContactAdapter());
//   await Hive.openBox<Contact>('contacts');
//   runApp(const MaterialApp(
//     home: ContactScreen(),
//   ));
// }
