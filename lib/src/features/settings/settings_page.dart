import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/l10n/l10n.dart';
import '../../routing/app_routes.dart';
import '../../shared/nav_lock.dart';
import 'subpages/settings_subpage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with NavLock {
  final _client = Supabase.instance.client;

  Future<void> _open(String key) async {
    await runLocked(() async {
      if (!mounted) return;
      final targetName = '${AppRoutes.settings}/$key';
      final current = ModalRoute.of(context)?.settings.name;
      if (current == targetName) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsSubpage(pageKey: key),
          settings: RouteSettings(name: targetName),
        ),
      );
    });
  }

  Future<void> _signOut() async {
    await runLocked(() async {
      try {
        await _client.auth.signOut();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (_) => false,
        );
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.signOutError)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        children: [
          _PromoCard(onTap: () => _open('promo')),
          _SectionHeader(context.l10n.accountHeader),
          _Tile(
            title: context.l10n.yourSubscription,
            subtitle: context.l10n.managePlan,
            leading: Icons.shield_outlined,
            onTap: () => _open('subscription'),
          ),
          _Tile(
            title: context.l10n.giftSubscription,
            leading: Icons.card_giftcard_outlined,
            onTap: () => _open('gift'),
          ),
          _Tile(
            title: context.l10n.connectDevice,
            subtitle: context.l10n.connectDeviceSubtitle,
            leading: Icons.wifi_tethering_outlined,
            onTap: () => _open('connect_device'),
          ),
          _Tile(
            title: context.l10n.manageDevices,
            leading: Icons.devices_other_outlined,
            onTap: () => _open('manage_devices'),
          ),
          _Tile(
            title: context.l10n.restorePurchases,
            leading: Icons.restore_outlined,
            onTap: () => _open('restore_purchases'),
          ),
          _Tile(
            title: context.l10n.changeEmail,
            leading: Icons.alternate_email_outlined,
            onTap: () => _open('change_email'),
          ),
          _Tile(
            title: context.l10n.help,
            leading: Icons.help_outline,
            onTap: () => _open('help'),
          ),
          _SectionHeader(context.l10n.preferencesHeader),
          _Tile(
            title: context.l10n.appearance,
            trailingBadge: context.l10n.newBadge,
            onTap: () => _open('appearance'),
          ),
          _Tile(
            title: context.l10n.privacyControls,
            trailingBadge: context.l10n.newBadge,
            onTap: () => _open('privacy'),
          ),
          _Tile(
            title: context.l10n.units,
            trailingValue: context.l10n.unitsKilometers,
            onTap: () => _open('units'),
          ),
          _Tile(
            title: context.l10n.temperature,
            trailingValue: context.l10n.temperatureCelsius,
            onTap: () => _open('temperature'),
          ),
          _Tile(
            title: context.l10n.defaultHighlightMedia,
            subtitle: context.l10n.defaultHighlightMediaSubtitle,
            onTap: () => _open('default_media'),
          ),
          SwitchListTile(
            title: Text(context.l10n.autoplayVideo),
            value: true,
            onChanged: (_) {},
          ),
          _Tile(
            title: context.l10n.defaultMaps,
            onTap: () => _open('default_maps'),
          ),
          _Tile(
            title: context.l10n.feedOrder,
            subtitle: context.l10n.feedOrderSubtitle,
            onTap: () => _open('feed_order'),
          ),
          _Tile(
            title: context.l10n.trainingZones,
            subtitle: context.l10n.trainingZonesSubtitle,
            onTap: () => _open('training_zones'),
          ),
          _Tile(
            title: context.l10n.siriShortcuts,
            onTap: () => _open('siri_shortcuts'),
          ),
          _Tile(
            title: context.l10n.beacon,
            onTap: () => _open('beacon'),
          ),
          _Tile(
            title: context.l10n.partnerIntegrations,
            onTap: () => _open('partner_integrations'),
          ),
          _Tile(
            title: context.l10n.weather,
            onTap: () => _open('weather'),
          ),
          _Tile(
            title: context.l10n.healthData,
            onTap: () => _open('health_data'),
          ),
          _Tile(
            title: context.l10n.contacts,
            onTap: () => _open('contacts'),
          ),
          _Tile(
            title: context.l10n.pushNotifications,
            onTap: () => _open('push_notifications'),
          ),
          _Tile(
            title: context.l10n.emailNotifications,
            onTap: () => _open('email_notifications'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
              ),
              onPressed: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((r) => r.isFirst);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.signOutError)),
                  );
                }
              },
              child: Text(context.l10n.signOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailingValue,
    this.trailingBadge,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final String? trailingValue;
  final String? trailingBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trailing = trailingBadge != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trailingBadge!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          )
        : trailingValue != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingValue!,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              )
            : const Icon(Icons.chevron_right);

    return ListTile(
      leading: leading != null
          ? Icon(
              leading,
              size: 22,
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.black54),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '60%',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.promoTitle,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.promoSubtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
