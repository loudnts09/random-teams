class Sorteio {
  final int id;
  final DateTime dataHora;
  final List<List<String>> times; // Lista de times com nomes dos jogadores

  Sorteio({
    required this.id,
    required this.dataHora,
    required this.times,
  });

  factory Sorteio.fromMap(Map<String, dynamic> map) {
    return Sorteio(
      id: map['id'],
      dataHora: DateTime.parse(map['data_hora']),
      times: [], // Será preenchido pelo repositório
    );
  }
}
