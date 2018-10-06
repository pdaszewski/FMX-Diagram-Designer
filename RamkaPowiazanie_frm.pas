unit RamkaPowiazanie_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Effects,
  FMX.Objects, FMX.Layouts;

type
  TRamkaPowiazanie = class(TFrame)
    BackGround: TRectangle;
    BlurEffect1: TBlurEffect;
    Menu: TRectangle;
    lbl_menu_name: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    btn_add: TButton;
    but_cancel: TButton;
    od_procesu: TRectangle;
    do_procesu: TRectangle;
    lbl_od_procesu: TLabel;
    lbl_do_procesu: TLabel;
    rec_do: TRectangle;
    img_do: TImage;
    rec_od: TRectangle;
    img_od: TImage;
    WzorLinii: TLine;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
