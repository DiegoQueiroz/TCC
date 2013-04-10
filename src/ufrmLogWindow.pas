unit ufrmLogWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmLogWindow = class(TForm)
    log: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  frmLogWindow: TfrmLogWindow;

procedure LogMe(txt: string = ''; pShowHided: Boolean = False); overload;
procedure LogMe(txt: string; args: array of const; pShowHided: Boolean = False); overload;
procedure LogMe(num: Integer; pShowHided: Boolean = False); overload;
procedure LimpaLog;

implementation

uses ufrmPrincipal;

{$R *.dfm}

procedure LogMe(txt: string; pShowHided: Boolean);
begin
  if pShowHided or frmLogWindow.Visible then
    frmLogWindow.log.Lines.Append(txt);
end;

procedure LogMe(txt: string; args: array of const; pShowHided: Boolean = False);
begin
  LogMe(Format(txt,args),pShowHided);
end;

procedure LogMe(num: Integer; pShowHided: Boolean = False);
begin
  LogMe(IntToStr(num),pShowHided);
end;

procedure LimpaLog;
begin
  frmLogWindow.log.Clear;
end;

procedure TfrmLogWindow.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogWindow.Button2Click(Sender: TObject);
begin
  LimpaLog;
end;

end.
