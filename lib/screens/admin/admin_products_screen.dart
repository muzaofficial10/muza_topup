import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/package_model.dart';
import '../../services/product_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<PackageModel> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final pkgs = await context.read<ProductService>().getAllPackages();
    if (mounted) setState(() {
      _packages = pkgs;
      _loading = false;
    });
  }

  void _openEditor({PackageModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PackageEditorSheet(existing: existing, onSaved: _load),
    );
  }

  Future<void> _delete(PackageModel pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Delete Package'),
        content: Text('Remove "${pkg.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<ProductService>().deletePackage(pkg.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _openEditor())],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.neonBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.neonBlue,
              tabs: [Tab(text: 'PUBG UC'), Tab(text: 'eFootball Coins')],
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
                  : TabBarView(
                      children: [
                        _buildList(GameType.pubg),
                        _buildList(GameType.efootball),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(GameType game) {
    final list = _packages.where((p) => p.game == game).toList();
    if (list.isEmpty) {
      return const Center(child: Text('No packages yet', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final pkg = list[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('\$${pkg.price.toStringAsFixed(2)} · ${pkg.isActive ? "Active" : "Hidden"}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.neonBlue, size: 20), onPressed: () => _openEditor(existing: pkg)),
              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20), onPressed: () => _delete(pkg)),
            ],
          ),
        );
      },
    );
  }
}

class _PackageEditorSheet extends StatefulWidget {
  final PackageModel? existing;
  final VoidCallback onSaved;
  const _PackageEditorSheet({this.existing, required this.onSaved});

  @override
  State<_PackageEditorSheet> createState() => _PackageEditorSheetState();
}

class _PackageEditorSheetState extends State<_PackageEditorSheet> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late final _amountCtrl = TextEditingController(text: widget.existing?.amount.toString() ?? '');
  late final _priceCtrl = TextEditingController(text: widget.existing?.price.toString() ?? '');
  GameType _game = GameType.pubg;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) _game = widget.existing!.game;
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _amountCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    final pkg = PackageModel(
      id: widget.existing?.id ?? '',
      game: _game,
      name: _nameCtrl.text.trim(),
      amount: int.tryParse(_amountCtrl.text) ?? 0,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      isActive: true,
      sortOrder: widget.existing?.sortOrder ?? 0,
    );
    final service = context.read<ProductService>();
    if (widget.existing != null) {
      await service.updatePackage(widget.existing!.id, pkg);
    } else {
      await service.addPackage(pkg);
    }
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? 'Add Package' : 'Edit Package',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SegmentedButton<GameType>(
            segments: const [
              ButtonSegment(value: GameType.pubg, label: Text('PUBG')),
              ButtonSegment(value: GameType.efootball, label: Text('eFootball')),
            ],
            selected: {_game},
            onSelectionChanged: (s) => setState(() => _game = s.first),
          ),
          const SizedBox(height: 14),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Package Name (e.g. 325 UC)')),
          const SizedBox(height: 14),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (UC / Coins)'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Price (USD)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save Package'),
          ),
        ],
      ),
    );
  }
}
