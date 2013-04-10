object frmLogWindow: TfrmLogWindow
  Left = 377
  Top = 254
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'Janela de resultados'
  ClientHeight = 317
  ClientWidth = 448
  Color = clSkyBlue
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    448
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object log: TMemo
    Left = 0
    Top = 7
    Width = 446
    Height = 283
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object Button1: TButton
    Left = 371
    Top = 294
    Width = 75
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'Fechar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 294
    Width = 75
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'Limpar'
    TabOrder = 2
    OnClick = Button2Click
  end
end
