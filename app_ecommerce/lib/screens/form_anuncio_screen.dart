import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/anuncio.dart';
import '../helpers/db_helper.dart';

class FormAnuncioScreen extends StatefulWidget {
  final Anuncio? anuncio;

  const FormAnuncioScreen({super.key, this.anuncio});

  @override
  State<FormAnuncioScreen> createState() => _FormAnuncioScreenState();
}

class _FormAnuncioScreenState extends State<FormAnuncioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;

  String? _imagePath;

  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.anuncio != null;

    _tituloController =
        TextEditingController(text: _isEditing ? widget.anuncio!.titulo : '');
    _descricaoController = TextEditingController(
        text: _isEditing ? widget.anuncio!.descricao : '');
    _precoController = TextEditingController(
        text: _isEditing ? widget.anuncio!.preco.toStringAsFixed(2) : '');

    if (_isEditing) {
      _imagePath = widget.anuncio!.imagePath;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  void _salvarFormulario() async {
    if (!mounted) return;

    final isValid = _formKey.currentState!.validate();
    final hasImage = _imagePath != null;

    if (!isValid) {
      return;
    }

    if (!hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma imagem para o anúncio.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final titulo = _tituloController.text;
    final descricao = _descricaoController.text;
    final preco =
        double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;

    final anuncioSalvo = Anuncio(
      id: _isEditing ? widget.anuncio!.id : _uuid.v4(),
      titulo: titulo,
      descricao: descricao,
      preco: preco,
      imagePath: _imagePath!,
    );

    try {
      if (_isEditing) {
        await DBHelper.update(anuncioSalvo);
      } else {
        await DBHelper.insert(anuncioSalvo);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar o anúncio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validarCampoObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _validarPreco(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Por favor, insira um número válido.';
    }
    if (double.parse(value.replaceAll(',', '.')) <= 0) {
      return 'O preço deve ser maior que zero.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Anúncio' : 'Adicionar Anúncio'),
        backgroundColor: const Color(0xFFFFE600),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvarFormulario,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: _imagePath == null
                          ? const Text('Nenhuma imagem selecionada.',
                              style: TextStyle(color: Colors.grey))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(_imagePath!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Selecionar Imagem da Galeria'),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: _validarCampoObrigatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: _validarCampoObrigatorio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validarPreco,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvarFormulario,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3483FA),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0))),
                child: Text(
                    _isEditing ? 'Salvar Alterações' : 'Cadastrar Anúncio',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }}