import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:lista_do_mercadinho/core/database/db_helper.dart';
import 'package:lista_do_mercadinho/core/theme/theme_provider.dart';
import 'package:lista_do_mercadinho/features/compras/models/produto.dart';
import 'package:lista_do_mercadinho/features/compras/providers/lista_produtos.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class BannerAnuncio extends StatefulWidget {
  const BannerAnuncio({super.key});

  @override
  State<BannerAnuncio> createState() => _BannerAnuncioState();
}

class _DashboardPageState extends State<DashboardPage> {
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatadorData = DateFormat('dd/MM/yyyy - HH:mm');

  late Future<List<Map<String, dynamic>>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _atualizarPainel();
  }

  void _atualizarPainel() {
    setState(() {
      _historicoFuture = DbHelper.instance.getHistoricoCompras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Painel'),
        actions: [
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _historicoFuture,
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
                      final String? apelido = compra['nome'];

                      return Dismissible(
                        key: ValueKey(compra['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.onError,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Apagar Histórico"),
                                  content: const Text(
                                    "Deseja realmente excluir esta compra do seu histórico?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      child: const Text("Excluir"),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (direction) async {
                          await DbHelper.instance.excluirCompra(compra['id']);
                          _atualizarPainel();
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () =>
                                _mostrarDetalhesCompra(context, compra),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              child: const Icon(Icons.shopping_cart_outlined),
                            ),
                            title: Text(
                              apelido != null && apelido.isNotEmpty
                                  ? apelido
                                  : formatadorData.format(dataCompra),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: apelido != null && apelido.isNotEmpty
                                ? Text(formatadorData.format(dataCompra))
                                : null,
                            trailing: Text(
                              formatadorMoeda.format(compra['valorTotal']),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
          ),
          const BannerAnuncio(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final db = DbHelper.instance;
            final rascunho = await db.getRascunho();
            if (!context.mounted) return;

            if (rascunho.isNotEmpty) {
              final bool? continuar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Lista em Andamento'),
                  content: const Text(
                    'Você tem uma lista de compras que não foi finalizada. Deseja continuar de onde parou?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        db.salvarNoRascunho([]);
                        Navigator.pop(context, false);
                      },
                      child: const Text('Descartar e Criar Nova'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Continuar Lista'),
                    ),
                  ],
                ),
              );

              if (continuar == true) {
                await Provider.of<ListaDeProdutos>(
                  context,
                  listen: false,
                ).carregarRascunho();
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    'home',
                  ).then((_) => _atualizarPainel());
                }
                return;
              }
            }

            await Provider.of<ListaDeProdutos>(
              context,
              listen: false,
            ).carregarRascunho();

            final itens = await db.getAllItensComprados();
            if (!context.mounted) return;

            if (itens.isEmpty) {
              Navigator.pushNamed(
                context,
                'home',
              ).then((_) => _atualizarPainel());
            } else {
              _mostrarPopUpNovaLista(context);
            }
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Nova Lista'),
        ),
      ),
    );
  }

  void _mostrarDetalhesCompra(
    BuildContext context,
    Map<String, dynamic> compra,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _DetalhesCompraSheet(compra: compra, onAtualizar: _atualizarPainel),
    );
  }

  void _mostrarPopUpNovaLista(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _NovaListaSheet(onAtualizar: _atualizarPainel),
    );
  }
}

class _BannerAnuncioState extends State<BannerAnuncio> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _carregarBanner();
  }

  void _carregarBanner() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Falha no Banner: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    return const SizedBox.shrink();
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

class _DetalhesCompraSheet extends StatefulWidget {
  final Map<String, dynamic> compra;
  final VoidCallback onAtualizar;

  const _DetalhesCompraSheet({required this.compra, required this.onAtualizar});

  @override
  State<_DetalhesCompraSheet> createState() => _DetalhesCompraSheetState();
}

class _DetalhesCompraSheetState extends State<_DetalhesCompraSheet> {
  List<Map<String, dynamic>> _itens = [];
  bool _carregando = true;
  final Set<String> _itensSelecionados = {};

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    final itens = await DbHelper.instance.getItensDaCompra(widget.compra['id']);
    setState(() {
      _itens = itens;
      for (var item in itens) _itensSelecionados.add(item['id']);
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reaproveitar Compra',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecione os itens que deseja adicionar à sua nova lista:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _itens.length,
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      final isSelected = _itensSelecionados.contains(
                        item['id'],
                      );
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(item['nome']),
                        subtitle: Text(
                          'Qtd: ${item['quantidade']} | R\$ ${(item['preco'] as num).toDouble().toStringAsFixed(2)}',
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            value == true
                                ? _itensSelecionados.add(item['id'])
                                : _itensSelecionados.remove(item['id']);
                          });
                        },
                      );
                    },
                  ),
          ),
          ElevatedButton.icon(
            onPressed: _itensSelecionados.isEmpty
                ? null
                : () {
                    final itensParaImportar = _itens
                        .where((i) => _itensSelecionados.contains(i['id']))
                        .map(
                          (i) => Produto(
                            id: const Uuid().v4(),
                            nome: i['nome'],
                            preco: (i['preco'] as num).toDouble(),
                            quantidade: i['quantidade'],
                          ),
                        )
                        .toList();

                    Provider.of<ListaDeProdutos>(
                      context,
                      listen: false,
                    ).importarItens(itensParaImportar);

                    Navigator.pop(context);
                    // Puxa o gatilho ao voltar!
                    Navigator.pushNamed(
                      context,
                      'home',
                    ).then((_) => widget.onAtualizar());
                  },
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('Importar para Nova Lista'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _NovaListaSheet extends StatefulWidget {
  final VoidCallback onAtualizar;

  const _NovaListaSheet({required this.onAtualizar});

  @override
  State<_NovaListaSheet> createState() => _NovaListaSheetState();
}

class _NovaListaSheetState extends State<_NovaListaSheet> {
  List<Map<String, dynamic>> _todosItens = [];
  bool _carregando = true;
  final Set<String> _itensSelecionados = {};

  @override
  void initState() {
    super.initState();
    _carregarTodosItens();
  }

  Future<void> _carregarTodosItens() async {
    final itens = await DbHelper.instance.getAllItensComprados();
    setState(() {
      _todosItens = itens;
      _carregando = false;
    });
  }

  void _irParaLista([List<Produto>? itensParaImportar]) {
    Navigator.pop(context);
    if (itensParaImportar != null && itensParaImportar.isNotEmpty) {
      Provider.of<ListaDeProdutos>(
        context,
        listen: false,
      ).importarItens(itensParaImportar);
    }
    Navigator.pushNamed(context, 'home').then((_) => widget.onAtualizar());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nova Lista de Compras',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecione os produtos que você quer comprar hoje, ou pule para criar uma lista vazia.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _todosItens.isEmpty
                ? const Center(
                    child: Text('Você ainda não tem itens no histórico.'),
                  )
                : ListView.builder(
                    itemCount: _todosItens.length,
                    itemBuilder: (context, index) {
                      final item = _todosItens[index];
                      final isSelected = _itensSelecionados.contains(
                        item['nome'],
                      );
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(item['nome']),
                        subtitle: Text(
                          'Último valor: R\$ ${(item['preco'] as num).toDouble().toStringAsFixed(2)}',
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            value == true
                                ? _itensSelecionados.add(item['nome'])
                                : _itensSelecionados.remove(item['nome']);
                          });
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _irParaLista(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Pular'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _itensSelecionados.isEmpty
                      ? null
                      : () {
                          final itensParaImportar = _todosItens
                              .where(
                                (i) => _itensSelecionados.contains(i['nome']),
                              )
                              .map(
                                (i) => Produto(
                                  id: const Uuid().v4(),
                                  nome: i['nome'],
                                  preco: (i['preco'] as num).toDouble(),
                                  quantidade: (i['quantidade'] as num).toInt(),
                                ),
                              )
                              .toList();
                          _irParaLista(itensParaImportar);
                        },
                  icon: const Icon(Icons.check),
                  label: Text('Criar com ${_itensSelecionados.length} itens'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
