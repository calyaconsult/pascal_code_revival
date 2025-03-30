{************************************************}
{                                                }
{   Turbo Pascal 6.0  / TurboVision              }
{   Umrechnung AD -> Hidjra et vice versa        }
{                                                }
{   Copyright (c) 1991 by Michael T Glünz        }
{                                                }
{************************************************}

program Hegira;

uses Objects, Drivers, Views, Menus, Dialogs, App, DTCNV1, Months;

const
  MaxLines          = 100;
  WinCount: Integer =   0;
  cmFileOpen        = 100;
  cmNewWin          = 101;
  cmEp              = 102;
  cmSj              = 103;
  cmSDt             = 104;
  cmSCd             = 105;
  cmAct             = 106;
  cmSMn             = 107;
  cmDIM             = 108;
  TrWota : array[1..7] of string[2] = ('Pa','Pt','Sa','Ça','Pr','Cu','Ct');

var
  LineCount: Integer;
  Lines: array[0..MaxLines - 1] of PString;

type

  PHjyear = ^Hjyear;
  PAdyear = ^Adyear;

  PInDtRec = ^InDtRec;
  InDtRec = record
           t,m : string[2];
           j   : string[4];
          end;

  POuDtRec = ^OuDtRec;
  OuDtRec = record
           t,wota : string[2];
           m : string[18];
           j   : string[4];
           wday : integer;
          end;

  PDemoWindow = ^TDemoWindow;
  TDemoWindow = object(TWindow)
  end;

  TMyApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewEpochDialog;
    procedure NewSjahrDialog;
    procedure ChngDatum(WD : PString);
    procedure ChngCday;
    procedure DoSomething;
    procedure HjrAd;
    procedure AdHjr;
    procedure Anzeigen(Anz: OuDtRec);
    procedure DispIsMonNms;
    procedure SetMonthNames;
  end;

  PInterior = ^TInterior;
  TInterior = object(TScroller)
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar);
    procedure Draw; virtual;
  end;

  PTarikh = ^Tarikh;
  Tarikh = record
             t,m,j : word
           end;

  PAdDatum = ^AdDatum;
  AdDatum = record
             t,m,j : word
           end;

  PSettingDialog = ^TSettingDialog;
  TSettingDialog = object(TDialog)
  end;

var
  MonthnamesDialogData, EpochDialogData, SjahrDialogData,
                                         ActionDialogData: Word;
  ChDtData : InDtRec;
  A, H : boolean;

{ TInterior }
constructor TInterior.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar);
begin
  TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  Options := Options or ofFramed;
  SetLimit(128, LineCount);
end;

procedure TInterior.Draw;
var
  Color: Byte;
  I, Y: Integer;
  B: TDrawBuffer;
begin
  Color := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', Color, Size.X);
    i := Delta.Y + Y;
    if (I < LineCount) and (Lines[I] <> nil) then
      MoveStr(B, Copy(Lines[I]^, Delta.X + 1, Size.X), Color);
    WriteLine(0, Y, Size.X, 1, B);
  end;
end;


{ TMyApp }
procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
     { cmNewWin: NewWindow; }
      cmEp: NewEpochDialog;
      cmSj: NewSjahrDialog;
      cmAct: DoSomething;
      cmSMn: SetMonthNames;
      cmDIM: DispIsMonNms;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen', 'F3', kbF3, cmFileOpen, hcNoContext,
      NewItem('~N~ew', 'F4', kbF4, cmNewWin, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~U~mrechnen', 'F2', kbF2, cmAct, hcNoContext,
      NewItem('~I~sl. Monatsnamen', 'Alt-I', kbAltI, cmDIM, hcNoContext,
      nil))))),
    NewSubMenu('~S~etting', hcNoContext, NewMenu(
      NewItem('~E~poche', 'Alt-E', kbAltE, cmEp, hcNoContext,
      NewItem('S~c~hJhr', 'Alt-C', kbAltC, cmSj, hcNoContext,
      NewItem('~M~onate', 'Alt-M', kbAltM, cmSMn, hcNoContext,
      nil)))),
  nil))))));
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F4~ New', kbF4, cmNewWin,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)))),
    nil)
  ));
end;

procedure TMyApp.SetMonthNames;
var
  Bruce: PView;
  Dialog: PSettingDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 50, 17);
  Dialog := New(PSettingDialog, Init(R, 'Monatsnamen'));
  with Dialog^ do
  begin
    R.Assign(6, 3, 24, 6);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~D~eutsch',
      NewSItem('~T~▒rkisch',
      nil))
    ));
    Insert(Bruce);
    R.Assign(5, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(MonthnamesDialogData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(MonthnamesDialogData);
  Dispose(Dialog, Done);
end;

procedure TMyApp.DispIsMonNms;
var
  Window: PDemoWindow;
  WTX : PView;
  R: TRect;
  i : integer;
  C : word;
  IMN : PMonName;
begin
  Inc(WinCount);
  R.Assign(0, 0, 23, 16);
  Window := New(PDemoWindow, Init(R, 'Isl. Monate', WinCount));
  with Window^ do
    begin
     IMN := New(PMonName);
     IMN^ := IslMonNames;
     for i:= 1 to 12 do
       begin
         R.Assign(2,i+1,22,i+2);
         WTX := New(PStaticText, Init(R, IMN^[i]));
         Insert(WTX);
       end;
    end;
  DeskTop^.Insert(Window);
end;

procedure TMyApp.NewEpochDialog;
var
  Bruce: PView;
  Dialog: PSettingDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 50, 17);
  Dialog := New(PSettingDialog, Init(R, 'Epoche'));
  with Dialog^ do
  begin
    R.Assign(6, 3, 24, 6);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~15~. 7. 622',
      NewSItem('~16~. 7. 622',
      nil))
    ));
    Insert(Bruce);
    R.Assign(5, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(EpochDialogData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(EpochDialogData);
  Dispose(Dialog, Done);
end;

procedure TMyApp.NewSjahrDialog;
var
  Bruce: PView;
  Dialog: PSettingDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 50, 17);
  Dialog := New(PSettingDialog, Init(R, 'Schaltjahr'));
  with Dialog^ do
  begin
    R.Assign(6, 3, 24, 6);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~15~. Jahr',
      NewSItem('~16~. Jahr',
      nil))
    ));
    Insert(Bruce);
    R.Assign(5, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(SjahrDialogData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(SjahrDialogData);
  Dispose(Dialog, Done);
end;

procedure TMyApp.HjrAd;
  var WhDt : PString;
      tag, monat, jahr, cd : integer;
      ActDat  : PHjyear;
      ConvDat : PAdyear;
      Ihrac : POuDtRec;

  begin
      New(WhDt);
      WhDt^ := ' Hijra';
      ChngDatum(WhDt);
      H := TRUE;
      with ChDtData do
        begin
           val(t,tag,cd);
           val(m,monat,cd);
           val(j,jahr,cd);
        end;
      New(ActDat, Init);
      ActDat^.ChangeSetting(EpochDialogData+15,SjahrDialogData+15);
      New(ConvDat, Init);
      Ihrac := New(POuDtRec);
      ActDat^.SetDatum(jahr,monat,tag);
      ConvDat^.SetCday(ActDat^.Cday);
      with ConvDat^ do
        begin
          Str(day,Ihrac^.t);
         { Str(month,Ihrac^.m); }
          Str(yr,Ihrac^.j);
          if MonthnamesDialogData = 0 then Ihrac^.m := copy(DtMonNames[month],4,14)
                                      else Ihrac^.m := copy(TrMonNames[month],4,14);
          Ihrac^.wota :=  wdayname;
          Ihrac^.wday :=  wday;
        end;
      Anzeigen(Ihrac^);
  end;

procedure TMyApp.AdHjr;
  var WhDt : PString;
      tag, monat, jahr, cd : integer;
      ActDat  : PAdyear;
      ConvDat : PHjyear;
      Ihrac : POuDtRec;

  begin
      New(WhDt);
      WhDt^ := ' A D ';
      ChngDatum(WhDt);
      H := TRUE;
      with ChDtData do
        begin
           val(t,tag,cd);
           val(m,monat,cd);
           val(j,jahr,cd);
        end;
      New(ActDat, Init);
      New(ConvDat, Init);
      New(Ihrac);
      ConvDat^.ChangeSetting(EpochDialogData+15,SjahrDialogData+15);
      ActDat^.SetDatum(jahr,monat,tag);
      ConvDat^.SetCday(ActDat^.Cday);
      with ConvDat^ do
        begin
          Str(day,Ihrac^.t);
         { Str(month,Ihrac^.m); }
          Str(yr,Ihrac^.j);
          Ihrac^.m := copy(IslMonNames[month],6,14);
          Ihrac^.wota := wdayname;
          Ihrac^.wday := wday;
        end;
      Anzeigen(Ihrac^);
  end;


procedure TMyApp.DoSomething;
var
  Bruce: PView;
  Dialog: PSettingDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 50, 17);
  Dialog := New(PSettingDialog, Init(R, 'Umrechnen'));
  with Dialog^ do
  begin
    R.Assign(6, 3, 24, 6);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~Hidjra~ -> AD',
      NewSItem('~AD~ -> Hidjra',
      nil))
    ));
    Insert(Bruce);
    R.Assign(5, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(ActionDialogData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then
     begin
       Dialog^.GetData(ActionDialogData);
       case ActionDialogData of
         0 : HjrAd;
         1 : AdHjr;
       end;
     end;
  Dispose(Dialog, Done);
end;

procedure TMyApp.Anzeigen;
var
  Harry: PView;
  Dialog: PSettingDialog;
  R: TRect;
  C: Word;
  AnzTex : string;
  wochtg : string[2];

begin
  if MonthnamesDialogData = 1 then wochtg := TrWota[Anz.wday]
                              else wochtg := Anz.wota;
  AnzTex := wochtg + '  ' + Anz.t + ' ' + Anz.m + ' ' + Anz.j;
  R.Assign(20,6,64,15);
  Dialog := New(PSettingDialog, Init(R, 'Datum 2'));
  with Dialog^ do
  begin
    R.Assign(10,2,30,3);
    Insert(New(PStaticText, Init(R, 'Umgerechnetes Datum')));
    R.Assign(10,4,35,5);
    Insert(New(PStaticText, Init(R, AnzTex)));
    R.Assign(30, 6, 41, 8);
    Insert(New(PButton, Init(R, 'Close', cmCancel, bfNormal)));
    C := Desktop^.ExecView(Dialog);
    Dispose(Dialog, Done);
  end;
end;

procedure TMyApp.ChngDatum;
var
  Bruce: PView;
  Dialog: PSettingDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 44, 19);
  Dialog := New(PSettingDialog, Init(R, 'Datum'));
  with Dialog^ do
  begin
    R.Assign(8,2,14,3);
    Bruce := New(PStaticText, Init(R, WD^));
    Insert(Bruce);
    R.Assign(15, 4, 20, 5);
    Bruce := New(PInputLine, Init(R, 2));
    Insert(Bruce);
    R.Assign(2, 4, 7, 5);
    Insert(New(PLabel, Init(R, 'Tag', Bruce)));
    R.Assign(15, 6, 20, 7);
    Bruce := New(PInputLine, Init(R, 2));
    Insert(Bruce);
    R.Assign(2, 6, 11, 7);
    Insert(New(PLabel, Init(R, 'Monat', Bruce)));
    R.Assign(13, 8, 20, 9);
    Bruce := New(PInputLine, Init(R, 4));
    Insert(Bruce);
    R.Assign(2, 8, 9, 9);
    Insert(New(PLabel, Init(R, 'Jahr', Bruce)));
    R.Assign(2, 10, 12, 12);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(12, 10, 22, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(ChDtData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then
     begin
        Dialog^.GetData(ChDtData);
     end;
  Dispose(Dialog, Done);
end;

procedure TMyApp.ChngCday;
  begin end;

{ procedure TMyApp.NewWindow;
var
  Window: PDemoWindow;
  R: TRect;
begin
  Inc(WinCount);
  R.Assign(0, 0, 45, 13);
  R.Move(Random(34), Random(11));
  Window := New(PDemoWindow, Init(R, 'Demo Window', WinCount));
  DeskTop^.Insert(Window);
end;  }

var
  MyApp: TMyApp;

begin
  A := FALSE;
  H := FALSE;
  MonthnamesDialogData := 0;
  ActionDialogData := 0;
  EpochDialogData := 0;
  SjahrDialogData := 1;
  ChDtData.t := '  ';
  ChDtData.m := '  ';
  ChDtData.j := '  ';
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
