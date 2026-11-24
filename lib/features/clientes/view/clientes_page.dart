import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/clientes_view_model.dart';
import 'cliente_form_page.dart';

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes - Top Açaí RV'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      // --- INÍCIO DA ALTERAÇÃO DO CACHE OFFLINE ---
      body: Column(
        children: [
          // O banner amarelo só aparece se o ViewModel avisar que está no cache
          if (context.watch<ClientesViewModel>().isFromCache)
            Container(
              width: double.infinity,
              color: Colors.amber.shade200,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Modo Offline: Exibindo dados salvos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          // O Expanded é necessário para a lista ocupar o resto da tela
          Expanded(
            child: Consumer<ClientesViewModel>(
              builder: (context, viewModel, child) {
                switch (viewModel.state) {
                  case ClientesState.loading:
                    return const Center(child: CircularProgressIndicator());
                  case ClientesState.empty:
                    return const Center(child: Text('Nenhum cliente cadastrado ainda.'));
                  case ClientesState.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(viewModel.errorMessage, style: const TextStyle(color: Colors.red)),
                          ElevatedButton(
                            onPressed: viewModel.carregarClientes,
                            child: const Text('Tentar novamente'),
                          )
                        ],
                      ),
                    );
                  case ClientesState.success:
                    return ListView.builder(
                      itemCount: viewModel.clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = viewModel.clientes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(cliente.nome),
                            subtitle: Text(cliente.telefone),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Excluir Cliente'),
                                    content: Text('Tem certeza que deseja excluir ${cliente.nome}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await viewModel.deletarCliente(cliente.id!);
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClienteFormPage(cliente: cliente),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
      // --- FIM DA ALTERAÇÃO ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClienteFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}