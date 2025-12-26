import 'package:flutter/cupertino.dart';
import 'package:mysmartadmin/app/app.dart';

import 'dev/domain_smoke_runner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runDomainSmokeTest();

  runApp(const LedgerApp());
}
