program FMXDiagramDesigner;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm_frm in 'MainForm_frm.pas' {AOknoGl},
  RamkaEdycjaProcesu_frm in 'RamkaEdycjaProcesu_frm.pas' {RamkaEdycjaProcesu: TFrame},
  RamkaMenuGlowne_frm in 'RamkaMenuGlowne_frm.pas' {RamkaMenuGlowne: TFrame},
  RamkaPowiazanie_frm in 'RamkaPowiazanie_frm.pas' {RamkaPowiazanie: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TAOknoGl, AOknoGl);
  Application.Run;
end.
