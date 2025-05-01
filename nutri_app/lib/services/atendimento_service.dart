import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtendimentoService {
//Dados de identificação
  static const String _prefsKeyIdentificacao =
      'hospital_atendimento_identificacao';

 Future<void> salvarDadosIdentificacao({
  required String nome,
  required String sexo,
  required Timestamp data_nascimento,
  String? hospital,
  String? clinica,
  String? quarto,
  String? leito,
  String? registro,
}) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Dados básicos (comuns a ambos os tipos)
  await prefs.setString('$_prefsKeyIdentificacao.nome', nome);
  await prefs.setString('$_prefsKeyIdentificacao.sexo', sexo);
  await prefs.setString(
    '$_prefsKeyIdentificacao.data_nascimento',
    data_nascimento.toDate().toIso8601String(),
  );

  // Dados específicos do hospital (opcionais)
  if (hospital != null) {
    await prefs.setString('$_prefsKeyIdentificacao.hospital', hospital);
  }
  if (clinica != null) {
    await prefs.setString('$_prefsKeyIdentificacao.clinica', clinica);
  }
  if (quarto != null) {
    await prefs.setString('$_prefsKeyIdentificacao.quarto', quarto);
  }
  if (leito != null) {
    await prefs.setString('$_prefsKeyIdentificacao.leito', leito);
  }
  if (registro != null) {
    await prefs.setString('$_prefsKeyIdentificacao.registro', registro);
  }
}

  Future<Map<String, dynamic>> carregarDadosIdentificacao() async {
    final prefs = await SharedPreferences.getInstance();

    // Carrega a data como string
    final dataString =
        prefs.getString('$_prefsKeyIdentificacao.data_nascimento') ?? '';

    // Converte para Timestamp se a string não estiver vazia
    Timestamp? dataTimestamp;
    if (dataString.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(dataString);
        dataTimestamp = Timestamp.fromDate(dateTime);
      } catch (e) {
        print("Erro ao converter data: $e");
      }
    }

    return {
      'nome': prefs.getString('$_prefsKeyIdentificacao.nome') ?? '',
      'sexo': prefs.getString('$_prefsKeyIdentificacao.sexo') ?? 'Selecione',
      'data_nascimento': dataTimestamp, // Retorna como Timestamp ou null
      'hospital': prefs.getString('$_prefsKeyIdentificacao.hospital') ?? '',
      'clinica': prefs.getString('$_prefsKeyIdentificacao.clinica') ?? '',
      'quarto': prefs.getString('$_prefsKeyIdentificacao.quarto') ?? '',
      'leito': prefs.getString('$_prefsKeyIdentificacao.leito') ?? '',
      'registro': prefs.getString('$_prefsKeyIdentificacao.registro') ?? '',
    };
  }

  Future<void> limparDadosIdentificacao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsKeyIdentificacao.nome');
    await prefs.remove('$_prefsKeyIdentificacao.sexo');
    await prefs.remove('$_prefsKeyIdentificacao.data_nascimento');
    await prefs.remove('$_prefsKeyIdentificacao.hospital');
    await prefs.remove('$_prefsKeyIdentificacao.clinica');
    await prefs.remove('$_prefsKeyIdentificacao.quarto');
    await prefs.remove('$_prefsKeyIdentificacao.leito');
    await prefs.remove('$_prefsKeyIdentificacao.registro');
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

    await prefs.setBool('$_prefsKeySocioeconomico.agua_encanada', aguaEncanada);
    await prefs.setBool(
        '$_prefsKeySocioeconomico.esgoto_encanado', esgotoEncanado);
    await prefs.setBool('$_prefsKeySocioeconomico.coleta_lixo', coletaLixo);
    await prefs.setBool('$_prefsKeySocioeconomico.luz_eletrica', luzEletrica);
    await prefs.setString('$_prefsKeySocioeconomico.tipo_casa', tipoCasa);
    await prefs.setString(
        '$_prefsKeySocioeconomico.numero_pessoas_moram_junto', numPessoas);
    await prefs.setString(
        '$_prefsKeySocioeconomico.renda_familiar', rendaFamiliar);
    await prefs.setString(
        '$_prefsKeySocioeconomico.renda_per_capita', rendaPerCapita);
    await prefs.setString(
        '$_prefsKeySocioeconomico.escolaridade', escolaridade);
    await prefs.setString('$_prefsKeySocioeconomico.profissao', profissao);
    await prefs.setString(
        '$_prefsKeySocioeconomico.producao_domestica_alimentos',
        producaoAlimentos);
  }

  Future<Map<String, dynamic>> carregarDadosSocioeconomicos() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'agua_encanada':
          prefs.getBool('$_prefsKeySocioeconomico.agua_encanada') ?? false,
      'esgoto_encanado':
          prefs.getBool('$_prefsKeySocioeconomico.esgoto_encanado') ?? false,
      'coleta_lixo':
          prefs.getBool('$_prefsKeySocioeconomico.coleta_lixo') ?? false,
      'luz_eletrica':
          prefs.getBool('$_prefsKeySocioeconomico.luz_eletrica') ?? false,
      'tipo_casa':
          prefs.getString('$_prefsKeySocioeconomico.tipo_casa') ?? 'Selecione',
      'numero_pessoas_moram_junto': prefs.getString(
              '$_prefsKeySocioeconomico.numero_pessoas_moram_junto') ??
          '',
      'renda_familiar':
          prefs.getString('$_prefsKeySocioeconomico.renda_familiar') ?? '',
      'renda_per_capita':
          prefs.getString('$_prefsKeySocioeconomico.renda_per_capita') ?? '',
      'escolaridade':
          prefs.getString('$_prefsKeySocioeconomico.escolaridade') ?? '',
      'profissao': prefs.getString('$_prefsKeySocioeconomico.profissao') ?? '',
      'producao_domestica_alimentos': prefs.getString(
              '$_prefsKeySocioeconomico.producao_domestica_alimentos') ??
          '',
    };
  }

  Future<void> limparDadosSocioeconomicos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeySocioeconomico.agua_encanada');
    await prefs.remove('$_prefsKeySocioeconomico.esgoto_encanado');
    await prefs.remove('$_prefsKeySocioeconomico.coleta_lixo');
    await prefs.remove('$_prefsKeySocioeconomico.luz_eletrica');
    await prefs.remove('$_prefsKeySocioeconomico.tipo_casa');
    await prefs.remove('$_prefsKeySocioeconomico.numero_pessoas_moram_junto');
    await prefs.remove('$_prefsKeySocioeconomico.renda_familiar');
    await prefs.remove('$_prefsKeySocioeconomico.renda_per_capita');
    await prefs.remove('$_prefsKeySocioeconomico.escolaridade');
    await prefs.remove('$_prefsKeySocioeconomico.profissao');
    await prefs.remove('$_prefsKeySocioeconomico.producao_domestica_alimentos');
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
        '$_prefsKeyAntecedentesPessoais.excesso_peso', excessoPeso);
    await prefs.setBool('$_prefsKeyAntecedentesPessoais.diabetes', diabetes);
    await prefs.setBool('$_prefsKeyAntecedentesPessoais.outros', outros);
    await prefs.setString(
        '$_prefsKeyAntecedentesPessoais.outros_descricao', outrosDescricao);
  }

  Future<Map<String, dynamic>> carregarAntecedentesPessoais() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'dislipidemias':
          prefs.getBool('$_prefsKeyAntecedentesPessoais.dislipidemias') ??
              false,
      'has': prefs.getBool('$_prefsKeyAntecedentesPessoais.has') ?? false,
      'cancer': prefs.getBool('$_prefsKeyAntecedentesPessoais.cancer') ?? false,
      'excesso_peso':
          prefs.getBool('$_prefsKeyAntecedentesPessoais.excesso_peso') ?? false,
      'diabetes':
          prefs.getBool('$_prefsKeyAntecedentesPessoais.diabetes') ?? false,
      'outros': prefs.getBool('$_prefsKeyAntecedentesPessoais.outros') ?? false,
      'outros_descricao':
          prefs.getString('$_prefsKeyAntecedentesPessoais.outros_descricao') ??
              '',
    };
  }

  Future<void> limparAntecedentesPessoais() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyAntecedentesPessoais.dislipidemias');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.has');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.cancer');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.excesso_peso');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.diabetes');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.outros');
    await prefs.remove('$_prefsKeyAntecedentesPessoais.outros_descricao');
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
        '$_prefsKeyAntecedentesFamiliares.excesso_peso', excessoPeso);
    await prefs.setBool('$_prefsKeyAntecedentesFamiliares.diabetes', diabetes);
    await prefs.setBool('$_prefsKeyAntecedentesFamiliares.outros', outros);
    await prefs.setString(
        '$_prefsKeyAntecedentesFamiliares.outros_descricao', outrosDescricao);
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
      'excesso_peso':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.excesso_peso') ??
              false,
      'diabetes':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.diabetes') ?? false,
      'outros':
          prefs.getBool('$_prefsKeyAntecedentesFamiliares.outros') ?? false,
      'outros_descricao': prefs
              .getString('$_prefsKeyAntecedentesFamiliares.outros_descricao') ??
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
    await prefs.remove('$_prefsKeyAntecedentesFamiliares.outros_descricao');
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

    // Dados clínicos e nutricionais
    await prefs.setString(
        '$_prefsKeyDadosClinicos.diagnostico_clinico', diagnostico);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.prescricao_dietoterapica', prescricao);
    await prefs.setString('$_prefsKeyDadosClinicos.aceitacao', aceitacao);

    // Alimentação
    await prefs.setString(
        '$_prefsKeyDadosClinicos.alimentacao_habitual', alimentacaoHabitual);
    await prefs.setString('$_prefsKeyDadosClinicos.resumo_outro_nutriente',
        especificarAlimentacao);

    // Histórico médico
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.possui_doenca_anterior', doencaAnterior);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.diagnostico_nutricional', doencaAnteriorDesc);
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.possui_cirurgia_recente', cirurgiaRecente);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.resumo_medicamentos_vitaminas_minerais_prescritos',
        cirurgiaDesc);
    await prefs.setBool('$_prefsKeyDadosClinicos.possui_febre', febre);

    // Peso
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.possui_alteracao_peso_recente', alteracaoPeso);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.quantidade_perca_peso_recente', quantoPeso);

    // Nutrição
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.possui_desconforto_oral_gastrointestinal',
        desconfortos);
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.possui_necessidade_dieta_hospitalar',
        necessidadeDieta);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.resumo_necessidade_dieta_hospitalar',
        qualDieta);
    await prefs.setBool(
        '$_prefsKeyDadosClinicos.possui_suplementacao_nutricional',
        suplementacao);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.resumo_suplemento_nutricional',
        tipoSuplementacao);

    // Hábitos
    await prefs.setBool('$_prefsKeyDadosClinicos.possui_tabagismo', tabagismo);
    await prefs.setBool('$_prefsKeyDadosClinicos.possui_etilismo', etilismo);

    // Condição funcional
    await prefs.setString(
        '$_prefsKeyDadosClinicos.possui_condicao_funcional', condicaoFuncional);
    await prefs.setString('$_prefsKeyDadosClinicos.resumo_condicao_funcional',
        especificarCondicao);

    // Exames e medicamentos
    await prefs.setString(
        '$_prefsKeyDadosClinicos.resumo_exames_laboratoriais', medicamentos);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.resumo_exame_fisico', examesLaboratoriais);
    await prefs.setString(
        '$_prefsKeyDadosClinicos.resumo_exame_fisico', exameFisico);
  }

  Future<Map<String, dynamic>> carregarDadosClinicosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      // Dados clínicos e nutricionais
      'diagnostico_clinico':
          prefs.getString('$_prefsKeyDadosClinicos.diagnostico_clinico') ?? '',
      'prescricao_dietoterapica':
          prefs.getString('$_prefsKeyDadosClinicos.prescricao_dietoterapica') ??
              '',
      'aceitacao': prefs.getString('$_prefsKeyDadosClinicos.aceitacao') ?? '',

      // Alimentação
      'alimentacao_habitual':
          prefs.getString('$_prefsKeyDadosClinicos.alimentacao_habitual') ??
              'Selecione',
      'resumo_outro_nutriente':
          prefs.getString('$_prefsKeyDadosClinicos.resumo_outro_nutriente') ??
              '',

      // Histórico médico
      'possui_doenca_anterior':
          prefs.getBool('$_prefsKeyDadosClinicos.possui_doenca_anterior') ??
              false,
      'diagnostico_nutricional':
          prefs.getString('$_prefsKeyDadosClinicos.diagnostico_nutricional') ??
              '',
      'possui_cirurgia_recente':
          prefs.getBool('$_prefsKeyDadosClinicos.possui_cirurgia_recente') ??
              false,
      'resumo_medicamentos_vitaminas_minerais_prescritos': prefs.getString(
              '$_prefsKeyDadosClinicos.resumo_medicamentos_vitaminas_minerais_prescritos') ??
          '',
      'possui_febre':
          prefs.getBool('$_prefsKeyDadosClinicos.possui_febre') ?? false,

      // Peso
      'possui_alteracao_peso_recente': prefs.getBool(
              '$_prefsKeyDadosClinicos.possui_alteracao_peso_recente') ??
          false,
      'quantidade_perca_peso_recente': prefs.getString(
              '$_prefsKeyDadosClinicos.quantidade_perca_peso_recente') ??
          '',

      // Nutrição
      'possui_desconforto_oral_gastrointestinal': prefs.getBool(
              '$_prefsKeyDadosClinicos.possui_desconforto_oral_gastrointestinal') ??
          false,
      'possui_necessidade_dieta_hospitalar': prefs.getBool(
              '$_prefsKeyDadosClinicos.possui_necessidade_dieta_hospitalar') ??
          false,
      'resumo_necessidade_dieta_hospitalar': prefs.getString(
              '$_prefsKeyDadosClinicos.resumo_necessidade_dieta_hospitalar') ??
          '',
      'possui_suplementacao_nutricional': prefs.getBool(
              '$_prefsKeyDadosClinicos.possui_suplementacao_nutricional') ??
          false,
      'resumo_suplemento_nutricional': prefs.getString(
              '$_prefsKeyDadosClinicos.resumo_suplemento_nutricional') ??
          '',

      // Hábitos
      'possui_tabagismo':
          prefs.getBool('$_prefsKeyDadosClinicos.possui_tabagismo') ?? false,
      'possui_etilismo':
          prefs.getBool('$_prefsKeyDadosClinicos.possui_etilismo') ?? false,

      // Condição funcional
      'possui_condicao_funcional': prefs
              .getString('$_prefsKeyDadosClinicos.possui_condicao_funcional') ??
          'Selecione',
      'resumo_condicao_funcional': prefs
              .getString('$_prefsKeyDadosClinicos.resumo_condicao_funcional') ??
          '',

      // Exames e medicamentos
      'resumo_exames_laboratoriais': prefs.getString(
              '$_prefsKeyDadosClinicos.resumo_exames_laboratoriais') ??
          '',
      'resumo_exame_fisico':
          prefs.getString('$_prefsKeyDadosClinicos.resumo_exame_fisico') ?? '',
    };
  }

  Future<void> limparDadosClinicosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyDadosClinicos.diagnostico_clinico');
    await prefs.remove('$_prefsKeyDadosClinicos.prescricao_dietoterapica');
    await prefs.remove('$_prefsKeyDadosClinicos.aceitacao');
    await prefs.remove('$_prefsKeyDadosClinicos.alimentacao_habitual');
    await prefs.remove('$_prefsKeyDadosClinicos.resumo_outro_nutriente');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_doenca_anterior');
    await prefs.remove('$_prefsKeyDadosClinicos.diagnostico_nutricional');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_cirurgia_recente');
    await prefs.remove(
        '$_prefsKeyDadosClinicos.resumo_medicamentos_vitaminas_minerais_prescritos');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_febre');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_alteracao_peso_recente');
    await prefs.remove('$_prefsKeyDadosClinicos.quantidade_perca_peso_recente');
    await prefs.remove(
        '$_prefsKeyDadosClinicos.possui_desconforto_oral_gastrointestinal');
    await prefs
        .remove('$_prefsKeyDadosClinicos.possui_necessidade_dieta_hospitalar');
    await prefs
        .remove('$_prefsKeyDadosClinicos.resumo_necessidade_dieta_hospitalar');
    await prefs
        .remove('$_prefsKeyDadosClinicos.possui_suplementacao_nutricional');
    await prefs.remove('$_prefsKeyDadosClinicos.resumo_suplemento_nutricional');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_tabagismo');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_etilismo');
    await prefs.remove('$_prefsKeyDadosClinicos.possui_condicao_funcional');
    await prefs.remove('$_prefsKeyDadosClinicos.resumo_condicao_funcional');
    await prefs.remove('$_prefsKeyDadosClinicos.resumo_exames_laboratoriais');
    await prefs.remove('$_prefsKeyDadosClinicos.resumo_exame_fisico');
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

    await prefs.setString('$_prefsKeyAntropometricos.peso_atual', pesoAtual);
    await prefs.setString('$_prefsKeyAntropometricos.peso_usual', pesoUsual);
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
        '$_prefsKeyAntropometricos.porcentagem_gc', percentualGordura);
    await prefs.setString(
        '$_prefsKeyAntropometricos.porcentagem_perca_peso_por_tempo',
        perdaPeso);
    await prefs.setString('$_prefsKeyAntropometricos.diagnostico_nutricional',
        diagnosticoNutricional);
  }

  Future<Map<String, String>> carregarDadosAntropometricos() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'peso_atual':
          prefs.getString('$_prefsKeyAntropometricos.peso_atual') ?? '',
      'peso_usual':
          prefs.getString('$_prefsKeyAntropometricos.peso_usual') ?? '',
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
      'porcentagem_gc':
          prefs.getString('$_prefsKeyAntropometricos.porcentagem_gc') ?? '',
      'porcentagem_perca_peso_por_tempo': prefs.getString(
              '$_prefsKeyAntropometricos.porcentagem_perca_peso_por_tempo') ??
          '',
      'diagnostico_nutricional': prefs
              .getString('$_prefsKeyAntropometricos.diagnostico_nutricional') ??
          '',
    };
  }

  Future<void> limparDadosAntropometricos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyAntropometricos.peso_atual');
    await prefs.remove('$_prefsKeyAntropometricos.peso_usual');
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
    await prefs.remove('$_prefsKeyAntropometricos.porcentagem_gc');
    await prefs
        .remove('$_prefsKeyAntropometricos.porcentagem_perca_peso_por_tempo');
    await prefs.remove('$_prefsKeyAntropometricos.diagnostico_nutricional');
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

    await prefs.setString('$_prefsKeyRequerimentos.kcal_dia', kcalDia);
    await prefs.setString('$_prefsKeyRequerimentos.kcal_kg', kcalKg);
    await prefs.setString('$_prefsKeyRequerimentos.cho', cho);
    await prefs.setString('$_prefsKeyRequerimentos.lip', lip);
    await prefs.setString('$_prefsKeyRequerimentos.Ptn', ptnPorcentagem);
    await prefs.setString('$_prefsKeyRequerimentos.ptn_kg', ptnKg);
    await prefs.setString('$_prefsKeyRequerimentos.ptn_dia', ptnDia);
    await prefs.setString('$_prefsKeyRequerimentos.liquido_kg', liquidoKg);
    await prefs.setString('$_prefsKeyRequerimentos.liquido_dia', liquidoDia);
    await prefs.setString('$_prefsKeyRequerimentos.fibras', fibras);
    await prefs.setString('$_prefsKeyRequerimentos.outros', outros);
  }

  Future<Map<String, String>> carregarRequerimentosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'kcal_dia': prefs.getString('$_prefsKeyRequerimentos.kcal_dia') ?? '',
      'kcal_kg': prefs.getString('$_prefsKeyRequerimentos.kcal_kg') ?? '',
      'cho': prefs.getString('$_prefsKeyRequerimentos.cho') ?? '',
      'lip': prefs.getString('$_prefsKeyRequerimentos.lip') ?? '',
      'Ptn': prefs.getString('$_prefsKeyRequerimentos.Ptn') ?? '',
      'ptn_kg': prefs.getString('$_prefsKeyRequerimentos.ptn_kg') ?? '',
      'ptn_dia': prefs.getString('$_prefsKeyRequerimentos.ptn_dia') ?? '',
      'liquido_kg': prefs.getString('$_prefsKeyRequerimentos.liquido_kg') ?? '',
      'liquido_dia':
          prefs.getString('$_prefsKeyRequerimentos.liquido_dia') ?? '',
      'fibras': prefs.getString('$_prefsKeyRequerimentos.fibras') ?? '',
      'outros': prefs.getString('$_prefsKeyRequerimentos.outros') ?? '',
    };
  }

  Future<void> limparRequerimentosNutricionais() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('$_prefsKeyRequerimentos.kcal_dia');
    await prefs.remove('$_prefsKeyRequerimentos.kcal_kg');
    await prefs.remove('$_prefsKeyRequerimentos.cho');
    await prefs.remove('$_prefsKeyRequerimentos.lip');
    await prefs.remove('$_prefsKeyRequerimentos.Ptn');
    await prefs.remove('$_prefsKeyRequerimentos.ptn_kg');
    await prefs.remove('$_prefsKeyRequerimentos.ptn_dia');
    await prefs.remove('$_prefsKeyRequerimentos.liquido_kg');
    await prefs.remove('$_prefsKeyRequerimentos.liquido_dia');
    await prefs.remove('$_prefsKeyRequerimentos.fibras');
    await prefs.remove('$_prefsKeyRequerimentos.outros');
  }

// Dados de conduta nutricional e finalização
  static const String _prefsKeyConduta = 'hospital_atendimento_conduta';

  Future<void> salvarCondutaNutricional({
    required String estagiario,
    required String professor,
    required String idEstagiario,
    required String idProfessor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKeyConduta.estagiario', estagiario);
    await prefs.setString('$_prefsKeyConduta.professor', professor);
    await prefs.setString('$_prefsKeyConduta.idEstagiario', idEstagiario);
    await prefs.setString('$_prefsKeyConduta.idProfessor', idProfessor);
  }

  Future<Map<String, String>> carregarCondutaNutricional() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'estagiario': prefs.getString('$_prefsKeyConduta.estagiario') ?? '',
      'professor':
          prefs.getString('$_prefsKeyConduta.professor') ?? 'Selecione',
    };
  }

  static const String _prefsKeytipoAtendimento =
      'hospital_atendimento_tipo_atendimento';

  Future<void> salvarTipoAtendimento(String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeytipoAtendimento, tipo);
  }

  Future<String?> obterTipoAtendimento() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeytipoAtendimento);
  }

  Future<void> excluirTipoAtendimento() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeytipoAtendimento);
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

  Future<Map<String, dynamic>> obterDadosCompletos() async {
    var identificacao = await carregarDadosIdentificacao();
    var socioeconomicos = await carregarDadosSocioeconomicos();
    var antecedentesPessoais = await carregarAntecedentesPessoais();
    var antecedentesFamiliares = await carregarAntecedentesFamiliares();
    var dadosClinicos = await carregarDadosClinicosNutricionais();
    var antropometricos = await carregarDadosAntropometricos();
    var consumoAlimentar = await carregarConsumoAlimentar();
    var requerimentos = await carregarRequerimentosNutricionais();
    var conduta = await carregarCondutaNutricional();

    // Garanta que a data esteja no formato Timestamp
    Timestamp data = Timestamp.now();

    return {
      ...identificacao,
      ...socioeconomicos,
      ...antecedentesPessoais,
      ...antecedentesFamiliares,
      ...dadosClinicos,
      ...antropometricos,
      ...consumoAlimentar,
      ...requerimentos,
      ...conduta,
      'data': data,
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
      'criado_por': user.uid,
      'criado_em': FieldValue.serverTimestamp(),
      'status_atendimento': 'enviado',
    });
  }

  Future<void> salvarProfessorSelecionado(String professor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'hospital_atendimento.professor_selecionado', professor);
  }

  Future<String?> carregarProfessorSelecionado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('hospital_atendimento.professor_selecionado');
  }

  obterAtendimentoAtual() {}
}
