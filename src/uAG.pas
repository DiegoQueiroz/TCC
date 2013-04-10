unit uAG;

interface

uses
  SysUtils, Dialogs;

const
  MAXNUM_RANDOM = 1000;

type
  TFitnessResult    = type Integer;
  TCromossomo       = type string;
  TCromossomoArray  = array of Integer;
  TPopulacao        = array of TCromossomo;

  // Lista encadeada utilizada para selecionar os melhores
  PAvaliacao = ^TAvaliacao;
  TAvaliacao = record
    Indice: Integer;
    Fitness: TFitnessResult;
    next: PAvaliacao;
  end;

  TAlgoritmoGenetico = class;
  FitnessProc = function(pAG: TAlgoritmoGenetico; pCrom: TCromossomo): TFitnessResult;

  TAlgoritmoGenetico = class
  private
    FTamanhoPopulacao: Integer;
    FFitness: FitnessProc;
    FTamanhoCromossomo: Integer;
    FTamanhoGene: Integer;
    FTaxaMutacao: Double;
    FTaxaCruzamento: Double;

    TamanhoSelecao: Integer;

    procedure SetTamanhoPopulacao(const Value: Integer);
    procedure SetTamanhoGene(const Value: Integer);
    procedure SetTaxaCruzamento(const Value: Double);
    procedure SetTaxaMutacao(const Value: Double);
  protected
    Populacao: TPopulacao;
    Selecao: TPopulacao;
    function CrossOver(C1, C2: TCromossomo): TCromossomo;
    function Mutacao(pCrom: TCromossomo): TCromossomo;
    function GeraIndividuo: TCromossomo;
    function GeraMascara(pTamanho: Integer; pProbabilidade: Double; out oMascara: string): Boolean;
  public
    constructor Create;

    function NovaGeracao: TCromossomo;
    function IniciaPopulacao: TCromossomo;
    function SelecionaMelhores: TPopulacao;

    function ConvertToArray(pCrom: TCromossomo): TCromossomoArray;

    property TamanhoCromossomo: Integer     read FTamanhoCromossomo write FTamanhoCromossomo;
    property TamanhoGene      : Integer     read FTamanhoGene       write SetTamanhoGene;    
    property TamanhoPopulacao : Integer     read FTamanhoPopulacao  write SetTamanhoPopulacao;
    property Fitness          : FitnessProc read FFitness           write FFitness;
    property TaxaMutacao      : Double      read FTaxaMutacao       write SetTaxaMutacao;
    property TaxaCruzamento   : Double      read FTaxaCruzamento    write SetTaxaCruzamento;
  published
  end;

implementation

uses StrUtils, Math, ufrmLogWindow, uFunc;

{ TAlgoritmoGenetico }

function TAlgoritmoGenetico.ConvertToArray(pCrom: TCromossomo): TCromossomoArray;
var
  i: Integer;
  GeneStr: string;
begin
  SetLength(Result,FTamanhoCromossomo);

  for i:=0 to FTamanhoCromossomo-1 do
  begin
    GeneStr := Copy(pCrom,i*FTamanhoGene+1,FTamanhoGene);
    Result[i] := BinToDec(GeneStr);
  end;
end;

constructor TAlgoritmoGenetico.Create;
begin
  inherited Create;

  FTaxaMutacao       := 0.0;  // sem mutação
  FTaxaCruzamento    := 0.9;  // 90% de cruzamento
  FTamanhoPopulacao  := 0;  // população inicial de 0
  SetLength(Populacao,FTamanhoPopulacao);
end;

function TAlgoritmoGenetico.CrossOver(C1, C2: TCromossomo): TCromossomo;
const
  PROBABILIDADE = 0.5;
var
  mascara: string;
  num, i: Integer;
  pCrom: string;
begin
  num := Trunc(Random * MAXNUM_RANDOM);

  if num < (MAXNUM_RANDOM * FTaxaCruzamento) then
  begin
    GeraMascara(FTamanhoCromossomo,PROBABILIDADE,mascara);

    // este indivíduo aleatório será utilizado para fazer o cruzamento dos indivíduos

  // C1        = 101 010 101 010 - 101 010 101 010
  //                  |   |   |             |         >---|
  // mascara   =  1   0   0   0     1   1   0   1         |
  //              |                 |   |       |     >---|
  // C2        = 111 000 001 100 - 001 010 110 001        |
  //                                                      |
  // Resultado = 111 000 101 010 - 001 010 101 001  <-----|

    Result := '';
    for i:=1 to FTamanhoCromossomo do
    begin
      pCrom := IfThen(mascara[i]='0',C1,C2);

      Result := Result + Copy(pCrom,(i-1)*FTamanhoGene+1,FTamanhoGene);
    end;
  //  ShowMessage(C1 + #13#10 + C2 + #13#10 + mascara + #13#10#13#10 + Result);
  end
  else
  begin
    num := Trunc(Random * MAXNUM_RANDOM);

    Result := IfThen(num >= (MAXNUM_RANDOM * 0.5),C1,C2);
  end;
end;

function TAlgoritmoGenetico.GeraIndividuo: TCromossomo;
const
  PROBABILIDADE = 0.5;
var
  i, quantBits: Integer;
  num: Integer;
begin
  quantBits := FTamanhoCromossomo * FTamanhoGene;

  Result := '';
  for i:=1 to quantBits do
  begin
    num := Trunc(Random * MAXNUM_RANDOM);

    Result := Result + IfThen(num >= (MAXNUM_RANDOM * PROBABILIDADE),'0','1');
  end;
end;

function TAlgoritmoGenetico.GeraMascara(pTamanho: Integer;
  pProbabilidade: Double; out oMascara: string): Boolean;
var
  i, num: Integer;
begin
  Result := False;
  oMascara := '';

  for i:=1 to pTamanho do
  begin
    num := Trunc(Random * MAXNUM_RANDOM);

    if num >= (MAXNUM_RANDOM * pProbabilidade) then
    begin
      oMascara := oMascara + '0';
    end
    else
    begin
      oMascara := oMascara + '1';
      Result := True;
    end;
  end;

end;

function TAlgoritmoGenetico.IniciaPopulacao: TCromossomo;
var
  i: Integer;
begin
  SetLength(Populacao,FTamanhoPopulacao);
  for i:=0 to FTamanhoPopulacao-1 do
  begin
    Populacao[i] := GeraIndividuo;
  end;

  Selecao := SelecionaMelhores;
  Result  := Selecao[0]; 

//  LogMe('>>> População iniciada!');
end;

function TAlgoritmoGenetico.Mutacao(pCrom: TCromossomo): TCromossomo;
var
  i, quantBits: Integer;
  mascara: string;
begin
  Result := '';
  quantBits := FTamanhoCromossomo * FTamanhoGene;

  if GeraMascara(quantBits,FTaxaMutacao,mascara) then
  begin
    for i:=1 to quantBits do
    begin
      Result := Result + IfThen(mascara[i]='0',pCrom[i],IfThen(pCrom[i]='0','1','0'));
    end;
  end;
end;

function TAlgoritmoGenetico.NovaGeracao: TCromossomo;
var
  i: Integer;
begin
  for i:=0 to FTamanhoPopulacao-1 do
  begin
    Populacao[i] := CrossOver(Selecao[RandomRange(0,tamanhoSelecao)],Selecao[RandomRange(0,tamanhoSelecao)]);
    Populacao[i] := Mutacao(Populacao[i]);
  end;

  Selecao := SelecionaMelhores;
  Result  := Selecao[0];    
end;

function TAlgoritmoGenetico.SelecionaMelhores: TPopulacao;
const
  PERCENT_POPULACAO = 10;
var
  i, j: Integer;
  avaliacao, reg, prev, novoreg: PAvaliacao;
begin
  TamanhoSelecao := Round(FTamanhoPopulacao * (1 / PERCENT_POPULACAO));
  avaliacao := nil;

  for i:=0 to FTamanhoPopulacao-1 do
  begin
    New(novoreg);
    novoreg^.next := nil;
    novoreg^.Indice := i;
    novoreg^.Fitness := Fitness(Self,Populacao[i]);

    if avaliacao = nil then
    begin
      avaliacao := novoreg;
    end
    else
    begin
      reg := avaliacao;
      prev := nil;
      
      j := 0;
      while j < tamanhoSelecao do
      begin
        if reg^.Fitness >= novoreg^.Fitness then // insere novoreg antes do registro
        begin
          novoreg^.next := reg;
          if prev = nil then
          begin
            avaliacao := novoreg;
          end
          else
          begin
            prev^.next := novoreg;
          end;

          Break;
        end;

        if reg^.next <> nil then
        begin
          prev := reg;
          reg := reg^.next;
        end
        else
        begin
          reg^.next := novoreg; // novoreg passa a ser o último registro
          Break;
        end;

        Inc(j);
      end;

      if j = tamanhoSelecao then // registro não inserido
      begin
        Dispose(novoreg); // joga registro fora
      end
      else
      begin
        prev := nil;
        reg := avaliacao;

        j := 0;
        while (j < tamanhoSelecao) and (reg <> nil) do
        begin
          prev := reg;
          reg := reg^.next;
          Inc(j);
        end;

        if reg <> nil then
        begin
          prev^.next := nil;

          while reg <> nil do
          begin
            prev := reg^.next;
            Dispose(reg);

            reg := prev;
          end;
        end;
      end;
    end;
  end;

  j := 0;
  SetLength(Result,j);

  reg := avaliacao;
  while reg <> nil do
  begin
    j := j + 1;
    SetLength(Result,j);

    Result[j-1] := Populacao[reg^.Indice];

    prev := reg;
    reg := reg^.next;
    
    Dispose(prev); // libera memória da lista
  end;

end;

procedure TAlgoritmoGenetico.SetTamanhoGene(const Value: Integer);
begin
  if FTamanhoGene <> Value then
  begin
    FTamanhoGene := Value;
  end;
//  LogMe('Tamanho Gene      : %d',[FTamanhoGene],True);
end;

procedure TAlgoritmoGenetico.SetTamanhoPopulacao(const Value: Integer);
begin
  if FTamanhoPopulacao <> Value then
  begin
    FTamanhoPopulacao := Value;
    SetLength(Populacao,FTamanhoPopulacao);
  end;
//  LogMe('Tamanho População : %d',[FTamanhoPopulacao],True);
end;

procedure TAlgoritmoGenetico.SetTaxaCruzamento(const Value: Double);
begin
  if FTaxaCruzamento <> Value then
  begin
    FTaxaCruzamento := Value;
  end;
//  LogMe('Taxa de Cruzamento: %2.2f',[FTaxaCruzamento],True);
end;

procedure TAlgoritmoGenetico.SetTaxaMutacao(const Value: Double);
begin
  if FTaxaMutacao <> Value then
  begin
    FTaxaMutacao := Value;
  end;
//  LogMe('Taxa de Mutação   : %2.2f',[FTaxaMutacao],True);
end;

end.

