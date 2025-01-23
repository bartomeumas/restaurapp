// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurapp/models/measure_model.dart';
import 'package:flutter_restaurapp/models/product_model.dart';
import 'package:flutter_restaurapp/services/firebase_service.dart';
import 'package:flutter_restaurapp/services/product_service.dart';
import 'package:image_picker/image_picker.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _measureController;
  late TextEditingController _scarseStateController;
  late TextEditingController _sufficientStateController;
  String _selectedMeasure = 'kg';
  bool _isDirty = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAdmin = false; // Variable to store admin status

  Future<void> _selectFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _isDirty = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.details);
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _measureController = TextEditingController(text: widget.product.measure);
    _scarseStateController =
        TextEditingController(text: widget.product.scarseState.toString());
    _sufficientStateController =
        TextEditingController(text: widget.product.sufficientState.toString());

    _selectedMeasure =
        widget.product.measure.isNotEmpty ? widget.product.measure : 'kg';

    _nameController.addListener(_handleTextFieldChanges);
    _descriptionController.addListener(_handleTextFieldChanges);
    _quantityController.addListener(_handleTextFieldChanges);
    _measureController.addListener(_handleTextFieldChanges);
    _scarseStateController.addListener(_handleTextFieldChanges);
    _sufficientStateController.addListener(_handleTextFieldChanges);

    FirebaseService().isUserAdmin().then((value) {
      setState(() {
        _isAdmin = value;
      });
    }).catchError((error) {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _measureController.dispose();
    _scarseStateController.dispose();
    _sufficientStateController.dispose();
    super.dispose();
  }

  void _handleTextFieldChanges() {
    setState(() {
      _isDirty = true;
    });
  }

  void _updateProductDetails() async {
    if (_image != null) {
      try {
        String imageUrl = await FirebaseService().uploadImage(_image!);
        Product updatedProduct = Product(
          id: widget.product.id,
          name: _nameController.text,
          details: _descriptionController.text,
          quantity: double.parse(_quantityController.text),
          measure: _selectedMeasure,
          scarseState: double.parse(_scarseStateController.text),
          sufficientState: double.parse(_sufficientStateController.text),
          thumbnailImage: imageUrl,
        );

        if (widget.product.id.isEmpty) {
          await ProductService().createProduct(updatedProduct);
        } else {
          await ProductService().updateProduct(updatedProduct);
        }

        setState(() {
          _isDirty = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hubo un error guardando los cambios')),
        );
      }
    } else {
      Product updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        details: _descriptionController.text,
        quantity: double.parse(_quantityController.text),
        measure: _selectedMeasure,
        scarseState: double.parse(_scarseStateController.text),
        sufficientState: double.parse(_sufficientStateController.text),
        thumbnailImage: widget.product.thumbnailImage,
      );

      try {
        if (widget.product.id.isEmpty) {
          await ProductService().createProduct(updatedProduct);
        } else {
          await ProductService().updateProduct(updatedProduct);
        }

        setState(() {
          _isDirty = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hubo un error guardando los cambios')),
        );
      }
    }
  }

  void _deleteProduct() async {
    try {
      await ProductService().deleteProduct(widget.product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error eliminando el producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.product.id.isEmpty
            ? const Text("Crear producto")
            : const Text("Editar producto"),
        actions: <Widget>[
          if (_isAdmin && widget.product.id.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _image == null ||
                              widget.product.thumbnailImage.isNotEmpty
                          ? Colors.white
                          : Colors.white,
                    ),
                    child: GestureDetector(
                      onTap: _selectFromGallery,
                      child: ClipOval(
                        child: _image == null &&
                                widget.product.thumbnailImage.isNotEmpty
                            ? Image.network(
                                widget.product.thumbnailImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : _image == null
                                ? const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 80,
                                    color: Colors.lightBlue,
                                  )
                                : Image.file(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Medida',
                      ),
                      value: _selectedMeasure,
                      items: <Measure>[
                        Measure(name: 'Kilogramos', value: 'kg'),
                        Measure(name: 'Gramos', value: 'g'),
                        Measure(name: 'Miligramos', value: 'mg'),
                        Measure(name: 'Litros', value: 'L'),
                        Measure(name: 'Unidades', value: 'u'),
                      ].map((Measure measure) {
                        return DropdownMenuItem<String>(
                          value: measure.value,
                          child: Text(measure.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMeasure = newValue ?? "kg";
                          _measureController.text = newValue ?? "";
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una medida';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                      ),
                    ),
                    TextFormField(
                      controller: _scarseStateController,
                      readOnly: !_isAdmin, // Readonly based on isAdmin status
                      decoration: const InputDecoration(
                        labelText: 'Estado escaso',
                      ),
                    ),
                    TextFormField(
                      controller: _sufficientStateController,
                      decoration: const InputDecoration(
                        labelText: 'Estado suficiente',
                      ),
                      readOnly: !_isAdmin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isDirty)
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProductDetails,
                    child: const Text('Guardar cambios'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
