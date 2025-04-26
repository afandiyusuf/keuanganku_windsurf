// lib/presentation/screens/home/add_transaction_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/transaction.dart';
import '../../../core/services/image_service.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../../di/injection.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // Null jika menambah transaksi baru, non-null jika mengedit

  const AddTransactionScreen({
    Key? key, 
    this.transaction,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late TransactionType _type;
  late DateTime _selectedDate;
  late String _selectedCategoryId;
  bool _isEditing = false;
  String? _imagePath;
  final ImageService _imageService = sl<ImageService>();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    
    // Inisialisasi nilai default atau dari transaksi yang akan diedit
    if (_isEditing) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _type = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
      _selectedCategoryId = widget.transaction!.categoryId;
      _imagePath = widget.transaction!.imagePath;
    } else {
      _type = TransactionType.expense;
      _selectedDate = DateTime.now();
      _selectedCategoryId = 'expense_other';
    }
    
    // Load categories when screen opens
    Future.microtask(
      () => context.read<CategoryViewModel>().loadCategories(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final imagePath = await _imageService.takePhoto();
    if (imagePath != null) {
      setState(() {
        // Hapus gambar lama jika ada
        if (_imagePath != null) {
          _imageService.deleteImage(_imagePath);
        }
        _imagePath = imagePath;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imagePath = await _imageService.pickImageFromGallery();
    if (imagePath != null) {
      setState(() {
        // Hapus gambar lama jika ada
        if (_imagePath != null) {
          _imageService.deleteImage(_imagePath);
        }
        _imagePath = imagePath;
      });
    }
  }

  void _removeImage() {
    if (_imagePath != null) {
      _imageService.deleteImage(_imagePath);
      setState(() {
        _imagePath = null;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<TransactionViewModel>();
      
      if (_isEditing) {
        // Update existing transaction
        final updatedTransaction = Transaction(
          id: widget.transaction!.id,
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          type: _type,
          categoryId: _selectedCategoryId,
          imagePath: _imagePath, // Simpan path gambar untuk semua tipe transaksi
        );
        
        viewModel.updateTransaction(updatedTransaction);
      } else {
        // Add new transaction
        final transaction = Transaction(
          id: const Uuid().v4(),
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          type: _type,
          categoryId: _selectedCategoryId,
          imagePath: _imagePath, // Simpan path gambar untuk semua tipe transaksi
        );
        
        viewModel.addTransaction(transaction);
      }
      
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateType(TransactionType? value) {
    if (value != null && value != _type) {
      setState(() {
        _type = value;
        // Reset category when type changes
        _selectedCategoryId = value == TransactionType.expense ? 'expense_other' : 'income_other';
        
        // Tidak perlu menghapus gambar saat berganti tipe transaksi
        // karena sekarang kedua tipe transaksi bisa menggunakan gambar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Pilih Tanggal'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Tipe Transaksi:'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<TransactionType>(
                          dense: true,
                          title: Text(
                            'Pengeluaran',
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: TransactionType.expense,
                          groupValue: _type,
                          onChanged: _updateType,
                          selectedTileColor: Colors.redAccent,
                        ),
                        RadioListTile<TransactionType>(
                          dense: true,
                          title: Text(
                            'Pemasukan',
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: TransactionType.income,
                          groupValue: _type,
                          onChanged: _updateType,
                          selectedTileColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Kategori:'),
                const SizedBox(height: 8),
                Consumer<CategoryViewModel>(
                  builder: (context, categoryViewModel, child) {
                    if (categoryViewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final categories = _type == TransactionType.expense
                        ? categoryViewModel.expenseCategories
                        : categoryViewModel.incomeCategories;

                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category.id == _selectedCategoryId;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    category.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category.name,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                
                // Lampiran gambar untuk semua tipe transaksi (bukan hanya pemasukan)
                const SizedBox(height: 24),
                const Text(
                  'Lampiran Bukti Transaksi:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Preview gambar jika ada
                if (_imagePath != null) ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Tombol untuk mengambil gambar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'SIMPAN PERUBAHAN' : 'SIMPAN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}