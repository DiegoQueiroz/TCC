unit uAeronave;

interface

uses uAG, uFunc;

const
  MAIORPONTO = 100; // os pontos sorteados serão menor que este ponto
  DISTANCIAPONTOS = 2;

var
  pontos: array of TFloatPoint;
  rotas: TConjuntoRota;
  quantRotas, quantPontos: Integer;

procedure CriaPontos(pQuantidade: Integer);
procedure CriaRotas(pQuantidade: Integer);
function FuncaoObjetivo(pAG: TAlgoritmoGenetico; pCrom: TCromossomo): TFitnessResult;
function ExtraiRetasCromossomo(pAG: TAlgoritmoGenetico; pCrom: TCromossomo): TConjuntoRota;

implementation

uses
  Math, ufrmLogWindow, Types;

procedure CriaPontos(pQuantidade: Integer);
var
  i, j: Integer;
  tempPonto: TFloatPoint;
  pontoValido: Boolean;
begin
  quantPontos := pQuantidade;
  SetLength(pontos,quantPontos);
  for i:=0 to quantPontos-1 do
  begin
    repeat
      tempPonto := FloatPoint(Random(MAIORPONTO),Random(MAIORPONTO));

      pontoValido := True;      
      for j:=0 to i-1 do
      begin
        if FloatPointInRect(
          Rect(Round(pontos[j].X)-DISTANCIAPONTOS,Round(pontos[j].Y)-DISTANCIAPONTOS,Round(pontos[j].X)+DISTANCIAPONTOS,Round(pontos[j].Y)+DISTANCIAPONTOS),
          tempPonto
        ) then
        begin
          pontoValido := False;
        end;
      end;

    until pontoValido;

    pontos[i] := tempPonto;
  end;
end;

procedure CriaRotas(pQuantidade: Integer);
var
  i, j: Integer;
  a, b: Integer;
  tempRota: TRota;
  rotaNaoExistente: Boolean;
begin
  quantRotas := pQuantidade;

  SetLength(rotas,quantRotas);
  for i:=0 to quantRotas-1 do
  begin
    repeat
      a := RandomRange(0,quantPontos);
      repeat
        b := RandomRange(0,quantPontos);
      until b <> a;

      tempRota := Rota(a,b);

      rotaNaoExistente := True;
      for j:=0 to i-1 do
      begin
        if (tempRota.Origem = rotas[j].Origem)
        or (tempRota.Origem = rotas[j].Destino)
        or (tempRota.Destino = rotas[j].Origem)
        or (tempRota.Destino = rotas[j].Destino)
        then
        begin
          rotaNaoExistente := False;
        end;
      end;

    until rotaNaoExistente;

    rotas[i] := tempRota;
  end;
end;

function ExtraiRetasCromossomo(pAG: TAlgoritmoGenetico; pCrom: TCromossomo): TConjuntoRota;
var
  i, aeronave, voo: Integer; // variáveis indice
  tamanhoPedaco: Integer; // tamanho do cromossomo que corresponde a uma aeronave
  quantAeronaves: Integer;
  cromArray: TCromossomoArray;
  quantRotasCromossomo: Integer;
  Inicio, Fim, Origem, Destino, pontoTeste: Integer;
  passoInicial, passoFinal: Integer;
begin
  quantAeronaves := quantRotas;
  cromArray := pAG.ConvertToArray(pCrom);

  tamanhoPedaco := pAG.TamanhoCromossomo div quantAeronaves;

  quantRotasCromossomo := 0;
  SetLength(Result,quantRotasCromossomo);

  for aeronave:=0 to quantAeronaves-1 do
  begin
    Inicio  := rotas[aeronave].Origem;
    Fim     := rotas[aeronave].Destino;

    passoInicial := tamanhoPedaco*aeronave;
    passoFinal   := tamanhoPedaco*(aeronave+1);

    voo := passoInicial;
    while voo <= passoFinal do
    begin
      if voo = passoInicial then // primeiro voo sempre parte do ponto inicial
      begin
        Origem := Inicio;
      end
      else
      begin
        Origem := cromArray[voo-1];
      end;

      if voo = passoFinal then // último voo sempre vai para o ponto final
      begin
        Destino := Fim;
      end
      else
      begin
        if cromArray[voo] < Length(pontos) then
        begin
          Destino := cromArray[voo];
        end
        else
        begin
          Destino := Inicio;
            // faz com que o próximo loop seja ativado e o ponto de destino
            // se torne o Ponto Final
        end;

        // destino NÃO pode ser igual a origem ou a qualquer outro ponto já
        // visitado nestes casos o próximo ponto se torna o ponto final
        for i:=passoInicial to voo+1 do
        begin
          if i = passoInicial then
            pontoTeste := Inicio
          else if i = (voo+1) then
            pontoTeste := Fim
          else
            pontoTeste := cromArray[i-1];

          if Destino = pontoTeste then
          begin
            Destino := Fim;
            voo := passoFinal;

            Break;
          end;
        end;
      end;

      // neste ponto eu tenho garantia que os pontos não são iguais
      // e que o destino não é igual a nenhum ponto já visitado

      // agora eu cadastro as rotas
      quantRotasCromossomo := quantRotasCromossomo + 1;
      SetLength(Result,quantRotasCromossomo);

      // calculo os coeficiente das retas

      Result[quantRotasCromossomo-1].Origem := Origem;
      Result[quantRotasCromossomo-1].Destino := Destino;

      // reta cadastrada
      // passa para o próximo ponto

      voo := voo + 1; // passa para o próximo voo
    end;
  end;
end;

function FuncaoObjetivo(pAG: TAlgoritmoGenetico; pCrom: TCromossomo): TFitnessResult;
var
  i, j, k, l, aeronave, voo: Integer; // variáveis indice
  tamanhoPedaco: Integer; // tamanho do cromossomo que corresponde a uma aeronave
  quantAeronaves: Integer;
  cromArray: TCromossomoArray;
  retas: array of array of TReta;
  quantRetas: Integer;
  Inicio, Fim, Origem, Destino, pontoTeste: TFloatPoint;
  passoInicial, passoFinal: Integer;
begin
  Result := 0;

  quantAeronaves := quantRotas;

  cromArray := pAG.ConvertToArray(pCrom);

//  txt := '';
//  for i:=0 to Length(cromArray)-1 do
//  begin
//    txt := txt + Format('%*d',[pAG.TamanhoGene,cromArray[i]]);
//  end;
//
//  frmPrincipal.LogMe('--> Função Objetivo');
//  frmPrincipal.LogMe('pCrom = %s',[pCrom]);
//  frmPrincipal.LogMe('pCrom = %s',[txt]);
//  frmPrincipal.LogMe('***');

  // 1) descobrir todas as rotas (cada rota é uma função de reta (a e b)
  // 2) descobrir o X de colisão de todas as rotas com todas as rotas
  // 3) quantizar os conflitos reais (veriricar se o X de colisão encontra-se no meio de alguma rota)

  ///// INICIO DO ALGORITMO

  // 1) descobrir todas as rotas (cada rota é uma função de reta (a e b)
  SetLength(retas,quantAeronaves);
  
  tamanhoPedaco := pAG.TamanhoCromossomo div quantAeronaves;

  for aeronave:=0 to quantAeronaves-1 do
  begin
    quantRetas := 0;
    SetLength(retas[aeronave],quantRetas);

    Inicio  := pontos[rotas[aeronave].Origem];
    Fim     := pontos[rotas[aeronave].Destino];

    passoInicial := tamanhoPedaco*aeronave;
    passoFinal   := tamanhoPedaco*(aeronave+1);

    voo := passoInicial;
    while voo <= passoFinal do
    begin
      if voo = passoInicial then // primeiro voo sempre parte do ponto inicial
      begin
        Origem := Inicio;
      end
      else
      begin
        Origem := pontos[cromArray[voo-1]];
      end;

      if voo = passoFinal then // último voo sempre vai para o ponto final
      begin
        Destino := Fim;
      end
      else
      begin
        if cromArray[voo] < Length(pontos) then
        begin
          Destino := pontos[cromArray[voo]];
        end
        else
        begin
          Destino := Inicio;
            // faz com que o próximo loop seja ativado e o ponto de destino
            // se torne o Ponto Final
        end;

        // destino NÃO pode ser igual a origem ou a qualquer outro ponto já
        // visitado nestes casos o próximo ponto se torna o ponto final
        for i:=passoInicial to voo+1 do
        begin
          if i = passoInicial then
            pontoTeste := Inicio
          else if i = (voo+1) then
            pontoTeste := Fim
          else
            pontoTeste := pontos[cromArray[i-1]];

          if PontosIguais(Destino,pontoTeste) then
          begin
            Destino := Fim;
            voo := passoFinal;

            Break;
          end;
        end;
      end;

      // neste ponto eu tenho garantia que os pontos não são iguais
      // e que o destino não é igual a nenhum ponto já visitado

      // agora eu cadastro as rotas
      quantRetas := quantRetas + 1;
      SetLength(retas[aeronave],quantRetas);

      // calculo os coeficiente das retas

      retas[aeronave][quantRetas-1].a := Origem.Y - Destino.Y;
      retas[aeronave][quantRetas-1].b := Destino.X - Origem.X;
      retas[aeronave][quantRetas-1].c := Origem.X * Destino.Y - Destino.X * Origem.Y;

      retas[aeronave][quantRetas-1].Origem := Origem;
      retas[aeronave][quantRetas-1].Destino := Destino;

      // reta cadastrada
      // passa para o próximo ponto

      voo := voo + 1; // passa para o próximo voo
    end;
  end;

  // 2) descobrir o X de colisão de todas as rotas com todas as rotas

    // Considerações:
    // * não há porque analisar a colisão das retas da mesma nave
    // *

  // comparar todas as rotas com todas as rotas
  for j:=0 to quantAeronaves-2 do
  begin
    for i:=j+1 to quantAeronaves-1 do
    begin
//      frmPrincipal.LogMe('j(origem)=%d - i(destino)=%d',[j,i]);

      for k:=0 to Length(retas[j])-1 do
      begin
        for l:=0 to Length(retas[i])-1 do
        begin
//          frmPrincipal.LogMe(' ---- k(rota1)=%d - l(rota2)=%d',[k,l]);
          //

          // j = aeronave origem
          // i = aeronave destino

          // k = reta da aeronave origem
          // l = reta da aeronave destino

          // reta 1 = retas[j][k]
          // reta 2 = retas[i][l]

          // 3) quantizar os conflitos reais (veriricar se o X de colisão encontra-se no meio de alguma rota)

//          case PontoColisao(retas[j][k],retas[i][l]) of
//            trSobrepostas:
//              frmPrincipal.LogMe('Sobrepostas');
//            trConcorrentes:
//              frmPrincipal.LogMe('Concorrentes');
//            trConcorrentesNaoConflitantes:
//              frmPrincipal.LogMe('Não conflitantes');
//            trParalelas:
//              frmPrincipal.LogMe('Paralelas');
//          end;

          case PontoColisao(retas[j][k],retas[i][l]) of
            trSobrepostas: Result := Result + 2;
            trConcorrentes: Result := Result + 1;
          end;

        end;
      end;
    end;
  end;
end;

end.
