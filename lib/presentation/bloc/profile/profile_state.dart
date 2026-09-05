import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isAssistance;
  final String clientName;
  final String clientId;
  final String clientUcc;
  final double availableBalance;
  final bool isFundLoading;
  final String profilePicture;
  final bool isUploadingPicture;

  const ProfileState({
    this.isAssistance = false,
    this.clientName = '',
    this.clientId = '',
    this.clientUcc = '',
    this.availableBalance = 0.0,
    this.isFundLoading = false,
    this.profilePicture = '',
    this.isUploadingPicture = false,
  });

  ProfileState copyWith({
    bool? isAssistance,
    String? clientName,
    String? clientId,
    String? clientUcc,
    double? availableBalance,
    bool? isFundLoading,
    String? profilePicture,
    bool? isUploadingPicture,
  }) {
    return ProfileState(
      isAssistance: isAssistance ?? this.isAssistance,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      clientUcc: clientUcc ?? this.clientUcc,
      availableBalance: availableBalance ?? this.availableBalance,
      isFundLoading: isFundLoading ?? this.isFundLoading,
      profilePicture: profilePicture ?? this.profilePicture,
      isUploadingPicture: isUploadingPicture ?? this.isUploadingPicture,
    );
  }

  @override
  List<Object> get props => [isAssistance, clientName, clientId, clientUcc, availableBalance, isFundLoading, profilePicture, isUploadingPicture];
}
