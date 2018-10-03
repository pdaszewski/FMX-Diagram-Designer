unit RamkaEdycjaProcesu_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects,
  FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.Effects;

type
  TRamkaEdycjaProcesu = class(TFrame)
    Menu: TRectangle;
    Label1: TLabel;
    btn_save_process_data: TButton;
    memo_process_name: TMemo;
    BackGround: TRectangle;
    BlurEffect1: TBlurEffect;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses MainForm_frm;

end.
