import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool? status;
  String? message;
  User? user;
  String? dhanAccessToken;
  String? token;

  LoginModel({
    this.status,
    this.message,
    this.user,
    this.dhanAccessToken,
    this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json["status"],
    message: json["message"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    dhanAccessToken: json["dhanAccessToken"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "user": user?.toJson(),
    "dhanAccessToken": dhanAccessToken,
    "token": token,
  };
}

class User {
  String? dhanClientId;
  String? dhanClientName;
  String? dhanClientUcc;

  User({
    this.dhanClientId,
    this.dhanClientName,
    this.dhanClientUcc,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    dhanClientId: json["dhanClientId"],
    dhanClientName: json["dhanClientName"],
    dhanClientUcc: json["dhanClientUcc"],
  );

  Map<String, dynamic> toJson() => {
    "dhanClientId": dhanClientId,
    "dhanClientName": dhanClientName,
    "dhanClientUcc": dhanClientUcc,
  };
}