import 'package:cloud_firestore/cloud_firestore.dart';

class AtendimentoModel {
  final String? id;
  final String nome;
  final String sexo;
  final DateTime dataNascimento;
  final String hospital;
  final String clinica;
  final String quarto;
  final String leito;
  final String registro;
  final bool aguaEncanada;
  final bool esgotoEncanado;
  final bool coletaLixo;
  final bool luzEletrica;
  final String casa;
  final int numeroPessoasMoramJunto;
  final double rendaFamiliar;
  final double rendaPerCapta;
  final String escolaridade;
  final String profissao;
  final bool producaoDomesticaAlimentos;
  final bool possuiDislipidemias;
  final bool possuiHAS;
  final bool possuiCancer;
  final bool possuiExcessoPeso;
  final bool possuiDiabetes;
  final bool possuiOutraDoenca;
  final bool familiarPossuiDislipidemias;
  final bool familiarPossuiHAS;
  final bool familiarPossuiCancer;
  final bool familiarPossuiExcessoPeso;
  final bool familiarPossuiDiabetes;
  final String diaAlimentarHabitual;
  final String diaAlimentarAtual;
  final double kcalDia;
  final double kcalKg;
  final double cho;
  final double lip;
  final double ptn;
  final double ptnKg;
  final double ptnDia;
  final double liquidoKg;
  final double liquidoDia;
  final double fibrasDia;
  final String resumoOutroNutriente;
  final String diagnosticoClinico;
  final String prescricaoDietoterapica;
  final String aceitacao;
  final String alimentacaoHabitual;
  final bool possuiDoencaAnterior;
  final bool possuiCirurgiaRecente;
  final bool possuiFebre;
  final bool possuiAlteracaoPesoRecente;
  final double quantidadePercaPesoRecente;
  final bool possuiDesconfortoOralGastrointestinal;
  final bool possuiNecessidadeDietaHospitalar;
  final String resumoNecessidadeDietaHospitalar;
  final bool possuiSuplementacaoNutricional;
  final String resumoSuplementoNutricional;
  final bool possuiTabagismo;
  final bool possuiEtilismo;
  final bool possuiCondicaoFuncional;
  final String resumoCondicaoFuncional;
  final double pesoAtual;
  final double pesoUsual;
  final double estatura;
  final double imc;
  final double pi;
  final double cb;
  final double pct;
  final double pcb;
  final double pcse;
  final double pcsi;
  final double cmb;
  final double ca;
  final double aj;
  final double porcentagemGc;
  final double porcentagemPercaPesoPorTempo;
  final String diagnosticoNutricional;
  final String resumoMedicamentosVitaminasMineraisPrescritos;
  final String resumoExamesLaboratoriais;
  final String resumoExameFisico;
  final String observacaoSupervisor;
  final String idAluno;
  final String idProfessorSupervisor;
  final String statusAtendimento;
  final DateTime criadoEm;
  final String criadoPor;
  final DateTime atualizadoEm;
  final String atualizadoPor;
  final String nomeAluno;
  final String nomeProfessor;

  AtendimentoModel({
    this.id,
    required this.nome,
    required this.sexo,
    required this.dataNascimento,
    required this.hospital,
    required this.clinica,
    required this.quarto,
    required this.leito,
    required this.registro,
    required this.aguaEncanada,
    required this.esgotoEncanado,
    required this.coletaLixo,
    required this.luzEletrica,
    required this.casa,
    required this.numeroPessoasMoramJunto,
    required this.rendaFamiliar,
    required this.rendaPerCapta,
    required this.escolaridade,
    required this.profissao,
    required this.producaoDomesticaAlimentos,
    required this.possuiDislipidemias,
    required this.possuiHAS,
    required this.possuiCancer,
    required this.possuiExcessoPeso,
    required this.possuiDiabetes,
    required this.possuiOutraDoenca,
    required this.familiarPossuiDislipidemias,
    required this.familiarPossuiHAS,
    required this.familiarPossuiCancer,
    required this.familiarPossuiExcessoPeso,
    required this.familiarPossuiDiabetes,
    required this.diaAlimentarHabitual,
    required this.diaAlimentarAtual,
    required this.kcalDia,
    required this.kcalKg,
    required this.cho,
    required this.lip,
    required this.ptn,
    required this.ptnKg,
    required this.ptnDia,
    required this.liquidoKg,
    required this.liquidoDia,
    required this.fibrasDia,
    required this.resumoOutroNutriente,
    required this.diagnosticoClinico,
    required this.prescricaoDietoterapica,
    required this.aceitacao,
    required this.alimentacaoHabitual,
    required this.possuiDoencaAnterior,
    required this.possuiCirurgiaRecente,
    required this.possuiFebre,
    required this.possuiAlteracaoPesoRecente,
    required this.quantidadePercaPesoRecente,
    required this.possuiDesconfortoOralGastrointestinal,
    required this.possuiNecessidadeDietaHospitalar,
    required this.resumoNecessidadeDietaHospitalar,
    required this.possuiSuplementacaoNutricional,
    required this.resumoSuplementoNutricional,
    required this.possuiTabagismo,
    required this.possuiEtilismo,
    required this.possuiCondicaoFuncional,
    required this.resumoCondicaoFuncional,
    required this.pesoAtual,
    required this.pesoUsual,
    required this.estatura,
    required this.imc,
    required this.pi,
    required this.cb,
    required this.pct,
    required this.pcb,
    required this.pcse,
    required this.pcsi,
    required this.cmb,
    required this.ca,
    required this.aj,
    required this.porcentagemGc,
    required this.porcentagemPercaPesoPorTempo,
    required this.diagnosticoNutricional,
    required this.resumoMedicamentosVitaminasMineraisPrescritos,
    required this.resumoExamesLaboratoriais,
    required this.resumoExameFisico,
    required this.observacaoSupervisor,
    required this.idAluno,
    required this.idProfessorSupervisor,
    required this.statusAtendimento,
    required this.criadoEm,
    required this.criadoPor,
    required this.atualizadoEm,
    required this.atualizadoPor,
    required this.nomeAluno,
    required this.nomeProfessor,
  });

  factory AtendimentoModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return AtendimentoModel(
      id: documentId,
      nome: map['nome'] ?? '',
      sexo: map['sexo'] ?? '',
      dataNascimento: (map['data_nascimento'] as Timestamp).toDate(),
      hospital: map['hospital'] ?? '',
      clinica: map['clinica'] ?? '',
      quarto: map['quarto'] ?? '',
      leito: map['leito'] ?? '',
      registro: map['registro'] ?? '',
      aguaEncanada: map['agua_encanada'] ?? false,
      esgotoEncanado: map['esgoto_encanado'] ?? false,
      coletaLixo: map['coleta_lixo'] ?? false,
      luzEletrica: map['luz_eletrica'] ?? false,
      casa: map['casa'] ?? '',
      numeroPessoasMoramJunto: (map['numero_pessoas_moram_junto'] ?? 0).toInt(),
      rendaFamiliar: (map['renda_familar'] ?? 0).toDouble(),
      rendaPerCapta: (map['renda_per_capta'] ?? 0).toDouble(),
      escolaridade: map['escolaridade'] ?? '',
      profissao: map['profissao'] ?? '',
      producaoDomesticaAlimentos: map['producao_domestica_alimentos'] ?? false,
      possuiDislipidemias: map['possui_dislipidemias'] ?? false,
      possuiHAS: map['possui_has'] ?? false,
      possuiCancer: map['possui_cancer'] ?? false,
      possuiExcessoPeso: map['possui_excesso_peso'] ?? false,
      possuiDiabetes: map['possui_diabetes'] ?? false,
      possuiOutraDoenca: map['possui_outra_doenca'] ?? false,
      familiarPossuiDislipidemias:
          map['familiar_possui_dislipidemias'] ?? false,
      familiarPossuiHAS: map['familiar_possui_has'] ?? false,
      familiarPossuiCancer: map['familiar_possui_cancer'] ?? false,
      familiarPossuiExcessoPeso: map['familiar_possui_excesso_peso'] ?? false,
      familiarPossuiDiabetes: map['familiar_possui_diabetes'] ?? false,
      diaAlimentarHabitual: map['dia_alimentar_habitual'] ?? '',
      diaAlimentarAtual: map['dia_alimentar_atual'] ?? '',
      kcalDia: (map['kcal_dia'] ?? 0).toDouble(),
      kcalKg: (map['kcal_kg'] ?? 0).toDouble(),
      cho: (map['CHO'] ?? 0).toDouble(),
      lip: (map['Lip'] ?? 0).toDouble(),
      ptn: (map['Ptn'] ?? 0).toDouble(),
      ptnKg: (map['ptn_kg'] ?? 0).toDouble(),
      ptnDia: (map['ptn_dia'] ?? 0).toDouble(),
      liquidoKg: (map['liquido_kg'] ?? 0).toDouble(),
      liquidoDia: (map['liquido_dia'] ?? 0).toDouble(),
      fibrasDia: (map['fibras_dia'] ?? 0).toDouble(),
      resumoOutroNutriente: map['resumo_outro_nutriente'] ?? '',
      diagnosticoClinico: map['diagnostico_clinico'] ?? '',
      prescricaoDietoterapica: map['prescricao_dietoterapica'] ?? '',
      aceitacao: map['aceitacao'] ?? '',
      alimentacaoHabitual: map['alimentacao_habitual'] ?? '',
      possuiDoencaAnterior: map['possui_doenca_anterior'] ?? false,
      possuiCirurgiaRecente: map['possui_cirurgia_recente'] ?? false,
      possuiFebre: map['possui_febre'] ?? false,
      possuiAlteracaoPesoRecente: map['possui_alteracao_peso_recente'] ?? false,
      quantidadePercaPesoRecente:
          (map['quantidade_perca_peso_recente'] ?? 0).toDouble(),
      possuiDesconfortoOralGastrointestinal:
          map['possui_desconforto_oral_gastrointestinal'] ?? false,
      possuiNecessidadeDietaHospitalar:
          map['possui_necessidade_dieta_hospitalar'] ?? false,
      resumoNecessidadeDietaHospitalar:
          map['resumo_necessidade_dieta_hospitalar'] ?? '',
      possuiSuplementacaoNutricional:
          map['possui_suplementacao_nutricional'] ?? false,
      resumoSuplementoNutricional: map['resumo_suplemento_nutricional'] ?? '',
      possuiTabagismo: map['possui_tabagismo'] ?? false,
      possuiEtilismo: map['possui_etilismo'] ?? false,
      possuiCondicaoFuncional: map['possui_condicao_funcional'] ?? false,
      resumoCondicaoFuncional: map['resumo_condicao_funcional'] ?? '',
      pesoAtual: (map['peso_atual'] ?? 0).toDouble(),
      pesoUsual: (map['peso_usual'] ?? 0).toDouble(),
      estatura: (map['estatura'] ?? 0).toDouble(),
      imc: (map['imc'] ?? 0).toDouble(),
      pi: (map['pi'] ?? 0).toDouble(),
      cb: (map['cb'] ?? 0).toDouble(),
      pct: (map['pct'] ?? 0).toDouble(),
      pcb: (map['pcb'] ?? 0).toDouble(),
      pcse: (map['pcse'] ?? 0).toDouble(),
      pcsi: (map['pcsi'] ?? 0).toDouble(),
      cmb: (map['cmb'] ?? 0).toDouble(),
      ca: (map['ca'] ?? 0).toDouble(),
      aj: (map['aj'] ?? 0).toDouble(),
      porcentagemGc: (map['porcentagem_gc'] ?? 0).toDouble(),
      porcentagemPercaPesoPorTempo:
          (map['porcentagem_perca_peso_por_tempo'] ?? 0).toDouble(),
      diagnosticoNutricional: map['diagnostico_nutricional'] ?? '',
      resumoMedicamentosVitaminasMineraisPrescritos:
          map['resumo_medicamentos_vitaminas_minerais_prescritos'] ?? '',
      resumoExamesLaboratoriais: map['resumo_exames_laboratoriais'] ?? '',
      resumoExameFisico: map['resumo_exame_fisico'] ?? '',
      observacaoSupervisor: map['observacao_supervisor'] ?? '',
      idAluno: map['id_aluno'] ?? '',
      idProfessorSupervisor: map['id_professor_supervisor'] ?? '',
      statusAtendimento: map['status_atendimento'] ?? '',
      criadoEm: (map['criado_em'] as Timestamp).toDate(),
      criadoPor: map['criado_por'] ?? '',
      atualizadoEm: (map['atualizado_em'] as Timestamp).toDate(),
      atualizadoPor: map['atualizado_por'] ?? '',
      nomeAluno: map['nome_aluno'] ?? '',
      nomeProfessor: map['nome_professor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'sexo': sexo,
      'data_nascimento': Timestamp.fromDate(dataNascimento),
      'hospital': hospital,
      'clinica': clinica,
      'quarto': quarto,
      'leito': leito,
      'registro': registro,
      'agua_encanada': aguaEncanada,
      'esgoto_encanado': esgotoEncanado,
      'coleta_lixo': coletaLixo,
      'luz_eletrica': luzEletrica,
      'casa': casa,
      'numero_pessoas_moram_junto': numeroPessoasMoramJunto,
      'renda_familar': rendaFamiliar,
      'renda_per_capta': rendaPerCapta,
      'escolaridade': escolaridade,
      'profissao': profissao,
      'producao_domestica_alimentos': producaoDomesticaAlimentos,
      'possui_dislipidemias': possuiDislipidemias,
      'possui_has': possuiHAS,
      'possui_cancer': possuiCancer,
      'possui_excesso_peso': possuiExcessoPeso,
      'possui_diabetes': possuiDiabetes,
      'possui_outra_doenca': possuiOutraDoenca,
      'familiar_possui_dislipidemias': familiarPossuiDislipidemias,
      'familiar_possui_has': familiarPossuiHAS,
      'familiar_possui_cancer': familiarPossuiCancer,
      'familiar_possui_excesso_peso': familiarPossuiExcessoPeso,
      'familiar_possui_diabetes': familiarPossuiDiabetes,
      'dia_alimentar_habitual': diaAlimentarHabitual,
      'dia_alimentar_atual': diaAlimentarAtual,
      'kcal_dia': kcalDia,
      'kcal_kg': kcalKg,
      'CHO': cho,
      'Lip': lip,
      'Ptn': ptn,
      'ptn_kg': ptnKg,
      'ptn_dia': ptnDia,
      'liquido_kg': liquidoKg,
      'liquido_dia': liquidoDia,
      'fibras_dia': fibrasDia,
      'resumo_outro_nutriente': resumoOutroNutriente,
      'diagnostico_clinico': diagnosticoClinico,
      'prescricao_dietoterapica': prescricaoDietoterapica,
      'aceitacao': aceitacao,
      'alimentacao_habitual': alimentacaoHabitual,
      'possui_doenca_anterior': possuiDoencaAnterior,
      'possui_cirurgia_recente': possuiCirurgiaRecente,
      'possui_febre': possuiFebre,
      'possui_alteracao_peso_recente': possuiAlteracaoPesoRecente,
      'quantidade_perca_peso_recente': quantidadePercaPesoRecente,
      'possui_desconforto_oral_gastrointestinal':
          possuiDesconfortoOralGastrointestinal,
      'possui_necessidade_dieta_hospitalar': possuiNecessidadeDietaHospitalar,
      'resumo_necessidade_dieta_hospitalar': resumoNecessidadeDietaHospitalar,
      'possui_suplementacao_nutricional': possuiSuplementacaoNutricional,
      'resumo_suplemento_nutricional': resumoSuplementoNutricional,
      'possui_tabagismo': possuiTabagismo,
      'possui_etilismo': possuiEtilismo,
      'possui_condicao_funcional': possuiCondicaoFuncional,
      'resumo_condicao_funcional': resumoCondicaoFuncional,
      'peso_atual': pesoAtual,
      'peso_usual': pesoUsual,
      'estatura': estatura,
      'imc': imc,
      'pi': pi,
      'cb': cb,
      'pct': pct,
      'pcb': pcb,
      'pcse': pcse,
      'pcsi': pcsi,
      'cmb': cmb,
      'ca': ca,
      'aj': aj,
      'porcentagem_gc': porcentagemGc,
      'porcentagem_perca_peso_por_tempo': porcentagemPercaPesoPorTempo,
      'diagnostico_nutricional': diagnosticoNutricional,
      'resumo_medicamentos_vitaminas_minerais_prescritos':
          resumoMedicamentosVitaminasMineraisPrescritos,
      'resumo_exames_laboratoriais': resumoExamesLaboratoriais,
      'resumo_exame_fisico': resumoExameFisico,
      'observacao_supervisor': observacaoSupervisor,
      'id_aluno': idAluno,
      'id_professor_supervisor': idProfessorSupervisor,
      'status_atendimento': statusAtendimento,
      'criado_por': criadoPor,
      'atualizado_por': atualizadoPor,
      'nome_aluno': nomeAluno,
      'nome_professor': nomeProfessor,
    };
  }
}
