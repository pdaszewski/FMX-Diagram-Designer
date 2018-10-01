program FMXDiagramDesigner;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm_frm in 'MainForm_frm.pas' {AOknoGl};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAOknoGl, AOknoGl);
  Application.Run;
end.
