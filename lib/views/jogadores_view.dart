import 'package:flutter/material.dart';

class JogadoresView extends StatefulWidget {
  const JogadoresView({super.key});

  @override
  State<JogadoresView> createState() => _JogadoresViewState();
}

class _JogadoresViewState extends State<JogadoresView> {
  final List<String> _jogadores = ['Arthur', 'Nathalia', 'Larissa'];

  // Função para abrir popup de adicionar/editar jogador
  void _abrirDialogo({String? nomeAntigo, int? index}) {
    final TextEditingController controller =
        TextEditingController(text: nomeAntigo ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nomeAntigo == null ? 'Adicionar Jogador' : 'Editar Jogador'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = controller.text.trim();
              if (nome.isNotEmpty) {
                setState(() {
                  if (index != null) {
                    _jogadores[index] = nome; // Editar
                  } else {
                    _jogadores.add(nome); // Adicionar
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(nomeAntigo == null ? 'Adicionar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  // Função para confirmar exclusão
  void _confirmarExclusao(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir jogador'),
        content: Text('Deseja realmente excluir "${_jogadores[index]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _jogadores.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar jogadores'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirDialogo(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _jogadores.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum jogador adicionado ainda.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: _jogadores.length,
                itemBuilder: (context, index) {
                  final nome = _jogadores[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(nome),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _abrirDialogo(
                              nomeAntigo: nome,
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarExclusao(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
