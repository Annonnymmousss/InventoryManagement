import 'package:equatable/equatable.dart';
import 'package:inventory_management/models/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterProducts extends ProductEvent {
  final String? category;
  final bool? lowStock;

  const FilterProducts({this.category, this.lowStock});

  @override
  List<Object?> get props => [category, lowStock];
}
