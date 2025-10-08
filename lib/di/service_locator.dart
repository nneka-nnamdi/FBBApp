
import 'package:fight_blight_bmore/data/repository.dart';
import 'package:fight_blight_bmore/data/sharedpref/shared_preference_helper.dart';
import 'package:fight_blight_bmore/di/local_module.dart';
import 'package:fight_blight_bmore/services/location_service.dart';
import 'package:fight_blight_bmore/services/navigation_service.dart';
import 'package:fight_blight_bmore/stores/error/error_store.dart';
import 'package:fight_blight_bmore/stores/form/form_store.dart';
import 'package:fight_blight_bmore/stores/post/post_store.dart';
import 'package:fight_blight_bmore/stores/user/user_store.dart';
import 'package:fight_blight_bmore/utils/session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // factories:-----------------------------------------------------------------
  getIt.registerFactory(() => ErrorStore());
  getIt.registerFactory(() => FormStore());

  // singletons:----------------------------------------------------------------
  getIt.registerSingletonAsync<SharedPreferences>(() => LocalModule.provideSharedPreferences());
  getIt.registerSingleton(SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()));
  getIt.registerSingleton(SessionManager());
  getIt.registerSingleton(LocationService());

  // repository:----------------------------------------------------------------
  getIt.registerSingleton(Repository(
    getIt<SharedPreferenceHelper>(),
  ));

  // stores:--------------------------------------------------------------------
  getIt.registerSingleton(PostStore());
  getIt.registerSingleton(UserStore());

  // navigation:--------------------------------------------------------------------
  getIt.registerLazySingleton(() => NavigationService());
}
