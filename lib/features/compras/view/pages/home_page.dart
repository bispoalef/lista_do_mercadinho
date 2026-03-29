import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../providers/lista_produtos.dart';
import '../widgets/item_da_lista_carrinho.dart';
import '../widgets/item_da_lista_pendente.dart';
import '../widgets/novo_produto_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  InterstitialAd? _interstitialAd;
  final String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  @override
  void initState() {
    super.initState();
    _carregarAnuncioTelaCheia();
  }

  void _carregarAnuncioTelaCheia() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Anúncio de tela cheia carregado!');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Falha ao carregar tela cheia: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListaDeProdutos>(
      builder: (context, lista, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            if (lista.getLista.isEmpty && lista.getCarrinho.isEmpty) {
              if (context.mounted) Navigator.pop(context);
              return;
            }

            final bool? sair = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Continuar Compra?'),
                content: const Text(
                  'Você deseja continuar editando sua lista ou voltar para a tela inicial? Seus itens ficarão salvos no rascunho.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continuar Compra'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ir para Início'),
                  ),
                ],
              ),
            );

            if (sair == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Minha Lista',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.list_alt), text: 'Pendentes'),
                    Tab(
                      icon: Icon(Icons.shopping_cart_checkout),
                      text: 'No Carrinho',
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  lista.getLista.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum item pendente.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : lista.getLista.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum item pendente.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ReorderableListView.builder(
                          buildDefaultDragHandles: false,

                          proxyDecorator:
                              (
                                Widget child,
                                int index,
                                Animation<double> animation,
                              ) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                        return Material(
                                          elevation: 4,
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: child,
                                        );
                                      },
                                  child: child,
                                );
                              },

                          onReorder: (oldIndex, newIndex) {
                            lista.reordenarLista(oldIndex, newIndex);
                          },
                          itemCount: lista.getLista.length,
                          itemBuilder: (ctx, i) {
                            final produto = lista.getLista[i];
                            return ItemDaListaPendente(
                              key: ValueKey(produto.id),
                              produto: produto,
                              list: lista,
                              index: i,
                            );
                          },
                        ),

                  lista.getCarrinho.isEmpty
                      ? const Center(
                          child: Text(
                            'Carrinho vazio.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: lista.getCarrinho.length,
                          itemBuilder: (ctx, i) {
                            final produto = lista.getCarrinho[i];
                            return ItemDaListaCarrinho(
                              key: ValueKey(produto.id),
                              produto: produto,
                              list: lista,
                            );
                          },
                        ),
                ],
              ),

              bottomNavigationBar: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total da Compra:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            formatadorMoeda.format(lista.valorTotalCarrinho()),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: lista.getCarrinho.isEmpty
                                  ? null
                                  : () {
                                      _controller.clear();
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Finalizar Compra'),
                                          content: TextField(
                                            controller: _controller,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Apelido da Compra (Opcional)',
                                              hintText: 'Ex: Compra do Mês',
                                            ),
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Cancelar'),
                                            ),
                                            FilledButton(
                                              onPressed: () async {
                                                final nome = _controller.text
                                                    .trim();
                                                await lista.finalizarCompra(
                                                  apelido: nome.isEmpty
                                                      ? null
                                                      : nome,
                                                );

                                                if (context.mounted) {
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Compra salva com sucesso! 🛒',
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                  if (_interstitialAd != null) {
                                                    _interstitialAd!.show();
                                                  }
                                                }
                                              },
                                              child: const Text(
                                                'Salvar e Sair',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Finalizar'),
                            ),
                          ),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      NovoProdutoDialog(lista: lista),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
