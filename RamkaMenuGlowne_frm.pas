unit RamkaMenuGlowne_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects,
  FMX.Effects;

type
  TRamkaMenuGlowne = class(TFrame)
    Menu: TRectangle;
    btn_new_diagram: TButton;
    lbl_menu_name: TLabel;
    btn_close_menu: TButton;
    BlurEffect1: TBlurEffect;
    BackGround: TRectangle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
