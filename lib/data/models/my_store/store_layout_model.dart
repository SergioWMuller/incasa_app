import 'package:incasa_app/domain/entities/my_store/store_layout.dart';

class StoreLayoutModel extends StoreLayout {
  const StoreLayoutModel({required super.nodes, required super.version});

  factory StoreLayoutModel.fromJson(Map<String, dynamic> json) {
    final layout = StoreLayout.fromJson(json);
    return StoreLayoutModel(nodes: layout.nodes, version: layout.version);
  }

  factory StoreLayoutModel.fromEntity(StoreLayout layout) {
    return StoreLayoutModel(nodes: layout.nodes, version: layout.version);
  }
}
