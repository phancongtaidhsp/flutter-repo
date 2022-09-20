import 'dart:async';
import 'package:collection/collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zendesk2/zendesk2.dart';
import '../../../values/color-helper.dart';

class ZendeskChatPage extends StatefulWidget {
  final String? displayOrderId;
  ZendeskChatPage({this.displayOrderId});
  @override
  _ZendeskChatPageState createState() => _ZendeskChatPageState();
}

class _ZendeskChatPageState extends State<ZendeskChatPage> {
  final Zendesk2Chat _z = Zendesk2Chat.instance;
  final picker = ImagePicker();
  final scrollController = ScrollController();
  final textEditingController = TextEditingController();
  String activeText = 'Waiting';
  ChatProviderModel? _providerModel;
  ChatSettingsModel? _chatSettingsModel;
  CONNECTION_STATUS? _connectionStatus;
  late ChatAccountModel _chatAccountModel;

  StreamSubscription<ChatProviderModel>? _subscriptionProvidersStream;
  StreamSubscription<CONNECTION_STATUS>? _subscriptionConnetionStatusStream;
  StreamSubscription<ChatSettingsModel>? _subscriptionChatSettingsStream;
  StreamSubscription<ChatAccountModel>? _subscriptionAccountProvidersStream;

  Future<bool> _onWillPopScope() async {
    await _z.endChat();
    await Future.delayed(Duration(milliseconds: 2000));
    await _subscriptionProvidersStream?.cancel();
    await _subscriptionConnetionStatusStream?.cancel();
    await _subscriptionChatSettingsStream?.cancel();
    await _subscriptionAccountProvidersStream?.cancel();
    await _z.dispose();
    await _z.disconnect();
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _z.connect();
      _subscriptionProvidersStream =
          _z.providersStream?.listen((providerModel) {
        _providerModel = providerModel;
        Timer(
          // Without adding deplay, there will be a problen (Tested with 500 miliseconds, it's failed)
          Duration(seconds: 1),
          () => scrollController
              .jumpTo(scrollController.position.maxScrollExtent),
        );
        setState(() {});
      });
      _subscriptionChatSettingsStream =
          _z.chatSettingsStream?.listen((settingsModel) {
        _chatSettingsModel = settingsModel;
        print('Chat Settings: $_chatSettingsModel');
        setState(() {});
      });
      _subscriptionConnetionStatusStream =
          _z.connectionStatusStream?.listen((connectionStatus) {
        _connectionStatus = connectionStatus;
        print('Connection Status: $_connectionStatus');
        setState(() {});
      });
      _subscriptionAccountProvidersStream =
          _z.chatIsOnlineStream?.listen((chatAccountModel) {
        _chatAccountModel = chatAccountModel;
        print('isOnline: $_chatAccountModel');
        setState(() {});
      });
    });

    // This function wait until the connection status is connected then send display order id.
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.displayOrderId != null &&
          _connectionStatus == CONNECTION_STATUS.CONNECTED) {
        _sendForFirstTime('My Order ID: ${widget.displayOrderId}');
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus != null) {
      activeText = _connectionStatus.toString().split('.')[1].toLowerCase();
    }
    final mq = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarColor: lightBack,
              statusBarIconBrightness: Brightness.light),
          leadingWidth: 48,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GemSpot Support',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Arial Rounded MT Bold',
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          activeText[0].toUpperCase() + activeText.substring(1),
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Arial Rounded MT Light',
                              color: Colors.black87),
                        ),
                        SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _connectionStatus ==
                                      CONNECTION_STATUS.CONNECTED
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkResponse(
                onTap: () {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'hello@gem.live',
                  );

                  launch(emailLaunchUri.toString());
                },
                child: Icon(
                  Icons.email,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                width: 24,
              ),
              InkResponse(
                onTap: () {
                  launch("tel:01158506414");
                },
                child: Icon(
                  Icons.phone,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        body: _providerModel == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_providerModel != null) Expanded(child: _chat()),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_providerModel != null &&
                          _providerModel!.agents.isNotEmpty)
                        if (_providerModel!.agents.first.isTyping)
                          Text(
                            'Agent is typing...',
                            textAlign: TextAlign.start,
                          ),
                      Padding(
                        padding: EdgeInsets.only(bottom: mq.viewPadding.bottom),
                        child: Column(
                          children: [
                            buildInput(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void _attach() async {
    bool isPhoto = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Row(
              children: [
                Icon(Icons.camera_alt),
                SizedBox(
                  width: 8,
                ),
                Text('Photo'),
              ],
            ),
            onTap: () => Navigator.of(context).pop(true),
          ),
          ListTile(
            title: Row(
              children: [
                Icon(FontAwesomeIcons.file),
                SizedBox(
                  width: 8,
                ),
                Text('File'),
              ],
            ),
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    final compatibleExt = _chatSettingsModel?.supportedFileTypes;

    final result = isPhoto
        ? await picker.pickImage(source: ImageSource.gallery)
        : await FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FileType.custom,
            allowedExtensions: compatibleExt?.toList() ?? [],
          );

    final file =
        result is FilePickerResult ? result.files.single : (result as XFile);
    final path = file is PlatformFile ? file.path : (file as XFile).path;
    if (path != null) {
      _z.sendFile(path);
    }
    Timer(
      Duration(seconds: 1),
      () => scrollController.jumpTo(scrollController.position.maxScrollExtent),
    );
  }

  void _send() async {
    final text = textEditingController.text;
    if (text.isNotEmpty) {
      await _z.sendMessage(text);
      textEditingController.clear();
      _z.sendTyping(false);
      setState(() {});
      Timer(
        Duration(seconds: 1),
        () =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent),
      );
    }
  }

  void _sendForFirstTime(String orderId) async {
    if (orderId.isNotEmpty) {
      await _z.sendMessage(orderId);
      textEditingController.clear();
      _z.sendTyping(false);
      setState(() {});
      Timer(
        Duration(seconds: 1),
        () =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent),
      );
    }
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: _attach,
                color: Colors.black45,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    await _z.sendMessage(value);
                    textEditingController.clear();
                    _z.sendTyping(false);
                    setState(() {});
                    Timer(
                      Duration(seconds: 1),
                      () => scrollController
                          .jumpTo(scrollController.position.maxScrollExtent),
                    );
                  }
                },
                onChanged: (text) => _z.sendTyping(text.isNotEmpty),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.normal, color: Colors.black54),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _send,
                color: Colors.black54,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 62.0,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 4.0,
        )
      ]),
    );
  }

  Widget _chat() => Padding(
        padding: EdgeInsets.only(bottom: 20, top: 10),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: (_providerModel!.logs).map(
              (log) {
                ChatMessage? chatMessage = log.chatLogType.chatMessage;

                String message = chatMessage?.message ?? '';

                String name = log.displayName;

                bool isAttachment = false;
                bool isJoinOrLeave = false;
                bool isAgent = log.chatParticipant == CHAT_PARTICIPANT.AGENT;

                Agent? agent;
                if (isAgent)
                  agent = _providerModel!.agents.firstWhereOrNull(
                      (element) => element.displayName == name);

                switch (log.chatLogType.logType) {
                  case LOG_TYPE.ATTACHMENT_MESSAGE:
                    message = 'Attachment';
                    isAttachment = true;
                    break;
                  case LOG_TYPE.MEMBER_JOIN:
                    message = '$name Joined!';
                    isJoinOrLeave = true;
                    break;
                  case LOG_TYPE.MEMBER_LEAVE:
                    message = '$name Left!';
                    isJoinOrLeave = true;
                    break;
                  case LOG_TYPE.MESSAGE:
                    message = message;
                    break;
                  case LOG_TYPE.OPTIONS_MESSAGE:
                    message = 'Options message';
                    break;
                }

                bool isVisitor =
                    log.chatParticipant == CHAT_PARTICIPANT.VISITOR;

                final imageUrl = log.chatLogType.chatAttachment?.url;

                final mimeType = log.chatLogType.chatAttachment
                    ?.chatAttachmentAttachment.mimeType
                    ?.toLowerCase();
                final isImage = mimeType == null
                    ? false
                    : (mimeType.contains('jpg') ||
                        mimeType.contains('png') ||
                        mimeType.contains('jpeg') ||
                        mimeType.contains('gif'));

                return isJoinOrLeave
                    ? Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Arial Rounded MT Light',
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: isVisitor
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0)),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isAgent)
                                  agent?.avatar != null
                                      ? CachedNetworkImage(
                                          imageUrl: agent!.avatar ?? '')
                                      : Container(),
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: !isVisitor
                                          ? Colors.grey[300]
                                          : !(imageUrl != null &&
                                                  imageUrl != '')
                                              ? primaryColor
                                              : Colors.white,
                                    ),
                                    padding:
                                        EdgeInsets.all(!isAttachment ? 10 : 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (isAttachment)
                                          GestureDetector(
                                            onTap: () => launch(log
                                                    .chatLogType
                                                    .chatAttachment
                                                    ?.chatAttachmentAttachment
                                                    .url ??
                                                ''),
                                            child: isImage
                                                ? (imageUrl != null &&
                                                        imageUrl != '')
                                                    ? CachedNetworkImage(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        imageUrl: imageUrl,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          child:
                                                              CircularProgressIndicator(),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      80,
                                                                  vertical: 16),
                                                        ),
                                                      )
                                                    : Container()
                                                : Column(
                                                    children: [
                                                      Icon(FontAwesomeIcons
                                                          .file),
                                                      Text(
                                                        log
                                                                .chatLogType
                                                                .chatAttachment
                                                                ?.chatAttachmentAttachment
                                                                .name ??
                                                            '',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                          ),
                                        !isAttachment
                                            ? Text(
                                                message,
                                                overflow: TextOverflow.visible,
                                                maxLines: 10,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        'Arial Rounded MT Light',
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
              },
            ).toList(),
          ),
        ),
      );
}
