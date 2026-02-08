import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Movnos'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @bodyMetricsCard.
  ///
  /// In pt, this message translates to:
  /// **'Métricas corporais'**
  String get bodyMetricsCard;

  /// No description provided for @trainingStatsCard.
  ///
  /// In pt, this message translates to:
  /// **'Estatísticas de treino'**
  String get trainingStatsCard;

  /// No description provided for @appBarYou.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get appBarYou;

  /// Shown under profile header to indicate who is signed in
  ///
  /// In pt, this message translates to:
  /// **'Conectado como {email}'**
  String signedInAs(String email);

  /// No description provided for @saving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get saving;

  /// No description provided for @appBarHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get appBarHome;

  /// No description provided for @appBarMaps.
  ///
  /// In pt, this message translates to:
  /// **'Mapas'**
  String get appBarMaps;

  /// No description provided for @appBarRecord.
  ///
  /// In pt, this message translates to:
  /// **'Gravar'**
  String get appBarRecord;

  /// No description provided for @appBarGroups.
  ///
  /// In pt, this message translates to:
  /// **'Grupos'**
  String get appBarGroups;

  /// Generic placeholder page subtitle
  ///
  /// In pt, this message translates to:
  /// **'Página {title} (em construção)'**
  String placeholderPage(String title);

  /// No description provided for @accountHeader.
  ///
  /// In pt, this message translates to:
  /// **'CONTA'**
  String get accountHeader;

  /// No description provided for @preferencesHeader.
  ///
  /// In pt, this message translates to:
  /// **'PREFERÊNCIAS'**
  String get preferencesHeader;

  /// No description provided for @promoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Economize até 60% com Strava + Runna'**
  String get promoTitle;

  /// No description provided for @promoSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo o que você precisa para alcançar suas metas de corrida, agora com até 60% de desconto.'**
  String get promoSubtitle;

  /// No description provided for @yourSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Sua assinatura'**
  String get yourSubscription;

  /// No description provided for @managePlan.
  ///
  /// In pt, this message translates to:
  /// **'Explore e gerencie sua assinatura'**
  String get managePlan;

  /// No description provided for @giftSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Presenteie com uma assinatura'**
  String get giftSubscription;

  /// No description provided for @connectDevice.
  ///
  /// In pt, this message translates to:
  /// **'Conectar um aplicativo ou dispositivo'**
  String get connectDevice;

  /// No description provided for @connectDeviceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Envie diretamente com quase qualquer aplicativo ou dispositivo de fitness'**
  String get connectDeviceSubtitle;

  /// No description provided for @manageDevices.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar aplicativos e dispositivos'**
  String get manageDevices;

  /// No description provided for @restorePurchases.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compras'**
  String get restorePurchases;

  /// No description provided for @changeEmail.
  ///
  /// In pt, this message translates to:
  /// **'Alterar e-mail'**
  String get changeEmail;

  /// No description provided for @help.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get help;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @privacyControls.
  ///
  /// In pt, this message translates to:
  /// **'Controles de privacidade'**
  String get privacyControls;

  /// No description provided for @units.
  ///
  /// In pt, this message translates to:
  /// **'Unidades de medição'**
  String get units;

  /// No description provided for @unitsKilometers.
  ///
  /// In pt, this message translates to:
  /// **'Quilômetros'**
  String get unitsKilometers;

  /// No description provided for @temperature.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura'**
  String get temperature;

  /// No description provided for @temperatureCelsius.
  ///
  /// In pt, this message translates to:
  /// **'Celsius'**
  String get temperatureCelsius;

  /// No description provided for @defaultHighlightMedia.
  ///
  /// In pt, this message translates to:
  /// **'Imagem padrão de destaque'**
  String get defaultHighlightMedia;

  /// No description provided for @defaultHighlightMediaSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Destaque o mapa ou uma foto para representar suas atividades no feed.'**
  String get defaultHighlightMediaSubtitle;

  /// No description provided for @autoplayVideo.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir vídeo automaticamente'**
  String get autoplayVideo;

  /// No description provided for @defaultMaps.
  ///
  /// In pt, this message translates to:
  /// **'Mapas padrão'**
  String get defaultMaps;

  /// No description provided for @feedOrder.
  ///
  /// In pt, this message translates to:
  /// **'Ordem do feed'**
  String get feedOrder;

  /// No description provided for @feedOrderSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Altere como as atividades são ordenadas em seu feed'**
  String get feedOrderSubtitle;

  /// No description provided for @trainingZones.
  ///
  /// In pt, this message translates to:
  /// **'Zonas de treinamento'**
  String get trainingZones;

  /// No description provided for @trainingZonesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Personalize suas zonas de treinamento'**
  String get trainingZonesSubtitle;

  /// No description provided for @siriShortcuts.
  ///
  /// In pt, this message translates to:
  /// **'Siri e atalhos'**
  String get siriShortcuts;

  /// No description provided for @beacon.
  ///
  /// In pt, this message translates to:
  /// **'Beacon'**
  String get beacon;

  /// No description provided for @partnerIntegrations.
  ///
  /// In pt, this message translates to:
  /// **'Integrações de parceiros'**
  String get partnerIntegrations;

  /// No description provided for @weather.
  ///
  /// In pt, this message translates to:
  /// **'Clima'**
  String get weather;

  /// No description provided for @healthData.
  ///
  /// In pt, this message translates to:
  /// **'Dados de saúde'**
  String get healthData;

  /// No description provided for @contacts.
  ///
  /// In pt, this message translates to:
  /// **'Contatos'**
  String get contacts;

  /// No description provided for @pushNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações por push'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações por e-mail'**
  String get emailNotifications;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @signOutError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao sair. Tente novamente.'**
  String get signOutError;

  /// Settings subpage landing app bar title
  ///
  /// In pt, this message translates to:
  /// **'{title}'**
  String settingsLanding(String title);

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signIn;

  /// No description provided for @emailPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe e-mail e senha.'**
  String get emailPasswordRequired;

  /// Generic unexpected error message
  ///
  /// In pt, this message translates to:
  /// **'Erro inesperado: {error}'**
  String unexpectedError(String error);

  /// No description provided for @newBadge.
  ///
  /// In pt, this message translates to:
  /// **'NOVIDADE'**
  String get newBadge;

  /// No description provided for @youTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get youTitle;

  /// No description provided for @progressTab.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get progressTab;

  /// No description provided for @activitiesTab.
  ///
  /// In pt, this message translates to:
  /// **'Atividades'**
  String get activitiesTab;

  /// No description provided for @trainingSelection.
  ///
  /// In pt, this message translates to:
  /// **'Seleção de treinos'**
  String get trainingSelection;

  /// No description provided for @seeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get seeAll;

  /// No description provided for @run.
  ///
  /// In pt, this message translates to:
  /// **'Corrida'**
  String get run;

  /// No description provided for @walk.
  ///
  /// In pt, this message translates to:
  /// **'Caminhada'**
  String get walk;

  /// No description provided for @thisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @distance.
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In pt, this message translates to:
  /// **'Tempo'**
  String get time;

  /// No description provided for @elevationGain.
  ///
  /// In pt, this message translates to:
  /// **'Ganho de elev.'**
  String get elevationGain;

  /// No description provided for @last12Weeks.
  ///
  /// In pt, this message translates to:
  /// **'Últimas 12 semanas'**
  String get last12Weeks;

  /// No description provided for @share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// No description provided for @dailyCheckIn.
  ///
  /// In pt, this message translates to:
  /// **'Check-in diário'**
  String get dailyCheckIn;

  /// No description provided for @checkInToday.
  ///
  /// In pt, this message translates to:
  /// **'Fazer check-in de hoje'**
  String get checkInToday;

  /// No description provided for @checkedInToday.
  ///
  /// In pt, this message translates to:
  /// **'Check-in de hoje feito ✅'**
  String get checkedInToday;

  /// No description provided for @bmi.
  ///
  /// In pt, this message translates to:
  /// **'IMC'**
  String get bmi;

  /// No description provided for @weightKg.
  ///
  /// In pt, this message translates to:
  /// **'Peso (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In pt, this message translates to:
  /// **'Altura (cm)'**
  String get heightCm;

  /// No description provided for @saved.
  ///
  /// In pt, this message translates to:
  /// **'Salvo ✅'**
  String get saved;

  /// No description provided for @fillWeightHeight.
  ///
  /// In pt, this message translates to:
  /// **'Preencha peso e altura'**
  String get fillWeightHeight;

  /// No description provided for @xp.
  ///
  /// In pt, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @xpTodayEarned.
  ///
  /// In pt, this message translates to:
  /// **'XP hoje'**
  String get xpTodayEarned;

  /// No description provided for @xpTotal.
  ///
  /// In pt, this message translates to:
  /// **'XP total'**
  String get xpTotal;

  /// No description provided for @todoCreateFlow.
  ///
  /// In pt, this message translates to:
  /// **'Em breve: fluxo de criação'**
  String get todoCreateFlow;

  /// No description provided for @easyRunTitle.
  ///
  /// In pt, this message translates to:
  /// **'Corrida leve'**
  String get easyRunTitle;

  /// No description provided for @easyRunSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Mantenha a consistência com uma corrida leve e confortável.'**
  String get easyRunSubtitle;

  /// No description provided for @activitiesListTodo.
  ///
  /// In pt, this message translates to:
  /// **'Em breve: lista de atividades'**
  String get activitiesListTodo;

  /// No description provided for @recordStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar'**
  String get recordStart;

  /// No description provided for @recordPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get recordPause;

  /// No description provided for @recordResume.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get recordResume;

  /// No description provided for @recordFinish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get recordFinish;

  /// No description provided for @recordDiscard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get recordDiscard;

  /// No description provided for @recordSaving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando treino...'**
  String get recordSaving;

  /// No description provided for @recordSaved.
  ///
  /// In pt, this message translates to:
  /// **'Treino salvo ✅'**
  String get recordSaved;

  /// No description provided for @recordSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar o treino. Tente novamente.'**
  String get recordSaveError;

  /// No description provided for @recordAlreadyRunning.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um treino em andamento.'**
  String get recordAlreadyRunning;

  /// No description provided for @recordNoSession.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum treino em andamento.'**
  String get recordNoSession;

  /// No description provided for @recordConfirmDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar treino?'**
  String get recordConfirmDiscardTitle;

  /// No description provided for @recordConfirmDiscardBody.
  ///
  /// In pt, this message translates to:
  /// **'Isso vai apagar este treino em andamento.'**
  String get recordConfirmDiscardBody;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
