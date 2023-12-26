class ChatUser {
  ChatUser({
    required this.isOnline,
    required this.Email,
    required this.lastActive,
    required this.id,
    required this.Image,
    required this.pushToken,
    required this.Name,
    required this.About,
    required this.CreatedAt,
  });
  late  bool isOnline;
  late  String Email;
  late  String lastActive;
  late  String id;
  late  String Image;
  late  String pushToken;
  late  String Name;
  late  String About;
  late  String CreatedAt;

  ChatUser.fromJson(Map<String, dynamic> json){
    isOnline = json['is_Online'] ?? '';
    Email = json['Email'] ?? '';
    lastActive = json['last_Active'] ?? '';
    id = json['id'] ?? '';
    Image = json['Image'] ?? '';
    pushToken = json['push_token'] ?? '';
    Name = json['Name'] ?? '';
    About = json['About'] ?? '';
    CreatedAt = json['Created_At'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_Online'] = isOnline;
    data['Email'] = Email;
    data['last_Active'] = lastActive;
    data['id'] = id;
    data['Image'] = Image;
    data['push_token'] = pushToken;
    data['Name'] = Name;
    data['About'] = About;
    data['Created_At'] = CreatedAt;
    return data;
  }
}