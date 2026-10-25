import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/features/orderscreen/providers/invoice_provider.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadMasterProducts();
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    _addController.clear();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: TextField(
          controller: _addController,
          decoration: const InputDecoration(
            hintText: 'اسم المنتج',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_addController.text.trim().isNotEmpty) {
                try {
                  await context
                      .read<InvoiceProvider>()
                      .addMasterProduct(_addController.text);
                  if (!mounted || !dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  showAppSnackBarOn(messenger, 'تم إضافة المنتج بنجاح');
                } catch (error) {
                  if (!mounted || !messenger.mounted) return;
                  showAppSnackBarOn(
                    messenger,
                    'تعذر إضافة المنتج: $error',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index, String currentName) {
    _editController.text = currentName;
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل المنتج'),
        content: TextField(
          controller: _editController,
          decoration: const InputDecoration(
            hintText: 'اسم المنتج',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editController.text.trim().isNotEmpty) {
                try {
                  await context
                      .read<InvoiceProvider>()
                      .editMasterProduct(index, _editController.text);
                  if (!mounted || !dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  showAppSnackBarOn(messenger, 'تم تعديل المنتج بنجاح');
                } catch (error) {
                  if (!mounted || !messenger.mounted) return;
                  showAppSnackBarOn(
                    messenger,
                    'تعذر تعديل المنتج: $error',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index, String productName) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف "$productName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
 try {
                await context
                    .read<InvoiceProvider>()
                    .deleteMasterProduct(index);
                if (!mounted || !dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                showAppSnackBarOn(messenger, 'تم حذف المنتج');
              } catch (error) {
                if (!mounted || !messenger.mounted) return;
                showAppSnackBarOn(
                  messenger,
                  'تعذر حذف المنتج: $error',
                  isError: true,
                );
              }
            },            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        actions: [
          IconButton(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            tooltip: 'إضافة منتج',
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          final products = provider.masterProductList;

          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اضغط على + لإضافة منتج جديد',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: products.length,
            onReorder: (oldIndex, newIndex) async {
              await provider.reorderMasterProducts(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                key: ValueKey(product),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(product),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showEditDialog(index, product),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteConfirmation(index, product),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'إضافة منتج',
        child: const Icon(Icons.add),
      ),
    );
  }
}
