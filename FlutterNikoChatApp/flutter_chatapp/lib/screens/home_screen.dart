import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatapp/helper/dailogs.dart';
import 'package:flutter_chatapp/screens/profile_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeyWidgetState();
}

class HomeyWidgetState extends State<HomeScreen> {
  //Storing All Users
  List<ChatUser> _list = [];

  //Storing All Search items
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //Update lastActive in firebase based on App lifecycle status
    //Pause - false
    //Resume (app screen open) - true
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        } else if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //If search is on, back button close search
        //Else close app
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            //Will go from search to home instead of closing app directly\
            //Gesture detector used for this too
            return Future.value(false);
          } else {
            //False do nothing. True perform normal back button aka go to previous screen
            return Future.value(true);
          }
        },
        child: Scaffold(
          //App Bar
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0.4),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(color: Colors.greenAccent)),
                      hintText: 'Search',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: .5),
                    onChanged: (val) {
                      //Search Logic
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.Name.toLowerCase().contains(val.toLowerCase()) ||
                            (i.Email.toLowerCase()
                                .contains(val.toLowerCase()))) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    })
                : const Text("Chat App"),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(Icons.more_vert)),
            ],
          ),
          //Floating Button
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              backgroundColor: Colors.greenAccent,
              onPressed: () async {
                _addChatUserDialog();
              },
              child: const Icon(
                Icons.message,
                color: Colors.white,
              ),
            ),
          ),
          //Dynamic Card Show
          body: StreamBuilder(
            //Get id of only known users
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //Data Loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //If some or all data loaded
                case ConnectionState.active:
                case ConnectionState.done:
                  //Get id of those users whose ids are provided
                  return StreamBuilder(
                      //Make sure that Field name is same as firebase
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //Data Loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            // return const Center(
                            //     child: CircularProgressIndicator());

                          //If some or all data loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];
                        }
                        //Logging for debug purposes
                        // if(snapshot.hasData){
                        //   final data = snapshot.data?.docs;
                        //   for(var i in data!){
                        //     print('Data ${jsonEncode(i.data())}');
                        //   }
                        // }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index],
                                );
                              });
                        } else {
                          return const Center(
                              child: Text(
                            'No Connections Found',
                            style: TextStyle(fontSize: 20),
                          ));
                        }
                      });
              }

            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  Text('  Add User'),
                ],
              ),

              content: TextFormField(
                //Auto Adjust Yourself
                maxLines: null,
                onChanged: (updatedEmail) => email = updatedEmail,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),

              //Actions
              actions: [
                //Cancel Button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),

                //Update Button
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    //Update Message
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackBar(
                              context, 'User Doest Not Exist!');
                        }
                      });
                    }
                  },
                  child: const Text('Add',
                      style: TextStyle(color: Colors.blueAccent)),
                )
              ],
            ));
  }
}
