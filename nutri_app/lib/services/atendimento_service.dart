import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtendimentoService {
//Dados de identificação
  static const String _prefsKeyIdentificacao =
      'hospital_atendimento_identificacao';

  Future<void> salvarDadosIdentificacao({
    required String name,
    required String gender,
    required String birthDate,
    required String hospital,
    required String clinic,
    required String room,
    required String bed,
    required String record,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKeyIdentificacao.name', name);
    await prefs.setString('$_prefsKeyIdentificacao.gender', gender);
    await prefs.setString('$_prefsKeyIdentificacao.birthDate', birthDate);
    await prefs.setString('$_prefsKeyIdentificacao.hospital', hospital);
    await prefs.setString('$_prefsKeyIdentificacao.clinic', clinic);
    await prefs.setString('$_prefsKeyIdentificacao.room', room);
    await prefs.setString('$_prefsKeyIdentificacao.bed', bed);
    await prefs.setString('$_prefsKeyIdentificacao.record', record);
  }

  Future<Map<String, String>> carregarDadosIdentificacao() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('$_prefsKeyIdentificacao.name') ?? '',
      'gender':
          prefs.getString('$_prefsKeyIdentificacao.gender') ?? 'Selecione',
      'birthDate': prefs.getString('$_prefsKeyIdentificacao.birthDate') ?? '',
      'hospital': prefs.getString('$_prefsKeyIdentificacao.hospital') ?? '',
      'clinic': prefs.getString('$_prefsKeyIdentificacao.clinic') ?? '',
      'room': prefs.getString('$_prefsKeyIdentificacao.room') ?? '',
      'bed': prefs.getString('$_prefsKeyIdentificacao.bed') ?? '',
      'record': prefs.getString('$_prefsKeyIdentificacao.record') ?? '',
    };
  }

  Future<void> limparDadosIdentificacao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsKeyIdentificacao.name');
    await prefs.remove('$_prefsKeyIdentificacao.gender');
    await prefs.remove('$_prefsKeyIdentificacao.birthDate');
    await prefs.remove('$_prefsKeyIdentificacao.hospital');
    await prefs.remove('$_prefsKeyIdentificacao.clinic');
    await prefs.remove('$_prefsKeyIdentificacao.room');
    await prefs.remove('$_prefsKeyIdentificacao.bed');
    await prefs.remove('$_prefsKeyIdentificacao.record');
  }

  // Dados socioeconômicos
  static const String _prefsKeySocioeconomico =
      'hospital_atendimento_socioeconomico';

  Future<void> salvarDadosSocioeconomicos({
    required bool aguaEncanada,
    required bool esgotoEncanado,
    required bool coletaLixo,
    required bool luzEletrica,
    required String tipoCasa,
    required String numPessoas,
    required String rendaFamiliar,
    required String rendaPerCapita,
    required String escolaridade,
    required String profissao,
    required String producaoAlimentos,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('$_prefsKeySocioeconomico.aguaEncanada', aguaEncanada);
    await prefs.setBool(
        '$_prefsKeySocioeconomico.esgotoEncanado', esgotoEncanado);
    await prefs.setBool('$_prefsKeySocioeconomico.coletaLixo', coletaLixo);
    await prefs.setBool('$_prefsKeySocioeconomico.luzEletrica', luzEletrica);
    await prefs.setString('$_prefsKeySocioeconomico.tipoCasa', tipoCasa);
    await prefs.setString('$_prefsKeySocioeconomico.numPessoas', numPessoas);
    await prefs.setString(
        '$_prefsKeySocioeconomico.rendaFamiliar', rendaFamiliar);
    await prefs.setString(
        '$_prefsKeySocioeconomico.rendaPerCapita', rendaPerCapita);
    await prefs.setString(
        '$_prefsKeySocioeconomico.escolaridade', escolaridade);
    await prefs.setString('$_prefsKeySocioeconomico.profissao', profissao);
    await prefs.setString(
        '$_prefsKeySocioeconomico.producaoAlimentos', producaoAlimentos);
  }

  Future<Map<String, dynamic>> carregarDadosSocioeconomicos() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'aguaEncanada':
          prefs.getBool('$_prefsKeySocioeconomico.aguaEncanada') ?? false,
      'esgotoEncanado':
          prefs.getBool('$_prefsKeySocioeconomico.esgotoEncanado') ?? false,
      'coletaLixo':
          prefs.getBool('$_prefsKeySocioeconomico.coletaLixo') ?? false,
      'luzEletrica':
          prefs.getBool('$_prefsKeySocioeconomico.luzEletrica') ?? false,
      'tipoCasa':
          prefs.getString('$_prefsKeySocioeconomico.tipoCasa') ?? 'Selecione',
      'numPessoas':
          prefs.getString('$_prefsKeySocioeconomico.numPessoas') ?? '',
      'rendaFamiliar':
          prefs.getString('$_prefsKeySocioeconomico.rendaFamiliar') ?? '',
      'rendaPerCapita':
          prefs.getString('$_prefsKeySocioeconomico.rendaPerCapita') ?? '',
      'escolaridade':
          prefs.getString('$_prefsKeySocioeconomico.escolaridade') ?? '',
      'profissao': prefs.getString('$_prefsKeySocioeconomico.profissao') ?? '',
      'producaoAlimentos':
          prefs.getString('$_prefsKeySocioeconomico.producaoAlimentos') ?? '',
    };
  }

  Future<void> limparDadosSocioeconomicos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeySocioeconomico.aguaEncanada');
    await prefs.remove('$_prefsKeySocioeconomico.esgotoEncanado');
    await prefs.remove('$_prefsKeySocioeconomico.coletaLixo');
    await prefs.remove('$_prefsKeySocioeconomico.luzEletrica');
    await prefs.remove('$_prefsKeySocioeconomico.tipoCasa');
    await prefs.remove('$_prefsKeySocioeconomico.numPessoas');
    await prefs.remove('$_prefsKeySocioeconomico.rendaFamiliar');
    await prefs.remove('$_prefsKeySocioeconomico.rendaPerCapita');
    await prefs.remove('$_prefsKeySocioeconomico.escolaridade');
    await prefs.remove('$_prefsKeySocioeconomico.profissao');
    await prefs.remove('$_prefsKeySocioeconomico.producaoAlimentos');
  }

// Antecedentes pessoais
  static const String _prefsKeyAntecedentesPessoais =
      'hospital_atendimento_antecedentes_pessoais';

  Future<void> salvarAntecedentesPessoais({
    required bool dislipidemias,
    required bool has,
    required bool cancer,
    required bool excessoPeso,
    required bool diabetes,
    required bool outros,
    required String outrosDescricao,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
        '$_prefsKeyAntecedentesPessoais.dislipidemias', dislipidemias);
    await prefs.setBool('$_prefsKeyAntecedentesPessoais.has', has);
    await prefs.setBool('$_prefsKeyAntecedentesPessoais.cancer', cancer);
    await prefs.setBool(
        '$_prefsKeyAntecedentesPessoais.excessoPeso', excessoPeso);
    await prefs.setBool('$_prefsKeyAntecedentesPessoais.diabetes', diabetes);
    await prefs.setBool('$_prefsKeyAntecedentesPessoais.outros', outros);
    await prefs.setString(
        '$_prefsKeyAntecedentesPessoais.outrosDescricao', outrosDescricao);
  }

  Future<Map<String, dynamic>> carregarAntecedentesPessoais() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'dislipidemias':
          prefs.getBool('$_prefsKeyAntecedentesPessoais.dislipidemias') ??
              false,
      'has': prefs.getBool('$_prefsKeyAntecedentesPessoais.has') ?? false,
      'cancer': prefs.getBool('$_prefsKeyAntecedentesPessoais.cancer') ?? false,
      'excessoPeso':
          prefs.getBool('$_prefsKeyAntecedentesPessoais.excessoPeso') ?? false,
      'diabetes':
          prefs.getBool('$_prefsKeyAntecedentesPessoais.diabetes') ?? false,
      'outros': prefs.getBool('$_prefsKeyAntecedentesPessoais.outros') ?? false,
      'outrosDescricao':
          prefs.getString('$_prefsKeyAntecedentesPessoais.outrosDescricao') ??
              '',
    };
  }

  Future<void> limparAntecedentesPessoais() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyAntecedentesPessoais.dislipidemias');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.has');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.cancer');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.excessoPeso');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.diabetes');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.outros');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.outrosDescricao');
  }

// Antecedentes familiares
  static const String _prefsKeyAntecedentesFamiliares =
      'hospital_atendimento_antecedentes_familiares';

  Future<void> salvarAntecedentesFamiliares({
    required bool dislipidemias,
    required bool has,
    required bool cancer,
    required bool excessoPeso,
    required bool diabetes,
    required bool outros,
    required String outrosDescricao,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
        '$_prefsKeyAntecedentesFamiliares.dislipidemias', dislipidemias);
    await prefs.setBool('$_prefsKeyAntecedentesFamiliares.has', has);
    await prefs.setBool('$_prefsKeyAntecedentesFamiliares.cancer', cancer);
    await prefs.setBool(
        '$_prefsKeyAntecedentesFamiliares.excessoPeso', excessoPeso);
    await prefs.setBool('$_prefsKeyAntecedentesFamiliares.diabetes', diabetes);
    await prefs.setBool('$_prefsKeyAntecedentesFamiliares.outros', outros);
    await prefs.setString(
        '$_prefsKeyAntecedentesFamiliares.outrosDescricao', outrosDescricao);
  }

  Future<Map<String, dynamic>> carregarAntecedentesFamiliares() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'dislipidemias':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.dislipidemias') ??
              false,
      'has': prefs.getBool('$_prefsKeyAntecedentesFamiliares.has') ?? false,
      'cancer':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.cancer') ?? false,
      'excessoPeso':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.excessoPeso') ??
              false,
      'diabetes':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.diabetes') ?? false,
      'outros':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.outros') ?? false,
      'outrosDescricao':
          prefs.getString('$_prefsKeyAntecedentesFamiliares.outrosDescricao') ??
              '',
    };
  }

  Future<void> limparAntecedentesFamiliares() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyAntecedentesFamiliares.dislipidemias');
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.has');
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.cancer');
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.excessoPeso');
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.diabetes');
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.outros');
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.outrosDescricao');
  }

// Dados clínicos e nutricionais
  static const String _prefsKeyDadosClinicos =
      'hospital_atendimento_dados_clinicos';

  Future<void> salvarDadosClinicosNutricionais({
    required String diagnostico,
    required String prescricao,
    required String aceitacao,
    required String alimentacaoHabitual,
    required String especificarAlimentacao,
    required bool doencaAnterior,
    required String doencaAnteriorDesc,
    required bool cirurgiaRecente,
    required String cirurgiaDesc,
    required bool febre,
    required bool alteracaoPeso,
    required String quantoPeso,
    required bool desconfortos,
    required bool necessidadeDieta,
    required String qualDieta,
    required bool suplementacao,
    required String tipoSuplementacao,
    required bool tabagismo,
    required bool etilismo,
    required String condicaoFuncional,
    required String especificarCondicao,
    required String medicamentos,
    required String examesLaboratoriais,
    required String exameFisico,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Dados básicos
    await prefs.setString('$_prefsKeyDadosClinicos.diagnostico', diagnostico);
    await prefs.setString('$_prefsKeyDadosClinicos.prescricao', prescricao);
    await prefs.setString('$_prefsKeyDadosClinicos.aceitacao', aceitacao);

    // Alimentação
    await prefs.setString(
        '$_prefsKeyDadosClinicos.alimentacaoHabitual', alimentacaoHabitual);
    await prefs.setString('$_prefsKeyDadosClinicos.especificarAlimentacao',
        especificarAlimentacao);

    // Histórico médico
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.doencaAnterior', doencaAnterior);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.doencaAnteriorDesc', doencaAnteriorDesc);
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.cirurgiaRecente', cirurgiaRecente);
    await prefs.setString('$_prefsKeyDadosClinicos.cirurgiaDesc', cirurgiaDesc);
    await prefs.setBool('$_prefsKeyDadosClinicos.febre', febre);

    // Peso
    await prefs.setBool('$_prefsKeyDadosClinicos.alteracaoPeso', alteracaoPeso);
    await prefs.setString('$_prefsKeyDadosClinicos.quantoPeso', quantoPeso);

    // Nutrição
    await prefs.setBool('$_prefsKeyDadosClinicos.desconfortos', desconfortos);
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.necessidadeDieta', necessidadeDieta);
    await prefs.setString('$_prefsKeyDadosClinicos.qualDieta', qualDieta);
    await prefs.setBool('$_prefsKeyDadosClinicos.suplementacao', suplementacao);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.tipoSuplementacao', tipoSuplementacao);

    // Hábitos
    await prefs.setBool('$_prefsKeyDadosClinicos.tabagismo', tabagismo);
    await prefs.setBool('$_prefsKeyDadosClinicos.etilismo', etilismo);

    // Condição funcional
    await prefs.setString(
        '$_prefsKeyDadosClinicos.condicaoFuncional', condicaoFuncional);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.especificarCondicao', especificarCondicao);

    // Exames e medicamentos
    await prefs.setString('$_prefsKeyDadosClinicos.medicamentos', medicamentos);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.examesLaboratoriais', examesLaboratoriais);
    await prefs.setString('$_prefsKeyDadosClinicos.exameFisico', exameFisico);
  }

  Future<Map<String, dynamic>> carregarDadosClinicosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      // Dados básicos
      'diagnostico':
          prefs.getString('$_prefsKeyDadosClinicos.diagnostico') ?? '',
      'prescricao': prefs.getString('$_prefsKeyDadosClinicos.prescricao') ?? '',
      'aceitacao': prefs.getString('$_prefsKeyDadosClinicos.aceitacao') ?? '',

      // Alimentação
      'alimentacaoHabitual':
          prefs.getString('$_prefsKeyDadosClinicos.alimentacaoHabitual') ??
              'Selecione',
      'especificarAlimentacao':
          prefs.getString('$_prefsKeyDadosClinicos.especificarAlimentacao') ??
              '',

      // Histórico médico
      'doencaAnterior':
          prefs.getBool('$_prefsKeyDadosClinicos.doencaAnterior') ?? false,
      'doencaAnteriorDesc':
          prefs.getString('$_prefsKeyDadosClinicos.doencaAnteriorDesc') ?? '',
      'cirurgiaRecente':
          prefs.getBool('$_prefsKeyDadosClinicos.cirurgiaRecente') ?? false,
      'cirurgiaDesc':
          prefs.getString('$_prefsKeyDadosClinicos.cirurgiaDesc') ?? '',
      'febre': prefs.getBool('$_prefsKeyDadosClinicos.febre') ?? false,

      // Peso
      'alteracaoPeso':
          prefs.getBool('$_prefsKeyDadosClinicos.alteracaoPeso') ?? false,
      'quantoPeso': prefs.getString('$_prefsKeyDadosClinicos.quantoPeso') ?? '',

      // Nutrição
      'desconfortos':
          prefs.getBool('$_prefsKeyDadosClinicos.desconfortos') ?? false,
      'necessidadeDieta':
          prefs.getBool('$_prefsKeyDadosClinicos.necessidadeDieta') ?? false,
      'qualDieta': prefs.getString('$_prefsKeyDadosClinicos.qualDieta') ?? '',
      'suplementacao':
          prefs.getBool('$_prefsKeyDadosClinicos.suplementacao') ?? false,
      'tipoSuplementacao':
          prefs.getString('$_prefsKeyDadosClinicos.tipoSuplementacao') ?? '',

      // Hábitos
      'tabagismo': prefs.getBool('$_prefsKeyDadosClinicos.tabagismo') ?? false,
      'etilismo': prefs.getBool('$_prefsKeyDadosClinicos.etilismo') ?? false,

      // Condição funcional
      'condicaoFuncional':
          prefs.getString('$_prefsKeyDadosClinicos.condicaoFuncional') ??
              'Selecione',
      'especificarCondicao':
          prefs.getString('$_prefsKeyDadosClinicos.especificarCondicao') ?? '',

      // Exames e medicamentos
      'medicamentos':
          prefs.getString('$_prefsKeyDadosClinicos.medicamentos') ?? '',
      'examesLaboratoriais':
          prefs.getString('$_prefsKeyDadosClinicos.examesLaboratoriais') ?? '',
      'exameFisico':
          prefs.getString('$_prefsKeyDadosClinicos.exameFisico') ?? '',
    };
  }

  Future<void> limparDadosClinicosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyDadosClinicos.diagnostico');
    await prefs.remove('$_prefsKeyDadosClinicos.prescricao');
    await prefs.remove('$_prefsKeyDadosClinicos.aceitacao');
    await prefs.remove('$_prefsKeyDadosClinicos.alimentacaoHabitual');
    await prefs.remove('$_prefsKeyDadosClinicos.especificarAlimentacao');
    await prefs.remove('$_prefsKeyDadosClinicos.doencaAnterior');
    await prefs.remove('$_prefsKeyDadosClinicos.doencaAnteriorDesc');
    await prefs.remove('$_prefsKeyDadosClinicos.cirurgiaRecente');
    await prefs.remove('$_prefsKeyDadosClinicos.cirurgiaDesc');
    await prefs.remove('$_prefsKeyDadosClinicos.febre');
    await prefs.remove('$_prefsKeyDadosClinicos.alteracaoPeso');
    await prefs.remove('$_prefsKeyDadosClinicos.quantoPeso');
    await prefs.remove('$_prefsKeyDadosClinicos.desconfortos');
    await prefs.remove('$_prefsKeyDadosClinicos.necessidadeDieta');
    await prefs.remove('$_prefsKeyDadosClinicos.qualDieta');
    await prefs.remove('$_prefsKeyDadosClinicos.suplementacao');
    await prefs.remove('$_prefsKeyDadosClinicos.tipoSuplementacao');
    await prefs.remove('$_prefsKeyDadosClinicos.tabagismo');
    await prefs.remove('$_prefsKeyDadosClinicos.etilismo');
    await prefs.remove('$_prefsKeyDadosClinicos.condicaoFuncional');
    await prefs.remove('$_prefsKeyDadosClinicos.especificarCondicao');
    await prefs.remove('$_prefsKeyDadosClinicos.medicamentos');
    await prefs.remove('$_prefsKeyDadosClinicos.examesLaboratoriais');
    await prefs.remove('$_prefsKeyDadosClinicos.exameFisico');
  }

// Dados antropométricos
  static const String _prefsKeyAntropometricos =
      'hospital_atendimento_antropometricos';

  Future<void> salvarDadosAntropometricos({
    required String pesoAtual,
    required String pesoUsual,
    required String estatura,
    required String imc,
    required String pi,
    required String cb,
    required String pct,
    required String pcb,
    required String pcse,
    required String pcsi,
    required String cmb,
    required String ca,
    required String cp,
    required String aj,
    required String percentualGordura,
    required String perdaPeso,
    required String diagnosticoNutricional,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('$_prefsKeyAntropometricos.pesoAtual', pesoAtual);
    await prefs.setString('$_prefsKeyAntropometricos.pesoUsual', pesoUsual);
    await prefs.setString('$_prefsKeyAntropometricos.estatura', estatura);
    await prefs.setString('$_prefsKeyAntropometricos.imc', imc);
    await prefs.setString('$_prefsKeyAntropometricos.pi', pi);
    await prefs.setString('$_prefsKeyAntropometricos.cb', cb);
    await prefs.setString('$_prefsKeyAntropometricos.pct', pct);
    await prefs.setString('$_prefsKeyAntropometricos.pcb', pcb);
    await prefs.setString('$_prefsKeyAntropometricos.pcse', pcse);
    await prefs.setString('$_prefsKeyAntropometricos.pcsi', pcsi);
    await prefs.setString('$_prefsKeyAntropometricos.cmb', cmb);
    await prefs.setString('$_prefsKeyAntropometricos.ca', ca);
    await prefs.setString('$_prefsKeyAntropometricos.cp', cp);
    await prefs.setString('$_prefsKeyAntropometricos.aj', aj);
    await prefs.setString(
        '$_prefsKeyAntropometricos.percentualGordura', percentualGordura);
    await prefs.setString('$_prefsKeyAntropometricos.perdaPeso', perdaPeso);
    await prefs.setString('$_prefsKeyAntropometricos.diagnosticoNutricional',
        diagnosticoNutricional);
  }

  Future<Map<String, String>> carregarDadosAntropometricos() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'pesoAtual': prefs.getString('$_prefsKeyAntropometricos.pesoAtual') ?? '',
      'pesoUsual': prefs.getString('$_prefsKeyAntropometricos.pesoUsual') ?? '',
      'estatura': prefs.getString('$_prefsKeyAntropometricos.estatura') ?? '',
      'imc': prefs.getString('$_prefsKeyAntropometricos.imc') ?? '',
      'pi': prefs.getString('$_prefsKeyAntropometricos.pi') ?? '',
      'cb': prefs.getString('$_prefsKeyAntropometricos.cb') ?? '',
      'pct': prefs.getString('$_prefsKeyAntropometricos.pct') ?? '',
      'pcb': prefs.getString('$_prefsKeyAntropometricos.pcb') ?? '',
      'pcse': prefs.getString('$_prefsKeyAntropometricos.pcse') ?? '',
      'pcsi': prefs.getString('$_prefsKeyAntropometricos.pcsi') ?? '',
      'cmb': prefs.getString('$_prefsKeyAntropometricos.cmb') ?? '',
      'ca': prefs.getString('$_prefsKeyAntropometricos.ca') ?? '',
      'cp': prefs.getString('$_prefsKeyAntropometricos.cp') ?? '',
      'aj': prefs.getString('$_prefsKeyAntropometricos.aj') ?? '',
      'percentualGordura':
          prefs.getString('$_prefsKeyAntropometricos.percentualGordura') ?? '',
      'perdaPeso': prefs.getString('$_prefsKeyAntropometricos.perdaPeso') ?? '',
      'diagnosticoNutricional':
          prefs.getString('$_prefsKeyAntropometricos.diagnosticoNutricional') ??
              '',
    };
  }

  Future<void> limparDadosAntropometricos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyAntropometricos.pesoAtual');
    await prefs.remove('$_prefsKeyAntropometricos.pesoUsual');
    await prefs.remove('$_prefsKeyAntropometricos.estatura');
    await prefs.remove('$_prefsKeyAntropometricos.imc');
    await prefs.remove('$_prefsKeyAntropometricos.pi');
    await prefs.remove('$_prefsKeyAntropometricos.cb');
    await prefs.remove('$_prefsKeyAntropometricos.pct');
    await prefs.remove('$_prefsKeyAntropometricos.pcb');
    await prefs.remove('$_prefsKeyAntropometricos.pcse');
    await prefs.remove('$_prefsKeyAntropometricos.pcsi');
    await prefs.remove('$_prefsKeyAntropometricos.cmb');
    await prefs.remove('$_prefsKeyAntropometricos.ca');
    await prefs.remove('$_prefsKeyAntropometricos.cp');
    await prefs.remove('$_prefsKeyAntropometricos.aj');
    await prefs.remove('$_prefsKeyAntropometricos.percentualGordura');
    await prefs.remove('$_prefsKeyAntropometricos.perdaPeso');
    await prefs.remove('$_prefsKeyAntropometricos.diagnosticoNutricional');
  }

// Dados de consumo alimentar
  static const String _prefsKeyConsumoAlimentar =
      'hospital_atendimento_consumo_alimentar';

  Future<void> salvarConsumoAlimentar({
    required String habitual,
    required String atual,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('$_prefsKeyConsumoAlimentar.habitual', habitual);
    await prefs.setString('$_prefsKeyConsumoAlimentar.atual', atual);
  }

  Future<Map<String, String>> carregarConsumoAlimentar() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'habitual': prefs.getString('$_prefsKeyConsumoAlimentar.habitual') ?? '',
      'atual': prefs.getString('$_prefsKeyConsumoAlimentar.atual') ?? '',
    };
  }

  Future<void> limparConsumoAlimentar() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyConsumoAlimentar.habitual');
    await prefs.remove('$_prefsKeyConsumoAlimentar.atual');
  }

// Dados de requerimentos nutricionais
  static const String _prefsKeyRequerimentos =
      'hospital_atendimento_requerimentos';

  Future<void> salvarRequerimentosNutricionais({
    required String kcalDia,
    required String kcalKg,
    required String cho,
    required String lip,
    required String ptnPorcentagem,
    required String ptnKg,
    required String ptnDia,
    required String liquidoKg,
    required String liquidoDia,
    required String fibras,
    required String outros,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('$_prefsKeyRequerimentos.kcalDia', kcalDia);
    await prefs.setString('$_prefsKeyRequerimentos.kcalKg', kcalKg);
    await prefs.setString('$_prefsKeyRequerimentos.cho', cho);
    await prefs.setString('$_prefsKeyRequerimentos.lip', lip);
    await prefs.setString(
        '$_prefsKeyRequerimentos.ptnPorcentagem', ptnPorcentagem);
    await prefs.setString('$_prefsKeyRequerimentos.ptnKg', ptnKg);
    await prefs.setString('$_prefsKeyRequerimentos.ptnDia', ptnDia);
    await prefs.setString('$_prefsKeyRequerimentos.liquidoKg', liquidoKg);
    await prefs.setString('$_prefsKeyRequerimentos.liquidoDia', liquidoDia);
    await prefs.setString('$_prefsKeyRequerimentos.fibras', fibras);
    await prefs.setString('$_prefsKeyRequerimentos.outros', outros);
  }

  Future<Map<String, String>> carregarRequerimentosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'kcalDia': prefs.getString('$_prefsKeyRequerimentos.kcalDia') ?? '',
      'kcalKg': prefs.getString('$_prefsKeyRequerimentos.kcalKg') ?? '',
      'cho': prefs.getString('$_prefsKeyRequerimentos.cho') ?? '',
      'lip': prefs.getString('$_prefsKeyRequerimentos.lip') ?? '',
      'ptnPorcentagem':
          prefs.getString('$_prefsKeyRequerimentos.ptnPorcentagem') ?? '',
      'ptnKg': prefs.getString('$_prefsKeyRequerimentos.ptnKg') ?? '',
      'ptnDia': prefs.getString('$_prefsKeyRequerimentos.ptnDia') ?? '',
      'liquidoKg': prefs.getString('$_prefsKeyRequerimentos.liquidoKg') ?? '',
      'liquidoDia': prefs.getString('$_prefsKeyRequerimentos.liquidoDia') ?? '',
      'fibras': prefs.getString('$_prefsKeyRequerimentos.fibras') ?? '',
      'outros': prefs.getString('$_prefsKeyRequerimentos.outros') ?? '',
    };
  }

  Future<void> limparRequerimentosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyRequerimentos.kcalDia');
    await prefs.remove('$_prefsKeyRequerimentos.kcalKg');
    await prefs.remove('$_prefsKeyRequerimentos.cho');
    await prefs.remove('$_prefsKeyRequerimentos.lip');
    await prefs.remove('$_prefsKeyRequerimentos.ptnPorcentagem');
    await prefs.remove('$_prefsKeyRequerimentos.ptnKg');
    await prefs.remove('$_prefsKeyRequerimentos.ptnDia');
    await prefs.remove('$_prefsKeyRequerimentos.liquidoKg');
    await prefs.remove('$_prefsKeyRequerimentos.liquidoDia');
    await prefs.remove('$_prefsKeyRequerimentos.fibras');
    await prefs.remove('$_prefsKeyRequerimentos.outros');
  }

// Dados de conduta nutricional e finalização
  static const String _prefsKeyConduta = 'hospital_atendimento_conduta';

  Future<void> salvarCondutaNutricional({
    required String estagiario,
    required String professor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKeyConduta.estagiario', estagiario);
    await prefs.setString('$_prefsKeyConduta.professor', professor);
  }

  Future<Map<String, String>> carregarCondutaNutricional() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'estagiario': prefs.getString('$_prefsKeyConduta.estagiario') ?? '',
      'professor':
          prefs.getString('$_prefsKeyConduta.professor') ?? 'Selecione',
    };
  }

  Future<void> limparTodosDadosAtendimento() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_prefsKeyConduta);
    await prefs.remove(_prefsKeyConsumoAlimentar);
    await prefs.remove(_prefsKeyAntropometricos);
    await prefs.remove(_prefsKeyDadosClinicos);
    await prefs.remove(_prefsKeyAntecedentesFamiliares);
    await prefs.remove(_prefsKeyAntecedentesPessoais);
    await prefs.remove(_prefsKeySocioeconomico);
    await prefs.remove(_prefsKeyIdentificacao);
  }

  // Chaves para SharedPreferences
  static const String _prefsKeyAtendimento = 'hospital_atendimento';

  Future<void> salvarIdentificacao() async {
    
  }

Future<Map<String, dynamic>> obterDadosCompletos() async {
  return {
    'identificacao': await carregarDadosIdentificacao(),
    'socioeconomicos': await carregarDadosSocioeconomicos(),
    'antecedentesPessoais': await carregarAntecedentesPessoais(),
    'antecedentesFamiliares': await carregarAntecedentesFamiliares(),
    'dadosClinicos': await carregarDadosClinicosNutricionais(),
    'antropometricos': await carregarDadosAntropometricos(),
    'consumoAlimentar': await carregarConsumoAlimentar(),
    'requerimentos': await carregarRequerimentosNutricionais(),
    'conduta': await carregarCondutaNutricional(),
    'data': DateTime.now().toIso8601String(),
  };
}

  Future<void> limparTodosDados() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = await prefs.getKeys();
    final atendimentoKeys =
        keys.where((key) => key.startsWith(_prefsKeyAtendimento));

    for (final key in atendimentoKeys) {
      await prefs.remove(key);
    }
  }

  // Método para salvar no Firebase
  Future<void> salvarAtendimentoNoFirebase(Map<String, dynamic> dados) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await FirebaseFirestore.instance.collection('atendimento').add({
      ...dados,
      'criadoPor': user.uid,
      'criadoEm': FieldValue.serverTimestamp(),
      'status': 'enviado',
    });
  }

  Future<void> salvarProfessorSelecionado(String professor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('professor_selecionado', professor);
  }

  Future<String?> carregarProfessorSelecionado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('professor_selecionado');
  }
}