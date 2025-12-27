import 'package:flutter/cupertino.dart';
import 'package:mysmartadmin/app/app.dart';

import 'core/database_provider.dart';
import 'dev/domain_cross_entity_smoke_runner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseProvider.instance;
  await runCrossEntitySmokeTests(db);

  runApp(const LedgerApp());
}
