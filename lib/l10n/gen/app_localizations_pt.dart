// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Movnos';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get logout => 'Sair';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get loading => 'Carregando...';

  @override
  String get bodyMetricsCard => 'Métricas corporais';

  @override
  String get trainingStatsCard => 'Estatísticas de treino';

  @override
  String get appBarYou => 'Você';

  @override
  String signedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get saving => 'Salvando...';

  @override
  String get appBarHome => 'Início';

  @override
  String get appBarMaps => 'Mapas';

  @override
  String get appBarRecord => 'Gravar';

  @override
  String get appBarGroups => 'Grupos';

  @override
  String placeholderPage(String title) {
    return 'Página $title (em construção)';
  }

  @override
  String get accountHeader => 'CONTA';

  @override
  String get preferencesHeader => 'PREFERÊNCIAS';

  @override
  String get promoTitle => 'Economize até 60% com Strava + Runna';

  @override
  String get promoSubtitle =>
      'Tudo o que você precisa para alcançar suas metas de corrida, agora com até 60% de desconto.';

  @override
  String get yourSubscription => 'Sua assinatura';

  @override
  String get managePlan => 'Explore e gerencie sua assinatura';

  @override
  String get giftSubscription => 'Presenteie com uma assinatura';

  @override
  String get connectDevice => 'Conectar um aplicativo ou dispositivo';

  @override
  String get connectDeviceSubtitle =>
      'Envie diretamente com quase qualquer aplicativo ou dispositivo de fitness';

  @override
  String get manageDevices => 'Gerenciar aplicativos e dispositivos';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get changeEmail => 'Alterar e-mail';

  @override
  String get help => 'Ajuda';

  @override
  String get appearance => 'Aparência';

  @override
  String get privacyControls => 'Controles de privacidade';

  @override
  String get units => 'Unidades de medição';

  @override
  String get unitsKilometers => 'Quilômetros';

  @override
  String get temperature => 'Temperatura';

  @override
  String get temperatureCelsius => 'Celsius';

  @override
  String get defaultHighlightMedia => 'Imagem padrão de destaque';

  @override
  String get defaultHighlightMediaSubtitle =>
      'Destaque o mapa ou uma foto para representar suas atividades no feed.';

  @override
  String get autoplayVideo => 'Reproduzir vídeo automaticamente';

  @override
  String get defaultMaps => 'Mapas padrão';

  @override
  String get feedOrder => 'Ordem do feed';

  @override
  String get feedOrderSubtitle =>
      'Altere como as atividades são ordenadas em seu feed';

  @override
  String get trainingZones => 'Zonas de treinamento';

  @override
  String get trainingZonesSubtitle => 'Personalize suas zonas de treinamento';

  @override
  String get siriShortcuts => 'Siri e atalhos';

  @override
  String get beacon => 'Beacon';

  @override
  String get partnerIntegrations => 'Integrações de parceiros';

  @override
  String get weather => 'Clima';

  @override
  String get healthData => 'Dados de saúde';

  @override
  String get contacts => 'Contatos';

  @override
  String get pushNotifications => 'Notificações por push';

  @override
  String get emailNotifications => 'Notificações por e-mail';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutError => 'Erro ao sair. Tente novamente.';

  @override
  String settingsLanding(String title) {
    return '$title';
  }

  @override
  String get loginTitle => 'Entrar';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get emailPasswordRequired => 'Informe e-mail e senha.';

  @override
  String unexpectedError(String error) {
    return 'Erro inesperado: $error';
  }

  @override
  String get newBadge => 'NOVIDADE';

  @override
  String get youTitle => 'Você';

  @override
  String get progressTab => 'Progresso';

  @override
  String get activitiesTab => 'Atividades';

  @override
  String get trainingSelection => 'Seleção de treinos';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get run => 'Corrida';

  @override
  String get walk => 'Caminhada';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get distance => 'Distância';

  @override
  String get time => 'Tempo';

  @override
  String get elevationGain => 'Ganho de elev.';

  @override
  String get last12Weeks => 'Últimas 12 semanas';

  @override
  String get share => 'Compartilhar';

  @override
  String get dailyCheckIn => 'Check-in diário';

  @override
  String get checkInToday => 'Fazer check-in de hoje';

  @override
  String get checkedInToday => 'Check-in de hoje feito ✅';

  @override
  String get bmi => 'IMC';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get heightCm => 'Altura (cm)';

  @override
  String get saved => 'Salvo ✅';

  @override
  String get fillWeightHeight => 'Preencha peso e altura';

  @override
  String get xp => 'XP';

  @override
  String get xpTodayEarned => 'XP hoje';

  @override
  String get xpTotal => 'XP total';

  @override
  String get todoCreateFlow => 'Em breve: fluxo de criação';

  @override
  String get easyRunTitle => 'Corrida leve';

  @override
  String get easyRunSubtitle =>
      'Mantenha a consistência com uma corrida leve e confortável.';

  @override
  String get activitiesListTodo => 'Em breve: lista de atividades';

  @override
  String get recordStart => 'Iniciar';

  @override
  String get recordPause => 'Pausar';

  @override
  String get recordResume => 'Retomar';

  @override
  String get recordFinish => 'Finalizar';

  @override
  String get recordDiscard => 'Descartar';

  @override
  String get recordSaving => 'Salvando treino...';

  @override
  String get recordSaved => 'Treino salvo ✅';

  @override
  String get recordSaveError => 'Erro ao salvar o treino. Tente novamente.';

  @override
  String get recordAlreadyRunning => 'Já existe um treino em andamento.';

  @override
  String get recordNoSession => 'Nenhum treino em andamento.';

  @override
  String get recordConfirmDiscardTitle => 'Descartar treino?';

  @override
  String get recordConfirmDiscardBody =>
      'Isso vai apagar este treino em andamento.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Movnos';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get logout => 'Sair';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get loading => 'Carregando...';

  @override
  String get bodyMetricsCard => 'Métricas corporais';

  @override
  String get trainingStatsCard => 'Estatísticas de treino';

  @override
  String get appBarYou => 'Você';

  @override
  String signedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get saving => 'Salvando...';

  @override
  String get appBarHome => 'Início';

  @override
  String get appBarMaps => 'Mapas';

  @override
  String get appBarRecord => 'Gravar';

  @override
  String get appBarGroups => 'Grupos';

  @override
  String placeholderPage(String title) {
    return 'Página $title (em construção)';
  }

  @override
  String get accountHeader => 'CONTA';

  @override
  String get preferencesHeader => 'PREFERÊNCIAS';

  @override
  String get promoTitle => 'Economize até 60% com Strava + Runna';

  @override
  String get promoSubtitle =>
      'Tudo o que você precisa para alcançar suas metas de corrida, agora com até 60% de desconto.';

  @override
  String get yourSubscription => 'Sua assinatura';

  @override
  String get managePlan => 'Explore e gerencie sua assinatura';

  @override
  String get giftSubscription => 'Presenteie com uma assinatura';

  @override
  String get connectDevice => 'Conectar um aplicativo ou dispositivo';

  @override
  String get connectDeviceSubtitle =>
      'Envie diretamente com quase qualquer aplicativo ou dispositivo de fitness';

  @override
  String get manageDevices => 'Gerenciar aplicativos e dispositivos';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get changeEmail => 'Alterar e-mail';

  @override
  String get help => 'Ajuda';

  @override
  String get appearance => 'Aparência';

  @override
  String get privacyControls => 'Controles de privacidade';

  @override
  String get units => 'Unidades de medição';

  @override
  String get unitsKilometers => 'Quilômetros';

  @override
  String get temperature => 'Temperatura';

  @override
  String get temperatureCelsius => 'Celsius';

  @override
  String get defaultHighlightMedia => 'Imagem padrão de destaque';

  @override
  String get defaultHighlightMediaSubtitle =>
      'Destaque o mapa ou uma foto para representar suas atividades no feed.';

  @override
  String get autoplayVideo => 'Reproduzir vídeo automaticamente';

  @override
  String get defaultMaps => 'Mapas padrão';

  @override
  String get feedOrder => 'Ordem do feed';

  @override
  String get feedOrderSubtitle =>
      'Altere como as atividades são ordenadas em seu feed';

  @override
  String get trainingZones => 'Zonas de treinamento';

  @override
  String get trainingZonesSubtitle => 'Personalize suas zonas de treinamento';

  @override
  String get siriShortcuts => 'Siri e atalhos';

  @override
  String get beacon => 'Beacon';

  @override
  String get partnerIntegrations => 'Integrações de parceiros';

  @override
  String get weather => 'Clima';

  @override
  String get healthData => 'Dados de saúde';

  @override
  String get contacts => 'Contatos';

  @override
  String get pushNotifications => 'Notificações por push';

  @override
  String get emailNotifications => 'Notificações por e-mail';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutError => 'Erro ao sair. Tente novamente.';

  @override
  String settingsLanding(String title) {
    return '$title';
  }

  @override
  String get loginTitle => 'Entrar';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get emailPasswordRequired => 'Informe e-mail e senha.';

  @override
  String unexpectedError(String error) {
    return 'Erro inesperado: $error';
  }

  @override
  String get newBadge => 'NOVIDADE';

  @override
  String get youTitle => 'Você';

  @override
  String get progressTab => 'Progresso';

  @override
  String get activitiesTab => 'Atividades';

  @override
  String get trainingSelection => 'Seleção de treinos';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get run => 'Corrida';

  @override
  String get walk => 'Caminhada';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get distance => 'Distância';

  @override
  String get time => 'Tempo';

  @override
  String get elevationGain => 'Ganho de elev.';

  @override
  String get last12Weeks => 'Últimas 12 semanas';

  @override
  String get share => 'Compartilhar';

  @override
  String get dailyCheckIn => 'Check-in diário';

  @override
  String get checkInToday => 'Fazer check-in de hoje';

  @override
  String get checkedInToday => 'Check-in de hoje feito ✅';

  @override
  String get bmi => 'IMC';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get heightCm => 'Altura (cm)';

  @override
  String get saved => 'Salvo ✅';

  @override
  String get fillWeightHeight => 'Preencha peso e altura';

  @override
  String get xp => 'XP';

  @override
  String get xpTodayEarned => 'XP hoje';

  @override
  String get xpTotal => 'XP total';

  @override
  String get todoCreateFlow => 'Em breve: fluxo de criação';

  @override
  String get easyRunTitle => 'Corrida leve';

  @override
  String get easyRunSubtitle =>
      'Mantenha a consistência com uma corrida leve e confortável.';

  @override
  String get activitiesListTodo => 'Em breve: lista de atividades';

  @override
  String get recordStart => 'Iniciar';

  @override
  String get recordPause => 'Pausar';

  @override
  String get recordResume => 'Retomar';

  @override
  String get recordFinish => 'Finalizar';

  @override
  String get recordDiscard => 'Descartar';

  @override
  String get recordSaving => 'Salvando treino...';

  @override
  String get recordSaved => 'Treino salvo ✅';

  @override
  String get recordSaveError => 'Erro ao salvar o treino. Tente novamente.';

  @override
  String get recordAlreadyRunning => 'Já existe um treino em andamento.';

  @override
  String get recordNoSession => 'Nenhum treino em andamento.';

  @override
  String get recordConfirmDiscardTitle => 'Descartar treino?';

  @override
  String get recordConfirmDiscardBody =>
      'Isso vai apagar este treino em andamento.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';
}
