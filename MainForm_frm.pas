unit MainForm_frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ExtCtrls, FMX.Objects, FMX.Effects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, RamkaEdycjaProcesu_frm, FMX.ScrollBox, FMX.Memo,
  RamkaMenuGlowne_frm, FMX.MaterialSources, System.ImageList, FMX.ImgList, RamkaPowiazanie_frm;

type
 obiekt = record
  id_obiektu : Integer;
  wskaznik : TRectangle;
 end;

type
  powiazanie = record
    od_obiektu: Integer;
    do_obiektu: Integer;
    od_strzalka: Boolean;
    do_strzalka: Boolean;
    strzalka_od: TImage;
    strzalka_do: TImage;
    linia: TLine;
    linia2: TLine;
    linia3: TLine;
  end;

type
 punkt_styku = record
  x : Single;
  y : Single;
 end;

type
  TAOknoGl = class(TForm)
    Tlo: TImage;
    GridGlowny: TGridPanelLayout;
    GridMenuGornego: TGridPanelLayout;
    btn_hamburger: TButton;
    btn_dodaj_nowy_proces: TButton;
    ScrollBox: TScrollBox;
    WzorLinii: TLine;
    WzorObiektu: TRectangle;
    Wzor_label: TLabel;
    RamkaEdycjaProcesu1: TRamkaEdycjaProcesu;
    Rysowanie: TTimer;
    RamkaMenuGlowne1: TRamkaMenuGlowne;
    WzorStrzalki: TImage;
    btn_laczenie_procesow: TButton;
    RamkaPowiazanie1: TRamkaPowiazanie;

    procedure Deaktywuj_obiekt;
    procedure Czysc_obiekty_i_powiazania;
    function Ostatni_obiekt: Integer;
    procedure Dodaj_wskaznik(proces : TRectangle; index_procesu : Integer);
    procedure Rysuj_powiazania;
    procedure Rysuj_powiazanie(od_obiektu, do_obiektu: Integer; od_strzalka, do_strzalka: Boolean; linia, linia2, linia3: TLine; strzalka_od, strzalka_do: TImage);
    procedure Dodaj_powiazanie(od_obiektu_index, do_obiektu_index: Integer; od_strzalka, do_strzalka: Boolean);
    procedure DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
    procedure Edycja_danych_procesu;

    procedure Czysc_punkty_styku;
    procedure Dodaj_punkt_styku(x,y : Single);
    function Czy_juz_jest_tu_punkt_styku(x,y : Single): Boolean;

    procedure Odznacz_wybrane(pierwszy, drugi : Boolean);
    procedure Ustaw_strzalke_powiazania(strzalka : String);

    procedure FormCreate(Sender: TObject);
    procedure WzorObiektuMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure WzorObiektuMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure WzorObiektuMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Wzor_labelDblClick(Sender: TObject);
    procedure Wzor_labelTap(Sender: TObject; const Point: TPointF);
    procedure btn_dodaj_nowy_procesClick(Sender: TObject);
    procedure btn_hamburgerClick(Sender: TObject);
    procedure RamkaEdycjaProcesu1btn_save_process_dataClick(Sender: TObject);
    procedure RysowanieTimer(Sender: TObject);
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
 wersja = '0.4.0';
 data_kompilacji = '2018-10-05';

 max_obiektow = 100;
 max_powiazan = 1000;
 max_punktow_styku = 10000;

 odstep_miedzy_liniami = 10;

var
  AOknoGl: TAOknoGl;
  MouseIsDown: Boolean;
  X1, Y1: Integer;
  wybrany: TRectangle;
  wybrany_pierwszy: TRectangle;
  wybrany_drugi: TRectangle;
  label_wybranego: Integer;

  obiekty : array[1..max_obiektow] of obiekt;
  powiazania: array [1 .. max_powiazan] of powiazanie;
  punkty_styku: array[1 .. max_punktow_styku] of punkt_styku;

implementation

{$R *.fmx}

procedure TAOknoGl.Ustaw_strzalke_powiazania(strzalka: string);
begin
 strzalka:=Trim(AnsiLowerCase(strzalka));
 if strzalka='do' then
  Begin
   if RamkaPowiazanie1.img_do.Visible then RamkaPowiazanie1.img_do.Visible:=False
   else RamkaPowiazanie1.img_do.Visible:=True;
  End
 else
  Begin
   if RamkaPowiazanie1.img_od.Visible then RamkaPowiazanie1.img_od.Visible:=False
   else RamkaPowiazanie1.img_od.Visible:=True;
  End;
end;

procedure TAOknoGl.Odznacz_wybrane(pierwszy, drugi : Boolean);
Begin
 if (pierwszy) and (wybrany_pierwszy<>nil) then
  Begin
   wybrany_pierwszy.Fill.Color:=TAlphaColor($AA0F077A);
   wybrany_pierwszy:=nil;
  End;
 if (drugi) and (wybrany_drugi<>nil)  then
  Begin
   wybrany_drugi.Fill.Color:=TAlphaColor($AA0F077A);
   wybrany_drugi:=nil;
  End;
End;

function TAOknoGl.Czy_juz_jest_tu_punkt_styku(x,y : Single): Boolean;
Var
 wynik : Boolean;
 i: Integer;
Begin
 wynik:=False;
 for i := 1 to max_punktow_styku do
  Begin
   if (punkty_styku[i].x=x) and (punkty_styku[i].y=y) then
    Begin
     wynik:=True;
     Break;
    End;
  End;
 Czy_juz_jest_tu_punkt_styku:=wynik;
End;

procedure TAOknoGl.Czysc_punkty_styku;
var
  i: Integer;
Begin
 for i := 1 to max_punktow_styku do
  Begin
   punkty_styku[i].x:=0;
   punkty_styku[i].y:=0;
  End;
End;

procedure TAOknoGl.Dodaj_punkt_styku(x,y : Single);
Var
  i: Integer;
Begin
 for i := 1 to max_punktow_styku do
  Begin
   if (punkty_styku[i].x=0) and (punkty_styku[i].y=0) then
    Begin
     punkty_styku[i].x:=x;
     punkty_styku[i].y:=y;
     Break;
    End;
  End;
End;

procedure TAOknoGl.Dodaj_powiazanie(od_obiektu_index, do_obiektu_index: Integer; od_strzalka, do_strzalka: Boolean);
var
  i: Integer;
  nowy: Integer;
  tmpl, tmpl2, tmpl3: TLine;
  img1, img2: TImage;
Begin
 nowy:=0;
 for i := 1 to max_powiazan do
  Begin
   if (Powiazania[i].od_obiektu=0) and (nowy=0) then nowy:=i;
  End;

 if nowy>0 then
  Begin
   Powiazania[nowy].od_obiektu:=od_obiektu_index;
   Powiazania[nowy].do_obiektu:=do_obiektu_index;
   Powiazania[nowy].od_strzalka:=od_strzalka;
   Powiazania[nowy].do_strzalka:=do_strzalka;

   tmpl := TLine(WzorLinii.Clone(self));
   tmpl.Parent := ScrollBox;
   tmpl.Visible:=True;
   Powiazania[nowy].linia:=tmpl;

   tmpl2 := TLine(WzorLinii.Clone(self));
   tmpl2.Parent := ScrollBox;
   tmpl2.Visible:=True;
   Powiazania[nowy].linia2:=tmpl2;

   tmpl3 := TLine(WzorLinii.Clone(self));
   tmpl3.Parent := ScrollBox;
   tmpl3.Visible:=True;
   Powiazania[nowy].linia3:=tmpl3;

   img1 := TImage(WzorStrzalki.Clone(Self));
   img1.Parent := ScrollBox;
   img1.Visible := True;
   powiazania[nowy].strzalka_od:=img1;

   img2 := TImage(WzorStrzalki.Clone(Self));
   img2.Parent := ScrollBox;
   img2.Visible := True;
   powiazania[nowy].strzalka_do:=img2;

   Rysuj_powiazania;
  End;
End;

procedure TAOknoGl.DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
  begin
    L.LineType := TLineType.Diagonal;
    L.RotationCenter.X := 0.0;
    L.RotationCenter.Y := 0.0;
    if (p2.X >= p1.X) then begin
      // Line goes left to right, what about vertical?
      if (p2.Y > p1.Y) then begin
        // Case #1 - Line goes high to low, so NORMAL DIAGONAL
        L.RotationAngle := 0;
        L.Position.X := p1.X;
        L.Width := p2.X - p1.X;
        L.Position.Y := p1.Y;
        L.Height := p2.Y - p1.Y;
      end else begin
        // Case #2 - Line goes low to high, so REVERSE DIAGONAL
        // X and Y are now upper left corner and width and height reversed
        L.RotationAngle := -90;
        L.Position.X := p1.X;
        L.Width := p1.Y - p2.Y;
        L.Position.Y := p1.Y;
        L.Height := p2.X - p1.X;
      end;
    end else begin
      // Line goes right to left
      if (p1.Y > p2.Y) then begin
        // Case #3 - Line goes high to low (but reversed) so NORMAL DIAGONAL
        L.RotationAngle := 0;
        L.Position.X := p2.X;
        L.Width := p1.X - p2.X;
        L.Position.Y := p2.Y;
        L.Height := p1.Y - p2.Y;
      end else begin
        // Case #4 - Line goes low to high, REVERSE DIAGONAL
        // X and Y are now upper left corner and width and height reversed
        L.RotationAngle := -90;
        L.Position.X := p2.X;
        L.Width := p2.Y - p1.Y;
        L.Position.Y := p2.Y;
        L.Height := p1.X - p2.X;
      end;
    end;
    if (L.Height < 0.01) then L.Height := 0.1;
    if (L.Width < 0.01) then L.Width := 0.1;
  end;

procedure TAOknoGl.RamkaEdycjaProcesu1btn_delete_processClick(Sender: TObject);
Var
 i, id_procesu, ktory_w_tablicy : Integer;
begin
 ktory_w_tablicy:=0;
 id_procesu:=0;
 for i:= 1 to max_obiektow do
  Begin
   if obiekty[i].wskaznik=wybrany then
    Begin
     id_procesu:=obiekty[i].id_obiektu;
     ktory_w_tablicy:=i;
    End;
  End;

 if ktory_w_tablicy>0 then
  Begin
   Rysowanie.Enabled:=False;
   Deaktywuj_obiekt;
   wybrany:=nil;
   //Najpierw kasujê obiekt
   obiekty[ktory_w_tablicy].id_obiektu:=0;
   {$IFDEF ANDROID}
    obiekty[ktory_w_tablicy].wskaznik.DisposeOf;
   {$ELSE}
    obiekty[ktory_w_tablicy].wskaznik.Free;
    obiekty[ktory_w_tablicy].wskaznik:=nil;
   {$ENDIF}

   //Teraz kasujê powi¹zania
   for i := 1 to max_powiazan do
    Begin
     if (powiazania[i].od_obiektu=id_procesu) OR (powiazania[i].do_obiektu=id_procesu) then
      Begin
       powiazania[i].od_obiektu := 0;
       powiazania[i].do_obiektu := 0;
       powiazania[i].od_strzalka := False;
       powiazania[i].do_strzalka := False;
       {$IFDEF ANDROID}
       powiazania[i].linia.DisposeOf;
       powiazania[i].linia2.DisposeOf;
       powiazania[i].linia3.DisposeOf;
       powiazania[i].strzalka_od.DisposeOf;
       powiazania[i].strzalka_do.DisposeOf;
       {$ELSE}
       powiazania[i].linia.Free;
       powiazania[i].linia:=nil;
       powiazania[i].linia2.Free;
       powiazania[i].linia2:=nil;
       powiazania[i].linia3.Free;
       powiazania[i].linia3:=nil;
       powiazania[i].strzalka_od.Free;
       powiazania[i].strzalka_od:=nil;
       powiazania[i].strzalka_do.Free;
       powiazania[i].strzalka_do:=nil;
       {$ENDIF}
      End;
    End;

   RamkaEdycjaProcesu1.Visible:=False;
   Rysuj_powiazania;
   Rysowanie.Enabled:=True;
  End;
end;

procedure TAOknoGl.RamkaEdycjaProcesu1btn_save_process_dataClick(Sender: TObject);
var
  i: Integer;
begin
 for i := 0 to wybrany.ChildrenCount-1 do
  Begin
   if wybrany.Children[i] is TLabel then
    Begin
     TLabel(wybrany.Children[i]).Text:=RamkaEdycjaProcesu1.memo_process_name.Text;
    End;
  End;
 RamkaEdycjaProcesu1.Visible:=False;
 Deaktywuj_obiekt;
end;

procedure TAOknoGl.RamkaEdycjaProcesu1btn_udelete_linksClick(Sender: TObject);
Var
 i, id_procesu, ktory_w_tablicy : Integer;
begin
 ktory_w_tablicy:=0;
 id_procesu:=0;
 for i:= 1 to max_obiektow do
  Begin
   if obiekty[i].wskaznik=wybrany then
    Begin
     id_procesu:=obiekty[i].id_obiektu;
     ktory_w_tablicy:=i;
    End;
  End;

 if ktory_w_tablicy>0 then
  Begin
   Rysowanie.Enabled:=False;
   Deaktywuj_obiekt;
   //Teraz kasujê powi¹zania
   for i := 1 to max_powiazan do
    Begin
     if (powiazania[i].od_obiektu=id_procesu) OR (powiazania[i].do_obiektu=id_procesu) then
      Begin
       powiazania[i].od_obiektu := 0;
       powiazania[i].do_obiektu := 0;
       powiazania[i].od_strzalka := False;
       powiazania[i].do_strzalka := False;
       {$IFDEF ANDROID}
       powiazania[i].linia.DisposeOf;
       powiazania[i].linia2.DisposeOf;
       powiazania[i].linia3.DisposeOf;
       powiazania[i].strzalka_od.DisposeOf;
       powiazania[i].strzalka_do.DisposeOf;
       {$ELSE}
       powiazania[i].linia.Free;
       powiazania[i].linia:=nil;
       powiazania[i].linia2.Free;
       powiazania[i].linia2:=nil;
       powiazania[i].linia3.Free;
       powiazania[i].linia3:=nil;
       powiazania[i].strzalka_od.Free;
       powiazania[i].strzalka_od:=nil;
       powiazania[i].strzalka_do.Free;
       powiazania[i].strzalka_do:=nil;
       {$ENDIF}
      End;
    End;

   RamkaEdycjaProcesu1.Visible:=False;
   Rysuj_powiazania;
   Rysowanie.Enabled:=True;
  End;
end;

procedure TAOknoGl.RamkaMenuGlowne1btn_close_menuClick(Sender: TObject);
begin
 RamkaMenuGlowne1.Visible:=False;
end;

procedure TAOknoGl.RamkaMenuGlowne1btn_new_diagramClick(Sender: TObject);
begin
 Czysc_obiekty_i_powiazania;
 RamkaMenuGlowne1.Visible:=False;
end;

procedure TAOknoGl.RamkaPowiazanie1btn_addClick(Sender: TObject);
Var
 od_obiektu, do_obiektu : Integer;
  i: Integer;
begin
 if (RamkaPowiazanie1.img_do.Visible=False) and (RamkaPowiazanie1.img_do.Visible=False) then
  Begin
   //Musi byæ jakaœ strza³ka
  End
 else
  Begin
   for i := 1 to max_obiektow do
    Begin
     if obiekty[i].wskaznik=wybrany_pierwszy then od_obiektu:=obiekty[i].id_obiektu;
     if obiekty[i].wskaznik=wybrany_drugi then do_obiektu:=obiekty[i].id_obiektu;
    End;
   Dodaj_powiazanie(od_obiektu, do_obiektu, RamkaPowiazanie1.img_od.Visible, RamkaPowiazanie1.img_do.Visible);
   Rysuj_powiazania;
   RamkaPowiazanie1.Visible:=False;
   Odznacz_wybrane(False,True);
  End;
end;

procedure TAOknoGl.RamkaPowiazanie1but_cancelClick(Sender: TObject);
begin
 RamkaPowiazanie1.Visible:=False;
 Odznacz_wybrane(False,True);
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

procedure TAOknoGl.RysowanieTimer(Sender: TObject);
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
  for i := 1 to max_powiazan do
  Begin
    if Powiazania[i].od_obiektu > 0 then
    Begin
      for o := 1 to max_obiektow do
      Begin
        if Obiekty[o].id_obiektu = Powiazania[i].od_obiektu then obiekt_index_od := o;
      End;
      for o := 1 to max_obiektow do
      Begin
        if Obiekty[o].id_obiektu = Powiazania[i].do_obiektu then obiekt_index_do := o;
      End;
      Rysuj_powiazanie(obiekt_index_od, obiekt_index_do, Powiazania[i].od_strzalka, Powiazania[i].do_strzalka, Powiazania[i].linia, Powiazania[i].linia2, Powiazania[i].linia3, Powiazania[i].strzalka_od, Powiazania[i].strzalka_do);
    End;
  End;
End;

procedure TAOknoGl.Rysuj_powiazanie(od_obiektu, do_obiektu: Integer; od_strzalka, do_strzalka: Boolean; linia, linia2, linia3: TLine; strzalka_od, strzalka_do: TImage);
var
  od_rect, do_rect: TRectangle;
  poy, koy : Single;
  x1, y1 : Single;
  x2, y2 : Single;
  ox, oy : Single;
  kier: Char;
  pozycja_test: Integer;
  licznik_obrotow: Integer;
begin

 if (od_strzalka) or (do_strzalka) then
  Begin
    od_rect := Obiekty[od_obiektu].wskaznik;
    do_rect := Obiekty[do_obiektu].wskaznik;

    poy:=od_rect.Position.Y-od_rect.Height-(od_rect.Height/2);
    koy:=od_rect.Position.Y+od_rect.Height+(od_rect.Height/2);

    if (do_rect.Position.Y>poy) and (do_rect.Position.Y<koy) then
     Begin
      //Jeœli obiekty s¹ na podobnym poziomie;
      y1:=od_rect.Position.Y+(od_rect.Height/2);
      y2:=do_rect.Position.Y+(do_rect.Height/2);

      if do_rect.Position.X>od_rect.Position.X then
       Begin
        //docelowy jest na prawo
        x1:=od_rect.Position.X+od_rect.Width;
        x2:=do_rect.Position.X;
        kier:='P';
       End
      else
       Begin
        //docelowy jest na lewo
        x1:=od_rect.Position.X;
        x2:=do_rect.Position.X+do_rect.Width;
        kier:='L';
       End;

      End
    else
     Begin
      if do_rect.Position.Y>od_rect.Position.Y then
       Begin
        //Jeœli obiekt docelowy jest ni¿ej ni¿ obiekt Ÿród³owy
        y1:=od_rect.Position.Y+od_rect.Height;
        y2:=do_rect.Position.Y;
        kier:='D';
       End
      else
       Begin
        y1:=od_rect.Position.Y;
        y2:=do_rect.Position.Y+do_rect.Height;
        kier:='G';
       End;

       x1:=od_rect.Position.X+(od_rect.Width/2);
       x2:=do_rect.Position.X+(do_rect.Width/2);
     End;


     if Czy_juz_jest_tu_punkt_styku(x1,y1)=True then
      Begin
       pozycja_test:=odstep_miedzy_liniami;
       licznik_obrotow:=1;
       Repeat
        if kier IN ['L','P'] then y1:=y1+pozycja_test;
        if kier IN ['D','G'] then x1:=x1+pozycja_test;
        if licznik_obrotow<0 then licznik_obrotow:=licznik_obrotow-1
        else licznik_obrotow:=licznik_obrotow+1;
        licznik_obrotow:=licznik_obrotow*-1;
        pozycja_test:=odstep_miedzy_liniami*licznik_obrotow;
        Until Czy_juz_jest_tu_punkt_styku(x1,y1)=False;
      End;
     Dodaj_punkt_styku(x1,y1);

     if Czy_juz_jest_tu_punkt_styku(x2,y2)=True then
      Begin
       pozycja_test:=odstep_miedzy_liniami;
       licznik_obrotow:=1;
       Repeat
        if kier IN ['L','P'] then y2:=y2+pozycja_test;
        if kier IN ['D','G'] then x2:=x2+pozycja_test;
        if licznik_obrotow<0 then licznik_obrotow:=licznik_obrotow-1
        else licznik_obrotow:=licznik_obrotow+1;
        licznik_obrotow:=licznik_obrotow*-1;
        pozycja_test:=odstep_miedzy_liniami*-licznik_obrotow;
        Until Czy_juz_jest_tu_punkt_styku(x2,y2)=False;
      End;
     Dodaj_punkt_styku(x2,y2);


    if kier='D' then
     Begin
      oy:=y1+((y2-y1)/2);
      DrawLineBetweenPoints(linia, PointF(x1, y1), PointF(x1, oy));
      DrawLineBetweenPoints(linia2, PointF(x1, oy), PointF(x2, oy));
      DrawLineBetweenPoints(linia3, PointF(x2, oy), PointF(x2, y2));
      if do_strzalka=True then
       Begin
        strzalka_do.Visible:=True;
        strzalka_do.Position.X:=x2-(WzorStrzalki.Width/2);
        strzalka_do.Position.Y:=y2-WzorStrzalki.Height+7;
        strzalka_do.RotationAngle:=90;
       End
      else strzalka_do.Visible:=False;
      if od_strzalka=True then
       Begin
        strzalka_od.Visible:=True;
        strzalka_od.Position.X:=x1-(WzorStrzalki.Width/2);
        strzalka_od.Position.Y:=y1-7;
        strzalka_od.RotationAngle:=270;
       End
      else strzalka_od.Visible:=False;
     End;
   if kier='G' then
     Begin
      oy:=y2+((y1-y2)/2);
      DrawLineBetweenPoints(linia, PointF(x1, y1), PointF(x1, oy));
      DrawLineBetweenPoints(linia2, PointF(x1, oy), PointF(x2, oy));
      DrawLineBetweenPoints(linia3, PointF(x2, oy), PointF(x2, y2));
      if do_strzalka=True then
       Begin
        strzalka_do.Visible:=True;
        strzalka_do.Position.X:=x2-(WzorStrzalki.Width/2);
        strzalka_do.Position.Y:=y2-7;
        strzalka_do.RotationAngle:=270;
       End
      else strzalka_do.Visible:=False;
      if od_strzalka=True then
       Begin
        strzalka_od.Visible:=True;
        strzalka_od.Position.X:=x1-(WzorStrzalki.Width/2);
        strzalka_od.Position.Y:=y1-WzorStrzalki.Height+7;
        strzalka_od.RotationAngle:=90;
       End
      else strzalka_od.Visible:=False;
     End;

    if kier='P' then
     Begin
      ox:=x1+((x2-x1)/2);
      DrawLineBetweenPoints(linia, PointF(x1, y1), PointF(ox, y1));
      DrawLineBetweenPoints(linia2, PointF(ox, y1), PointF(ox, y2));
      DrawLineBetweenPoints(linia3, PointF(ox, y2), PointF(x2, y2));
      if do_strzalka=True then
       Begin
        strzalka_do.Visible:=True;
        strzalka_do.Position.X:=x2-(WzorStrzalki.Width)+7;
        strzalka_do.Position.Y:=y2-(WzorStrzalki.Height/2);
        strzalka_do.RotationAngle:=0;
       End
      else strzalka_do.Visible:=False;
      if od_strzalka=True then
       Begin
        strzalka_od.Visible:=True;
        strzalka_od.Position.X:=x1-7;
        strzalka_od.Position.Y:=y1-(WzorStrzalki.Height/2);
        strzalka_od.RotationAngle:=180;
       End
      else strzalka_od.Visible:=False;
     End;
    if kier='L' then
     Begin
      ox:=x2+((x1-x2)/2);
      DrawLineBetweenPoints(linia, PointF(x1, y1), PointF(ox, y1));
      DrawLineBetweenPoints(linia2, PointF(ox, y1), PointF(ox, y2));
      DrawLineBetweenPoints(linia3, PointF(ox, y2), PointF(x2, y2));
      if do_strzalka=True then
       Begin
        strzalka_do.Visible:=True;
        strzalka_do.Position.X:=x2-7;
        strzalka_do.Position.Y:=y2-(WzorStrzalki.Height/2);
        strzalka_do.RotationAngle:=180;
       End
      else strzalka_do.Visible:=False;
      if od_strzalka=True then
       Begin
        strzalka_od.Visible:=True;
        strzalka_od.Position.X:=x1-(WzorStrzalki.Width)+7;
        strzalka_od.Position.Y:=y1-(WzorStrzalki.Height/2);
        strzalka_od.RotationAngle:=0;
       End
      else strzalka_od.Visible:=False;
     End;

    od_rect.BringToFront;
    do_rect.BringToFront;

  end;

end;

procedure TAOknoGl.Dodaj_wskaznik(proces : TRectangle; index_procesu : Integer);
var
  i: Integer;
  nowy: Integer;
Begin
 nowy:=0;
 for i := 1 to max_obiektow do
  Begin
   if (obiekty[i].id_obiektu=0) and (nowy=0) then nowy:=i;
  End;

 obiekty[nowy].id_obiektu:=index_procesu;
 obiekty[nowy].wskaznik:=proces;
End;

function TAOknoGl.Ostatni_obiekt: Integer;
Var
 wynik : Integer;
  i: Integer;
Begin
 wynik:=0;
  for i := 1 to max_obiektow do
   Begin
    if obiekty[i].id_obiektu>0 then wynik:=obiekty[i].id_obiektu;
   End;
 Ostatni_obiekt:=wynik;
End;

procedure TAOknoGl.btn_dodaj_nowy_procesClick(Sender: TObject);
Var
 tmp : TRectangle;
 i : Integer;
  index_obiektu: Integer;
begin
 Odznacz_wybrane(True,True);
 btn_laczenie_procesow.IsPressed:=False;

 tmp := TRectangle(WzorObiektu.Clone(self));
 tmp.Parent := ScrollBox;
 tmp.Visible:=True;
 tmp.Position.X:=+10;
 tmp.Position.Y:=GridMenuGornego.Position.Y+GridMenuGornego.Height+10;
 tmp.OnMouseDown:=WzorObiektuMouseDown;
 tmp.OnMouseMove:=WzorObiektuMouseMove;
 tmp.OnMouseUp:=WzorObiektuMouseUp;
 tmp.OnDblClick:=Wzor_labelDblClick;
 tmp.OnTap:=Wzor_labelTap;

 index_obiektu:=Ostatni_obiekt+1;
 Dodaj_wskaznik(tmp,index_obiektu);

 for i := 0 to tmp.ChildrenCount-1 do
  Begin
   if tmp.Children[i] is TLabel then
    Begin
     TLabel(tmp.Children[i]).Text:='Nowy proces'+#13+'('+IntToStr(index_obiektu)+')';
    End;
  End;

 Rysuj_powiazania;
end;

procedure TAOknoGl.btn_hamburgerClick(Sender: TObject);
begin
 RamkaMenuGlowne1.Visible:=Not(RamkaMenuGlowne1.Visible);
end;

procedure TAOknoGl.btn_laczenie_procesowClick(Sender: TObject);
begin
 Odznacz_wybrane(True,True);
end;

procedure TAOknoGl.Czysc_obiekty_i_powiazania;
var
  i: Integer;
Begin
 for i := 1 to max_obiektow do
  Begin
   obiekty[i].id_obiektu:=0;
   {$IFDEF ANDROID}
    obiekty[i].wskaznik.DisposeOf;
   {$ELSE}
    obiekty[i].wskaznik.Free;
    obiekty[i].wskaznik:=nil;
   {$ENDIF}
  End;

 for i := 1 to max_powiazan do
  Begin
   Powiazania[i].od_obiektu := 0;
   Powiazania[i].do_obiektu := 0;
   Powiazania[i].od_strzalka := False;
   Powiazania[i].do_strzalka := False;
   {$IFDEF ANDROID}
    Powiazania[i].linia.DisposeOf;
    Powiazania[i].linia2.DisposeOf;
    Powiazania[i].linia3.DisposeOf;
    Powiazania[i].strzalka_od.DisposeOf;
    Powiazania[i].strzalka_do.DisposeOf;
   {$ELSE}
    Powiazania[i].linia.Free;
    Powiazania[i].linia:=nil;
    Powiazania[i].linia2.Free;
    Powiazania[i].linia2:=nil;
    Powiazania[i].linia3.Free;
    Powiazania[i].linia3:=nil;
    Powiazania[i].strzalka_od.Free;
    Powiazania[i].strzalka_od:=nil;
    Powiazania[i].strzalka_do.Free;
    Powiazania[i].strzalka_do:=nil;
   {$ENDIF}
  End;
 Rysuj_powiazania;
End;

procedure TAOknoGl.FormCreate(Sender: TObject);
begin
 Caption:='FMX Obiekty Designer - wersja: '+wersja;
 MouseIsDown := False;
 WzorObiektu.Visible:=False;
 WzorLinii.Visible:=False;
 Czysc_obiekty_i_powiazania;
 RamkaMenuGlowne1.Visible:=False;
 RamkaEdycjaProcesu1.Visible:=False;

 {$IFDEF ANDROID}
   Wzor_label.TextSettings.Font.Size:=10;
 {$ELSE}
   Wzor_label.TextSettings.Font.Size:=12;
 {$ENDIF}
end;

procedure TAOknoGl.WzorObiektuMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
 if btn_laczenie_procesow.IsPressed then
  Begin
   if wybrany_pierwszy = nil then
    Begin
     wybrany_pierwszy:=TRectangle(Sender);
     wybrany_pierwszy.BringToFront;
     wybrany_pierwszy.Fill.Color:=TAlphaColor($AA7A0707);
    End
   else
    Begin
     //Jeœli pierwszy jest ju¿ wybrany
     if TRectangle(Sender)=wybrany_pierwszy then
      Begin
       //Jeœli nowo klikniêty jest wybranym
       wybrany_pierwszy.Fill.Color:=TAlphaColor($AA0F077A);
       wybrany_pierwszy:=Nil;
      End
     else
      Begin
       //Jeœli pierwszy jest wybrany i teraz wybraliœmy drugi!
       wybrany_drugi:=TRectangle(Sender);
       wybrany_drugi.BringToFront;
       wybrany_drugi.Fill.Color:=TAlphaColor($AA7A0707);
       RamkaPowiazanie1.Visible:=True;
       RamkaPowiazanie1.lbl_od_procesu.Text:= TLabel(wybrany_pierwszy.Children[0]).Text;
       RamkaPowiazanie1.lbl_do_procesu.Text:= TLabel(wybrany_drugi.Children[0]).Text;
       RamkaPowiazanie1.img_od.Visible:=False;
       RamkaPowiazanie1.img_do.Visible:=True;
      End;
    End;
  End
 else
  Begin
   wybrany:=TRectangle(Sender);
   wybrany.BringToFront;
   X1 := round(X);
   Y1 := round(Y);
   wybrany.Fill.Color:=TAlphaColor($AA7A0707);
   MouseIsDown := True;
   Rysowanie.Enabled:=True;
  End;
end;

procedure TAOknoGl.WzorObiektuMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
 if btn_laczenie_procesow.IsPressed = False then
  Begin
   if MouseIsDown then
    begin
      wybrany.Position.X := wybrany.Position.X + round(X) - X1;
      wybrany.Position.Y := wybrany.Position.Y + round(Y) - Y1;
    end;
  End;
end;

procedure TAOknoGl.Deaktywuj_obiekt;
Begin
 MouseIsDown := False;
 wybrany.Fill.Color:=TAlphaColor($AA0F077A);
 Rysowanie.Enabled:=False;
 Rysuj_powiazania;
End;

procedure TAOknoGl.WzorObiektuMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
 if btn_laczenie_procesow.IsPressed = False then Deaktywuj_obiekt;
end;

procedure TAOknoGl.Edycja_danych_procesu;
var
  i: Integer;
begin
 if btn_laczenie_procesow.IsPressed = False then
  Begin
    for i := 0 to wybrany.ChildrenCount - 1 do
    Begin
      if wybrany.Children[i] is TLabel then
      Begin
        RamkaEdycjaProcesu1.Visible := True;
        RamkaEdycjaProcesu1.memo_process_name.Text := TLabel(wybrany.Children[i]).Text;
      End;
    End;
  End;
end;

procedure TAOknoGl.Wzor_labelDblClick(Sender: TObject);
begin
 Edycja_danych_procesu;
end;

procedure TAOknoGl.Wzor_labelTap(Sender: TObject; const Point: TPointF);
begin
 Edycja_danych_procesu;
end;

end.
