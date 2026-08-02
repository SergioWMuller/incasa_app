import 'package:incasa_app/core/constants/supabase_constants.dart';
import 'package:incasa_app/core/network/supabase_client.dart';
import 'package:incasa_app/data/models/profile/phone_model.dart';

/// DataSource para a tabela `phones` (incasa-api.yaml §04).
///
/// RLS: cada usuário só enxerga/escreve os próprios telefones
/// (`user_id = app_user_id()`), então depende do JWT do Supabase.
abstract class PhoneSupabaseDataSource {
  /// Lista os telefones do usuário autenticado.
  Future<List<PhoneModel>> getPhones();

  /// Cria um telefone (POST /phones). Envia apenas os campos de `PhoneInsert`.
  Future<PhoneModel> createPhone(PhoneModel phone);
}

class PhoneSupabaseDataSourceImpl implements PhoneSupabaseDataSource {
  final SupabaseClientWrapper supabase;

  PhoneSupabaseDataSourceImpl({required this.supabase});

  @override
  Future<List<PhoneModel>> getPhones() async {
    try {
      final response = await supabase
          .from(SupabaseConstants.phonesTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PhoneModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar telefones no Supabase: $e');
    }
  }

  @override
  Future<PhoneModel> createPhone(PhoneModel phone) async {
    try {
      final response = await supabase
          .from(SupabaseConstants.phonesTable)
          .insert(phone.toInsert())
          .select()
          .single();

      return PhoneModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar telefone no Supabase: $e');
    }
  }
}
