import 'package:equatable/equatable.dart';

import '../../core/constants/constants.dart';

///A standard model to reduce the redundancy of documentation
///and also it helps to reduce fogetting the important functions of a class
abstract class Model extends Equatable {
  ///Returns the data in Json format
  Json get toJson;

  ///Creates new instance of the Object
  Model copyWith();

  @override
  String toString() {
    return toJson.toString();
  }

  @override
  List<dynamic> get props => toJson.values.toList();
}
