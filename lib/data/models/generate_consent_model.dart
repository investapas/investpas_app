import 'dart:convert';

GenerateConsentModel generateConsentModelFromJson(String str) => GenerateConsentModel.fromJson(json.decode(str));

String generateConsentModelToJson(GenerateConsentModel data) => json.encode(data.toJson());

class GenerateConsentModel {
  bool? status;
  String? message;
  ConsentData? data;

  GenerateConsentModel({
    this.status,
    this.message,
    this.data,
  });

  factory GenerateConsentModel.fromJson(Map<String, dynamic> json) => GenerateConsentModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : ConsentData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ConsentData {
  String? consentId;
  String? consentStatus;

  ConsentData({
    this.consentId,
    this.consentStatus,
  });

  factory ConsentData.fromJson(Map<String, dynamic> json) => ConsentData(
    consentId: json["consentId"],
    consentStatus: json["consentStatus"],
  );

  Map<String, dynamic> toJson() => {
    "consentId": consentId,
    "consentStatus": consentStatus,
  };
}