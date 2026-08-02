import 'dart:convert';
import 'package:incasa_app/data/models/my_store/store_layout_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache local do layout da `EditarLojaView` (ai/EDITAR_LOJA_VIEW.md §8.4).
///
/// Usado exclusivamente como cache — nunca é a fonte de verdade.
abstract class MyStoreLayoutLocalDataSource {
  Future<StoreLayoutModel?> getLayout();
  Future<void> saveLayout(StoreLayoutModel layout);
}

class MyStoreLayoutLocalDataSourceImpl implements MyStoreLayoutLocalDataSource {
  static const String _layoutKey = 'loja_layout_json';

  @override
  Future<StoreLayoutModel?> getLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutJson = prefs.getString(_layoutKey);
    if (layoutJson == null || layoutJson.isEmpty) return null;
    return StoreLayoutModel.fromJson(
      jsonDecode(layoutJson) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveLayout(StoreLayoutModel layout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutKey, jsonEncode(layout.toJson()));
  }
}
