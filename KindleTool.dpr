program KindleTool;

uses
  Forms,
  f_fmMain in 'f_fmMain.pas' {Form3},
  md5 in 'md5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
