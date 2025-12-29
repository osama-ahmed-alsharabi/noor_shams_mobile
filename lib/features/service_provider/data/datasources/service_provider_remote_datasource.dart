import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_provider_model.dart';

abstract class ServiceProviderRemoteDataSource {
  Future<ServiceProviderModel> getProviderProfile(String id);
  Future<void> updateProviderProfile(ServiceProviderModel provider);
}

class ServiceProviderRemoteDataSourceImpl
    implements ServiceProviderRemoteDataSource {
  final SupabaseClient supabase;

  ServiceProviderRemoteDataSourceImpl(this.supabase);

  @override
  Future<ServiceProviderModel> getProviderProfile(String id) async {
    final response = await supabase
        .from('service_providers')
        .select()
        .eq('id', id)
        .single();

    // We might need to join with 'users' table if some data is there,
    // but assuming 'service_providers' view or table has all needed info or we duplicate.
    // Ideally, for this model which extends User, we might need to fetch User data too.
    // However, for simplicity let's assume 'service_providers' table has the extra fields
    // and we fetch basic user info separately or it's joined.
    // For now, let's assume the table `service_providers` contains all the specific fields,
    // and we might need to merge with User data if they are split.
    // NOTE: 'users' table has name/email/role. 'service_providers' has rest.
    // To construct ServiceProviderModel (which includes name/email), we need both.

    final userResponse = await supabase
        .from('users')
        .select()
        .eq('id', id)
        .single();

    final combinedData = {...userResponse, ...response};

    return ServiceProviderModel.fromJson(combinedData);
  }

  @override
  Future<void> updateProviderProfile(ServiceProviderModel provider) async {
    // Update 'users' table part
    await supabase
        .from('users')
        .update({
          'name': provider.name,
          // email is usually not updatable this easily or handled by Auth
        })
        .eq('id', provider.id);

    // Update 'service_providers' table part
    final providerData = {
      'profession': provider.profession,
      'bio': provider.bio,
      'experienceYears': provider.experienceYears,
      'portfolioImages': provider.portfolioImages,
      'isAvailable': provider.isAvailable,
      // rating/reviewCount usually updated by system, not user edit
    };

    // Check if row exists, if not upsert?
    // Using upsert for service_provider side
    await supabase.from('service_providers').upsert({
      'id': provider.id,
      ...providerData,
    });
  }
}
