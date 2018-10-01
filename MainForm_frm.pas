unit MainForm_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ExtCtrls, FMX.Objects, FMX.Effects,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TAOknoGl = class(TForm)
    WzorObiektu: TRectangle;
    Tlo: TImage;
    btn_new_process: TButton;
    Wzor_label: TLabel;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Rectangle2: TRectangle;
    Label2: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure WzorObiektuMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure WzorObiektuMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure WzorObiektuMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure btn_new_processClick(Sender: TObject);
    procedure Wzor_labelDblClick(Sender: TObject);
    procedure Wzor_labelTap(Sender: TObject; const Point: TPointF);
    procedure Deaktywuj_obiekt;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
 wersja = '0.1.0';
 data_kompilacji = '2018-09-30';

var
  AOknoGl: TAOknoGl;
  MouseIsDown: Boolean;
  X1, Y1: Integer;
  wybrany: TRectangle;
  label_wybranego: Integer;

implementation

{$R *.fmx}

procedure TAOknoGl.btn_new_processClick(Sender: TObject);
Var
 tmp : TRectangle;
 i : Integer;
begin
 tmp := TRectangle(WzorObiektu.Clone(self));
 tmp.Parent := self;
 tmp.Visible:=True;
 tmp.Position.X:=10;
 tmp.Position.Y:=10;
 tmp.OnMouseDown:=WzorObiektuMouseDown;
 tmp.OnMouseMove:=WzorObiektuMouseMove;
 tmp.OnMouseUp:=WzorObiektuMouseUp;
 tmp.OnDblClick:=Wzor_labelDblClick;
 tmp.OnTap:=Wzor_labelTap;
 for i := 0 to tmp.ChildrenCount-1 do
  Begin
   if tmp.Children[i] is TLabel then
    Begin
     TLabel(tmp.Children[i]).Text:='Nowy proces';
    End;
  End;
end;

procedure TAOknoGl.FormCreate(Sender: TObject);
begin
 Caption:='FMX Diagram Designer - wersja: '+wersja;
 MouseIsDown := False;
 WzorObiektu.Visible:=False;
end;

procedure TAOknoGl.WzorObiektuMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  wybrany:=TRectangle(Sender);
  wybrany.BringToFront;
  X1 := round(X);
  Y1 := round(Y);
  wybrany.Fill.Color:=TAlphaColor($AA7A0707);
  MouseIsDown := True;
end;

procedure TAOknoGl.WzorObiektuMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
 if MouseIsDown then
  begin
    wybrany.Position.X := wybrany.Position.X + round(X) - X1;
    wybrany.Position.Y := wybrany.Position.Y + round(Y) - Y1;
  end;
end;

procedure TAOknoGl.Button1Click(Sender: TObject);
var
 Brush : TStrokeBrush;
begin
Brush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.Azure);
  Brush.Thickness := 2;
  with Canvas do
  begin
    BeginScene();
    DrawLine(PointF(10, 10), PointF(100, 10), 1, Brush);
    EndScene;
  end;
 Brush.Free;
end;

procedure TAOknoGl.Deaktywuj_obiekt;
Begin
 MouseIsDown := False;
 wybrany.Fill.Color:=TAlphaColor($AA0F077A);
End;

procedure TAOknoGl.WzorObiektuMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
 Deaktywuj_obiekt;
end;

procedure TAOknoGl.Wzor_labelDblClick(Sender: TObject);
var
  i: Integer;
begin
 for i := 0 to wybrany.ChildrenCount-1 do
  Begin
   if wybrany.Children[i] is TLabel then
    Begin
     TLabel(wybrany.Children[i]).Text:=InputBox('WprowadŸ nazwê procesu','Nazwa:',TLabel(wybrany.Children[i]).Text);
    End;
  End;
  Deaktywuj_obiekt;
end;

procedure TAOknoGl.Wzor_labelTap(Sender: TObject; const Point: TPointF);
var
  i: Integer;
begin
  for i := 0 to wybrany.ChildrenCount - 1 do
  Begin
    if wybrany.Children[i] is TLabel then
    Begin
     label_wybranego:=i;
      InputBox('WprowadŸ nazwê procesu:', '', TLabel(wybrany.Children[i]).Text,
        procedure(const AResult: TModalResult; const AValue: string)
        begin
          case AResult of
            { Detect which button was pushed and show a different message }
            mrOk:
              begin
                // AValue is the result of the inputbox dialog
                TLabel(wybrany.Children[label_wybranego]).Text:=AValue;
              end;
            mrCancel:
              begin
              end;
          end;
        end);

    End;
  End;
  Deaktywuj_obiekt;
end;

end.
