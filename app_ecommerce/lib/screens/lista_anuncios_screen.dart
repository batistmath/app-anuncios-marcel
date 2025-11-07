import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../models/anuncio.dart';
import 'form_anuncio_screen.dart';
import '../helpers/db_helper.dart';

class ListaAnunciosScreen extends StatefulWidget {
  const ListaAnunciosScreen({super.key});

  @override
  State<ListaAnunciosScreen> createState() => _ListaAnunciosScreenState();
}

class _ListaAnunciosScreenState extends State<ListaAnunciosScreen> {
  late Future<List<Anuncio>> _anunciosFuture;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _refreshAnuncios();
  }

  void _refreshAnuncios() {
    setState(() {
      _anunciosFuture = DBHelper.getAll();
    });
  }

  void _navegarParaFormulario([Anuncio? anuncio]) async {
    final bool? foiSalvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => FormAnuncioScreen(anuncio: anuncio),
      ),
    );

    if (foiSalvo == true) {
      _refreshAnuncios();
    }
  }

  void _removerAnuncio(Anuncio anuncioRemovido) async {
    await DBHelper.delete(anuncioRemovido.id);
    _refreshAnuncios();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Anúncio removido!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () async {
            await DBHelper.insert(anuncioRemovido);
            _refreshAnuncios();
          },
        ),
      ),
    );
  }

  void _mostrarOpcoesShare(Anuncio anuncio) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('WhatsApp'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _sharePorWhatsApp(anuncio);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms),
                title: const Text('SMS'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _sharePorSMS(anuncio);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('E-mail'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _sharePorEmail(anuncio);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildShareText(Anuncio anuncio) {
    return 'Olha esse anúncio no Mercado Livre: ${anuncio.titulo} por ${_currencyFormat.format(anuncio.preco)}. ${anuncio.descricao}';
  }

  Future<void> _launchUri(Uri uri, String appName) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _mostrarSnackBar('Não foi possível abrir o $appName.');
    }
  }

  void _sharePorWhatsApp(Anuncio anuncio) {
    final text = _buildShareText(anuncio);
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    _launchUri(uri, 'WhatsApp');
  }

  void _sharePorSMS(Anuncio anuncio) {
    final text = _buildShareText(anuncio);
    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');
    _launchUri(uri, 'app de SMS');
  }

  void _sharePorEmail(Anuncio anuncio) {
    final text = _buildShareText(anuncio);
    final subject = 'Confira este anúncio: ${anuncio.titulo}';
    final uri = Uri.parse(
        'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(text)}');
    _launchUri(uri, 'app de E-mail');
  }

  void _mostrarSnackBar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado Livre'),
        backgroundColor: const Color(0xFFFFE600),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navegarParaFormulario(null),
          ),
        ],
      ),
      body: FutureBuilder<List<Anuncio>>(
        future: _anunciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar anúncios: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum anúncio cadastrado.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final anuncios = snapshot.data!;
          return ListView.builder(
            itemCount: anuncios.length,
            itemBuilder: (ctx, index) {
              final anuncio = anuncios[index];
              return _buildAnuncioItem(anuncio);
            },
          );
        },
      ),
    );
  }

  Widget _buildAnuncioItem(Anuncio anuncio) {
    return InkWell(
      onTap: () => _navegarParaFormulario(anuncio),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(anuncio.imagePath),
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anuncio.descricao,
                      style: const TextStyle(fontSize: 16.0),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(anuncio.preco),
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Frete grátis',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.blue[600]),
                    onPressed: () {
                      _mostrarOpcoesShare(anuncio);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[700]),
                    onPressed: () {
                      _removerAnuncio(anuncio);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}