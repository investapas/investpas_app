
import 'package:share_plus/share_plus.dart';
/// Share Service
class ShareService{
  ShareService._();
  /// Shares the given text using the Share API.
  ///
  /// The [text] parameter represents the text to be shared.
  ///
  /// This function is asynchronous and does not return anything.
  static Future<void> shareText(String text,{String ?subject}) async {
    await Share.share(text,subject:subject );
  }
}
