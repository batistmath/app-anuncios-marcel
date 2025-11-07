class Anuncio {
  final String id;
  final String titulo;
  final String descricao;
  final double preco;
  final String imagePath;

  Anuncio({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'imagePath': imagePath,
    };
  }

  factory Anuncio.fromMap(Map<String, dynamic> map) {
    return Anuncio(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      preco: map['preco'],
      imagePath: map['imagePath'],
    );
  }
}