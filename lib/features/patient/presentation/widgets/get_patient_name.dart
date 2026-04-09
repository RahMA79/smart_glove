import 'package:smart_glove/supabase_client.dart';

/// Reads patient name from Supabase: public.users -> field: name
Future<String?> getPatientName(String uid) async {
  try {
    final data = await supabase
        .from('users')
        .select('name')
        .eq('id', uid)
        .maybeSingle();
    if (data == null) return null;
    final name = data['name'];
    if (name == null) return null;
    return name.toString();
  } catch (_) {
    return null;
  }
}
