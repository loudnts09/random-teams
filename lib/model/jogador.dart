class Jogador {

  int? id;
  String nome;
  final String? foto;
  int nivel;

  Jogador({this.id, required this.nome, this.foto, required this.nivel});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'nome': nome,
      'foto': foto,
      'nivel': nivel
    };
  }

  factory Jogador.fromMap(Map<String, dynamic> map){
    return Jogador(
      id: map['id'],
      nome: map['nome'],
      foto: map['foto'],
      nivel: map['nivel']
    );
  }
}