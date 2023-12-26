import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatapp/api/apis.dart';
import 'package:flutter_chatapp/helper/my_date_util.dart';
import 'package:flutter_chatapp/models/chat_user.dart';
import 'package:flutter_chatapp/screens/view_profile_screen.dart';
import 'package:flutter_chatapp/widgets/message_card.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //List of Messages
  List<Message> _list = [];

  //For handling message text changes
  final _textController = TextEditingController();

  //For showing Emojis
  //Checking if images up;padomg
  bool _showEmoji = false, _isUploading = false;

  @override
  void initState() {
    super.initState();
    //Fix AppBar blackness
    Future.delayed(const Duration(milliseconds: 1), () {
      //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
    });

    // Wait until the widget tree is fully built before scrolling down
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   _scrollDown();
    // });

  }

  @override
  Widget build(BuildContext context) {
    //Fixes Clipping
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              //If emojis are shown it closes the emoji thing\
              //Gesture detector used for this too
              return Future.value(false);
            } else {
              //False do nothing. True perform normal back button aka go to previous screen
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.purple[100],
              //Removes the auto back button
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),

            //Body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      //Make sure that Field name is same as firebase
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //Data Loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();

                          //If some or all data loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;

                            //Get Json Data
                            //print('Data ${jsonEncode(data![0].data())}');
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                        }

                        //Logging for debug purposes
                        if (snapshot.hasData) {
                          final data = snapshot.data?.docs;
                          for (var i in data!) {
                            log('Data ${jsonEncode(i.data())}');
                          }
                        }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              //Reverse scrolls to bottom and shows list bottom to up.
                              // Also set api get all message order to descending
                              //reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              });
                        } else {
                          return const Center(
                              child: Text(
                            'Say Hi!',
                            style: TextStyle(fontSize: 20),
                          ));
                        }
                      }),
                ),

                // //Progress Indicator for showing uploading
                // if (_isUploading)
                //   const Align(
                //       alignment: Alignment.centerRight,
                //       child: Padding(
                //           padding:
                //               EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                //           child: CircularProgressIndicator(
                //             strokeWidth: 2,
                //           ))),
                //Chat Field
                _chatInput(),

                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        initCategory: Category.SMILEYS,
                        emojiSizeMax: 32 *
                            //Import Dart io
                            (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Top App Bar
  Widget _appBar() {
    //Inkwell used for clickable effect
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
            children: [
              // => used when single line code
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                  )),
              //Profile Picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: mq.height * .05,
                  height: mq.height * .05,

                  //If user updates Images, update change in UI
                  imageUrl: list.isNotEmpty ? list[0].Image : widget.user.Image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),

              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Username
                  Text(
                    list.isNotEmpty ? widget.user.Name : widget.user.Name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 2,
                  ),

                  //Last Seen
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  //Bottom Text Field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .03),
      child: Row(
        children: [
          //Input field and Buttons
          //Expanded Fixes Max space thing
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //EmojiButton
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),

                  //Expanded takes as much space as it can
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0.01),
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent[100])),
                  )),

                  //Pick Image from Gallery
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick multiple images.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 80);

                        //Uploading and sending images one by one
                        for (var i in images) {
                          if (images.isNotEmpty) {
                            log('Image Path ${i.path} -- MimeType: ${i.mimeType}');
                            //Show Progress Indicator by changing bool value
                            setState(() => _isUploading = true);
                            await APIs.sendChatImage(widget.user, File(i.path));
                            setState(() => _isUploading = true);
                          }
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  //Pick Image from Camera
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);

                        if (image != null) {
                          log('Image Path ${image.path}');
                          //Show Progress Indicator by changing bool value
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      )),

                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),

          //Send Message Button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  //When user sends the first message
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  //Simple Send Message
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                  _textController.text = '';
                }
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            color: Colors.greenAccent,
            shape: const CircleBorder(),
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  // This is what you're looking for!
  // void _scrollDown() {
  //   _controller.animateTo(
  //     _controller.position.maxScrollExtent,
  //     curve: Curves.easeOut,
  //     duration: const Duration(milliseconds: 1000),
  //   );  }
}
