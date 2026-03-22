import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_do_mercadinho/core/database/db_helper.dart';
import 'package:lista_do_mercadinho/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatadorData = DateFormat('dd/MM/yyyy - HH:mm');

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Painel'),
        actions: [
          // <-- Novo botão de tema aqui!
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DbHelper.instance.getHistoricoCompras(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Nenhum histórico ainda.\nCrie sua primeira lista!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 16,
                ),
              ),
            );
          }

          final compras = snapshot.data!;

          final gastoTotal = compras.fold<double>(
            0,
            (soma, item) => soma + (item['valorTotal'] as double),
          );
          final gastoMedio = gastoTotal / compras.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Estatísticas Gerais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _EstatisticaItem(
                            titulo: 'Gasto Total',
                            valor: formatadorMoeda.format(gastoTotal),
                          ),
                          _EstatisticaItem(
                            titulo: 'Média/Lista',
                            valor: formatadorMoeda.format(gastoMedio),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Últimas Compras',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ...compras.map((compra) {
                final dataCompra = DateTime.parse(compra['data']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    title: Text(
                      formatadorData.format(dataCompra),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      formatadorMoeda.format(compra['valorTotal']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, 'home').then((_) {
            setState(() {});
          });
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nova Lista'),
      ),
    );
  }
}

class _EstatisticaItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _EstatisticaItem({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
