import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mt_my_ledger/bloc/auth/auth_bloc.dart';
import 'package:mt_my_ledger/bloc/theme_bloc.dart';
import 'package:mt_my_ledger/core/extensions/screen_utils.dart';
import 'package:mt_my_ledger/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _spendingLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpendingLimit();
  }

  Future<void> _loadSpendingLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final spendingLimit = prefs.getDouble('spending_limit');
    if (spendingLimit != null) {
      setState(() {
        _spendingLimitController.text = spendingLimit.toString();
      });
    }
  }

  Future<void> _saveSpendingLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final spendingLimit = double.tryParse(_spendingLimitController.text);
    if (spendingLimit != null) {
      await prefs.setDouble('spending_limit', spendingLimit);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(LocaleKeys.budget_saved.tr())));
      }
    }
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    final photoURL = user.photoURL;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (photoURL != null)
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: photoURL,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                radius: 40,
                child: const Icon(Icons.person, size: 40),
              ),
            ),
          )
        else
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            radius: 40,
            child: const Icon(Icons.person, size: 40),
          ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? LocaleKeys.no_name.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? LocaleKeys.no_email.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(LocaleKeys.language.tr()),
          subtitle: Text(
            context.locale.languageCode == 'th'
                ? LocaleKeys.thai.tr()
                : context.locale.languageCode == 'ko'
                    ? LocaleKeys.korean.tr()
                    : LocaleKeys.english.tr(),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(LocaleKeys.language.tr()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text(LocaleKeys.thai.tr()),
                      value: 'th',
                      groupValue: context.locale.languageCode,
                      onChanged: (value) {
                        context.setLocale(const Locale('th', 'TH'));
                        Navigator.of(context).pop();
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(LocaleKeys.english.tr()),
                      value: 'en',
                      groupValue: context.locale.languageCode,
                      onChanged: (value) {
                        context.setLocale(const Locale('en', 'US'));
                        Navigator.of(context).pop();
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(LocaleKeys.korean.tr()),
                      value: 'ko',
                      groupValue: context.locale.languageCode,
                      onChanged: (value) {
                        context.setLocale(const Locale('ko', 'KR'));
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            String themeSubtitle;
            switch (state.themeMode) {
              case ThemeMode.light:
                themeSubtitle = LocaleKeys.light_mode.tr();
                break;
              case ThemeMode.dark:
                themeSubtitle = LocaleKeys.dark_mode.tr();
                break;
              case ThemeMode.system:
                themeSubtitle = LocaleKeys.system_default.tr();
                break;
            }

            return ListTile(
              title: Text(LocaleKeys.display_theme.tr()),
              subtitle: Text(themeSubtitle),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(LocaleKeys.select_theme.tr()),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeMode>(
                          title: Text(LocaleKeys.light_mode.tr()),
                          value: ThemeMode.light,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(
                              ThemeChanged(themeMode: value!),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(LocaleKeys.dark_mode.tr()),
                          value: ThemeMode.dark,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(
                              ThemeChanged(themeMode: value!),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(LocaleKeys.system_default.tr()),
                          value: ThemeMode.system,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            context.read<ThemeBloc>().add(
                              ThemeChanged(themeMode: value!),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          title: Text(LocaleKeys.spending_limit.tr()),
          subtitle: Text(
            '${_spendingLimitController.text.isNotEmpty ? _spendingLimitController.text : LocaleKeys.not_set.tr()} ฿',
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(LocaleKeys.set_spending_limit.tr()),
                content: TextField(
                  controller: _spendingLimitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.enter_budget.tr(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(LocaleKeys.cancel.tr()),
                  ),
                  TextButton(
                    onPressed: () {
                      _saveSpendingLimit();
                      Navigator.of(context).pop();
                    },
                    child: Text(LocaleKeys.save.tr()),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (context.isMobile) {
            return Column(
              children: [
                const SizedBox(height: 16),
                if (user != null) _buildUserProfile(context, user),
                const SizedBox(height: 16),
                const Divider(height: 1),
                Expanded(child: _buildSettingsList(context)),
              ],
            );
          } else {
            return Row(
              children: [
                if (user != null)
                  Expanded(flex: 3, child: _buildUserProfile(context, user))
                else
                   Expanded(
                    child: Center(child: Text(LocaleKeys.no_user_data.tr())),
                  ),
                const VerticalDivider(width: 1),
                Expanded(flex: 4, child: _buildSettingsList(context)),
              ],
            );
          }
        },
      ),
    );
  }
}