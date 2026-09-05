import '../../Extensions/Extensions.dart';
import '../../core/constants/constants.dart';
import 'Model.dart';
import 'category.dart';

///Product model
class ProductModel extends Model {
  /// id
  final int? id;
  /// title
  final String title;
  /// description
  final String? description;
  /// price
  final double? price;
  /// images
  final List<String>? images;
  /// category
  final CategoryModel? category;
/// constructor
  ProductModel(
      {this.id,
      this.title='',
      this.description,
      this.price,
      this.images,
      this.category});

  @override
  ProductModel copyWith(
      {String? title,
      String? description,
      double? price,
      List<String>? images,
      CategoryModel? category}) {
    return ProductModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        images: images ?? this.images,
        category: category ?? this.category);
  }

  @override
  
  Json get toJson => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'images': images,
        'category': category?.toJson
      };

      /// Creates the model from given json
  factory ProductModel.fromJson(Json json) {
    return ProductModel(
      id: json.id,
      title: json.safeString('title'),
      description: json.safeString('description'),
      price: json.safeDouble('price'),
      images: json.safeListOfStrings('images'),
      category: CategoryModel.fromJson(json.safeJson('category')),
    );
  }
  /// Creates an invalid product model with default values.
  ///
  /// Returns a [ProductModel] instance with the following properties:
  /// - id: 0
  /// - title: An empty string
  /// - description: An empty string
  /// - price: 0.0
  /// - images: An empty list of strings
  /// - category: The result of calling [CategoryModel.invalidCategory]
  ///
  /// This function is typically used to create a placeholder or default product
  /// when no valid product data is available.
  static ProductModel invalidProduct() {
    return ProductModel(
      id: 0,
      description: '',
      price: 0.0,
      images: const <String>[],
      category: CategoryModel.invalidCategory(),
    );
  }
}
