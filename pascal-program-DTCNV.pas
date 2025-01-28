program DTCNV;

{ This program will, once it is finished and tested,
  calculate the CDay, i.e. the number of days elapsed sind 1/1/1 AD, for a given Julian or Gregorian date
  and the Gregorian date for a given CDay.
  Status:
    - CalcCday has passed the first test
    - CalcDatum fails -> the year should be close to "estimated year" but so far it is an absurd number.
}

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
      Writeln('CDay: ',cday);
  end;

procedure CalcDatum;
    var mad : mtype;
    msg: boolean;
    k, l, s, v, y, yr, month, day, tage, j, m, t, cday  : LongInt;
    estimatedyear : Double;
    
    procedure vierhundert;
       begin
          l := 146097;
          y := floor(tage,1);
          j := 400*y;
          k:= tage-y*1;
       end; {vierhundert}
    procedure hundert;
       begin
          l := 36524;
          y := floor(k,1);
          j := j+100*y;
          k := k-y*1;
          y := floor(k,1461);
          j := j+4*y;
          k := k-y*1461;
       end; {hundert}
    procedure ersterjanuar;
       begin
          y := floor(k,365);
          j := j+y+1;
          k := k-y*365;
          if k=0 then begin j:=j-1; k := 365 end
       end; {ersterjanuar}
    procedure vhschalttag;
       begin
          if (k = 0) and ((j mod 400) = 0) then ersterjanuar;
          if (k = 0) and ((j mod 100) > 0) then k := 366
                                                else ersterjanuar
          end; {vhschalttag}
    procedure vorgregor;
       begin
          y := floor(tage, 1461);
          j := 4*y;
          k := tage-y*1461+2;
          if k = 1461 then begin k := 366; j := j+4 end
                      else begin
                              if k = 1462 then k := 1461;
                              ersterjanuar
                           end
       end; {vorgregor}
    begin
       cday := 739252; { Output of CalcCday }
       estimatedyear := cday/365;
       Writeln('Estimated year: ',Round(estimatedyear):0);
       mad := ma;
       tage := cday;
       if tage <= Gregein then vorgregor
                          else begin
                                  vierhundert;
                                  if k = 0 then k := 366
                                           else begin
                                                   hundert;
                                                   vhschalttag
                                                end
                               end;
       s := 0;
       k := k-1;
       m := 1;
       v := 0;
       if k >= 31 then begin
                          if (j mod 4) <= 0 then begin
                                                    s := 1;
                                                    if ((j mod 100) = 0)
                                                    and ((j mod 400) > 0)
                                                    and (tage > Gregein)
                                                    then s := 0
                                                  end;
       repeat
         m := m+1;
         if m = 2 then v := 31-s
                  else v := mad [m-1]
       until k < (mad[m]+s)
    end;
    t := k-v-s+1;
    if j = 0 then msg := TRUE else msg := FALSE;
    if j <= 0 then j := j-1;
    yr := j;
    month := m;
    day := t;
    Writeln('Calculated year:', yr,' month: ',month,' day: ',day);
    end;

begin
    CalcCday;
    CalcDatum
end.
