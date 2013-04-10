object frmPrincipal: TfrmPrincipal
  Left = 210
  Top = 157
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Modelo Aeronaves - Diego Queiroz'
  ClientHeight = 401
  ClientWidth = 593
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Verdana'
  Font.Style = []
  Menu = MenuPrincipal
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object btnStartAG: TButton
    Left = 272
    Top = 364
    Width = 146
    Height = 25
    Caption = 'Iniciar/Reiniciar AG'
    TabOrder = 0
    OnClick = btnStartAGClick
  end
  object btnContinuarAG: TButton
    Left = 453
    Top = 364
    Width = 91
    Height = 25
    Caption = 'Continuar'
    Enabled = False
    TabOrder = 1
    OnClick = btnContinuarAGClick
  end
  object grpParametrosPopulacao: TGroupBox
    Left = 8
    Top = 10
    Width = 251
    Height = 56
    Caption = '[ Par'#226'metros da popula'#231#227'o ]'
    TabOrder = 2
    object Label7: TLabel
      Left = 15
      Top = 25
      Width = 141
      Height = 14
      Caption = 'N'#250'mero de indiv'#237'duos:'
    end
    object edtNumIndividuos: TEdit
      Left = 160
      Top = 20
      Width = 76
      Height = 22
      TabOrder = 0
      Text = '100'
    end
  end
  object grpParametrosEvolucao: TGroupBox
    Left = 8
    Top = 71
    Width = 251
    Height = 211
    Caption = '[ Par'#226'metros de evolu'#231#227'o ]'
    TabOrder = 3
    object Label3: TLabel
      Left = 15
      Top = 21
      Width = 136
      Height = 14
      Caption = 'Taxa de Cruzamento:'
    end
    object Label8: TLabel
      Left = 15
      Top = 46
      Width = 112
      Height = 14
      Caption = 'Taxa de Muta'#231#227'o:'
    end
    object lblQtdGeracoes: TLabel
      Left = 15
      Top = 185
      Width = 116
      Height = 14
      Caption = 'M'#225'x. de gera'#231#245'es:'
    end
    object edtTaxaCruzamento: TEdit
      Left = 160
      Top = 18
      Width = 80
      Height = 22
      TabOrder = 0
      Text = '0,9'
    end
    object edtTaxaMutacao: TEdit
      Left = 160
      Top = 43
      Width = 80
      Height = 22
      TabOrder = 1
      Text = '0,1'
    end
    object grpCondicaoParada: TRadioGroup
      Left = 15
      Top = 75
      Width = 226
      Height = 101
      Hint = 
        'Condi'#231#227'o de parada:'#13#10#13#10'* Somente na solu'#231#227'o ideal'#13#10'   Executa no' +
        'vas gera'#231#245'es at'#233' encontrar a solu'#231#227'o ideal para o problema'#13#10'   (' +
        'como a solu'#231#227'o ideal pode n'#227'o existir, esta condi'#231#227'o pode gerar ' +
        'um loop infinito).'#13#10#13#10'* Estrat'#233'gia elitista'#13#10'   Executa novas ge' +
        'ra'#231#245'es at'#233' que seja notado que n'#227'o h'#225' mais'#13#10'   converg'#234'ncia entr' +
        'e as gera'#231#245'es.'#13#10#13#10'* Quantidade fixa de gera'#231#245'es'#13#10'   Executa a qu' +
        'antidade de gera'#231#245'es especificada.'#13#10#13#10'* Nunca parar'#13#10'   Executa ' +
        'novas gera'#231#245'es infinitamente at'#233' que o usu'#225'rio solicite que Pare' +
        '.'
      Caption = '[ Condi'#231#227'o de parada ]'
      ItemIndex = 0
      Items.Strings = (
        'Somente na solu'#231#227'o ideal'
        'Estrat'#233'gia elitista'
        'Quantidade fixa de gera'#231#245'es'
        'Nunca parar')
      TabOrder = 2
      OnClick = grpCondicaoParadaClick
    end
    object edtQtdGeracoes: TEdit
      Left = 155
      Top = 182
      Width = 80
      Height = 22
      TabOrder = 3
      Text = '200'
    end
  end
  object grpEstatisticas: TGroupBox
    Left = 8
    Top = 286
    Width = 251
    Height = 103
    Caption = '[ Estat'#237'sticas ]'
    TabOrder = 4
    object Label10: TLabel
      Left = 15
      Top = 24
      Width = 93
      Height = 14
      Caption = 'Gera'#231#227'o atual:'
    end
    object Label11: TLabel
      Left = 15
      Top = 49
      Width = 135
      Height = 14
      Caption = 'Melhor solu'#231#227'o atual:'
    end
    object Label12: TLabel
      Left = 15
      Top = 74
      Width = 135
      Height = 14
      Caption = 'Melhor solu'#231#227'o geral:'
    end
    object edtGeracaoAtual: TEdit
      Left = 155
      Top = 21
      Width = 80
      Height = 22
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object edtMelhorSolucaoAtual: TEdit
      Left = 155
      Top = 46
      Width = 80
      Height = 22
      ReadOnly = True
      TabOrder = 1
      Text = '-'
    end
    object edtMelhorSolucaoGeral: TEdit
      Left = 155
      Top = 71
      Width = 80
      Height = 22
      ReadOnly = True
      TabOrder = 2
      Text = '-'
    end
  end
  object hrpParametrosProblema: TGroupBox
    Left = 272
    Top = 8
    Width = 311
    Height = 103
    Caption = '[ Par'#226'metros do problema ]'
    TabOrder = 5
    object Label5: TLabel
      Left = 10
      Top = 25
      Width = 147
      Height = 14
      Caption = 'Quantidade de pontos:'
    end
    object Label6: TLabel
      Left = 10
      Top = 50
      Width = 136
      Height = 14
      Caption = 'Quantidade de rotas:'
    end
    object edtQtdPontos: TEdit
      Left = 210
      Top = 20
      Width = 91
      Height = 22
      TabOrder = 0
      Text = '6'
    end
    object edtQtdRotas: TEdit
      Left = 210
      Top = 45
      Width = 91
      Height = 22
      TabOrder = 1
      Text = '2'
    end
    object btnReiniciarGrafico: TButton
      Left = 153
      Top = 73
      Width = 147
      Height = 23
      Caption = 'Redesenhar gr'#225'fico'
      TabOrder = 2
      OnClick = btnReiniciarGraficoClick
    end
    object btnReset: TButton
      Left = 10
      Top = 74
      Width = 75
      Height = 21
      Caption = 'Reiniciar'
      TabOrder = 3
      OnClick = btnResetClick
    end
  end
  object grpGrafico: TGroupBox
    Left = 272
    Top = 115
    Width = 311
    Height = 243
    Caption = '[ Gr'#225'fico ]'
    TabOrder = 6
    object Grafico: TImage
      Left = 45
      Top = 17
      Width = 220
      Height = 220
    end
  end
  object btnStopAG: TBitBtn
    Left = 550
    Top = 364
    Width = 31
    Height = 25
    Enabled = False
    TabOrder = 7
    OnClick = btnStopAGClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333FFFFF3333333333999993333333333F77777FFF333333999999999
      33333337777FF377FF3333993370739993333377FF373F377FF3399993000339
      993337777F777F3377F3393999707333993337F77737333337FF993399933333
      399377F3777FF333377F993339903333399377F33737FF33377F993333707333
      399377F333377FF3377F993333101933399377F333777FFF377F993333000993
      399377FF3377737FF7733993330009993933373FF3777377F7F3399933000399
      99333773FF777F777733339993707339933333773FF7FFF77333333999999999
      3333333777333777333333333999993333333333377777333333}
    NumGlyphs = 2
  end
  object btn100times: TButton
    Left = 236
    Top = 276
    Width = 75
    Height = 25
    Caption = '100 times!'
    TabOrder = 8
    Visible = False
    OnClick = btn100timesClick
  end
  object MenuPrincipal: TMainMenu
    Left = 360
    Top = 145
    object Sobre1: TMenuItem
      Caption = 'Sobre...'
      OnClick = Sobre1Click
    end
    object Visualizar1: TMenuItem
      Caption = 'Visualizar'
      object Janeladeresutlados1: TMenuItem
        AutoCheck = True
        Caption = 'Janela de resultados'
        ShortCut = 116
        OnClick = Janeladeresutlados1Click
      end
    end
    object Sair1: TMenuItem
      Caption = 'Sair'
      OnClick = Sair1Click
    end
  end
end
