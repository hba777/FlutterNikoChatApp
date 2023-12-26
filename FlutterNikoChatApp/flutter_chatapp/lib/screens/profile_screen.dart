import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/screens/auth/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dailogs.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //For changing profile picture
  String? _image;
  //For using Form Widget which is used for validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //Gesture Detector is used to hide keyboard
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile Screen"),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
              backgroundColor: Colors.greenAccent,
              onPressed: () async {
                //Showing Progress
                Dialogs.showProgressBar(context);

                //Updating Last Active Status when logged out
                await APIs.updateActiveStatus(false);

                //SignOut
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //Remove the Progress Bar Once action completed
                    Navigator.pop(context);

                    //For moving to home screen
                    Navigator.pop(context);

                    //Store new data rather than old
                    APIs.auth = FirebaseAuth.instance;

                    //For moving to login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('Logout')),
        ),

        //Form Used for Validation
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 100,
            ),

            //Scrolling fixes Errors
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                Stack(
                  children: [
                    //Profile Picture
                    _image != null
                        //local image
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Center(
                              child: Image.file(
                                //Import dartIO not html
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Center(
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.Image,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        onPressed: () {
                          _showBottomSheet();
                        },
                        color: Colors.white,
                        elevation: 1,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(widget.user.Email,
                    style: const TextStyle(color: Colors.black, fontSize: 16)),
                SizedBox(
                  height: mq.height * .03,
                ),
                SizedBox(
                  width: mq.width * 1.25,
                  child: TextFormField(
                    initialValue: widget.user.Name,
                    //Used to check if field empty
                    onSaved: (val) => APIs.me.Name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Filed',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Username',
                        label: const Text('Name')),
                  ),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                SizedBox(
                  width: mq.width * 1.25,
                  child: TextFormField(
                    initialValue: widget.user.About,
                    onSaved: (val) => APIs.me.About = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Filed',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'About',
                        label: const Text('About')),
                  ),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .5, mq.height * .06)),
                  onPressed: () {
                    //Used for Field Data Validation. Calls widgets validator attribute
                    if (_formKey.currentState!.validate()) {
                      //Save the data using the function
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then((value) {
                        Dialogs.showSnackBar(
                            context, 'Profile Updated Successfully');
                      });
                      log('Inside validator');
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ]),
            ),
          ),
        ),
        //Dynamic Card Show
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            //For gap from top
            padding:
                EdgeInsets.only(top: mq.height * .04, bottom: mq.height * .05),
            children: [
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .3),
                          shape: const CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);

                        if (image != null) {
                          log(
                              'Image Path ${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });
                          
                          APIs.updateProfilePicture(File(_image!));
                          //Hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.height * .3),
                          shape: const CircleBorder()),
                      onPressed: () async {
                        // Pick an image.
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);

                        if (image != null) {
                          log('Image Path ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));

                          //Hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
