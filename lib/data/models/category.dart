import '../../Extensions/Extensions.dart';
import '../../core/constants/constants.dart';
import 'Model.dart';

/// Category model
class CategoryModel extends Model {
  /// id
  final int id;

  /// name
  final String name;

  /// image
  final String image;

  /// constructor
  CategoryModel({required this.id, required this.name, required this.image});

  @override
  CategoryModel copyWith({String? name, String? image}) {
    return CategoryModel(
        id: id, name: name ?? this.name, image: image ?? this.image);
  }

  @override

  Json get toJson =>  {
        'id': id,
        'name': name,
        'image': image,
      };

/// category model from json
  factory CategoryModel.fromJson(Json json) {
    return CategoryModel(
      id: json.id,
      name: json.safeString('name'),
      image: json.safeString('image',),


      
    );
  }

  /// Returns a `CategoryModel` instance with invalid values.
  ///
  /// The `id` is set to `0`, the `name` is an empty string, and the `image` is
  /// also an empty string.
  ///
  /// Returns a `CategoryModel` instance.
 static CategoryModel invalidCategory() {
    return CategoryModel(id: 0, name: '', image: '');
  }
}
