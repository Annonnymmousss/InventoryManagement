import 'package:equatable/equatable.dart';
import 'package:inventory_management/models/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final String? selectedCategory;
  final bool showLowStock;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    this.selectedCategory,
    this.showLowStock = false,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    String? selectedCategory,
    bool? showLowStock,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showLowStock: showLowStock ?? this.showLowStock,
    );
  }

  @override
  List<Object?> get props => [products, filteredProducts, selectedCategory, showLowStock];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

