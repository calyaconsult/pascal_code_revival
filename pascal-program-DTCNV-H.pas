program DTCNV_H;

type
  mtype = array[0..12] of integer;
  TLongIntArray = array of LongInt;
  WdN = array[1..7] of string[2];

const
  Gregein = 577735;
  Sisal = 10631;
  Hegire = 227014;
  MaxInt = 32767;
  year = 1446;
  month = 1;
  day = 1;

  WdayNms : WdN = ('SO', 'MO', 'DI', 'MI', 'DO', 'FR', 'SA');
  ma : mtype = (0,31,59,90,120,151, 181, 212, 243,273,304,334,365);
  mb : mtype = (710,1773,2482,3545,4608,5317,6380,7443,8506,9215,10278,MaxInt,0);
  mh : mtype = (2,5,7,10,13,0,18,21,24,26, 29, MaxInt,0);

function floor(a, b: LongInt): LongInt;
  begin
    if (a < 0) and (b > 0) or (a > 0) and (b < 0) then
      floor := a div b - 1
    else
      floor := a div b;
  end;

procedure CalcCday_H;
   var mhig : mtype;
       dh, tage, l, s, j, k, m, t, u, v, cyc : LongInt;
       ep : integer;
       sj, yr, cday : LongInt;
       msg : boolean;

   procedure accumulate; { Monate in Tage,
                           Anzahl Tage alterniert zw. 30 u. 29 }
     var x, q : integer;
     begin
       q := 1;    { Startwert Anzahl verg. Monate}
       for x := 1 to 6 do
           begin
             u := u + 30;
             q := q + 1;
             if m < q then exit
                      else
                         begin
                            u := u + 29;
                            q := q + 1;
                            if m < q then exit
                         end
      end; { accumulate }
end;

begin
   ep := 15; {Defaultwert für Epoche }
   sj := 15; {Defaultwert für Schaltjahr }

   yr := year;
   mhig := mh;
   j := yr;
   m := month - 1;
   t := day;

   if ep = 16 then dh := Hegire else dh := Hegire-1;
   if j = 0 then begin
                 msg := TRUE;
                 j := 1;
                 yr := 1;
             end
      else msg := FALSE;
   if j < 0 then j := j + 1;
   k := j - 1;
   cyc  := floor(k,30); { Anzahl 30jahreszyklen }
   tage := Sisal*cyc;
   k := k-cyc*30;      { Jahre im aktuellen Zyklus }
   mhig[5] := sj;      { Einsetzen Schaltjahr }
   v := -1;            { Startwert }
   repeat
     v := v+1;         { Schalttage }
   until k < mhig[v];
   u := 0;   { Vergangene Monate in Tagen }
   if m >= 1 then accumulate;
   cday := tage + k*354 + v + u + t + dh;
   Writeln(cday);
end;

procedure CalcDatum_H;
   var mbd : mtype;
   dh, tage, y, j, k, m, t, cyc, s, v : LongInt;
   lr,yrl, vr : real;
   ep, sj : integer;
   cday: LongInt;
   msg: boolean;

   procedure countmonths (var m: Longint; s: LongInt);
      var x,q: integer;
      begin
      q := 60;
      for x := 1 to 5 do
         begin
            m := m+1;
            if s < q then exit;
            q := q+30;
            m := m+1;
            if s < q then exit;
            q := q+29
         end;
      m := m+1
    end; { countmonths }

   begin
      ep := 15; {Defaultwert für Epoche }
      sj := 15; {Defaultwert für Schaltjahr }
      cday := 739074;
      mbd := mb;
      tage := cday;
      if ep = 16 then dh := Hegire else dh := Hegire - 1;
      y := tage-dh;
      cyc  := floor(y,Sisal);       { Anzahl 30jahreszyklen }
      y := y-Sisal*cyc;             { Tage im aktuellen Zyklus }
      if y = 0 then begin           { letzter Tag im Zyklus }
                      cyc := cyc-1;
                      y := Sisal;
                    end;
      k := 30*cyc;                   { Anzahl Jahre der verg. Zyklen }
      t:= -1;                        { Startwert }
      if sj = 16 then mbd [5] := 5671   { Schaltjahr wird berücksichtigt }
                 else mbd [5] := 5317;
      repeat
        t := t+1                        { Schalttage }
      until y < mbd [t];
      if y < 1418 then lr := 0.9985
               else if y < 2482
               then lr := 0.9986
               else if (sj = 15) and (y = 5316) or (y < 4253)
               then lr := 0.9988
               else lr := 0.9989;
      yrl := y;                        { Umrechnung von Tagen in Jahre }
      vr := lr*yrl/354.0;
      v := trunc(vr);
      j := k+v+1;
      s := y-354*v-t;                  { Verbleibende Tage im Jahr }
      m := 1;                          { Startwert Monate }
      if s >= 31 then countmonths(m,s);
      t := s-trunc((m-1)*29.5+0.5);
      if j = 0 then msg := TRUE else msg := FALSE;
      if j <= 0 then j := j-1;

      Writeln(j, ' ',m, ' ',t)
    end;

begin
  CalcCday_H;
  CalcDatum_H
end.
