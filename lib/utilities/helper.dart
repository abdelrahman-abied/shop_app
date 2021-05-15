import 'package:flutter/material.dart';
import 'package:shop_app/language/app_locale.dart';

String getString(BuildContext context, String key) {
  return AppLocale.of(context).getString(key);
}
