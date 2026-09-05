import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:investapas/presentation/bloc/profile/profile_event.dart';
import 'package:investapas/presentation/bloc/profile/profile_state.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/shared_prefs_helper.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final SharedPrefsHelper prefs = SharedPrefsHelper();
  Timer? _fundTimer;

  ProfileBloc() : super(const ProfileState()) {

    on<ToggleAiAssistance>((event, emit) {
      if (state.isAssistance != event.value) {
        emit(state.copyWith(isAssistance: event.value));
      }
    });

    on<LoadUserPrefsEvent>(_loadUserPrefs);
    on<LoadFundLimitEvent>(_loadFundLimit);
    on<LoadProfileEvent>(_loadProfile);
    on<UploadProfilePictureEvent>(_uploadProfilePicture);
    on<RemoveProfilePictureEvent>(_removeProfilePicture);

    add(LoadUserPrefsEvent());
    add(LoadProfileEvent());
    add(const LoadFundLimitEvent(silent: false));

    _fundTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const LoadFundLimitEvent(silent: true));
    });
  }

  @override
  Future<void> close() {
    _fundTimer?.cancel();
    return super.close();
  }

  Future<void> _loadUserPrefs(
      LoadUserPrefsEvent event,
      Emitter<ProfileState> emit,
      ) async {
    final name = await prefs.getClientName() ?? '';
    final id = await prefs.getClientId() ?? '';
    final ucc = await prefs.getClientUcc() ?? '';
    emit(state.copyWith(clientName: name, clientId: id, clientUcc: ucc));
  }

  Future<void> _loadFundLimit(
      LoadFundLimitEvent event,
      Emitter<ProfileState> emit,
      ) async {
    if (!event.silent) {
      emit(state.copyWith(isFundLoading: true));
    }
    try {
      final accessToken = await prefs.getAccessToken() ?? '';
      if (accessToken.isEmpty) {
        if (!event.silent) emit(state.copyWith(isFundLoading: false));
        return;
      }

      final response = await ApiHelper.post(
        ApiEndpoints.fundLimitApi,
        {"dhanAccessToken": accessToken},
      );

      if (response != null && response["status"] == true) {
        final data = response["data"] as Map<String, dynamic>? ?? {};
        final balance = ((data["availablBalance"] ?? data["availableBalance"] ?? data["availabelBalance"] ?? 0) as num).toDouble();
        emit(state.copyWith(isFundLoading: false, availableBalance: balance));
      } else {
        if (!event.silent) emit(state.copyWith(isFundLoading: false));
      }
    } catch (e) {
      if (!event.silent) emit(state.copyWith(isFundLoading: false));
    }
  }

  Future<void> _loadProfile(
      LoadProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      final response = await ApiHelper.get(ApiEndpoints.profileApi);
      if (response != null && response["status"] == true) {
        final data = response["data"] as Map<String, dynamic>? ?? {};
        emit(state.copyWith(
          profilePicture: data["profilePicture"] ?? '',
        ));
      }
    } catch (_) {}
  }

  Future<void> _uploadProfilePicture(
      UploadProfilePictureEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isUploadingPicture: true));
    try {
      final token = await prefs.getToken() ?? '';
      final uri = Uri.parse('${ApiHelper.baseUrl}${ApiEndpoints.profileUpdatePictureApi}');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = token
        ..files.add(await http.MultipartFile.fromPath('profile_picture', event.filePath));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final response = jsonDecode(body) as Map<String, dynamic>;

      if (response["status"] == true) {
        final url = response["data"]?["profilePicture"] ?? '';
        emit(state.copyWith(isUploadingPicture: false, profilePicture: url));
      } else {
        emit(state.copyWith(isUploadingPicture: false));
      }
    } catch (e) {
      emit(state.copyWith(isUploadingPicture: false));
    }
  }

  Future<void> _removeProfilePicture(
      RemoveProfilePictureEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isUploadingPicture: true));
    try {
      final response = await ApiHelper.delete(ApiEndpoints.profileRemovePictureApi);
      if (response != null && response["status"] == true) {
        emit(state.copyWith(isUploadingPicture: false, profilePicture: ''));
      } else {
        emit(state.copyWith(isUploadingPicture: false));
      }
    } catch (e) {
      emit(state.copyWith(isUploadingPicture: false));
    }
  }
}
