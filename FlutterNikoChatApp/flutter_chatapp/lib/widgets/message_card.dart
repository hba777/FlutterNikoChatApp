import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../api/apis.dart';
import '../helper/dailogs.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.me.id == widget.message.SenderId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  //Others Message
  Widget _blueMessage() {
    //Update last message read if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      //print('Message Read Empty');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Covers space as required
        Container(
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * .02
              : mq.width * .04),
          margin: EdgeInsets.symmetric(
              vertical: mq.width * .01, horizontal: mq.width * .04),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueAccent)),
          child: widget.message.type == Type.text
              ? Text(
                  widget.message.msg,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .01),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: mq.height * .2,
                    height: mq.height * .2,
                    imageUrl: widget.message.msg,
                    placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        )),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 70),
                  ),
                ),
        ),

        //Time. Also Using Padding for space from end because we are using space evenly.
        //Better to use Padding
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  //Ours Message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Time. Also Using Padding for space from end because we are using space evenly.
        //Better to use Padding
        Row(
          children: [
            //For Adding Space
            SizedBox(
              width: mq.width * .04,
            ),

            //Double Tick Blue icon
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            //For Adding Space
            const SizedBox(
              width: 2,
            ),
            //Sent Time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        //Covers space as required
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                vertical: mq.width * .01, horizontal: mq.width * .04),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.lightGreen)),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: mq.height * .2,
                      height: mq.height * .2,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 100),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //Bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            //Important
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: const BoxDecoration(color: Colors.grey),
              ),

              widget.message.type == Type.text
                  ? //Copy
                  //If text Selected
                  _OptionItem(
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.message.msg));

                        //Hiding Bottom Sheet
                        Navigator.pop(context);

                        Dialogs.showSnackBar(context, 'Text Copied');
                      })
                  :
                  //If image selected
                  _OptionItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        log('Image Url: ${widget.message.msg}');

                        try{
                          await GallerySaver.saveImage(widget.message.msg,
                          albumName: 'NikoChats')
                              .then((success) {
                            //Hide Bottom Sheet
                            Navigator.pop(context);

                            if(success != null && success){
                              Dialogs.showSnackBar(context, 'Image Saved');
                            }
                          });
                        }
                        catch(e){
                          log('Error while saving $e');
                        }
                      }),

              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.height * .04,
                ),

              //Edit
              if (widget.message.type == Type.text && isMe == true)
                _OptionItem(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Edit Text',
                    onTap: () {

                      //Hide Bottom sheet
                      Navigator.pop(context);

                      //Update Message Dialog
                      _showMessageDataDialog();
                    }),

              //Delete
              if (isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: 'Delete Text',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        //Hide sheet
                        Navigator.pop(context);
                      });
                    }),

              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.height * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name:
                      'Sent At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}:',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.greenAccent,
                    size: 26,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not Seen Yet'
                      : 'Read At ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}:',
                  onTap: () {}),
            ],
          );
        });
  }
  //Edit Message Dialog
  void _showMessageDataDialog(){
    String updatedMsg = widget.message.msg;

    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24,
      right: 24,
      top: 20,
      bottom: 10),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      title: const Row(
        children: [
          Icon(Icons.messenger_rounded,
          color: Colors.blue,),
          Text(' Update Message'),
        ],
      ),

      content: TextFormField(
        //Auto Adjust Yourself
        maxLines: null,
        onChanged: (value) => updatedMsg = value,
        initialValue: updatedMsg,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
      ),

      //Actions
      actions: [
        //Cancel Button
        MaterialButton(onPressed: (){

          Navigator.pop(context);

        },
        child: const Text('Cancel',
        style: TextStyle(color:Colors.blue),),
        ),

        //Update Button
        MaterialButton(onPressed: () {
          Navigator.pop(context);

          //Update Message
          APIs.updateeMessage(widget.message, updatedMsg);
        },
          child: const Text('Update',
            style: TextStyle(color:Colors.blueAccent)
          ),
        )
      ],

    ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  //Use Curly brace to make parameters names
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.width * .015),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '    $name',
                style: const TextStyle(letterSpacing: .5),
              ),
            )
          ],
        ),
      ),
    );
  }
}

