import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  File? _image;
  bool showSpinner = false;
  final _picker = ImagePicker();
  final postRef = FirebaseDatabase.instance.ref().child("posts");
  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;

  void _dialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            content: SizedBox(
              height: 120,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text("Camera"),
                    onTap: () {
                      getImageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text("Gallery"),
                    onTap: () {
                      getImageFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImageFromGallery() async {
    final _pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (_pickedImage != null) {
        _image = File(_pickedImage.path);
      } else {
        const Text("No image seleted!");
      }
    });
  }

  getImageFromCamera() async {
    final _pickedImage = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (_pickedImage != null) {
        _image = File(_pickedImage.path);
      } else {
        const Text("No image seleted!");
      }
    });
  }

  Future uploadImageToFirebase() async {
    return await FirebaseFirestore.instance.collection("posts").doc().set({
      "img": _image!.path,
      "title": titleController.text,
      "description": desController.text,
    }).then((value) {
      Navigator.of(context).pop();
      debugPrint("Post Published");
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Glance"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    _dialog(context);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * .25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                    ),
                    child: _image != null
                        ? ClipRect(
                            child: Image.file(
                              _image!.absolute,
                              fit: BoxFit.fill,
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * .2,
                            width: double.infinity,
                            child: const Center(
                              child: Icon(
                                Icons.camera,
                                size: 40,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Add Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: desController,
                        maxLines: 8,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "How are you feeling?",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          onPressed: () => uploadImageToFirebase(),
                          child: const Text("Post"))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
