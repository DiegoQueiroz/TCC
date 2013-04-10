unit uFunc;

interface

uses
  SysUtils, Types;

type
  TTipoRota = (trSobrepostas = -2, trConcorrentes = -1 , trConcorrentesNaoConflitantes = 1, trParalelas = 2);

  TFloatPoint = record
    X: Double;
    Y: Double;
  end;

  TRota = record
    Origem, Destino: Integer;
  end;
  TConjuntoRota = array of TRota;

  TReta = record
    a, b, c: Double;
    // a*x + b*y + c = 0
    //  ONDE:
    //    a = ( y1 - y2 )
    //    b = ( x2 - x1 )
    //    c = ( x1 * y2 - x2 * y1 )

    Origem, Destino: TFloatPoint;
    // pontos de restri��o da reta
  end;  

function Rota(pOrigem, pDestino: Integer): TRota;
function FloatPoint(X, Y: Double): TFloatPoint;
function BinToDec(pBin: string): Integer;
function PontosIguais(P1, P2: TFloatPoint): Boolean;
function PontoInterno(P1, P2, PTeste: TFloatPoint): Boolean;
function PontoColisao(reta1, reta2: TReta): TTipoRota;
function FloatPointInRect(const Rect: TRect; const P: TFloatPoint): Boolean;
function RetasEquivalentes(const reta1, reta2: TReta): Boolean;

implementation

uses ufrmLogWindow;

function FloatPointInRect(const Rect: TRect; const P: TFloatPoint): Boolean;
begin
  Result :=
    (P.X >= Rect.Left  ) and
    (P.X <  Rect.Right ) and
    (P.Y >= Rect.Top   ) and
    (P.Y <  Rect.Bottom);
end;

function RetasEquivalentes(const reta1, reta2: TReta): Boolean;
begin
  // esta fun��o s� deve ser chamado para analisar retas que j� foram
  // identificadas como paralelas

  Result := ((reta1.a * reta2.c) = (reta2.a * reta1.c)) and ((reta1.b * reta2.c) = (reta2.b * reta1.c));
end;

function PontoColisao(reta1, reta2: TReta): TTipoRota;
var
  pontoAux: TFloatPoint;
begin
  try
    // condi��es
    //    se A = 0
    //    --------> reta paralela ao eixo X
    //    se B = 0
    //    --------> reta paralala ao eixo Y
    //    se C = 0
    //    --------> reta que cruza a origem

    // coeficiente angular = -a / b

    // identifica se as retas s�o paralelas
    if (reta1.a * reta2.b) = (reta2.a * reta1.b) then
    begin
      // as retas s�o paralelas
      // verifica se elas n�o est�o no mesmo lugar do plano (retas iguais)

      if RetasEquivalentes(reta1,reta2) then // s�o a mesma reta!!!
      begin
        // identifica se os pontos de uma reta est�o dentro do intervalo
        // da outra reta ou se s�o a mesma rota

        if
          PontoInterno(reta1.Origem,reta1.Destino,reta2.Origem)
          or
          PontoInterno(reta1.Origem,reta1.Destino,reta2.Destino)
        then
        begin
          // as rotas se sobrep�e ou s�o iguais
          Result := trSobrepostas;
        end
        else
        begin
          // as retas s�o iguais mas n�o se sobrep�e, isto �, s�o paralelas
          Result := trParalelas;
        end;
      end
      else
      begin
        // retas paralelas em regi�es diferentes do plano
        Result := trParalelas;
      end;
    end
    else
    begin
      // retas concorrentes
      // encontra ponto de colis�o

      pontoAux.X := (reta2.b * reta1.c - reta1.b * reta2.c) / (reta2.a * reta1.b - reta1.a * reta2.b);
      pontoAux.Y := (reta2.a * reta1.c - reta1.a * reta2.c) / (reta1.a * reta2.b - reta2.a * reta1.b);

      // define se o ponto de colis�o est� dentro da rota das duas aeronaves
      if
        PontoInterno(reta1.Origem,reta1.Destino,pontoAux)
        and
        PontoInterno(reta2.Origem,reta2.Destino,pontoAux)
      then
      begin
        // existe um ponto de colis�o entre as rotas
        Result := trConcorrentes;
      end
      else
      begin
        // n�o existe um ponto de colis�o entre as rotas
        Result := trConcorrentesNaoConflitantes;
      end;

    end;
  except
    on E: Exception do
    begin
      LogMe('Exce��o encontrada na procura do ponto de colis�o! (%s)',[e.ClassName]);
      LogMe('a1 = %2.2f / a2 = %2.2f',[reta1.a,reta2.a]);
      LogMe('b1 = %2.2f / b2 = %2.2f',[reta1.b,reta2.b]);
      LogMe('c1 = %2.2f / c2 = %2.2f',[reta1.c,reta2.c]);

      Result := trParalelas;
      Abort;
    end;
  end;
end;


function PontoInterno(P1, P2, PTeste: TFloatPoint): Boolean;
begin
  Result :=
    ((P1.X >= PTeste.X) and (PTeste.X >= P2.X) or (P2.X >= PTeste.X) and (PTeste.X >= P1.X))
    and
    ((P1.Y >= PTeste.Y) and (PTeste.Y >= P2.Y) or (P2.Y >= PTeste.Y) and (PTeste.Y >= P1.Y));
end;

function PontosIguais(P1, P2: TFloatPoint): Boolean;
begin
  Result := (P1.X = P2.X) and (P1.Y = P2.Y);
end;

function Rota(pOrigem, pDestino: Integer): TRota;
begin
  Result.Origem := pOrigem;
  Result.Destino := pDestino;
end;

function BinToDec(pBin: string): Integer;
var
  i: Integer;
begin
  Result := 0;

  for i:=Length(pBin) downto 1 do
  begin
    case pBin[i] of
      '0':; // faz nada
      '1': Result := Result or ( 1 shl (Length(pBin)-i) );
      else raise Exception.Create('N�mero bin�rio inv�lido!!!');
    end;
  end;

end;

function FloatPoint(X, Y: Double): TFloatPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

end.


