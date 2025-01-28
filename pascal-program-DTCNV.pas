program DTCNV;

type
  mtype = array[0..12] of integer;
  TLongIntArray = array of LongInt;
  WdN = array[1..7] of string[2];

const
  Gregein = 577735;
  Sisal = 10631;
  Hegire = 227014;
  MaxInt = 32767;
  year = 2025;
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

procedure CalcCday;
    var mad : mtype;
    msg: boolean;
    cday, k, l, tage, q, v, y, yr, w, j, m, t: longint;

    begin
      yr := year;
      mad := ma;
      j := yr;
      m := month - 1;
      t := day;
      if j = 0 then begin
                      msg := TRUE;
                      j := 1;
                      yr := 1;
                    end
                 else msg := FALSE;
      if j < 0 then j := j + 1;
      k := j - 1;
      v := floor(k,400);
      y := 400*v;
      tage := 365*y+97*v;
      k := k-y;
      v := floor(k,100);
      y := 100*v;
      tage := tage+365*y+24*v;
      k := k-y;
      v:= floor(k,4);
      y := 4*v;
      tage:= tage+365*y+v;
      if ((((j mod 4) = 0) and ((j mod 100) <> 0) or ((j mod 400 = 0)))
                           and (m > 1)) then w := t + 1
                                        else w := t;
      l := mad[m];
      tage := tage+(k-y)*365+l+w; {gregorianisch}
      if tage <= Gregein then begin
                                 if ((j mod 4) = 0) and (m > 1)
                                      then w := t+1
                                      else w := t;
                                 k := j - 1;
                                 tage := k*365+floor(k,4)+l+w-2;
                              end;
      cday := tage;
      Writeln(cday);
  end;

begin
  CalcCday;
end.
