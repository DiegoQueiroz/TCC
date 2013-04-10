program Modelo1;

uses
  Forms,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  uAG in 'uAG.pas',
  uAeronave in 'uAeronave.pas',
  uFunc in 'uFunc.pas',
  ufrmLogWindow in 'ufrmLogWindow.pas' {frmLogWindow},
  ufrmSobre in 'ufrmSobre.pas' {AboutBox};

{$R *.res}

begin
//  ReportMemoryLeaksOnShutdown := True;
  Randomize;
  
  Application.Initialize;
  Application.Title := 'Modelo Aeronaves';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmLogWindow, frmLogWindow);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
