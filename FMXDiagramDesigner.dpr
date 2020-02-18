program FMXDiagramDesigner;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm_frm in 'MainForm_frm.pas' {MainForm},
  ProcessEditingFrame_frm in 'ProcessEditingFrame_frm.pas' {ProcessEditingFrame: TFrame},
  MainMenuFrame_frm in 'MainMenuFrame_frm.pas' {MainMenuFrame: TFrame},
  LinkageFrame_frm in 'LinkageFrame_frm.pas' {LinkageFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
