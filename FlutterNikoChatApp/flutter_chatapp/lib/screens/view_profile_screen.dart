import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';

//View user profile
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    //Gesture Detector is used to hide keyboard
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.Name),
        ),

        floatingActionButton:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Joined On:',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(MyDateUtil.getLastMessageTime(context: context,
                time: widget.user.CreatedAt,
                showYear: true ),
                style:
                const TextStyle(color: Colors.black87, fontSize: 16)),
          ],
        ),

        //Form Used for Validation
        body: Padding(
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
              ClipRRect(
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
              SizedBox(
                height: mq.height * .03,
              ),

              //User Email
              Text(widget.user.Email,
                  style: const TextStyle(color: Colors.black87,
                      fontSize: 16,
                  fontWeight: FontWeight.bold),),
              //User About
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('About:',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(widget.user.About,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),
                ],
              ),

              SizedBox(
                height: mq.height * .03,
              ),
            ]),
          ),
        ),
        //Dynamic Card Show
      ),
    );
  }
}
