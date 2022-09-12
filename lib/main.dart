
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(title: 'crud operation', home: MyApp()));
}

class MyApp extends StatelessWidget {
  final CollectionReference _product =
      FirebaseFirestore.instance.collection('products');

  MyApp({Key? key}) : super(key: key);
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  Future<void> _update({DocumentSnapshot? documentSnapshot, BuildContext? context}) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'];
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context!,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(label: Text('Name')),
              ), TextField(
                controller: _priceController,
                decoration: const InputDecoration(label: Text('Price')),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: ()async{
                final String name = _nameController.text;
                final String price = _priceController.text;
                await _product.doc(documentSnapshot!.id).update(
                    {'name': name, 'price': price});
                _nameController.text='';
                _priceController.text = '';
              }, child: const Text('Update'))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _product.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['name']),
                      subtitle: Text(documentSnapshot['price']),
                      trailing: SizedBox(
                        width: 50,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _update(documentSnapshot: documentSnapshot, context: context);
                                },
                                icon: const Icon(Icons.edit))
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
