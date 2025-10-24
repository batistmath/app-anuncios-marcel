import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:uuid/uuid.dart';
import '../models/anuncio.dart';
import 'form_anuncio_screen.dart';

class ListaAnunciosScreen extends StatefulWidget {
  const ListaAnunciosScreen({super.key});

  @override
  State<ListaAnunciosScreen> createState() => _ListaAnunciosScreenState();
}

class _ListaAnunciosScreenState extends State<ListaAnunciosScreen> {
  final List<Anuncio> _anuncios = [
    Anuncio(
      id: const Uuid().v4(),
      titulo: 'iPhone 13',
      descricao: 'iPhone 13 128GB Grafite, em excelente estado, com caixa e acessórios.',
      preco: 4500.00,
      imageUrl: 'https://m.media-amazon.com/images/I/41Zbbl4P+LL._AC_SX679_.jpg',
    ),
    Anuncio(
      id: const Uuid().v4(),
      titulo: 'Notebook Dell Inspiron',
      descricao: 'Notebook Dell Inspiron 15 3000, Intel Core i5, 8GB RAM, 256GB SSD, Tela 15.6" Full HD',
      preco: 2800.00,
      imageUrl: 'https://i.dell.com/is/image/DellContent/content/dam/ss2/product-images/dell-client-products/notebooks/inspiron-notebooks/15-3530-intel/media-gallery/black/notebook-inspiron-15-3530-nt-plastic-black-gallery-2.psd?fmt=png-alpha&pscan=auto&scl=1&hei=402&wid=606&qlt=100,1&resMode=sharp2&size=606,402&chrss=full',
    ),
  ];

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  void _navegarParaFormularioAdicionar() async {
    final novoAnuncio = await Navigator.of(context).push<Anuncio>(
      MaterialPageRoute(
        builder: (ctx) => const FormAnuncioScreen(),
      ),
    );

    if (novoAnuncio != null) {
      setState(() {
        _anuncios.add(novoAnuncio);
      });
      _mostrarSnackBar('Anúncio adicionado com sucesso!');
    }
  }

  void _navegarParaFormularioEditar(Anuncio anuncio) async {
    final anuncioEditado = await Navigator.of(context).push<Anuncio>(
      MaterialPageRoute(

        builder: (ctx) => FormAnuncioScreen(anuncio: anuncio),
      ),
    );

    if (anuncioEditado != null) {
      setState(() {
        final index = _anuncios.indexWhere((a) => a.id == anuncioEditado.id);
        if (index != -1) {
          _anuncios[index] = anuncioEditado;
        }
      });
      _mostrarSnackBar('Anúncio editado com sucesso!');
    }
  }

  void _removerAnuncio(String id) {
    Anuncio? anuncioRemovido;
    int? indexAnuncio;

    setState(() {
      indexAnuncio = _anuncios.indexWhere((a) => a.id == id);
      if(indexAnuncio != null && indexAnuncio! >= 0) {
        anuncioRemovido = _anuncios.removeAt(indexAnuncio!);
      }
    });

    if(anuncioRemovido != null && indexAnuncio != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anúncio removido!'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'DESFAZER',
            onPressed: () {
              setState(() {
                if(anuncioRemovido != null && indexAnuncio != null) {
                   _anuncios.insert(indexAnuncio!, anuncioRemovido!);
                }
              });
            },
          ),
        ),
      );
    }
  }

  void _mostrarSnackBar(String mensagem) {
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
        title: const Text(
          'Mercado Livre',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFFFE600),
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navegarParaFormularioAdicionar,
          ),
        ],
      ),
      body: _anuncios.isEmpty
          ? const Center(
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
            )
          : ListView.builder(
              itemCount: _anuncios.length,
              itemBuilder: (ctx, index) {
                final anuncio = _anuncios[index];
                return Dismissible(
                  key: Key(anuncio.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removerAnuncio(anuncio.id);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: _buildAnuncioItem(anuncio),
                );
              },
            ),
    );
  }


  Widget _buildAnuncioItem(Anuncio anuncio) {
    return InkWell(
      onTap: () => _navegarParaFormularioEditar(anuncio),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  anuncio.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Preço
                    Text(
                      _currencyFormat.format(anuncio.preco),
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}
