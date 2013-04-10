unit ufrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Math, uFunc, ExtCtrls, Menus, Buttons, uAG, DateUtils;

const
  // parametros do grafico
  TAMANHOPONTO  = 5;
  AFASTAMENTO   = 10;
  ESCALA        = 2;

type
  TfrmPrincipal = class(TForm)
    btnStartAG: TButton;
    btnContinuarAG: TButton;
    grpParametrosPopulacao: TGroupBox;
    MenuPrincipal: TMainMenu;
    Sobre1: TMenuItem;
    Label7: TLabel;
    edtNumIndividuos: TEdit;
    grpParametrosEvolucao: TGroupBox;
    Label3: TLabel;
    edtTaxaCruzamento: TEdit;
    Label8: TLabel;
    edtTaxaMutacao: TEdit;
    grpCondicaoParada: TRadioGroup;
    lblQtdGeracoes: TLabel;
    edtQtdGeracoes: TEdit;
    grpEstatisticas: TGroupBox;
    Label10: TLabel;
    edtGeracaoAtual: TEdit;
    Label11: TLabel;
    edtMelhorSolucaoAtual: TEdit;
    Label12: TLabel;
    edtMelhorSolucaoGeral: TEdit;
    hrpParametrosProblema: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    edtQtdPontos: TEdit;
    edtQtdRotas: TEdit;
    grpGrafico: TGroupBox;
    Grafico: TImage;
    Visualizar1: TMenuItem;
    Janeladeresutlados1: TMenuItem;
    btnStopAG: TBitBtn;
    Sair1: TMenuItem;
    btnReiniciarGrafico: TButton;
    btnReset: TButton;
    btn100times: TButton;
    procedure btnStartAGClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Janeladeresutlados1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure Sobre1Click(Sender: TObject);
    procedure grpCondicaoParadaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnReiniciarGraficoClick(Sender: TObject);
    procedure btnContinuarAGClick(Sender: TObject);
    procedure btnStopAGClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btn100timesClick(Sender: TObject);
  private
    AG: TAlgoritmoGenetico;
    condicaoParada: Boolean;
    estrategiaCount, geracaoParada: Integer;
    antigoFitness: TFitnessResult;
  public
    procedure LimpaGrafico;
    procedure DesenhaPontos;
    procedure DesenhaRotas(pRotas: TConjuntoRota);
    
    procedure ReiniciaEstatistica;
    procedure NovaEstatistica(pMelhorFitnessAtual: TFitnessResult);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses ufrmLogWindow, ufrmSobre, uAeronave;

{$R *.dfm}

procedure TfrmPrincipal.btnContinuarAGClick(Sender: TObject);
var
  melhor: TCromossomo;
  melhorFitness: TFitnessResult;
  inicio, fim: TDateTime;
  total: Integer;
begin
  condicaoParada := False;

  btnContinuarAG.Enabled := False;
  btnStartAG.Enabled := False;
  btnReiniciarGrafico.Enabled := False;
  btnStopAG.Enabled := True;

  inicio := now;
  repeat
    melhor := AG.NovaGeracao;
    melhorFitness := FuncaoObjetivo(AG,melhor);
    NovaEstatistica(melhorFitness);

    LimpaGrafico;
    DesenhaPontos;
    DesenhaRotas(ExtraiRetasCromossomo(AG,melhor));
//    LogMe('%.3d - Cromossomo: %s (%d)',[StrToIntDef(edtGeracaoAtual.Text,0),melhor, melhorFitness]);

    Application.ProcessMessages;

    case grpCondicaoParada.ItemIndex of
      0: // Somente solucao ideal
        begin
          if (edtQtdGeracoes.Text <> '0') and (edtQtdGeracoes.Text <> '') then
          begin
            condicaoParada := condicaoParada or (melhorFitness = 0);
            
            try
              if geracaoParada = -1 then
              begin
                if TryStrToInt(edtQtdGeracoes.Text,geracaoParada) then
                begin
                  geracaoParada := geracaoParada + StrToInt(edtGeracaoAtual.Text) -1;
                end
                else
                begin
                  Application.MessageBox('Erro nos valores inseridos!','Erro',MB_OK + MB_ICONERROR);
                  condicaoParada := True;
                end;
              end;

              condicaoParada := condicaoParada or (StrToInt(edtGeracaoAtual.Text) >= geracaoParada);
            except
              condicaoParada := True;
            end;
          end;
        end;
      1: // estratégia
        begin
          if antigoFitness = melhorFitness then
          begin
            estrategiaCount := estrategiaCount + 1;

            condicaoParada := condicaoParada or (estrategiaCount > 200);
          end
          else
          begin
            estrategiaCount := 0;
            antigoFitness := melhorFitness;
          end;
        end;
      2: // quantidade fixa de gerações
        begin
          try
            if geracaoParada = -1 then
            begin
              if TryStrToInt(edtQtdGeracoes.Text,geracaoParada) then
              begin
                geracaoParada := geracaoParada + StrToInt(edtGeracaoAtual.Text) -1;
              end
              else
              begin
                Application.MessageBox('Erro nos valores inseridos!','Erro',MB_OK + MB_ICONERROR);
                condicaoParada := True;
              end;
            end;

            condicaoParada := condicaoParada or (StrToInt(edtGeracaoAtual.Text) >= geracaoParada);
          except
            condicaoParada := True;
          end;
        end;
      3: // nunca parar
        begin
//          condicaoParada := condicaoParada;
        end;
    end;
  until condicaoParada;
  fim := now;

//  LogMe(FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz',inicio)+ ' -- ' + FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz',fim),True);
//  LogMe(FormatDateTime('hh:nn:ss.zzz',inicio)+ ' -- ' + FormatDateTime('hh:nn:ss.zzz',fim),True);

  total := (HourOf(fim) * 3600000 + MinuteOf(fim) * 60000 + SecondOf(fim) * 1000 + MilliSecondOf(fim)) - (HourOf(inicio) * 3600000 + MinuteOf(inicio) * 60000 + SecondOf(inicio) * 1000 + MilliSecondOf(inicio));

//  LogMe('Tempo total: %d ms',[total]);

  LogMe('%.4d --- %.10d',[StrToInt(edtMelhorSolucaoGeral.Text),total]);

  geracaoParada := -1;
  btnStopAG.Enabled := False;
  btnContinuarAG.Enabled := True;
  btnStartAG.Enabled := True;
  btnReiniciarGrafico.Enabled := True;  
end;

procedure TfrmPrincipal.btnReiniciarGraficoClick(Sender: TObject);
var
  qPontos, qRotas: Integer;
begin
  btnReiniciarGrafico.Enabled := False;

  qPontos := StrToIntDef(edtQtdPontos.Text,0);
  qRotas  := StrToIntDef(edtQtdRotas.Text,0);

  if (qRotas = 0) or (qPontos = 0) then
  begin
    Application.MessageBox('Quantidade de pontos e rotas informado é inválido!','Erro',MB_OK + MB_ICONINFORMATION);
  end
  else
  begin
    if qPontos >= (2*qRotas) then
    begin
      CriaPontos(qPontos);
      CriaRotas(qRotas);

      btnReset.Click;
    end
    else
    begin
      Application.MessageBox('A quantidade de pontos deve ser maior que 2x a quantidade de rotas! ( pontos >= 2*rotas )','Erro',MB_OK + MB_ICONINFORMATION);
    end;
  end;

  btnReiniciarGrafico.Enabled := True;
end;

procedure TfrmPrincipal.btnResetClick(Sender: TObject);
begin
  LimpaGrafico;
  DesenhaPontos;
  DesenhaRotas(rotas);

  ReiniciaEstatistica;
  btnContinuarAG.Enabled := False;
end;

procedure TfrmPrincipal.btnStartAGClick(Sender: TObject);
var
  taxaMutacao, taxaCruzamento: Double;
  numIndividuos: Integer;
begin
//  LogMe('***********************************************',True);
  if
    TryStrToFloat(edtTaxaMutacao.Text,taxaMutacao)
  and
    TryStrToFloat(edtTaxaCruzamento.Text,taxaCruzamento)
  and
    TryStrToInt(edtNumIndividuos.Text,numIndividuos)
  then
  begin
    AG.TaxaMutacao      := taxaMutacao;
    AG.TaxaCruzamento   := taxaCruzamento;
    AG.TamanhoPopulacao := numIndividuos;
  end
  else
  begin
    Application.MessageBox('Erro nos valores inseridos!','Erro',MB_OK + MB_ICONERROR);
    Exit;
  end;

  AG.TamanhoCromossomo:= quantRotas * (quantPontos - 2);
  AG.TamanhoGene      := Ceil ( Log2(quantPontos) );

  ReiniciaEstatistica;
  AG.IniciaPopulacao;

  btnContinuarAG.Enabled := True;
  btnContinuarAG.Click;
end;

procedure TfrmPrincipal.btnStopAGClick(Sender: TObject);
begin
  condicaoParada := True;
end;

procedure TfrmPrincipal.btn100timesClick(Sender: TObject);
var
  i: Integer;
begin
  grpCondicaoParada.ItemIndex := 2;
  edtQtdGeracoes.Text := '200';
  
  for i:=1 to 100 do
  begin
    btn100times.Caption := Format('%d times',[i]);
    btnReiniciarGrafico.Click;
    btnStartAG.Click;
  end;
end;

procedure TfrmPrincipal.DesenhaPontos;
var
  i: Integer;
  rect: TRect;
begin
  Grafico.Canvas.Brush.Color := clBlack;
  for i:=0 to quantPontos-1 do
  begin
    rect.Top    := Round(pontos[i].Y*ESCALA-(TAMANHOPONTO div 2))+AFASTAMENTO;
    rect.Left   := Round(pontos[i].X*ESCALA-(TAMANHOPONTO div 2))+AFASTAMENTO;
    rect.Right  := Round(pontos[i].X*ESCALA+(TAMANHOPONTO div 2))+AFASTAMENTO;
    rect.Bottom := Round(pontos[i].Y*ESCALA+(TAMANHOPONTO div 2))+AFASTAMENTO;
    Grafico.Canvas.Ellipse(rect);
  end;
end;

procedure TfrmPrincipal.DesenhaRotas(pRotas: TConjuntoRota);
var
  i: Integer;
begin
  for i:=0 to Length(pRotas)-1 do
  begin
    Grafico.Canvas.MoveTo(Round(pontos[pRotas[i].Origem].X*ESCALA)+AFASTAMENTO,Round(pontos[pRotas[i].Origem].Y*ESCALA)+AFASTAMENTO);
    Grafico.Canvas.LineTo(Round(pontos[pRotas[i].Destino].X*ESCALA)+AFASTAMENTO,Round(pontos[pRotas[i].Destino].Y*ESCALA)+AFASTAMENTO);
//    LogMe(pRotas[i].Origem);
//    LogMe(pRotas[i].Destino);
  end;
end;

procedure TfrmPrincipal.LimpaGrafico;
begin
  Grafico.Canvas.Brush.Color := clWhite;
  Grafico.Canvas.FillRect(Grafico.Canvas.ClipRect);
  Grafico.Canvas.Rectangle(Grafico.Canvas.ClipRect);
end;

procedure TfrmPrincipal.NovaEstatistica(pMelhorFitnessAtual: TFitnessResult);
var
  melhorFitnessEncontrado: TFitnessResult;
begin
  edtGeracaoAtual.Text := IntToStr(StrToIntDef(edtGeracaoAtual.Text,0) + 1);
  edtMelhorSolucaoAtual.Text := Format('%d',[pMelhorFitnessAtual]);

  melhorFitnessEncontrado := StrToIntDef(edtMelhorSolucaoGeral.Text,MaxInt);

  if pMelhorFitnessAtual < melhorFitnessEncontrado then
  begin
    edtMelhorSolucaoGeral.Text := IntToStr(pMelhorFitnessAtual);
  end;
end;

procedure TfrmPrincipal.ReiniciaEstatistica;
begin
  edtGeracaoAtual.Text := '0';
  edtMelhorSolucaoAtual.Text := '-';
  edtMelhorSolucaoGeral.Text := '-';
  
  antigoFitness := -1;
  geracaoParada := -1;
end;

procedure TfrmPrincipal.grpCondicaoParadaClick(Sender: TObject);
begin
  edtQtdGeracoes.Enabled := grpCondicaoParada.ItemIndex in [0,2];

  case grpCondicaoParada.ItemIndex of
    0: lblQtdGeracoes.Caption := 'Máx. de gerações:';
    2: lblQtdGeracoes.Caption := 'Qtd. de gerações:';
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  AG := TAlgoritmoGenetico.Create;
  AG.Fitness := FuncaoObjetivo;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  AG.Free;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  LimpaGrafico;
  btnReiniciarGrafico.Click; // inicia o gráfico
end;

procedure TfrmPrincipal.Janeladeresutlados1Click(Sender: TObject);
begin
  if Janeladeresutlados1.Checked then
  begin
    frmLogWindow.Show;
    frmLogWindow.Left := Self.Left + Self.Width;
    frmLogWindow.Top := Self.Top;
  end
  else
  begin
    frmLogWindow.Hide;
  end;
end;

procedure TfrmPrincipal.Sair1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.Sobre1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

end.
