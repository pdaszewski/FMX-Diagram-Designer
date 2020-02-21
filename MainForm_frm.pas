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
  TMainForm = class(TForm)
    BackgroundImage: TImage;
    MainGrid: TGridPanelLayout;
    TopMenuGrid: TGridPanelLayout;
    btn_hamburger: TButton;
    btn_dodaj_nowy_proces: TButton;
    ScrollBox: TScrollBox;
    LinePattern: TLine;
    ObjectPattern: TRectangle;
    LabelPattern: TLabel;
    ProcessEditingFrame1: TProcessEditingFrame;
    MainMenuFrame1: TMainMenuFrame;
    LinkageFrame1: TLinkageFrame;
    DrawingTimer: TTimer;
    ArrowsPattern: TImage;
    btn_laczenie_procesow: TButton;
    lbl_bottom_info: TLabel;
    SaveProjectDialog: TSaveDialog;
    OpenProjectDialog: TOpenDialog;

    procedure Deactivate_Object;
    procedure Clear_Objects_And_Links;
    function Last_Object: Integer;
    procedure Add_pointer(process: TRectangle; process_index: Integer);
    procedure Draw_links;
    procedure Draw_link(from_object, to_object: Integer; from_arrow, to_arrow: Boolean; text_line_1, text_line_2, text_line_3: TLine; from_arrow_image, to_arrow_image: TImage);
    procedure DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
    procedure Add_link(from_object_index, to_object_index: Integer; from_arrow, to_arrow: Boolean);
    procedure Remove_link(from_object_index, to_object_index: Integer);
    procedure Editing_process_data;
    function Which_connection(from_object, to_object: TRectangle): Integer;
    function Which_object(indicated_object: TRectangle): Integer;
    procedure Change_line_style(new_style : TStrokeDash);

    procedure Clean_contact_points;
    procedure Add_contact_point(x, y: Single);
    function Is_there_already_a_point_of_contact_here(x, y: Single): Boolean;

    procedure Deselect_objects(first, second: Boolean);
    procedure Set_link_arrow(arrow: String);
    function XML_value(record_line: string): String;

    procedure FormCreate(Sender: TObject);
    procedure ObjectPatternMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
    procedure ObjectPatternMouseMove(Sender: TObject; Shift: TShiftState; x, y: Single);
    procedure ObjectPatternMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
    procedure LabelPatternDblClick(Sender: TObject);
    procedure LabelPatternTap(Sender: TObject; const Point: TPointF);
    procedure btn_dodaj_nowy_procesClick(Sender: TObject);
    procedure btn_hamburgerClick(Sender: TObject);
    procedure ProcessEditingFrame1btn_save_process_dataClick(Sender: TObject);
    procedure DrawingTimerTimer(Sender: TObject);
    procedure MainMenuFrame1btn_new_diagramClick(Sender: TObject);
    procedure MainMenuFrame1btn_close_menuClick(Sender: TObject);
    procedure LinkageFrame1but_cancelClick(Sender: TObject);
    procedure btn_laczenie_procesowClick(Sender: TObject);
    procedure LinkageFrame1rec_doClick(Sender: TObject);
    procedure LinkageFrame1img_doClick(Sender: TObject);
    procedure LinkageFrame1rec_odClick(Sender: TObject);
    procedure LinkageFrame1img_odClick(Sender: TObject);
    procedure LinkageFrame1btn_addClick(Sender: TObject);
    procedure ProcessEditingFrame1btn_delete_processClick(Sender: TObject);
    procedure ProcessEditingFrame1btn_udelete_linksClick(Sender: TObject);
    procedure ObjectPatternMouseLeave(Sender: TObject);
    procedure MainMenuFrame1btn_full_screen_modeClick(Sender: TObject);
    procedure MainMenuFrame1btn_openClick(Sender: TObject);
    procedure MainMenuFrame1btn_saveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  version = '1.0.2.6';
  build_date = '2020-02-21';

  max_objects = 100;
  max_objects_links = 1000;
  max_poinst_of_contact = 10000;

  line_spacing = 10;

var
  MainForm: TMainForm;
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

procedure TMainForm.Change_line_style(new_style : TStrokeDash);
var
  i: Integer;
Begin
 LinePattern.Stroke.Dash:=new_style;
 LinkageFrame1.LinePattern.Stroke.Dash:=new_style;
 for i := 1 to max_objects_links do
  Begin
   if objects_links_array[i].from_object>0 then
    Begin
     objects_links_array[i].text_line_1.Stroke.Dash:=new_style;
     objects_links_array[i].text_line_2.Stroke.Dash:=new_style;
     objects_links_array[i].text_line_3.Stroke.Dash:=new_style;
    End;
  End;
End;

function TMainForm.Which_object(indicated_object: TRectangle): Integer;
Var
 outcome, i : Integer;
Begin
 outcome:=0;
 for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = indicated_object then outcome:=i;
  End;
 Which_object:=outcome;
End;

function TMainForm.Which_connection(from_object, to_object: TRectangle): Integer;
Var
  outcome: Integer;
  from_object_index, to_object_index: Integer;
  i: Integer;
Begin
  outcome := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = from_object then
      from_object_index := objects_array[i].id_object;
    if objects_array[i].indicator = to_object then
      to_object_index := objects_array[i].id_object;
  End;

  for i := 1 to max_objects_links do
  Begin
    if (objects_links_array[i].from_object = from_object_index) and (objects_links_array[i].to_object = to_object_index) then
      outcome := i;
    if (objects_links_array[i].from_object = to_object_index) and (objects_links_array[i].to_object = from_object_index) then
      outcome := i;
  End;

  Which_connection := outcome;
End;

procedure TMainForm.Set_link_arrow(arrow: String);
begin
  arrow := Trim(AnsiLowerCase(arrow));
  if arrow = 'do' then
  Begin
    if LinkageFrame1.img_do.Visible then
      LinkageFrame1.img_do.Visible := False
    else
      LinkageFrame1.img_do.Visible := True;
  End
  else
  Begin
    if LinkageFrame1.img_od.Visible then
      LinkageFrame1.img_od.Visible := False
    else
      LinkageFrame1.img_od.Visible := True;
  End;

  if (LinkageFrame1.img_od.Visible = False) and (LinkageFrame1.img_do.Visible = False) then
    LinkageFrame1.btn_add.Text := 'remove association'
  else
    LinkageFrame1.btn_add.Text := 'add association';
end;

procedure TMainForm.Deselect_objects(first, second: Boolean);
Begin
  if (first) and (selected_first <> nil) then
  Begin
    selected_first.Fill.Color := TAlphaColor($AA0F077A);
    selected_first := nil;
  End;
  if (second) and (selected_second <> nil) then
  Begin
    selected_second.Fill.Color := TAlphaColor($AA0F077A);
    selected_second := nil;
  End;
End;

function TMainForm.Is_there_already_a_point_of_contact_here(x, y: Single): Boolean;
Var
  outcome: Boolean;
  i: Integer;
Begin
  outcome := False;
  for i := 1 to max_poinst_of_contact do
  Begin
    if (point_of_contact_array[i].x = x) and (point_of_contact_array[i].y = y) then
    Begin
      outcome := True;
      Break;
    End;
  End;
  Is_there_already_a_point_of_contact_here := outcome;
End;

procedure TMainForm.Clean_contact_points;
var
  i: Integer;
Begin
  for i := 1 to max_poinst_of_contact do
  Begin
    point_of_contact_array[i].x := 0;
    point_of_contact_array[i].y := 0;
  End;
End;

procedure TMainForm.Add_contact_point(x, y: Single);
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

procedure TMainForm.Remove_link(from_object_index, to_object_index: Integer);
var
  i: Integer;
  is_exists: Boolean;
  existing_object: Integer;
Begin
  existing_object := 0;
  is_exists := False;
  for i := 1 to max_objects_links do
  Begin
    if (objects_links_array[i].from_object = from_object_index) and (objects_links_array[i].to_object = to_object_index) then
    Begin
      existing_object := i;
      is_exists := True;
    End;
    if (objects_links_array[i].from_object = to_object_index) and (objects_links_array[i].to_object = from_object_index) then
    Begin
      existing_object := i;
      is_exists := True;
    End;
  End;

  if is_exists = True then
  Begin
    objects_links_array[existing_object].from_object := 0;
    objects_links_array[existing_object].to_object := 0;
    objects_links_array[existing_object].from_arrow := False;
    objects_links_array[existing_object].to_arrow := False;
{$IFDEF ANDROID}
    objects_links_array[existing_object].linia.DisposeOf;
    objects_links_array[existing_object].linia2.DisposeOf;
    objects_links_array[existing_object].linia3.DisposeOf;
    objects_links_array[existing_object].strzalka_od.DisposeOf;
    objects_links_array[existing_object].strzalka_do.DisposeOf;
{$ELSE}
    objects_links_array[existing_object].text_line_1.Free;
    objects_links_array[existing_object].text_line_1 := nil;
    objects_links_array[existing_object].text_line_2.Free;
    objects_links_array[existing_object].text_line_2 := nil;
    objects_links_array[existing_object].text_line_3.Free;
    objects_links_array[existing_object].text_line_3 := nil;
    objects_links_array[existing_object].arrow_image_from.Free;
    objects_links_array[existing_object].arrow_image_from := nil;
    objects_links_array[existing_object].arrow_image_to.Free;
    objects_links_array[existing_object].arrow_image_to := nil;
{$ENDIF}
  End;
End;

procedure TMainForm.Add_link(from_object_index, to_object_index: Integer; from_arrow, to_arrow: Boolean);
var
  i: Integer;
  new: Integer;
  tmpl, tmpl2, tmpl3: TLine;
  img1, img2: TImage;
  is_exists: Boolean;
  existing: Integer;
Begin
  new := 0;
  existing := 0;
  is_exists := False;
  for i := 1 to max_objects_links do
  Begin
    if (objects_links_array[i].from_object = 0) and (new = 0) then
      new := i;
    if (objects_links_array[i].from_object = from_object_index) and (objects_links_array[i].to_object = to_object_index) then
    Begin
      existing := i;
      is_exists := True;
    End;
    if (objects_links_array[i].from_object = to_object_index) and (objects_links_array[i].to_object = from_object_index) then
    Begin
      existing := i;
      is_exists := True;
    End;
  End;

  if (new > 0) and (is_exists = False) then
  Begin
    objects_links_array[new].from_object := from_object_index;
    objects_links_array[new].to_object := to_object_index;
    objects_links_array[new].from_arrow := from_arrow;
    objects_links_array[new].to_arrow := to_arrow;

    tmpl := TLine(LinePattern.Clone(self));
    tmpl.Parent := ScrollBox;
    tmpl.Visible := True;
    objects_links_array[new].text_line_1 := tmpl;

    tmpl2 := TLine(LinePattern.Clone(self));
    tmpl2.Parent := ScrollBox;
    tmpl2.Visible := True;
    objects_links_array[new].text_line_2 := tmpl2;

    tmpl3 := TLine(LinePattern.Clone(self));
    tmpl3.Parent := ScrollBox;
    tmpl3.Visible := True;
    objects_links_array[new].text_line_3 := tmpl3;

    img1 := TImage(ArrowsPattern.Clone(self));
    img1.Parent := ScrollBox;
    img1.Visible := True;
    objects_links_array[new].arrow_image_from := img1;

    img2 := TImage(ArrowsPattern.Clone(self));
    img2.Parent := ScrollBox;
    img2.Visible := True;
    objects_links_array[new].arrow_image_to := img2;

    Draw_links;
  End;

  if is_exists = True then
  Begin
    objects_links_array[existing].from_object := from_object_index;
    objects_links_array[existing].to_object := to_object_index;
    objects_links_array[existing].from_arrow := from_arrow;
    objects_links_array[existing].to_arrow := to_arrow;
  End;
End;

procedure TMainForm.DrawLineBetweenPoints(L: TLine; p1, p2: TPointF);
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
  if (L.Height < 0.01) then L.Height := 0.1;
  if (L.Width < 0.01) then L.Width := 0.1;
end;

procedure TMainForm.ProcessEditingFrame1btn_delete_processClick(Sender: TObject);
Var
  i, process_id, which_in_array: Integer;
begin
  which_in_array := 0;
  process_id := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = selected then
    Begin
      process_id := objects_array[i].id_object;
      which_in_array := i;
    End;
  End;

  if which_in_array > 0 then
  Begin
    DrawingTimer.Enabled := False;
    Deactivate_Object;
    selected := nil;
    // Delete the object first
    objects_array[which_in_array].id_object := 0;
{$IFDEF ANDROID}
    obiekty[which_in_array].indicator.DisposeOf;
{$ELSE}
    objects_array[which_in_array].indicator.Free;
    objects_array[which_in_array].indicator := nil;
{$ENDIF}
    // Now deleting the connections
    for i := 1 to max_objects_links do
    Begin
      if (objects_links_array[i].from_object = process_id) OR (objects_links_array[i].to_object = process_id) then
      Begin
        objects_links_array[i].from_object := 0;
        objects_links_array[i].to_object := 0;
        objects_links_array[i].from_arrow := False;
        objects_links_array[i].to_arrow := False;
{$IFDEF ANDROID}
        objects_links_array[i].text_line_1.DisposeOf;
        objects_links_array[i].text_line_2.DisposeOf;
        objects_links_array[i].text_line_3.DisposeOf;
        objects_links_array[i].arrow_image_from.DisposeOf;
        objects_links_array[i].arrow_image_to.DisposeOf;
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

    ProcessEditingFrame1.Visible := False;
    Draw_links;
    DrawingTimer.Enabled := True;
  End;
end;

procedure TMainForm.ProcessEditingFrame1btn_save_process_dataClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to selected.ChildrenCount - 1 do
  Begin
    if selected.Children[i] is TLabel then
    Begin
      TLabel(selected.Children[i]).Text := ProcessEditingFrame1.memo_process_name.Text;
    End;
  End;
  ProcessEditingFrame1.Visible := False;
  Deactivate_Object;
end;

procedure TMainForm.ProcessEditingFrame1btn_udelete_linksClick(Sender: TObject);
Var
  i, process_id, which_in_array: Integer;
begin
  which_in_array := 0;
  process_id := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = selected then
    Begin
      process_id := objects_array[i].id_object;
      which_in_array := i;
    End;
  End;

  if which_in_array > 0 then
  Begin
    DrawingTimer.Enabled := False;
    Deactivate_Object;
    // Now deleting the connections
    for i := 1 to max_objects_links do
    Begin
      if (objects_links_array[i].from_object = process_id) OR (objects_links_array[i].to_object = process_id) then
      Begin
        objects_links_array[i].from_object := 0;
        objects_links_array[i].to_object := 0;
        objects_links_array[i].from_arrow := False;
        objects_links_array[i].to_arrow := False;
{$IFDEF ANDROID}
        objects_links_array[i].text_line_1.DisposeOf;
        objects_links_array[i].text_line_2.DisposeOf;
        objects_links_array[i].text_line_3.DisposeOf;
        objects_links_array[i].arrow_image_from.DisposeOf;
        objects_links_array[i].arrow_image_to.DisposeOf;
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

    ProcessEditingFrame1.Visible := False;
    Draw_links;
    DrawingTimer.Enabled := True;
  End;
end;

procedure TMainForm.MainMenuFrame1btn_close_menuClick(Sender: TObject);
begin
  MainMenuFrame1.Visible := False;
end;

procedure TMainForm.MainMenuFrame1btn_full_screen_modeClick(Sender: TObject);
begin
 if MainForm.FullScreen then MainForm.FullScreen:=False
 else MainForm.FullScreen:=True;
end;

procedure TMainForm.MainMenuFrame1btn_new_diagramClick(Sender: TObject);
begin
  Clear_Objects_And_Links;
  MainMenuFrame1.Visible := False;
end;

function TMainForm.XML_value(record_line: string): String;
Var
 outcome : String;
 poz: Integer;
Begin
 poz:=Pos('>',record_line); outcome:=Copy(record_line,poz+1,Length(record_line));
 poz:=Pos('</',outcome); outcome:=Copy(outcome,1,poz-1);
 outcome:=Trim(outcome);
 XML_value:=outcome;
End;

procedure TMainForm.MainMenuFrame1btn_openClick(Sender: TObject);
Var
  tmp: TRectangle;
  file_body : TStringList;
  text_line : String;
  o,i: Integer;
  is_loaded: Boolean;
  object_id: string;
  inscription: string;
  x_object: string;
  y_object: string;
  from_object: string;
  to_object: string;
  from_arrow: string;
  to_arrow: string;
begin
 Clear_Objects_And_Links;
 file_body := TStringList.Create;
 is_loaded:=False;

 { TODO : Add the project load from the file for Android and possibly iOS}
{$IFDEF ANDROID}

{$ELSE}
  if OpenProjectDialog.Execute then
   Begin
    file_body.LoadFromFile(OpenProjectDialog.FileName);
    is_loaded:=True;
   End;
{$ENDIF}

 if is_loaded=True then
  Begin
   MainMenuFrame1.Visible := False;
   for i := 0 to file_body.Count-1 do
    Begin
     text_line:=Trim(file_body.Strings[i]);

     if Pos('<object>',text_line)>0 then
      Begin
       //now I have access to the given objects
       object_id  :=XML_value(file_body.Strings[i+1]);
       inscription:=XML_value(file_body.Strings[i+2]);
       inscription:=StringReplace(inscription,'#13',#13,[rfReplaceAll]);
       x_object   :=XML_value(file_body.Strings[i+3]);
       y_object   :=XML_value(file_body.Strings[i+4]);

        tmp := TRectangle(ObjectPattern.Clone(self));
        tmp.Parent := ScrollBox;
        tmp.Visible := True;
        tmp.Position.x := StrToFloat(x_object);
        tmp.Position.y := StrToFloat(y_object);
        tmp.OnMouseDown := ObjectPatternMouseDown;
        tmp.OnMouseMove := ObjectPatternMouseMove;
        tmp.OnMouseUp := ObjectPatternMouseUp;
        tmp.OnDblClick := LabelPatternDblClick;
        tmp.OnMouseLeave := ObjectPatternMouseLeave;
        tmp.OnTap := LabelPatternTap;

        Add_pointer(tmp, StrToInt(object_id));

        for o := 0 to tmp.ChildrenCount - 1 do
         Begin
          if tmp.Children[o] is TLabel then
           Begin
            TLabel(tmp.Children[o]).Text := inscription;
           End;
         End;
      End;

     if Pos('<link>',text_line)>0 then
      Begin
       from_object :=XML_value(file_body.Strings[i+1]);
       to_object   :=XML_value(file_body.Strings[i+2]);
       from_arrow  :=XML_value(file_body.Strings[i+3]);
       to_arrow    :=XML_value(file_body.Strings[i+4]);
       Add_link(StrToInt(from_object),StrToInt(to_object),StrToBool(from_arrow),StrToBool(to_arrow));
      end;

    End;
  End;

 file_body.Free;
end;

procedure TMainForm.MainMenuFrame1btn_saveClick(Sender: TObject);
Var
  file_body : TStringList;
  object_text : String;
  object_text_lines : TStringList;
  t, i: Integer;
begin
 { TODO : Replace XML "assembly" manually with XML classes }
 object_text_lines := TStringList.Create;
 file_body := TStringList.Create;
 file_body.Add('<?xml version="1.0" encoding="utf-8"?>');
 file_body.Add('<diagram date="'+DateToStr(Date)+'">');

 file_body.Add('<objects>');
  for i := 1 to max_objects do
   Begin
    if objects_array[i].id_object>0 then
     Begin
      object_text_lines.Text:=TLabel(objects_array[i].indicator.Children[0]).Text;
      object_text:='';
      for t := 0 to object_text_lines.Count-1 do
       Begin
        if t=0 then object_text:=object_text_lines.Strings[t]
        else object_text:=object_text+'#13'+object_text_lines.Strings[t];
       End;

      file_body.Add(' <object>');
      file_body.Add('  <object_id>'+IntToStr(objects_array[i].id_object)+'</object_id>');
      file_body.Add('  <object_caption>'+object_text+'</object_caption>');
      file_body.Add('  <object_x>'+FloatToStr(objects_array[i].indicator.Position.X)+'</object_x>');
      file_body.Add('  <object_y>'+FloatToStr(objects_array[i].indicator.Position.Y)+'</object_y>');
      file_body.Add(' </object>');
     End;
   End;
  file_body.Add('</objects>');

  file_body.Add('<links>');
  for i := 1 to max_objects_links do
   Begin
    if objects_links_array[i].from_object>0 then
     Begin
      file_body.Add(' <link>');
      file_body.Add('  <link_from>'+IntToStr(objects_links_array[i].from_object)+'</link_from>');
      file_body.Add('  <link_to>'+IntToStr(objects_links_array[i].to_object)+'</link_to>');
      file_body.Add('  <arrow_from>'+BoolToStr(objects_links_array[i].from_arrow)+'</arrow_from>');
      file_body.Add('  <arrow_to>'+BoolToStr(objects_links_array[i].to_arrow)+'</arrow_to>');
      file_body.Add(' </link>');
     End;
   End;
  file_body.Add('</links>');
  file_body.Add('</diagram>');

{ TODO : Add project save to file for android and iOS}
{$IFDEF ANDROID}

{$ELSE}
  if SaveProjectDialog.Execute then file_body.SaveToFile(SaveProjectDialog.FileName, TEncoding.UTF8);
{$ENDIF}

 file_body.Free;
 object_text_lines.Free;
end;

procedure TMainForm.LinkageFrame1btn_addClick(Sender: TObject);
Var
  from_object, to_object: Integer;
  i: Integer;
begin
  for i := 1 to max_objects do
  Begin
    if objects_array[i].indicator = selected_first then
      from_object := objects_array[i].id_object;
    if objects_array[i].indicator = selected_second then
      to_object := objects_array[i].id_object;
  End;

  // If there are no arrows, the association is deleted!
  if (LinkageFrame1.img_od.Visible = False) and (LinkageFrame1.img_do.Visible = False) then
    Remove_link(from_object, to_object)
  else
    Add_link(from_object, to_object, LinkageFrame1.img_od.Visible, LinkageFrame1.img_do.Visible);

  Draw_links;
  LinkageFrame1.Visible := False;
  Deselect_objects(False, True);
end;

procedure TMainForm.LinkageFrame1but_cancelClick(Sender: TObject);
begin
  LinkageFrame1.Visible := False;
  Deselect_objects(False, True);
end;

procedure TMainForm.LinkageFrame1img_doClick(Sender: TObject);
begin
  Set_link_arrow('do');
end;

procedure TMainForm.LinkageFrame1img_odClick(Sender: TObject);
begin
  Set_link_arrow('od');
end;

procedure TMainForm.LinkageFrame1rec_doClick(Sender: TObject);
begin
  Set_link_arrow('do');
end;

procedure TMainForm.LinkageFrame1rec_odClick(Sender: TObject);
begin
  Set_link_arrow('od');
end;

procedure TMainForm.DrawingTimerTimer(Sender: TObject);
begin
  Draw_links;
end;

procedure TMainForm.Draw_links;
var
  i, o: Integer;
  object_index_from: Integer;
  object_index_to: Integer;
Begin
  Clean_contact_points;
  for i := 1 to max_objects_links do
  Begin
    if objects_links_array[i].from_object > 0 then
    Begin
      for o := 1 to max_objects do
      Begin
        if objects_array[o].id_object = objects_links_array[i].from_object then
          object_index_from := o;
      End;
      for o := 1 to max_objects do
      Begin
        if objects_array[o].id_object = objects_links_array[i].to_object then
          object_index_to := o;
      End;
      Draw_link(object_index_from, object_index_to, objects_links_array[i].from_arrow, objects_links_array[i].to_arrow,
        objects_links_array[i].text_line_1, objects_links_array[i].text_line_2, objects_links_array[i].text_line_3,
        objects_links_array[i].arrow_image_from, objects_links_array[i].arrow_image_to);
    End;
  End;
End;

procedure TMainForm.Draw_link(from_object, to_object: Integer; from_arrow, to_arrow: Boolean; text_line_1, text_line_2, text_line_3: TLine; from_arrow_image, to_arrow_image: TImage);
var
  od_rect, do_rect: TRectangle;
  poy, koy: Single;
  X1, Y1: Single;
  x2, y2: Single;
  ox, oy: Single;
  direction: Char;
  position_test: Integer;
  rev_counter: Integer;
begin
if (from_arrow) or (to_arrow) then
  Begin
    od_rect := objects_array[from_object].indicator;
    do_rect := objects_array[to_object].indicator;

    poy := od_rect.Position.y - od_rect.Height - (od_rect.Height / 2);
    koy := od_rect.Position.y + od_rect.Height + (od_rect.Height / 2);

    if (do_rect.Position.y > poy) and (do_rect.Position.y < koy) then
    Begin
      // Je?li obiekty s? na podobnym poziomie;
      Y1 := od_rect.Position.y + (od_rect.Height / 2);
      y2 := do_rect.Position.y + (do_rect.Height / 2);

      if do_rect.Position.x > od_rect.Position.x then
      Begin
        // docelowy jest na prawo
        X1 := od_rect.Position.x + od_rect.Width;
        x2 := do_rect.Position.x;
        direction := 'P';
      End
      else
      Begin
        // docelowy jest na lewo
        X1 := od_rect.Position.x;
        x2 := do_rect.Position.x + do_rect.Width;
        direction := 'L';
      End;

    End
    else
    Begin
      if do_rect.Position.y > od_rect.Position.y then
      Begin
        // Je?li obiekt docelowy jest ni?ej ni? obiekt ?ród?owy
        Y1 := od_rect.Position.y + od_rect.Height;
        y2 := do_rect.Position.y;
        direction := 'D';
      End
      else
      Begin
        Y1 := od_rect.Position.y;
        y2 := do_rect.Position.y + do_rect.Height;
        direction := 'G';
      End;

      X1 := od_rect.Position.x + (od_rect.Width / 2);
      x2 := do_rect.Position.x + (do_rect.Width / 2);
    End;

    if Is_there_already_a_point_of_contact_here(X1, Y1) = True then
    Begin
      position_test := line_spacing;
      rev_counter := 1;
      Repeat
        if direction IN ['L', 'P'] then
          Y1 := Y1 + position_test;
        if direction IN ['D', 'G'] then
          X1 := X1 + position_test;
        if rev_counter < 0 then
          rev_counter := rev_counter - 1
        else
          rev_counter := rev_counter + 1;
        rev_counter := rev_counter * -1;
        position_test := line_spacing * rev_counter;
      Until Is_there_already_a_point_of_contact_here(X1, Y1) = False;
    End;
    Add_contact_point(X1, Y1);

    if Is_there_already_a_point_of_contact_here(x2, y2) = True then
    Begin
      position_test := line_spacing;
      rev_counter := 1;
      Repeat
        if direction IN ['L', 'P'] then
          y2 := y2 + position_test;
        if direction IN ['D', 'G'] then
          x2 := x2 + position_test;
        if rev_counter < 0 then
          rev_counter := rev_counter - 1
        else
          rev_counter := rev_counter + 1;
        rev_counter := rev_counter * -1;
        position_test := line_spacing * -rev_counter;
      Until Is_there_already_a_point_of_contact_here(x2, y2) = False;
    End;
    Add_contact_point(x2, y2);

    if direction = 'D' then
    Begin
      oy := Y1 + ((y2 - Y1) / 2);
      DrawLineBetweenPoints(text_line_1, PointF(X1, Y1), PointF(X1, oy));
      DrawLineBetweenPoints(text_line_2, PointF(X1, oy), PointF(x2, oy));
      DrawLineBetweenPoints(text_line_3, PointF(x2, oy), PointF(x2, y2));
      if to_arrow = True then
      Begin
        to_arrow_image.Visible := True;
        to_arrow_image.Position.x := x2 - (ArrowsPattern.Width / 2);
        to_arrow_image.Position.y := y2 - ArrowsPattern.Height + 7;
        to_arrow_image.RotationAngle := 90;
      End
      else
        to_arrow_image.Visible := False;
      if from_arrow = True then
      Begin
        from_arrow_image.Visible := True;
        from_arrow_image.Position.x := X1 - (ArrowsPattern.Width / 2);
        from_arrow_image.Position.y := Y1 - 7;
        from_arrow_image.RotationAngle := 270;
      End
      else
        from_arrow_image.Visible := False;
    End;
    if direction = 'G' then
    Begin
      oy := y2 + ((Y1 - y2) / 2);
      DrawLineBetweenPoints(text_line_1, PointF(X1, Y1), PointF(X1, oy));
      DrawLineBetweenPoints(text_line_2, PointF(X1, oy), PointF(x2, oy));
      DrawLineBetweenPoints(text_line_3, PointF(x2, oy), PointF(x2, y2));
      if to_arrow = True then
      Begin
        to_arrow_image.Visible := True;
        to_arrow_image.Position.x := x2 - (ArrowsPattern.Width / 2);
        to_arrow_image.Position.y := y2 - 7;
        to_arrow_image.RotationAngle := 270;
      End
      else
        to_arrow_image.Visible := False;
      if from_arrow = True then
      Begin
        from_arrow_image.Visible := True;
        from_arrow_image.Position.x := X1 - (ArrowsPattern.Width / 2);
        from_arrow_image.Position.y := Y1 - ArrowsPattern.Height + 7;
        from_arrow_image.RotationAngle := 90;
      End
      else
        from_arrow_image.Visible := False;
    End;

    if direction = 'P' then
    Begin
      ox := X1 + ((x2 - X1) / 2);
      DrawLineBetweenPoints(text_line_1, PointF(X1, Y1), PointF(ox, Y1));
      DrawLineBetweenPoints(text_line_2, PointF(ox, Y1), PointF(ox, y2));
      DrawLineBetweenPoints(text_line_3, PointF(ox, y2), PointF(x2, y2));
      if to_arrow = True then
      Begin
        to_arrow_image.Visible := True;
        to_arrow_image.Position.x := x2 - (ArrowsPattern.Width) + 7;
        to_arrow_image.Position.y := y2 - (ArrowsPattern.Height / 2);
        to_arrow_image.RotationAngle := 0;
      End
      else
        to_arrow_image.Visible := False;
      if from_arrow = True then
      Begin
        from_arrow_image.Visible := True;
        from_arrow_image.Position.x := X1 - 7;
        from_arrow_image.Position.y := Y1 - (ArrowsPattern.Height / 2);
        from_arrow_image.RotationAngle := 180;
      End
      else
        from_arrow_image.Visible := False;
    End;
    if direction = 'L' then
    Begin
      ox := x2 + ((X1 - x2) / 2);
      DrawLineBetweenPoints(text_line_1, PointF(X1, Y1), PointF(ox, Y1));
      DrawLineBetweenPoints(text_line_2, PointF(ox, Y1), PointF(ox, y2));
      DrawLineBetweenPoints(text_line_3, PointF(ox, y2), PointF(x2, y2));
      if to_arrow = True then
      Begin
        to_arrow_image.Visible := True;
        to_arrow_image.Position.x := x2 - 7;
        to_arrow_image.Position.y := y2 - (ArrowsPattern.Height / 2);
        to_arrow_image.RotationAngle := 180;
      End
      else
        to_arrow_image.Visible := False;
      if from_arrow = True then
      Begin
        from_arrow_image.Visible := True;
        from_arrow_image.Position.x := X1 - (ArrowsPattern.Width) + 7;
        from_arrow_image.Position.y := Y1 - (ArrowsPattern.Height / 2);
        from_arrow_image.RotationAngle := 0;
      End
      else
        from_arrow_image.Visible := False;
    End;

    od_rect.BringToFront;
    do_rect.BringToFront;
  end;
end;

procedure TMainForm.Add_pointer(process: TRectangle; process_index: Integer);
var
  i: Integer;
  new: Integer;
Begin
  new := 0;
  for i := 1 to max_objects do
  Begin
    if (objects_array[i].id_object = 0) and (new = 0) then
      new := i;
  End;

  objects_array[new].id_object := process_index;
  objects_array[new].indicator := process;
End;

function TMainForm.Last_Object: Integer;
Var
  outcome: Integer;
  i: Integer;
Begin
  outcome := 0;
  for i := 1 to max_objects do
  Begin
    if objects_array[i].id_object = 0 then
     Begin
      outcome := i-1;
      Break;
     End;
  End;
  Last_Object := outcome;
End;

procedure TMainForm.btn_dodaj_nowy_procesClick(Sender: TObject);
Var
  tmp: TRectangle;
  i: Integer;
  object_index: Integer;
begin
  Deselect_objects(True, True);
  btn_laczenie_procesow.IsPressed := False;

  tmp := TRectangle(ObjectPattern.Clone(self));
  tmp.Parent := ScrollBox;
  tmp.Visible := True;
  tmp.Position.x := +10;
  tmp.Position.y := TopMenuGrid.Position.y + TopMenuGrid.Height + 10;
  tmp.OnMouseDown := ObjectPatternMouseDown;
  tmp.OnMouseMove := ObjectPatternMouseMove;
  tmp.OnMouseUp := ObjectPatternMouseUp;
  tmp.OnDblClick := LabelPatternDblClick;
  tmp.OnMouseLeave := ObjectPatternMouseLeave;
  tmp.OnTap := LabelPatternTap;

  object_index := Last_Object + 1;
  Add_pointer(tmp, object_index);

  for i := 0 to tmp.ChildrenCount - 1 do
  Begin
    if tmp.Children[i] is TLabel then
    Begin
      TLabel(tmp.Children[i]).Text := 'New process' + #13 + '(' + IntToStr(object_index) + ')';
    End;
  End;

  Draw_links;
end;

procedure TMainForm.btn_hamburgerClick(Sender: TObject);
begin
  MainMenuFrame1.Visible := Not(MainMenuFrame1.Visible);
end;

procedure TMainForm.btn_laczenie_procesowClick(Sender: TObject);
begin
  Deselect_objects(True, True);
end;

procedure TMainForm.Clear_Objects_And_Links;
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
  Draw_links;
End;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'FMX Diagram Designer - version: ' + version;
  lbl_bottom_info.Text:='FX Systems Piotr Daszewski FMX Diagram Designer - version: ' + version;
  MouseIsDown := False;
  ObjectPattern.Visible := False;
  LinePattern.Visible := False;
  Clear_Objects_And_Links;
  MainMenuFrame1.Visible := False;
  ProcessEditingFrame1.Visible := False;

{$IFDEF ANDROID}
  Wzor_label.TextSettings.Font.Size := 10;
{$ELSE}
  LabelPattern.TextSettings.Font.Size := 12;
{$ENDIF}
end;

procedure TMainForm.ObjectPatternMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
var
  active_association: Integer;
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
      // If the first one is already selected
      if TRectangle(Sender) = selected_first then
      Begin
        // If the newly clicked is selected
        selected_first.Fill.Color := TAlphaColor($AA0F077A);
        selected_first := Nil;
      End
      else
      Begin
        // If the first is chosen and now we have chosen the second!
        selected_second := TRectangle(Sender);
        selected_second.BringToFront;
        selected_second.Fill.Color := TAlphaColor($AA7A0707);
        LinkageFrame1.Visible := True;

        LinkageFrame1.lbl_od_procesu.Text := TLabel(selected_first.Children[0]).Text;
        LinkageFrame1.lbl_do_procesu.Text := TLabel(selected_second.Children[0]).Text;

        active_association := Which_connection(selected_first, selected_second);
        if active_association = 0 then
        Begin
          LinkageFrame1.img_od.Visible := False;
          LinkageFrame1.img_do.Visible := True;
          LinkageFrame1.btn_add.Text := 'add association';
        End
        else
        Begin
          LinkageFrame1.img_od.Visible := False;
          LinkageFrame1.img_do.Visible := False;
          if (objects_links_array[active_association].from_arrow=True)
          and (Which_object(selected_first)=objects_links_array[active_association].from_object ) then LinkageFrame1.img_od.Visible := True;
          if (objects_links_array[active_association].from_arrow=True)
          and (Which_object(selected_second)=objects_links_array[active_association].from_object ) then LinkageFrame1.img_do.Visible := True;

          if (objects_links_array[active_association].to_arrow=True)
          and (Which_object(selected_second)=objects_links_array[active_association].to_object ) then LinkageFrame1.img_do.Visible := True;
          if (objects_links_array[active_association].to_arrow=True)
          and (Which_object(selected_first)=objects_links_array[active_association].to_object ) then LinkageFrame1.img_od.Visible := True;

          LinkageFrame1.btn_add.Text := 'change the association';
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

procedure TMainForm.ObjectPatternMouseLeave(Sender: TObject);
begin
 if btn_laczenie_procesow.IsPressed = False then
    Deactivate_Object;
end;

procedure TMainForm.ObjectPatternMouseMove(Sender: TObject; Shift: TShiftState; x, y: Single);
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

procedure TMainForm.Deactivate_Object;
Begin
  MouseIsDown := False;
  if Assigned(selected) then selected.Fill.Color := TAlphaColor($AA0F077A);
  DrawingTimer.Enabled := False;
  Draw_links;
End;

procedure TMainForm.ObjectPatternMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Single);
begin
  if btn_laczenie_procesow.IsPressed = False then Deactivate_Object;
end;

procedure TMainForm.Editing_process_data;
var
  i: Integer;
begin
  if btn_laczenie_procesow.IsPressed = False then
  Begin
    for i := 0 to selected.ChildrenCount - 1 do
    Begin
      if selected.Children[i] is TLabel then
      Begin
        ProcessEditingFrame1.Visible := True;
        ProcessEditingFrame1.memo_process_name.Text := TLabel(selected.Children[i]).Text;
      End;
    End;
  End;
end;

procedure TMainForm.LabelPatternDblClick(Sender: TObject);
begin
  Editing_process_data;
end;

procedure TMainForm.LabelPatternTap(Sender: TObject; const Point: TPointF);
begin
  Editing_process_data;
end;

end.
