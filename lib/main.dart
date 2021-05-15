import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/language/app_locale.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_details_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import 'providers/orders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('locale', 'ar');
  Locale locale = Locale(prefs.getString('locale')??'en', '');
  runApp(MyApp(
    locale: locale,
  ));
}

class MyApp extends StatelessWidget {
  final Locale locale;

  MyApp({this.locale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (context, authValue, previousProduct) => previousProduct
            ..getData(authValue.token, authValue.userId,
                previousProduct == null ? null : previousProduct.items),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (context, authValue, previousOrders) => previousOrders
            ..getData(authValue.token, authValue.userId,
                previousOrders == null ? null : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryColor: Color(0XFF4A707A),
            accentColor: Colors.blueGrey,
            fontFamily: 'Lato',
          ),
          supportedLocales: [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: locale,
          localizationsDelegates: [
            AppLocale.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // this method localeResolutionCallback return  device current locale
          localeResolutionCallback: (currentLocale, supportedLocales) {
            if (currentLocale != null) {
              print(currentLocale.languageCode);
              for (Locale locale in supportedLocales) {
                if (currentLocale.languageCode == locale.languageCode) {
                  return currentLocale;
                }
              }
            }
            return supportedLocales.first;
          },
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapShot) =>
                      snapShot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductOverviewScreen.routesName: (_) => ProductOverviewScreen(),
            ProductDetailsScreen.routesName: (_) => ProductDetailsScreen(),
            CartScreen.routesName: (_) => CartScreen(),
            AuthScreen.routesName: (_) => AuthScreen(),
            EditProductScreen.routesName: (_) => EditProductScreen(),
            OrdersScreen.routesName: (_) => OrdersScreen(),
            SplashScreen.routesName: (_) => SplashScreen(),
            UserProductsScreen.routesName: (_) => UserProductsScreen(),
          },
        ),
      ),
    );
  }
}
