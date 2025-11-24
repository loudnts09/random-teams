class Jogador {

  int? id;
  String nome;
  final String? foto;

  Jogador({this.id, required this.nome, this.foto});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'nome': nome,
      'foto': foto,
    };
  }

  factory Jogador.fromMap(Map<String, dynamic> map){
    return Jogador(
      id: map['id'],
      nome: map['nome'],
      foto: map['foto']
    );
  }
}