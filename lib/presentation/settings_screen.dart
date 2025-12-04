import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mt_my_ledger/bloc/auth/auth_bloc.dart';
import 'package:mt_my_ledger/bloc/theme_bloc.dart';
import 'package:mt_my_ledger/core/extensions/screen_utils.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกงบประมาณแล้ว')));
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
                child: Icon(Icons.person, size: 40),
              ),
            ),
          )
        else
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'No Name',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? 'No Email',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return ListView(
      children: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return ListTile(
              title: const Text('ธีมการแสดงผล'),
              subtitle: Text(state.themeMode.toString().split('.').last),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('เลือกธีม'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text('โหมดสว่าง'),
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
                          title: const Text('โหมดมืด'),
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
                          title: const Text('ตามการตั้งค่าระบบ'),
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
          title: const Text('งบประมาณที่จำกัดไว้'),
          subtitle: Text(
            '${_spendingLimitController.text.isNotEmpty ? _spendingLimitController.text : 'ไม่ได้ตั้งค่า'} ฿',
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('ตั้งค่างบประมาณ'),
                content: TextField(
                  controller: _spendingLimitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'ใส่งบประมาณของคุณ',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('ยกเลิก'),
                  ),
                  TextButton(
                    onPressed: () {
                      _saveSpendingLimit();
                      Navigator.of(context).pop();
                    },
                    child: const Text('บันทึก'),
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
        title: const Text('ตั้งค่า'),
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
                SizedBox(height: 16),
                if (user != null) _buildUserProfile(context, user),
                SizedBox(height: 16),
                Divider(height: 1),
                Expanded(child: _buildSettingsList(context)),
              ],
            );
          } else {
            return Row(
              children: [
                if (user != null)
                  Expanded(flex: 3, child: _buildUserProfile(context, user))
                else
                  const Expanded(
                    child: Center(child: Text('ไม่พบข้อมูลผู้ใช้')),
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
