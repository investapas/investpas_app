import '../../Widgets/Widgets.dart';
import '../../data/data_sources/http_source.dart';
import '../../data/models/product.dart';
import '../apiUrls.dart';

/// product repository
class ProductRepository {
  ProductRepository._();

  /// instance of product repository
  static final ProductRepository instance = ProductRepository._();

  /// get http service
  HttpService get service => HttpService.instance;

  /// Asynchronously retrieves a list of ProductModel objects. Returns a Future that resolves to a List<ProductModel>.
  Future<List<ProductModel>> get() async {
    final response = await service.getRequest(Apiurls.getProducts);
    print('response===${response.list}');
    if (response.isList) {
      
      return response.list
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else {
      Widgets.showToast(response.message);
      return [];
    }
  }

  /// get product details
  Future<ProductModel> getDetails(int id) async {
    final response = await service.getRequest('${Apiurls.getProducts}$id');
    if (response.isSuccess) {
      return ProductModel.fromJson(response.json);
    } else {
      Widgets.showToast(response.message);
      return ProductModel.invalidProduct();
    }
  }
}
