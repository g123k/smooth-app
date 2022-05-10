import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/ProductListQueryConfiguration.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/helpers/collection_helpers.dart';

/// Import / Export of product lists via a JSON.
/// All lists are composed of barcodes
/// We support the history and user lists
class ProductListImportExport {
  static const String TMP_IMPORT = '''
  {"history":{
  "barcodes":["3274080005003", "7622210449283"]},
  "user_lists":{
  "my awesome list":{"barcodes":["5449000000996", "3017620425035"]},
  "saved for later":{"barcodes":["3175680011480", "1234567891"]}
  }}''';

  Future<void> import(
    final String jsonEncoded,
    final LocalDatabase localDatabase,
  ) async {
    final dynamic map = json.decode(jsonEncoded);
    if (map is! Map<String, dynamic>) {
      throw Exception('Expected Map<String, dynamic>');
    }
    final _ImportableLists lists = _ImportableLists(map);
    final Set<String> inputBarcodes = lists.extractBarcodes();

    final List<Product> products = await _fetchProducts(
      inputBarcodes.toList(growable: false),
    );

    await _saveNewProducts(localDatabase, products);
    await _saveNewProductsToLists(localDatabase, lists, products);
  }

  Future<List<Product>> _fetchProducts(
    List<String> barcodes,
  ) async {
    final SearchResult searchResult = await OpenFoodAPIClient.getProductList(
      ProductQuery.getUser(),
      ProductListQueryConfiguration(
        barcodes.toList(growable: false),
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
      ),
    );

    return searchResult.products ?? <Product>[];
  }

  Future<void> _saveNewProducts(
    LocalDatabase localDatabase,
    List<Product> products,
  ) async {
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final Map<String, Product> productsToAdd = <String, Product>{};
    for (final Product product in products) {
      productsToAdd[product.barcode!] = product;
      await daoProduct.put(product);
    }
  }

  Future<void> _saveNewProductsToLists(
    LocalDatabase localDatabase,
    _ImportableLists lists,
    List<Product> products,
  ) async {
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    await _importHistory(lists.history, products, daoProductList);
    await _importUserLists(lists.userLists, products, daoProductList);
  }

  Future<void> _importHistory(
    _ImportableList? list,
    List<Product> fetchedProducts,
    DaoProductList daoProductList,
  ) async {
    return _importList(
      list,
      ProductList.history(),
      fetchedProducts,
      daoProductList,
    );
  }

  Future<List<void>> _importUserLists(
    _ImportableUserLists? lists,
    List<Product> fetchedProducts,
    DaoProductList daoProductList,
  ) async {
    if (lists?.lists.isNotEmpty != true) {
      return <void>[];
    }

    final List<Future<void>> tasks = <Future<void>>[];
    for (final String key in lists!.lists.keys) {
      tasks.add(_importList(
        lists.lists[key],
        ProductList.user(key),
        fetchedProducts,
        daoProductList,
      ));
    }

    return Future.wait<void>(tasks);
  }

  Future<void> _importList(
    _ImportableList? list,
    ProductList productList,
    List<Product> fetchedProducts,
    DaoProductList daoProductList,
  ) async {
    if (list == null) {
      return;
    }

    productList.set(list.barcodes, _extractProductsMap(list, fetchedProducts));
    return daoProductList.put(productList);
  }

  Map<String, Product> _extractProductsMap(
    _ImportableList list,
    List<Product> fetchedProducts,
  ) {
    final Map<String, Product> productsToAdd = <String, Product>{};
    for (final String barcode in list.barcodes) {
      final Product? product = fetchedProducts.firstWhereOrNull(
        (Product product) => product.barcode == barcode,
      );

      if (product != null) {
        productsToAdd[barcode] = product;
      }
    }
    return productsToAdd;
  }
}

class _ImportableLists {
  _ImportableLists(
    Map<String, dynamic> json,
  )   : history = json['history'] is Map
            ? _ImportableList(json['history'] as Map<String, dynamic>)
            : null,
        userLists = json['user_lists'] is Map
            ? _ImportableUserLists(json['user_lists'] as Map<String, dynamic>)
            : null;

  final _ImportableList? history;
  final _ImportableUserLists? userLists;

  Set<String> extractBarcodes() {
    final Set<String> barcodes = <String>{};

    barcodes.addAllSafe(history?.barcodes);
    barcodes.addAllSafe(userLists?.extractBarcodes());

    return barcodes;
  }
}

class _ImportableUserLists {
  _ImportableUserLists(
    Map<String, dynamic> json,
  ) : lists = json.map(
          (String key, dynamic value) => MapEntry<String, _ImportableList>(
            key,
            _ImportableList(json[key] as Map<String, dynamic>),
          ),
        );

  final Map<String, _ImportableList> lists;

  Set<String> extractBarcodes() {
    final Set<String> barcodes = <String>{};

    for (final String key in lists.keys) {
      barcodes.addAllSafe(lists[key]?.barcodes);
    }

    return barcodes;
  }
}

class _ImportableList {
  _ImportableList(
    Map<String, dynamic> json,
  ) : barcodes = (json['barcodes'] as List<dynamic>).cast<String>();

  final List<String> barcodes;
}
