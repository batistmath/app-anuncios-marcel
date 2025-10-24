
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/anuncio.dart';

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
  late TextEditingController _imageUrlController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.anuncio != null;

    _tituloController = TextEditingController(text: _isEditing ? widget.anuncio!.titulo : '');
    _descricaoController = TextEditingController(text: _isEditing ? widget.anuncio!.descricao : '');
    _precoController = TextEditingController(text: _isEditing ? widget.anuncio!.preco.toStringAsFixed(2) : '');
    _imageUrlController = TextEditingController(text: _isEditing ? widget.anuncio!.imageUrl : '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      final titulo = _tituloController.text;
      final descricao = _descricaoController.text;
      final preco = double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;
      final imageUrl = _imageUrlController.text.isNotEmpty 
          ? _imageUrlController.text 
          : 'https://placehold.co/120x120/eee/333?text=Sem+Foto';

      final anuncioSalvo = Anuncio(
        id: _isEditing ? widget.anuncio!.id : _uuid.v4(),
        titulo: titulo,
        descricao: descricao,
        preco: preco,
        imageUrl: imageUrl,
      );

      Navigator.of(context).pop(anuncioSalvo);
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
        title: Text(
          _isEditing ? 'Editar Anúncio' : 'Adicionar Anúncio',
           style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFFFE600),
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black87),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validarPreco,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.startsWith('http')) {
                    return 'Insira uma URL válida (http://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvarFormulario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3483FA),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)
                  )
                ),
                child: Text(_isEditing ? 'Salvar Alterações' : 'Cadastrar Anúncio', style: const TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
