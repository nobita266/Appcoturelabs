import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/screen/start.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'provider/accounts.dart';
import 'provider/cart.dart';
import 'screen/start.dart';

void main() async {
  await initHiveForFlutter();
  await dotenv.load(fileName: ".env");
  final dio = Dio();
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));
  final link = Link.from([
    DioLink(dotenv.get('STG_URL'), client: dio),
  ]);
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
      ],
      child: MyApp(client: client),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  const MyApp({super.key, required this.client});

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.red, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          return MaterialApp(
            title: 'Magento Shop',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
              useMaterial3: true,
            ),
            home: const StartScreen(),
          );
        },
      ),
    );
  }
}
