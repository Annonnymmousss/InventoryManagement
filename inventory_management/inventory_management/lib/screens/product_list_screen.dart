// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management/bloc/product_bloc.dart';
import 'package:inventory_management/bloc/product_event.dart';
import 'package:inventory_management/bloc/product_state.dart';
import 'package:inventory_management/models/product.dart';
import 'package:inventory_management/screens/add_edit_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  final List<String> categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
    'Sports',
    'Food & Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [

          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              String? selectedCategory;
              if (state is ProductLoaded) {
                selectedCategory = state.selectedCategory;
              }
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text('Category', style: TextStyle(color: Colors.white)),
                  dropdownColor: Colors.blue[800],
                  iconEnabledColor: Colors.white,
                  underline: Container(),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories', style: TextStyle(color: Colors.white)),
                    ),
                    ...categories.map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    context.read<ProductBloc>().add(FilterProducts(category: value));
                  },
                ),
              );
            },
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'all') {
                context.read<ProductBloc>().add(const FilterProducts());
              } else if (value == 'low_stock') {
                context.read<ProductBloc>().add(const FilterProducts(lowStock: true));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Show All Products')),
              const PopupMenuItem(value: 'low_stock', child: Text('Show Low Stock Only')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ProductLoaded) {
            
            if (state.products.isEmpty) {
              return _buildEmptyState(context, 'No products in inventory', 
                'Add your first product to get started!');
            }
            
            if (state.filteredProducts.isEmpty && state.products.isNotEmpty) {
              return _buildEmptyState(context, 'No products match your filter', 
                'Try adjusting your filter criteria.');
            }
            
            return _buildProductList(context, state);
          }
          

          return _buildEmptyState(context, 'Welcome to Inventory Management', 
            'Add your first product to get started!');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, ProductLoaded state) {
    return Column(
      children: [
       
        if (state.selectedCategory != null || state.showLowStock)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getFilterText(state),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(const FilterProducts());
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
   
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(LoadProducts());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.filteredProducts.length,
              itemBuilder: (context, index) {
                final product = state.filteredProducts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.category, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${product.category}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('Qty: ${product.quantity}'),
                              const SizedBox(width: 16),
                              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                              Text('\$${product.price.toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.quantity <= 10)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, size: 16, color: Colors.orange[800]),
                                const SizedBox(width: 4),
                                Text(
                                  'Low Stock',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditProductScreen(product: product),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, product);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getFilterText(ProductLoaded state) {
    List<String> filters = [];
    
    if (state.selectedCategory != null) {
      filters.add('Category: ${state.selectedCategory}');
    }
    
    if (state.showLowStock) {
      filters.add('Low Stock Only');
    }
    
    return 'Filtered by: ${filters.join(', ')} (${state.filteredProducts.length} items)';
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this product?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Category: ${product.category}'),
                    Text('Quantity: ${product.quantity}'),
                    Text('Price: \$${product.price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProduct(product.id));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}