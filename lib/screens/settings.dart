import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class SettingsPage extends StatefulWidget {
  final Function(Brightness brightness) changeTheme;

  const SettingsPage({super.key, required this.changeTheme});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Brightness currentTheme;
  late bool isDarkMode;
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    currentTheme = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode = currentTheme == Brightness.dark;
  }

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
      widget.changeTheme(isDarkMode ? Brightness.dark : Brightness.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text(
          "الإعدادات",
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(OMIcons.settings, size: size.width * 0.06),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          physics: BouncingScrollPhysics(),
          children: [
            // معلومات التطبيق
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).cardColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          OMIcons.note,
                          size: size.width * 0.12,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: size.width * 0.03),
                        Text(
                          "ملاحظاتك",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                      thickness: 1.2,
                    ),
                    SizedBox(height: size.height * 0.015),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "النسخة: 1.0.0",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: size.width * 0.035,
                            color: textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          "تحديث تلقائي",
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: _autoSyncEnabled,
                          onChanged: (value) {
                            setState(() {
                              _autoSyncEnabled = value;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            // إعدادات السمة
            buildSettingsCard(
              context,
              "المظهر",
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildThemeOption(
                      context,
                      "فاتح",
                      OMIcons.wbSunny,
                      !isDarkMode,
                      () {
                        if (!isDarkMode) return;
                        toggleTheme(false);
                      },
                    ),
                    buildThemeOption(
                      context,
                      "داكن",
                      OMIcons.brightness3,
                      isDarkMode,
                      () {
                        if (isDarkMode) return;
                        toggleTheme(true);
                      },
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),

            // إعدادات الإشعارات
            buildSettingsCard(
              context,
              "الإشعارات",
              [
                buildToggleOption(
                  context,
                  "إشعارات التذكير",
                  Icons.notifications_active,
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                buildToggleOption(
                  context,
                  "تحديث الملاحظات",
                  Icons.sync,
                  _autoSyncEnabled,
                  (value) {
                    setState(() {
                      _autoSyncEnabled = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),

            // إعدادات الحساب
            buildSettingsCard(
              context,
              "الحساب",
              [
                buildListTile(
                  context,
                  Icons.person_outline,
                  "الملف الشخصي",
                  "عرض وتعديل الملف",
                  () {},
                ),
                buildListTile(
                  context,
                  Icons.lock_outline,
                  "الأمان",
                  "إدارة كلمات المرور",
                  () {},
                ),
                buildListTile(
                  context,
                  Icons.language,
                  "اللغة",
                  "العربية",
                  () {},
                ),
              ],
            ),

            SizedBox(height: size.height * 0.03),

            // دعم التطبيق
            buildSettingsCard(
              context,
              "دعم التطبيق",
              [
                buildListTile(
                  context,
                  Icons.help_outline,
                  "المساعدة",
                  "أسئلة شائعة",
                  () {},
                ),
                buildListTile(
                  context,
                  Icons.rate_review,
                  "تقييم التطبيق",
                  "قيم تجربتك",
                  () {},
                ),
                buildListTile(
                  context,
                  Icons.share,
                  "مشاركة التطبيق",
                  "شارك مع الأصدقاء",
                  () {},
                ),
              ],
            ),

            SizedBox(height: size.height * 0.04),

            // نبذة عن المطور
            Center(
              child: Text(
                "تم التطوير بواسطة: أحمد | جميع الحقوق محفوظة ©",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: size.width * 0.03,
                  color: textTheme.bodySmall?.color,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSettingsCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 3,
      shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.02,
                bottom: size.height * 0.015,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.045,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.015,
            horizontal: size.width * 0.02,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(isActive ? 0.15 : 0.05),
                blurRadius: isActive ? 8 : 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).iconTheme.color,
                size: size.width * 0.08,
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: size.width * 0.035,
                  color: isActive
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToggleOption(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: size.width * 0.055,
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.008),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: size.width * 0.05,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: size.width * 0.032,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: size.width * 0.035,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onTap: onTap,
      ),
    );
  }
}