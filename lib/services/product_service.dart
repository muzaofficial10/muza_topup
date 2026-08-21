import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../models/package_model.dart';

class ProductService {
  final _client = SupabaseService.client;

  Future<List<PackageModel>> getPackages(GameType game) async {
    final data = await _client
        .from('packages')
        .select()
        .eq('game', game.name)
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => PackageModel.fromJson(e)).toList();
  }

  // ---------- Admin only (RLS-enforced) ----------

  Future<List<PackageModel>> getAllPackages() async {
    final data = await _client.from('packages').select().order('game').order('sort_order');
    return (data as List).map((e) => PackageModel.fromJson(e)).toList();
  }

  Future<void> addPackage(PackageModel pkg) async {
    await _client.from('packages').insert(pkg.toJson());
  }

  Future<void> updatePackage(String id, PackageModel pkg) async {
    await _client.from('packages').update(pkg.toJson()).eq('id', id);
  }

  Future<void> deletePackage(String id) async {
    await _client.from('packages').delete().eq('id', id);
  }
}
