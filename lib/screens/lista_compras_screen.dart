import 'package:flutter/material.dart';
import '../models/item_model.dart';
//import '../helpers/database_helper.dart';

class ListaComprasScreen extends StatefulWidget {
  @override
  _ListaComprasScreenState createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  final List<Item> _itens = [];
  final TextEditingController _controllerNome = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _carregarItens(); // Carregar itens ao iniciar a tela
  }

  // Carrega os itens do banco de dados
  void _carregarItens() async {
    final itens = await dbHelper.getItems();
    setState(() {
      _itens.clear();
      _itens.addAll(itens);
    });
  }

  // Adiciona um item ao banco
  void _adicionarItem() async {
    final nome = _controllerNome.text;
    if (nome.isNotEmpty) {
      final novoItem = Item(nome: nome);
      await dbHelper.insertItem(novoItem); // Insere o item no banco
      _carregarItens(); // Atualiza a lista de itens
      _controllerNome.clear(); // Limpa o campo de nome
      setState(() {}); // Força a atualização da UI
    }
  }

  // Marca o item como comprado e atualiza no banco
  void _marcarComprado(int index) async {
    setState(() {
      _itens[index].comprado = !_itens[index].comprado;
    });
    await dbHelper.updateItem(_itens[index]); // Atualiza o item no banco
    _carregarItens(); // Atualiza a lista de itens
  }

  // Atualiza o preço de um item e faz o update no banco
  void _atualizarPreco(int index, String preco) async {
    final precoValue = double.tryParse(preco) ?? 0.0;
    setState(() {
      _itens[index].preco = precoValue;
    });
    await dbHelper.updateItem(_itens[index]); // Atualiza o preço no banco
    _carregarItens(); // Atualiza a lista de itens
  }

  // Cálculo do total dos itens comprados
  double get total {
    double soma = 0.0;
    for (var item in _itens) {
      if (item.comprado) soma += item.preco;
    }
    return soma;
  }

  // Método para excluir todos os itens do banco de dados
  void _limparLista() async {
    await dbHelper.deleteAllItems(); // Exclui todos os itens do banco
    _carregarItens(); // Atualiza a lista na interface
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Supermercado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controllerNome,
              decoration: InputDecoration(
                labelText: 'Nome do item',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _adicionarItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor de fundo azul
                    foregroundColor: Colors.white, // Cor do texto branco
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Raio da borda de 8
                    ),
                  ),
                  child: Text(
                    'Adicionar Item',
                    style: TextStyle(
                      fontSize: 16, // Tamanho da fonte
                      fontWeight: FontWeight.bold, // Peso da fonte
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _limparLista,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cor de fundo vermelha
                    foregroundColor: Colors.white, // Cor do texto branco
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Raio da borda de 8
                    ),
                  ),
                  child: Text(
                    'Limpar Lista',
                    style: TextStyle(
                      fontSize: 16, // Tamanho da fonte
                      fontWeight: FontWeight.bold, // Peso da fonte
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _itens.length,
                itemBuilder: (context, index) {
                  final item = _itens[index];
                  final TextEditingController _controllerPreco = TextEditingController();
                  _controllerPreco.text = item.preco.toStringAsFixed(2); // Definindo o preço inicial do item
                  
                  return ListTile(
                    title: Text(item.nome),
                    trailing: Checkbox(
                      value: item.comprado,
                      onChanged: (_) => _marcarComprado(index),
                    ),
                    tileColor: item.comprado ? Colors.green[100] : null,
                    subtitle: item.comprado
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Preço: R\$ ${item.preco.toStringAsFixed(2)}'),
                              TextField(
                                controller: _controllerPreco,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Digite o preço',
                                ),
                                onChanged: (value) {
                                  _atualizarPreco(index, value); // Atualiza o preço enquanto digita
                                },
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
