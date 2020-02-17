unit MainForm_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ExtCtrls, FMX.Objects, FMX.Effects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, ProcessEditingFrame_frm, FMX.ScrollBox, FMX.Memo,
  MainMenuFrame_frm, FMX.MaterialSources, System.ImageList, FMX.ImgList, LinkageFrame_frm;

type
  diagram_object = record
    id_object: Integer;
    indicator: TRectangle;
  end;

type
  object_link = record
    from_object: Integer;
    to_object: Integer;
    from_arrow: Boolean;
    to_arrow: Boolean;
    arrow_image_from: TImage;
    arrow_image_to: TImage;
    text_line_1: TLine;
    text_line_2: TLine;
    text_line_3: TLine;
  end;

type
  point_of_contact = record
    x: Single;
    y: Single;
  end;

type
  TAOknoGl = class(TForm)
    Tlo: TImage;
    GridGlowny: TGridPanelLayout;
    GridMenuGornego: TGridPanelLayout;
    btn_hamburger: TButton;
    btn_dodaj_nowy_proces: TButton;
    ScrollBox: TScrollBox;
    LinePattern: TLine;
    ObjectPattern: TRectangle;
    LabelPattern: TLabel;
    RamkaEdycjaProcesu1: TProcessEditingFrame;
    DrawingTimer: TTimer;
    RamkaMenuGlowne1: TMainMenuFrame;
    ArrowsPattern: TImage;
    btn_laczenie_procesow: TButton;
    RamkaPowiazanie1: TLinkageFrame;
    lbl_bottom_info: TLabel;
    SaveProjectDialog: TSaveDialog;
    OpenProjectDialog: TOpenDialog;

    procedure Deaktywuj_obiekt;
    procedure Czysc_obiekty_i_powiazania;
    function Ostatni_obiekt: Integer;
    procedure Dodaj_wskaznik(proces: TRectangle; index_procesu: Integer);
    procedure Rysuj_powiazania;
    procedure Rysuj_powiazanie(od_obiektu, do_obiektu: Integer; od_strzalka, do_strzalka: Boolean; linia, linia2, linia3: TLine; strzalka_od, strzalka_do: TImage);
    procedure Dodaj_powiazanie(od_obiektu_index, do_obiektu_index: Integer; od_strzalka, do_strzalka: Boolean);
    procedure Usun_powiazanie(od_obiektu_index, do_obiektu_index: Integer);
    procedure DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
    procedure Edycja_danych_procesu;
    function Ktore_powiazanie(od_obiektu, do_obiektu: TRectangle): Integer;
    function Ktory_obiekt(obiekt: TRectangle): Integer;
    procedure Zmien_styl_linii(nowy_styl : TStrokeDash);

    procedure Czysc_punkty_styku;
    procedure Dodaj_punkt_styku(x, y: Single);
    function Czy_juz_jest_tu_punkt_styku(x, y: Single): Boolean;

    procedure Odznacz_wybrane(pierwszy, drugi: Boolean);
    procedure Ustaw_strzalke_powiazania(strzalka: String);
    function Wartosc_XML(rekord: string): String;

    procedure FormCreate(Sender: TObject);
    procedure ObjectPatternMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
    procedure ObjectPatternMouseMove(Sender: TObject; Shift: TShiftState; x, y: Single);
    procedure ObjectPatternMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
    procedure LabelPatternDblClick(Sender: TObject);
    procedure LabelPatternTap(Sender: TObject; const Point: TPointF);
    procedure btn_dodaj_nowy_procesClick(Sender: TObject);
    procedure btn_hamburgerClick(Sender: TObject);
    procedure RamkaEdycjaProcesu1btn_save_process_dataClick(Sender: TObject);
    procedure DrawingTimerTimer(Sender: TObject);
    procedure RamkaMenuGlowne1btn_new_diagramClick(Sender: TObject);
    procedure RamkaMenuGlowne1btn_close_menuClick(Sender: TObject);
    procedure RamkaPowiazanie1but_cancelClick(Sender: TObject);
    procedure btn_laczenie_procesowClick(Sender: TObject);
    procedure RamkaPowiazanie1rec_doClick(Sender: TObject);
    procedure RamkaPowiazanie1img_doClick(Sender: TObject);
    procedure RamkaPowiazanie1rec_odClick(Sender: TObject);
    procedure RamkaPowiazanie1img_odClick(Sender: TObject);
    procedure RamkaPowiazanie1btn_addClick(Sender: TObject);
    procedure RamkaEdycjaProcesu1btn_delete_processClick(Sender: TObject);
    procedure RamkaEdycjaProcesu1btn_udelete_linksClick(Sender: TObject);
    procedure ObjectPatternMouseLeave(Sender: TObject);
    procedure RamkaMenuGlowne1btn_full_screen_modeClick(Sender: TObject);
    procedure RamkaMenuGlowne1btn_openClick(Sender: TObject);
    procedure RamkaMenuGlowne1btn_saveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  version = '1.0.1.8';
  build_date = '2020-02-17';

  max_objects = 100;
  max_objects_links = 1000;
  max_poinst_of_contact = 10000;

  line_spacing = 10;

var
  AOknoGl: TAOknoGl;
  MouseIsDown: Boolean;
  X1, Y1: Integer;
  selected: TRectangle;
  selected_first: TRectangle;
  selected_second: TRectangle;

  objects_array: array [1 .. max_objects] of diagram_object;
  objects_links_array: array [1 .. max_objects_links] of object_link;
  point_of_contact_array: array [1 .. max_poinst_of_contact] of point_of_contact;

implementation

{$R *.fmx}

procedure TAOknoGl.Zmien_styl_linii(nowy_styl : TStrokeDash);
var
  i: Integer;
Begin
 LinePattern.Stroke.Dash:=nowy_styl;
 RamkaPowiazanie1.WzorLinii.Stroke.Dash:=nowy_styl;
 for i := 1 to max_objects_links do
  Begin
   if objects_links_array[i].from_object>0 then
    Begin
     objects_links_array[i].text_line_1.Stroke.Dash:=nowy_styl;
     objects_links_array[i].text_line_2.Stroke.Dash:=nowy_styl;
     objects_links_array[i].text_line_3.Stroke.Dash:=nowy_styl;
    End;
  End;
End;

function TAOknoGl.Ktory_obiekt(obiekt: TRectangle): Integer;
Var
 wynik, i : Integer;
Begin
 wynik:=0;
 for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = obiekt then wynik:=i;
  End;
 Ktory_obiekt:=wynik;
End;

function TAOknoGl.Ktore_powiazanie(od_obiektu, do_obiektu: TRectangle): Integer;
Var
  wynik: Integer;
  od_obiektu_index, do_obiektu_index: Integer;
  i: Integer;
Begin
  wynik := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = od_obiektu then
      od_obiektu_index := objects_array[i].id_object;
    if objects_array[i].indicator = do_obiektu then
      do_obiektu_index := objects_array[i].id_object;
  End;

  for i := 1 to max_objects_links do
  Begin
    if (objects_links_array[i].from_object = od_obiektu_index) and (objects_links_array[i].to_object = do_obiektu_index) then
      wynik := i;
    if (objects_links_array[i].from_object = do_obiektu_index) and (objects_links_array[i].to_object = od_obiektu_index) then
      wynik := i;
  End;

  Ktore_powiazanie := wynik;
End;

procedure TAOknoGl.Ustaw_strzalke_powiazania(strzalka: string);
begin
  strzalka := Trim(AnsiLowerCase(strzalka));
  if strzalka = 'do' then
  Begin
    if RamkaPowiazanie1.img_do.Visible then
      RamkaPowiazanie1.img_do.Visible := False
    else
      RamkaPowiazanie1.img_do.Visible := True;
  End
  else
  Begin
    if RamkaPowiazanie1.img_od.Visible then
      RamkaPowiazanie1.img_od.Visible := False
    else
      RamkaPowiazanie1.img_od.Visible := True;
  End;

  if (RamkaPowiazanie1.img_od.Visible = False) and (RamkaPowiazanie1.img_do.Visible = False) then
    RamkaPowiazanie1.btn_add.Text := 'remove association'
  else
    RamkaPowiazanie1.btn_add.Text := 'add association';
end;

procedure TAOknoGl.Odznacz_wybrane(pierwszy, drugi: Boolean);
Begin
  if (pierwszy) and (selected_first <> nil) then
  Begin
    selected_first.Fill.Color := TAlphaColor($AA0F077A);
    selected_first := nil;
  End;
  if (drugi) and (selected_second <> nil) then
  Begin
    selected_second.Fill.Color := TAlphaColor($AA0F077A);
    selected_second := nil;
  End;
End;

function TAOknoGl.Czy_juz_jest_tu_punkt_styku(x, y: Single): Boolean;
Var
  wynik: Boolean;
  i: Integer;
Begin
  wynik := False;
  for i := 1 to max_poinst_of_contact do
  Begin
    if (point_of_contact_array[i].x = x) and (point_of_contact_array[i].y = y) then
    Begin
      wynik := True;
      Break;
    End;
  End;
  Czy_juz_jest_tu_punkt_styku := wynik;
End;

procedure TAOknoGl.Czysc_punkty_styku;
var
  i: Integer;
Begin
  for i := 1 to max_poinst_of_contact do
  Begin
    point_of_contact_array[i].x := 0;
    point_of_contact_array[i].y := 0;
  End;
End;

procedure TAOknoGl.Dodaj_punkt_styku(x, y: Single);
Var
  i: Integer;
Begin
  for i := 1 to max_poinst_of_contact do
  Begin
    if (point_of_contact_array[i].x = 0) and (point_of_contact_array[i].y = 0) then
    Begin
      point_of_contact_array[i].x := x;
      point_of_contact_array[i].y := y;
      Break;
    End;
  End;
End;

procedure TAOknoGl.Usun_powiazanie(od_obiektu_index, do_obiektu_index: Integer);
var
  i: Integer;
  czy_istnieje: Boolean;
  istniejacy: Integer;
Begin
  istniejacy := 0;
  czy_istnieje := False;
  for i := 1 to max_objects_links do
  Begin
    if (objects_links_array[i].from_object = od_obiektu_index) and (objects_links_array[i].to_object = do_obiektu_index) then
    Begin
      istniejacy := i;
      czy_istnieje := True;
    End;
    if (objects_links_array[i].from_object = do_obiektu_index) and (objects_links_array[i].to_object = od_obiektu_index) then
    Begin
      istniejacy := i;
      czy_istnieje := True;
    End;
  End;

  if czy_istnieje = True then
  Begin
    objects_links_array[istniejacy].from_object := 0;
    objects_links_array[istniejacy].to_object := 0;
    objects_links_array[istniejacy].from_arrow := False;
    objects_links_array[istniejacy].to_arrow := False;
{$IFDEF ANDROID}
    objects_links_array[istniejacy].linia.DisposeOf;
    objects_links_array[istniejacy].linia2.DisposeOf;
    objects_links_array[istniejacy].linia3.DisposeOf;
    objects_links_array[istniejacy].strzalka_od.DisposeOf;
    objects_links_array[istniejacy].strzalka_do.DisposeOf;
{$ELSE}
    objects_links_array[istniejacy].text_line_1.Free;
    objects_links_array[istniejacy].text_line_1 := nil;
    objects_links_array[istniejacy].text_line_2.Free;
    objects_links_array[istniejacy].text_line_2 := nil;
    objects_links_array[istniejacy].text_line_3.Free;
    objects_links_array[istniejacy].text_line_3 := nil;
    objects_links_array[istniejacy].arrow_image_from.Free;
    objects_links_array[istniejacy].arrow_image_from := nil;
    objects_links_array[istniejacy].arrow_image_to.Free;
    objects_links_array[istniejacy].arrow_image_to := nil;
{$ENDIF}
  End;
End;

procedure TAOknoGl.Dodaj_powiazanie(od_obiektu_index, do_obiektu_index: Integer; od_strzalka, do_strzalka: Boolean);
var
  i: Integer;
  nowy: Integer;
  tmpl, tmpl2, tmpl3: TLine;
  img1, img2: TImage;
  czy_istnieje: Boolean;
  istniejacy: Integer;
Begin
  nowy := 0;
  istniejacy := 0;
  czy_istnieje := False;
  for i := 1 to max_objects_links do
  Begin
    if (objects_links_array[i].from_object = 0) and (nowy = 0) then
      nowy := i;
    if (objects_links_array[i].from_object = od_obiektu_index) and (objects_links_array[i].to_object = do_obiektu_index) then
    Begin
      istniejacy := i;
      czy_istnieje := True;
    End;
    if (objects_links_array[i].from_object = do_obiektu_index) and (objects_links_array[i].to_object = od_obiektu_index) then
    Begin
      istniejacy := i;
      czy_istnieje := True;
    End;
  End;

  if (nowy > 0) and (czy_istnieje = False) then
  Begin
    objects_links_array[nowy].from_object := od_obiektu_index;
    objects_links_array[nowy].to_object := do_obiektu_index;
    objects_links_array[nowy].from_arrow := od_strzalka;
    objects_links_array[nowy].to_arrow := do_strzalka;

    tmpl := TLine(LinePattern.Clone(self));
    tmpl.Parent := ScrollBox;
    tmpl.Visible := True;
    objects_links_array[nowy].text_line_1 := tmpl;

    tmpl2 := TLine(LinePattern.Clone(self));
    tmpl2.Parent := ScrollBox;
    tmpl2.Visible := True;
    objects_links_array[nowy].text_line_2 := tmpl2;

    tmpl3 := TLine(LinePattern.Clone(self));
    tmpl3.Parent := ScrollBox;
    tmpl3.Visible := True;
    objects_links_array[nowy].text_line_3 := tmpl3;

    img1 := TImage(ArrowsPattern.Clone(self));
    img1.Parent := ScrollBox;
    img1.Visible := True;
    objects_links_array[nowy].arrow_image_from := img1;

    img2 := TImage(ArrowsPattern.Clone(self));
    img2.Parent := ScrollBox;
    img2.Visible := True;
    objects_links_array[nowy].arrow_image_to := img2;

    Rysuj_powiazania;
  End;

  if czy_istnieje = True then
  Begin
    objects_links_array[istniejacy].from_object := od_obiektu_index;
    objects_links_array[istniejacy].to_object := do_obiektu_index;
    objects_links_array[istniejacy].from_arrow := od_strzalka;
    objects_links_array[istniejacy].to_arrow := do_strzalka;
  End;
End;

procedure TAOknoGl.DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
begin
  L.LineType := TLineType.Diagonal;
  L.RotationCenter.x := 0.0;
  L.RotationCenter.y := 0.0;
  if (p2.x >= p1.x) then
  begin
    // Line goes left to right, what about vertical?
    if (p2.y > p1.y) then
    begin
      // Case #1 - Line goes high to low, so NORMAL DIAGONAL
      L.RotationAngle := 0;
      L.Position.x := p1.x;
      L.Width := p2.x - p1.x;
      L.Position.y := p1.y;
      L.Height := p2.y - p1.y;
    end
    else
    begin
      // Case #2 - Line goes low to high, so REVERSE DIAGONAL
      // X and Y are now upper left corner and width and height reversed
      L.RotationAngle := -90;
      L.Position.x := p1.x;
      L.Width := p1.y - p2.y;
      L.Position.y := p1.y;
      L.Height := p2.x - p1.x;
    end;
  end
  else
  begin
    // Line goes right to left
    if (p1.y > p2.y) then
    begin
      // Case #3 - Line goes high to low (but reversed) so NORMAL DIAGONAL
      L.RotationAngle := 0;
      L.Position.x := p2.x;
      L.Width := p1.x - p2.x;
      L.Position.y := p2.y;
      L.Height := p1.y - p2.y;
    end
    else
    begin
      // Case #4 - Line goes low to high, REVERSE DIAGONAL
      // X and Y are now upper left corner and width and height reversed
      L.RotationAngle := -90;
      L.Position.x := p2.x;
      L.Width := p2.y - p1.y;
      L.Position.y := p2.y;
      L.Height := p1.x - p2.x;
    end;
  end;
  if (L.Height < 0.01) then
    L.Height := 0.1;
  if (L.Width < 0.01) then
    L.Width := 0.1;
end;

procedure TAOknoGl.RamkaEdycjaProcesu1btn_delete_processClick(Sender: TObject);
Var
  i, id_procesu, ktory_w_tablicy: Integer;
begin
  ktory_w_tablicy := 0;
  id_procesu := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = selected then
    Begin
      id_procesu := objects_array[i].id_object;
      ktory_w_tablicy := i;
    End;
  End;

  if ktory_w_tablicy > 0 then
  Begin
    DrawingTimer.Enabled := False;
    Deaktywuj_obiekt;
    selected := nil;
    // Najpierw kasujê obiekt
    objects_array[ktory_w_tablicy].id_object := 0;
{$IFDEF ANDROID}
    obiekty[ktory_w_tablicy].wskaznik.DisposeOf;
{$ELSE}
    objects_array[ktory_w_tablicy].indicator.Free;
    objects_array[ktory_w_tablicy].indicator := nil;
{$ENDIF}
    // Teraz kasujê powi¹zania
    for i := 1 to max_objects_links do
    Begin
      if (objects_links_array[i].from_object = id_procesu) OR (objects_links_array[i].to_object = id_procesu) then
      Begin
        objects_links_array[i].from_object := 0;
        objects_links_array[i].to_object := 0;
        objects_links_array[i].from_arrow := False;
        objects_links_array[i].to_arrow := False;
{$IFDEF ANDROID}
        objects_links_array[i].linia.DisposeOf;
        objects_links_array[i].linia2.DisposeOf;
        objects_links_array[i].linia3.DisposeOf;
        objects_links_array[i].strzalka_od.DisposeOf;
        objects_links_array[i].strzalka_do.DisposeOf;
{$ELSE}
        objects_links_array[i].text_line_1.Free;
        objects_links_array[i].text_line_1 := nil;
        objects_links_array[i].text_line_2.Free;
        objects_links_array[i].text_line_2 := nil;
        objects_links_array[i].text_line_3.Free;
        objects_links_array[i].text_line_3 := nil;
        objects_links_array[i].arrow_image_from.Free;
        objects_links_array[i].arrow_image_from := nil;
        objects_links_array[i].arrow_image_to.Free;
        objects_links_array[i].arrow_image_to := nil;
{$ENDIF}
      End;
    End;

    RamkaEdycjaProcesu1.Visible := False;
    Rysuj_powiazania;
    DrawingTimer.Enabled := True;
  End;
end;

procedure TAOknoGl.RamkaEdycjaProcesu1btn_save_process_dataClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to selected.ChildrenCount - 1 do
  Begin
    if selected.Children[i] is TLabel then
    Begin
      TLabel(selected.Children[i]).Text := RamkaEdycjaProcesu1.memo_process_name.Text;
    End;
  End;
  RamkaEdycjaProcesu1.Visible := False;
  Deaktywuj_obiekt;
end;

procedure TAOknoGl.RamkaEdycjaProcesu1btn_udelete_linksClick(Sender: TObject);
Var
  i, id_procesu, ktory_w_tablicy: Integer;
begin
  ktory_w_tablicy := 0;
  id_procesu := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = selected then
    Begin
      id_procesu := objects_array[i].id_object;
      ktory_w_tablicy := i;
    End;
  End;

  if ktory_w_tablicy > 0 then
  Begin
    DrawingTimer.Enabled := False;
    Deaktywuj_obiekt;
    // Teraz kasujê powi¹zania
    for i := 1 to max_objects_links do
    Begin
      if (objects_links_array[i].from_object = id_procesu) OR (objects_links_array[i].to_object = id_procesu) then
      Begin
        objects_links_array[i].from_object := 0;
        objects_links_array[i].to_object := 0;
        objects_links_array[i].from_arrow := False;
        objects_links_array[i].to_arrow := False;
{$IFDEF ANDROID}
        objects_links_array[i].linia.DisposeOf;
        objects_links_array[i].linia2.DisposeOf;
        objects_links_array[i].linia3.DisposeOf;
        objects_links_array[i].strzalka_od.DisposeOf;
        objects_links_array[i].strzalka_do.DisposeOf;
{$ELSE}
        objects_links_array[i].text_line_1.Free;
        objects_links_array[i].text_line_1 := nil;
        objects_links_array[i].text_line_2.Free;
        objects_links_array[i].text_line_2 := nil;
        objects_links_array[i].text_line_3.Free;
        objects_links_array[i].text_line_3 := nil;
        objects_links_array[i].arrow_image_from.Free;
        objects_links_array[i].arrow_image_from := nil;
        objects_links_array[i].arrow_image_to.Free;
        objects_links_array[i].arrow_image_to := nil;
{$ENDIF}
      End;
    End;

    RamkaEdycjaProcesu1.Visible := False;
    Rysuj_powiazania;
    DrawingTimer.Enabled := True;
  End;
end;

procedure TAOknoGl.RamkaMenuGlowne1btn_close_menuClick(Sender: TObject);
begin
  RamkaMenuGlowne1.Visible := False;
end;

procedure TAOknoGl.RamkaMenuGlowne1btn_full_screen_modeClick(Sender: TObject);
begin
 if AOknoGl.FullScreen then AOknoGl.FullScreen:=False
 else AOknoGl.FullScreen:=True;
end;

procedure TAOknoGl.RamkaMenuGlowne1btn_new_diagramClick(Sender: TObject);
begin
  Czysc_obiekty_i_powiazania;
  RamkaMenuGlowne1.Visible := False;
end;

function TAOknoGl.Wartosc_XML(rekord: string): String;
Var
 wynik : String;
  poz: Integer;
Begin
 poz:=Pos('>',rekord); wynik:=Copy(rekord,poz+1,Length(rekord));
 poz:=Pos('</',wynik); wynik:=Copy(wynik,1,poz-1);
 wynik:=Trim(wynik);
 Wartosc_XML:=wynik;
End;

procedure TAOknoGl.RamkaMenuGlowne1btn_openClick(Sender: TObject);
Var
  tmp: TRectangle;
  plik : TStringList;
  linia : String;
  o,i: Integer;
  czy_wczytano: Boolean;
  id_obiektu: string;
  wpis: string;
  x_obiektu: string;
  y_obiektu: string;
  from_obiekt: string;
  to_obiekt: string;
  from_arrow: string;
  to_arrow: string;
begin
 Czysc_obiekty_i_powiazania;
 plik := TStringList.Create;
 czy_wczytano:=False;

 { TODO : Dopisaæ wczytywanie projektu z pliku dla androida i ewentualnie iOS }
{$IFDEF ANDROID}

{$ELSE}
  if OpenProjectDialog.Execute then
   Begin
    plik.LoadFromFile(OpenProjectDialog.FileName);
    czy_wczytano:=True;
   End;
{$ENDIF}

 if czy_wczytano=True then
  Begin
   RamkaMenuGlowne1.Visible := False;
   for i := 0 to plik.Count-1 do
    Begin
     linia:=Trim(plik.Strings[i]);

     if Pos('<object>',linia)>0 then
      Begin
       //teraz mam dostêp do danych obiektów
       id_obiektu :=Wartosc_XML(plik.Strings[i+1]);
       wpis       :=Wartosc_XML(plik.Strings[i+2]);
       wpis       :=StringReplace(wpis,'#13',#13,[rfReplaceAll]);
       x_obiektu  :=Wartosc_XML(plik.Strings[i+3]);
       y_obiektu  :=Wartosc_XML(plik.Strings[i+4]);

        tmp := TRectangle(ObjectPattern.Clone(self));
        tmp.Parent := ScrollBox;
        tmp.Visible := True;
        tmp.Position.x := StrToFloat(x_obiektu);
        tmp.Position.y := StrToFloat(y_obiektu);
        tmp.OnMouseDown := ObjectPatternMouseDown;
        tmp.OnMouseMove := ObjectPatternMouseMove;
        tmp.OnMouseUp := ObjectPatternMouseUp;
        tmp.OnDblClick := LabelPatternDblClick;
        tmp.OnMouseLeave := ObjectPatternMouseLeave;
        tmp.OnTap := LabelPatternTap;

        Dodaj_wskaznik(tmp, StrToInt(id_obiektu));

        for o := 0 to tmp.ChildrenCount - 1 do
         Begin
          if tmp.Children[o] is TLabel then
           Begin
            TLabel(tmp.Children[o]).Text := wpis;
           End;
         End;
      End;

     if Pos('<link>',linia)>0 then
      Begin
       from_obiekt :=Wartosc_XML(plik.Strings[i+1]);
       to_obiekt   :=Wartosc_XML(plik.Strings[i+2]);
       from_arrow  :=Wartosc_XML(plik.Strings[i+3]);
       to_arrow    :=Wartosc_XML(plik.Strings[i+4]);
       Dodaj_powiazanie(StrToInt(from_obiekt),StrToInt(to_obiekt),StrToBool(from_arrow),StrToBool(to_arrow));
      end;

    End;
  End;

 plik.Free;
end;

procedure TAOknoGl.RamkaMenuGlowne1btn_saveClick(Sender: TObject);
Var
  plik : TStringList;
  tekst_obiektu : String;
  linie_tekstowe_obiektu : TStringList;
  t, i: Integer;
begin
 { TODO : Zamieniæ "sk³adanie" XML rêcznie na jego obs³ugê z wykorzystaniem klas XML }
 linie_tekstowe_obiektu := TStringList.Create;
 plik := TStringList.Create;
 plik.Add('<?xml version="1.0" encoding="utf-8"?>');
 plik.Add('<diagram date="'+DateToStr(Date)+'">');

 plik.Add('<objects>');
  for i := 1 to max_objects do
   Begin
    if objects_array[i].id_object>0 then
     Begin
      linie_tekstowe_obiektu.Text:=TLabel(objects_array[i].indicator.Children[0]).Text;
      tekst_obiektu:='';
      for t := 0 to linie_tekstowe_obiektu.Count-1 do
       Begin
        if t=0 then tekst_obiektu:=linie_tekstowe_obiektu.Strings[t]
        else tekst_obiektu:=tekst_obiektu+'#13'+linie_tekstowe_obiektu.Strings[t];
       End;

      plik.Add(' <object>');
      plik.Add('  <object_id>'+IntToStr(objects_array[i].id_object)+'</object_id>');
      plik.Add('  <object_caption>'+tekst_obiektu+'</object_caption>');
      plik.Add('  <object_x>'+FloatToStr(objects_array[i].indicator.Position.X)+'</object_x>');
      plik.Add('  <object_y>'+FloatToStr(objects_array[i].indicator.Position.Y)+'</object_y>');
      plik.Add(' </object>');
     End;
   End;
  plik.Add('</objects>');

  plik.Add('<links>');
  for i := 1 to max_objects_links do
   Begin
    if objects_links_array[i].from_object>0 then
     Begin
      plik.Add(' <link>');
      plik.Add('  <link_from>'+IntToStr(objects_links_array[i].from_object)+'</link_from>');
      plik.Add('  <link_to>'+IntToStr(objects_links_array[i].to_object)+'</link_to>');
      plik.Add('  <arrow_from>'+BoolToStr(objects_links_array[i].from_arrow)+'</arrow_from>');
      plik.Add('  <arrow_to>'+BoolToStr(objects_links_array[i].to_arrow)+'</arrow_to>');
      plik.Add(' </link>');
     End;
   End;
  plik.Add('</links>');
  plik.Add('</diagram>');

{ TODO : Dopisaæ zapisywanie projektu do pliku dla androida i iOS }
{$IFDEF ANDROID}

{$ELSE}
  if SaveProjectDialog.Execute then plik.SaveToFile(SaveProjectDialog.FileName, TEncoding.UTF8);
{$ENDIF}

 plik.Free;
 linie_tekstowe_obiektu.Free;
end;

procedure TAOknoGl.RamkaPowiazanie1btn_addClick(Sender: TObject);
Var
  od_obiektu, do_obiektu: Integer;
  i: Integer;
begin
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = selected_first then
      od_obiektu := objects_array[i].id_object;
    if objects_array[i].indicator = selected_second then
      do_obiektu := objects_array[i].id_object;
  End;

  // Jeœli nie ma strza³ek to usuwane jest powi¹zanie!
  if (RamkaPowiazanie1.img_od.Visible = False) and (RamkaPowiazanie1.img_do.Visible = False) then
    Usun_powiazanie(od_obiektu, do_obiektu)
  else
    Dodaj_powiazanie(od_obiektu, do_obiektu, RamkaPowiazanie1.img_od.Visible, RamkaPowiazanie1.img_do.Visible);

  Rysuj_powiazania;
  RamkaPowiazanie1.Visible := False;
  Odznacz_wybrane(False, True);
end;

procedure TAOknoGl.RamkaPowiazanie1but_cancelClick(Sender: TObject);
begin
  RamkaPowiazanie1.Visible := False;
  Odznacz_wybrane(False, True);
end;

procedure TAOknoGl.RamkaPowiazanie1img_doClick(Sender: TObject);
begin
  Ustaw_strzalke_powiazania('do');
end;

procedure TAOknoGl.RamkaPowiazanie1img_odClick(Sender: TObject);
begin
  Ustaw_strzalke_powiazania('od');
end;

procedure TAOknoGl.RamkaPowiazanie1rec_doClick(Sender: TObject);
begin
  Ustaw_strzalke_powiazania('do');
end;

procedure TAOknoGl.RamkaPowiazanie1rec_odClick(Sender: TObject);
begin
  Ustaw_strzalke_powiazania('od');
end;

procedure TAOknoGl.DrawingTimerTimer(Sender: TObject);
begin
  Rysuj_powiazania;
end;

procedure TAOknoGl.Rysuj_powiazania;
var
  i, o: Integer;
  obiekt_index_od: Integer;
  obiekt_index_do: Integer;
Begin
  Czysc_punkty_styku;
  for i := 1 to max_objects_links do
  Begin
    if objects_links_array[i].from_object > 0 then
    Begin
      for o := 1 to max_objects do
      Begin
        if objects_array[o].id_object = objects_links_array[i].from_object then
          obiekt_index_od := o;
      End;
      for o := 1 to max_objects do
      Begin
        if objects_array[o].id_object = objects_links_array[i].to_object then
          obiekt_index_do := o;
      End;
      Rysuj_powiazanie(obiekt_index_od, obiekt_index_do, objects_links_array[i].from_arrow, objects_links_array[i].to_arrow,
        objects_links_array[i].text_line_1, objects_links_array[i].text_line_2, objects_links_array[i].text_line_3,
        objects_links_array[i].arrow_image_from, objects_links_array[i].arrow_image_to);
    End;
  End;
End;

procedure TAOknoGl.Rysuj_powiazanie(od_obiektu, do_obiektu: Integer; od_strzalka, do_strzalka: Boolean;
  linia, linia2, linia3: TLine; strzalka_od, strzalka_do: TImage);
var
  od_rect, do_rect: TRectangle;
  poy, koy: Single;
  X1, Y1: Single;
  x2, y2: Single;
  ox, oy: Single;
  kier: Char;
  pozycja_test: Integer;
  licznik_obrotow: Integer;
begin

  if (od_strzalka) or (do_strzalka) then
  Begin
    od_rect := objects_array[od_obiektu].indicator;
    do_rect := objects_array[do_obiektu].indicator;

    poy := od_rect.Position.y - od_rect.Height - (od_rect.Height / 2);
    koy := od_rect.Position.y + od_rect.Height + (od_rect.Height / 2);

    if (do_rect.Position.y > poy) and (do_rect.Position.y < koy) then
    Begin
      // Jeœli obiekty s¹ na podobnym poziomie;
      Y1 := od_rect.Position.y + (od_rect.Height / 2);
      y2 := do_rect.Position.y + (do_rect.Height / 2);

      if do_rect.Position.x > od_rect.Position.x then
      Begin
        // docelowy jest na prawo
        X1 := od_rect.Position.x + od_rect.Width;
        x2 := do_rect.Position.x;
        kier := 'P';
      End
      else
      Begin
        // docelowy jest na lewo
        X1 := od_rect.Position.x;
        x2 := do_rect.Position.x + do_rect.Width;
        kier := 'L';
      End;

    End
    else
    Begin
      if do_rect.Position.y > od_rect.Position.y then
      Begin
        // Jeœli obiekt docelowy jest ni¿ej ni¿ obiekt Ÿród³owy
        Y1 := od_rect.Position.y + od_rect.Height;
        y2 := do_rect.Position.y;
        kier := 'D';
      End
      else
      Begin
        Y1 := od_rect.Position.y;
        y2 := do_rect.Position.y + do_rect.Height;
        kier := 'G';
      End;

      X1 := od_rect.Position.x + (od_rect.Width / 2);
      x2 := do_rect.Position.x + (do_rect.Width / 2);
    End;

    if Czy_juz_jest_tu_punkt_styku(X1, Y1) = True then
    Begin
      pozycja_test := line_spacing;
      licznik_obrotow := 1;
      Repeat
        if kier IN ['L', 'P'] then
          Y1 := Y1 + pozycja_test;
        if kier IN ['D', 'G'] then
          X1 := X1 + pozycja_test;
        if licznik_obrotow < 0 then
          licznik_obrotow := licznik_obrotow - 1
        else
          licznik_obrotow := licznik_obrotow + 1;
        licznik_obrotow := licznik_obrotow * -1;
        pozycja_test := line_spacing * licznik_obrotow;
      Until Czy_juz_jest_tu_punkt_styku(X1, Y1) = False;
    End;
    Dodaj_punkt_styku(X1, Y1);

    if Czy_juz_jest_tu_punkt_styku(x2, y2) = True then
    Begin
      pozycja_test := line_spacing;
      licznik_obrotow := 1;
      Repeat
        if kier IN ['L', 'P'] then
          y2 := y2 + pozycja_test;
        if kier IN ['D', 'G'] then
          x2 := x2 + pozycja_test;
        if licznik_obrotow < 0 then
          licznik_obrotow := licznik_obrotow - 1
        else
          licznik_obrotow := licznik_obrotow + 1;
        licznik_obrotow := licznik_obrotow * -1;
        pozycja_test := line_spacing * -licznik_obrotow;
      Until Czy_juz_jest_tu_punkt_styku(x2, y2) = False;
    End;
    Dodaj_punkt_styku(x2, y2);

    if kier = 'D' then
    Begin
      oy := Y1 + ((y2 - Y1) / 2);
      DrawLineBetweenPoints(linia, PointF(X1, Y1), PointF(X1, oy));
      DrawLineBetweenPoints(linia2, PointF(X1, oy), PointF(x2, oy));
      DrawLineBetweenPoints(linia3, PointF(x2, oy), PointF(x2, y2));
      if do_strzalka = True then
      Begin
        strzalka_do.Visible := True;
        strzalka_do.Position.x := x2 - (ArrowsPattern.Width / 2);
        strzalka_do.Position.y := y2 - ArrowsPattern.Height + 7;
        strzalka_do.RotationAngle := 90;
      End
      else
        strzalka_do.Visible := False;
      if od_strzalka = True then
      Begin
        strzalka_od.Visible := True;
        strzalka_od.Position.x := X1 - (ArrowsPattern.Width / 2);
        strzalka_od.Position.y := Y1 - 7;
        strzalka_od.RotationAngle := 270;
      End
      else
        strzalka_od.Visible := False;
    End;
    if kier = 'G' then
    Begin
      oy := y2 + ((Y1 - y2) / 2);
      DrawLineBetweenPoints(linia, PointF(X1, Y1), PointF(X1, oy));
      DrawLineBetweenPoints(linia2, PointF(X1, oy), PointF(x2, oy));
      DrawLineBetweenPoints(linia3, PointF(x2, oy), PointF(x2, y2));
      if do_strzalka = True then
      Begin
        strzalka_do.Visible := True;
        strzalka_do.Position.x := x2 - (ArrowsPattern.Width / 2);
        strzalka_do.Position.y := y2 - 7;
        strzalka_do.RotationAngle := 270;
      End
      else
        strzalka_do.Visible := False;
      if od_strzalka = True then
      Begin
        strzalka_od.Visible := True;
        strzalka_od.Position.x := X1 - (ArrowsPattern.Width / 2);
        strzalka_od.Position.y := Y1 - ArrowsPattern.Height + 7;
        strzalka_od.RotationAngle := 90;
      End
      else
        strzalka_od.Visible := False;
    End;

    if kier = 'P' then
    Begin
      ox := X1 + ((x2 - X1) / 2);
      DrawLineBetweenPoints(linia, PointF(X1, Y1), PointF(ox, Y1));
      DrawLineBetweenPoints(linia2, PointF(ox, Y1), PointF(ox, y2));
      DrawLineBetweenPoints(linia3, PointF(ox, y2), PointF(x2, y2));
      if do_strzalka = True then
      Begin
        strzalka_do.Visible := True;
        strzalka_do.Position.x := x2 - (ArrowsPattern.Width) + 7;
        strzalka_do.Position.y := y2 - (ArrowsPattern.Height / 2);
        strzalka_do.RotationAngle := 0;
      End
      else
        strzalka_do.Visible := False;
      if od_strzalka = True then
      Begin
        strzalka_od.Visible := True;
        strzalka_od.Position.x := X1 - 7;
        strzalka_od.Position.y := Y1 - (ArrowsPattern.Height / 2);
        strzalka_od.RotationAngle := 180;
      End
      else
        strzalka_od.Visible := False;
    End;
    if kier = 'L' then
    Begin
      ox := x2 + ((X1 - x2) / 2);
      DrawLineBetweenPoints(linia, PointF(X1, Y1), PointF(ox, Y1));
      DrawLineBetweenPoints(linia2, PointF(ox, Y1), PointF(ox, y2));
      DrawLineBetweenPoints(linia3, PointF(ox, y2), PointF(x2, y2));
      if do_strzalka = True then
      Begin
        strzalka_do.Visible := True;
        strzalka_do.Position.x := x2 - 7;
        strzalka_do.Position.y := y2 - (ArrowsPattern.Height / 2);
        strzalka_do.RotationAngle := 180;
      End
      else
        strzalka_do.Visible := False;
      if od_strzalka = True then
      Begin
        strzalka_od.Visible := True;
        strzalka_od.Position.x := X1 - (ArrowsPattern.Width) + 7;
        strzalka_od.Position.y := Y1 - (ArrowsPattern.Height / 2);
        strzalka_od.RotationAngle := 0;
      End
      else
        strzalka_od.Visible := False;
    End;

    od_rect.BringToFront;
    do_rect.BringToFront;

  end;

end;

procedure TAOknoGl.Dodaj_wskaznik(proces: TRectangle; index_procesu: Integer);
var
  i: Integer;
  nowy: Integer;
Begin
  nowy := 0;
  for i := 1 to max_objects do
  Begin
    if (objects_array[i].id_object = 0) and (nowy = 0) then
      nowy := i;
  End;

  objects_array[nowy].id_object := index_procesu;
  objects_array[nowy].indicator := proces;
End;

function TAOknoGl.Ostatni_obiekt: Integer;
Var
  wynik: Integer;
  i: Integer;
Begin
  wynik := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].id_object = 0 then
     Begin
      wynik := i-1;
      Break;
     End;
  End;
  Ostatni_obiekt := wynik;
End;

procedure TAOknoGl.btn_dodaj_nowy_procesClick(Sender: TObject);
Var
  tmp: TRectangle;
  i: Integer;
  index_obiektu: Integer;
begin
  Odznacz_wybrane(True, True);
  btn_laczenie_procesow.IsPressed := False;

  tmp := TRectangle(ObjectPattern.Clone(self));
  tmp.Parent := ScrollBox;
  tmp.Visible := True;
  tmp.Position.x := +10;
  tmp.Position.y := GridMenuGornego.Position.y + GridMenuGornego.Height + 10;
  tmp.OnMouseDown := ObjectPatternMouseDown;
  tmp.OnMouseMove := ObjectPatternMouseMove;
  tmp.OnMouseUp := ObjectPatternMouseUp;
  tmp.OnDblClick := LabelPatternDblClick;
  tmp.OnMouseLeave := ObjectPatternMouseLeave;
  tmp.OnTap := LabelPatternTap;

  index_obiektu := Ostatni_obiekt + 1;
  Dodaj_wskaznik(tmp, index_obiektu);

  for i := 0 to tmp.ChildrenCount - 1 do
  Begin
    if tmp.Children[i] is TLabel then
    Begin
      TLabel(tmp.Children[i]).Text := 'New process' + #13 + '(' + IntToStr(index_obiektu) + ')';
    End;
  End;

  Rysuj_powiazania;
end;

procedure TAOknoGl.btn_hamburgerClick(Sender: TObject);
begin
  RamkaMenuGlowne1.Visible := Not(RamkaMenuGlowne1.Visible);
end;

procedure TAOknoGl.btn_laczenie_procesowClick(Sender: TObject);
begin
  Odznacz_wybrane(True, True);
end;

procedure TAOknoGl.Czysc_obiekty_i_powiazania;
var
  i: Integer;
Begin
  for i := 1 to max_objects do
  Begin
    objects_array[i].id_object := 0;
{$IFDEF ANDROID}
    obiekty[i].wskaznik.DisposeOf;
{$ELSE}
    objects_array[i].indicator.Free;
    objects_array[i].indicator := nil;
{$ENDIF}
  End;

  for i := 1 to max_objects_links do
  Begin
    objects_links_array[i].from_object := 0;
    objects_links_array[i].to_object := 0;
    objects_links_array[i].from_arrow := False;
    objects_links_array[i].to_arrow := False;
{$IFDEF ANDROID}
    objects_links_array[i].linia.DisposeOf;
    objects_links_array[i].linia2.DisposeOf;
    objects_links_array[i].linia3.DisposeOf;
    objects_links_array[i].strzalka_od.DisposeOf;
    objects_links_array[i].strzalka_do.DisposeOf;
{$ELSE}
    objects_links_array[i].text_line_1.Free;
    objects_links_array[i].text_line_1 := nil;
    objects_links_array[i].text_line_2.Free;
    objects_links_array[i].text_line_2 := nil;
    objects_links_array[i].text_line_3.Free;
    objects_links_array[i].text_line_3 := nil;
    objects_links_array[i].arrow_image_from.Free;
    objects_links_array[i].arrow_image_from := nil;
    objects_links_array[i].arrow_image_to.Free;
    objects_links_array[i].arrow_image_to := nil;
{$ENDIF}
  End;
  Rysuj_powiazania;
End;

procedure TAOknoGl.FormCreate(Sender: TObject);
begin
  Caption := 'FMX Diagram Designer - version: ' + version;
  lbl_bottom_info.Text:='FX Systems Piotr Daszewski FMX Diagram Designer - version: ' + version;
  MouseIsDown := False;
  ObjectPattern.Visible := False;
  LinePattern.Visible := False;
  Czysc_obiekty_i_powiazania;
  RamkaMenuGlowne1.Visible := False;
  RamkaEdycjaProcesu1.Visible := False;

{$IFDEF ANDROID}
  Wzor_label.TextSettings.Font.Size := 10;
{$ELSE}
  LabelPattern.TextSettings.Font.Size := 12;
{$ENDIF}
end;

procedure TAOknoGl.ObjectPatternMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
var
  powiazanie_aktywne: Integer;
begin
  if btn_laczenie_procesow.IsPressed then
  Begin
    if selected_first = nil then
    Begin
      selected_first := TRectangle(Sender);
      selected_first.BringToFront;
      selected_first.Fill.Color := TAlphaColor($AA7A0707);
    End
    else
    Begin
      // Jeœli pierwszy jest ju¿ wybrany
      if TRectangle(Sender) = selected_first then
      Begin
        // Jeœli nowo klikniêty jest wybranym
        selected_first.Fill.Color := TAlphaColor($AA0F077A);
        selected_first := Nil;
      End
      else
      Begin
        // Jeœli pierwszy jest wybrany i teraz wybraliœmy drugi!
        selected_second := TRectangle(Sender);
        selected_second.BringToFront;
        selected_second.Fill.Color := TAlphaColor($AA7A0707);
        RamkaPowiazanie1.Visible := True;

        RamkaPowiazanie1.lbl_od_procesu.Text := TLabel(selected_first.Children[0]).Text;
        RamkaPowiazanie1.lbl_do_procesu.Text := TLabel(selected_second.Children[0]).Text;

        powiazanie_aktywne := Ktore_powiazanie(selected_first, selected_second);
        if powiazanie_aktywne = 0 then
        Begin
          RamkaPowiazanie1.img_od.Visible := False;
          RamkaPowiazanie1.img_do.Visible := True;
          RamkaPowiazanie1.btn_add.Text := 'add association';
        End
        else
        Begin
          RamkaPowiazanie1.img_od.Visible := False;
          RamkaPowiazanie1.img_do.Visible := False;
          if (objects_links_array[powiazanie_aktywne].from_arrow=True)
          and (Ktory_obiekt(selected_first)=objects_links_array[powiazanie_aktywne].from_object ) then RamkaPowiazanie1.img_od.Visible := True;
          if (objects_links_array[powiazanie_aktywne].from_arrow=True)
          and (Ktory_obiekt(selected_second)=objects_links_array[powiazanie_aktywne].from_object ) then RamkaPowiazanie1.img_do.Visible := True;

          if (objects_links_array[powiazanie_aktywne].to_arrow=True)
          and (Ktory_obiekt(selected_second)=objects_links_array[powiazanie_aktywne].to_object ) then RamkaPowiazanie1.img_do.Visible := True;
          if (objects_links_array[powiazanie_aktywne].to_arrow=True)
          and (Ktory_obiekt(selected_first)=objects_links_array[powiazanie_aktywne].to_object ) then RamkaPowiazanie1.img_od.Visible := True;

          RamkaPowiazanie1.btn_add.Text := 'change the association';
        End;
      End;
    End;
  End
  else
  Begin
    selected := TRectangle(Sender);
    selected.BringToFront;
    X1 := round(x);
    Y1 := round(y);
    selected.Fill.Color := TAlphaColor($AA7A0707);
    MouseIsDown := True;
    DrawingTimer.Enabled := True;
  End;
end;

procedure TAOknoGl.ObjectPatternMouseLeave(Sender: TObject);
begin
 if btn_laczenie_procesow.IsPressed = False then
    Deaktywuj_obiekt;
end;

procedure TAOknoGl.ObjectPatternMouseMove(Sender: TObject; Shift: TShiftState; x, y: Single);
begin
  if btn_laczenie_procesow.IsPressed = False then
  Begin
    if MouseIsDown then
    begin
      selected.Position.x := selected.Position.x + round(x) - X1;
      selected.Position.y := selected.Position.y + round(y) - Y1;
    end;
  End;
end;

procedure TAOknoGl.Deaktywuj_obiekt;
Begin
  MouseIsDown := False;
  if Assigned(selected) then selected.Fill.Color := TAlphaColor($AA0F077A);
  DrawingTimer.Enabled := False;
  Rysuj_powiazania;
End;

procedure TAOknoGl.ObjectPatternMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
begin
  if btn_laczenie_procesow.IsPressed = False then
    Deaktywuj_obiekt;
end;

procedure TAOknoGl.Edycja_danych_procesu;
var
  i: Integer;
begin
  if btn_laczenie_procesow.IsPressed = False then
  Begin
    for i := 0 to selected.ChildrenCount - 1 do
    Begin
      if selected.Children[i] is TLabel then
      Begin
        RamkaEdycjaProcesu1.Visible := True;
        RamkaEdycjaProcesu1.memo_process_name.Text := TLabel(selected.Children[i]).Text;
      End;
    End;
  End;
end;

procedure TAOknoGl.LabelPatternDblClick(Sender: TObject);
begin
  Edycja_danych_procesu;
end;

procedure TAOknoGl.LabelPatternTap(Sender: TObject; const Point: TPointF);
begin
  Edycja_danych_procesu;
end;

end.
