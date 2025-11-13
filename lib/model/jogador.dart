class Jogador {

  int? id;
  String nome;

  Jogador({this.id, required this.nome});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory Jogador.fromMap(Map<String, dynamic> map){
    return Jogador(
      id: map['id'],
      nome: map['nome'],
    );
  }
}