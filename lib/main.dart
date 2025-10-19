import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- هذا جديد
import 'package:notes/services/sharedPref.dart';
import 'screens/home.dart';
import 'data/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData theme = appThemeLight;

  @override
  void initState() {
    super.initState();
    updateThemeFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      locale: Locale('ar'), // <-- اللغة العربية
      supportedLocales: [Locale('ar')], // <-- اللغات المدعومة
      localizationsDelegates: GlobalMaterialLocalizations.delegates, // <-- الترجمات
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // <-- من اليمين إلى اليسار
          child: child!,
        );
      },
      home: MyHomePage(key: UniqueKey(), title: 'الرئيسية', changeTheme: setTheme),
    );
  }

  setTheme(Brightness brightness) {
    setState(() {
      theme = brightness == Brightness.dark ? appThemeDark : appThemeLight;
    });
  }

  void updateThemeFromSharedPref() async {
    String themeText = await getThemeFromSharedPref();
    setTheme(themeText == 'light' ? Brightness.light : Brightness.dark);
  }
}
