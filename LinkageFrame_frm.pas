unit LinkageFrame_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Effects,
  FMX.Objects, FMX.Layouts;

type
  TLinkageFrame = class(TFrame)
    BackGround: TRectangle;
    BlurEffect1: TBlurEffect;
    Menu: TRectangle;
    lbl_menu_name: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    btn_add: TButton;
    but_cancel: TButton;
    from_process_rectangle: TRectangle;
    to_process_rectangle: TRectangle;
    lbl_od_procesu: TLabel;
    lbl_do_procesu: TLabel;
    rec_to: TRectangle;
    img_do: TImage;
    rec_from: TRectangle;
    img_od: TImage;
    LinePattern: TLine;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
