
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management/bloc/product_event.dart';
import 'package:inventory_management/bloc/product_state.dart';
import 'package:inventory_management/models/product.dart';
import 'package:inventory_management/repositories/product_repository.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<FilterProducts>(_onFilterProducts);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.getProducts();
    
      emit(ProductLoaded(
        products: products,
        filteredProducts: products,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      emit(ProductLoading());
      try {
        await repository.createProduct(event.product);
        add(LoadProducts());
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    }
  }

  void _onUpdateProduct(UpdateProduct event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      emit(ProductLoading());
      try {
        await repository.updateProduct(event.product);
        add(LoadProducts());
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    }
  }

  void _onDeleteProduct(DeleteProduct event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      emit(ProductLoading());
      try {
        await repository.deleteProduct(event.id);
        add(LoadProducts());
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    }
  }

  void _onFilterProducts(FilterProducts event, Emitter<ProductState> emit) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      if (currentState.products.isEmpty) {
        emit(currentState.copyWith(
          filteredProducts: [],
          selectedCategory: event.category,
          showLowStock: event.lowStock ?? false,
        ));
        return;
      }

      List<Product> filtered = List.from(currentState.products);

      if (event.category != null && event.category!.isNotEmpty) {
        filtered = filtered.where((product) => 
          product.category.toLowerCase() == event.category!.toLowerCase()
        ).toList();
      }


      if (event.lowStock == true) {
        filtered = filtered.where((product) => product.quantity <= 10).toList();
      }

      emit(currentState.copyWith(
        filteredProducts: filtered,
        selectedCategory: event.category,
        showLowStock: event.lowStock ?? false,
      ));
    }
  }
}