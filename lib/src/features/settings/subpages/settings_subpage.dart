import 'package:flutter/material.dart';

import '../../../app/l10n/l10n.dart';

class SettingsSubpage extends StatelessWidget {
  const SettingsSubpage({super.key, required this.pageKey});

  final String pageKey;

  String _title(BuildContext context) {
    final l10n = context.l10n;
    switch (pageKey) {
      case 'appearance':
        return l10n.appearance;
      case 'privacy':
        return l10n.privacyControls;
      case 'units':
        return l10n.units;
      case 'temperature':
        return l10n.temperature;
      case 'default_media':
        return l10n.defaultHighlightMedia;
      case 'autoplay_video':
        return l10n.autoplayVideo;
      case 'default_maps':
        return l10n.defaultMaps;
      case 'feed_order':
        return l10n.feedOrder;
      case 'training_zones':
        return l10n.trainingZones;
      case 'siri_shortcuts':
        return l10n.siriShortcuts;
      case 'beacon':
        return l10n.beacon;
      case 'partner_integrations':
        return l10n.partnerIntegrations;
      case 'weather':
        return l10n.weather;
      case 'health_data':
        return l10n.healthData;
      case 'contacts':
        return l10n.contacts;
      case 'push_notifications':
        return l10n.pushNotifications;
      case 'email_notifications':
        return l10n.emailNotifications;
      case 'subscription':
        return l10n.yourSubscription;
      case 'gift':
        return l10n.giftSubscription;
      case 'connect_device':
        return l10n.connectDevice;
      case 'manage_devices':
        return l10n.manageDevices;
      case 'restore_purchases':
        return l10n.restorePurchases;
      case 'change_email':
        return l10n.changeEmail;
      case 'help':
        return l10n.help;
      case 'promo':
        return l10n.promoTitle;
      default:
        return l10n.settingsTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _title(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.l10n.settingsLanding(title),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
