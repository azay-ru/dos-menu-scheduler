{$A+,B-,D-,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}
uses crt,dos;

type Watch = record
            sym,attr : Byte;
           end;

     TTimePoint = record
            Hour,Min,Code: Byte;
           end;

    TStar = record
            x,y,pos: Byte;
           end;
    ShortStr = String[80];

    TDirs = record
             Path: ShortStr;
             Code: Byte;
            end;

const
     WorkDay : array[0..6] of Boolean = (False,False,False,False,False,False,False);
     Star : array[1..12] of Byte = (250,249,7,43,42,15,42,43,7,249,250,32);
     StarDelay = 7;
     StarCount = 5;
     Logo = #13#10'DOS-����-�����஢騪 1.73 (C) 1995-2002 ALEKSEYZ, http://alekseyz.hotbox.ru';
     nDirs: Byte = 0;

Var
   Scr : array[1..25,1..80] of Watch absolute $B800:$0000;
   Mem : array[1..25,1..80] of Watch;
   Mem2: array[1..25,1..80] of Watch;
   Menu: array[1..20] of ShortStr;
   TimePoint: array[1..512] of TTimePoint;
   DirList: array[1..32] of TDirs;
   Stars: array[1..12] of TStar;
   d,w,i,j,x,y: Byte;
   r,h,h2,m,m2,s,s2,S100: Word;
   f: Text;
   ss: Boolean;
   _Str: ShortStr;
   Code: Integer;

function DateToStr: String;
var
   r,q: ShortStr;
   y,d,mm,dw,h,min,s,s1: Word;
begin
     GetDate(y,mm,d,dw);
     GetTime(h,min,s,s1);
     r := '';
     Str(d,q);
     if d < 10 then
        r := '0' + q
     else
        r := q;
     r := r + '/';
     Str(mm,q);
     if mm < 10 then
        r := r + '0' + q
     else
        r := r + q;
     Str(y,q);
     r := r + '/' + q + ' ';
     Str(h,q);
     if h < 10 then
        r := r + '0' + q
     else
        r := r + q;
     Str(min,q);
     r := r + ':';
     if min < 10 then
        r := r + '0' + q
     else
        r := r + q;
     DateToStr := r;
end;


Procedure ScrAndMem(a: Byte);
var
   _i,_j: Byte;
{   ah,b,c,d: Word;}
begin
     if a=0 then begin{ ���࠭塞 ⥪�騩 ��࠭ � �����}
     for _j:= 1 to 25 do
         for _i:= 1 to 80 do begin
             Mem2[_j,_i] := Scr[_j,_i];
              Scr[_j,_i].attr := DarkGray;
              Scr[_j,_i].sym := 32;
         end;
     for _i := 76 to 80 do
         Scr[1,_i].attr := Cyan;
     end
     else
     for _j:= 1 to 25 do {�����頥� ��࠭ �� �����}
         for _i:= 1 to 80 do
             Scr[_j,_i] := Mem2[_j,_i];
end;

{Function CheckDirs: Byte;
var
   z: Byte;
   Rec: SearchRec;
begin
     if nDirs = 0 then begin
        CheckDirs := 0;
        Exit;
     end;

end;}

Procedure Loging(const s2l: String; r:Byte);
var
   fa: text;
   _s: String;
begin
     Assign(fa,'mschedul.log');
     Append(fa);
     if IOResult <> 0 then
        Exit;
     Str(r, _s);
     Write(fa, DateToStr + ' Code=' + _s);
     WriteLn(fa, s2l);
     Close(fa);
end;


Procedure CheckTimer;
var
   qq,ww,ee,rr,z: Word;
   _s: String[10];
   Rec: SearchRec;
begin
  if ss then begin
     GetDate(qq,ww,ee,rr);
     if WorkDay[rr] then begin
        GetTime(qq,ww,ee,rr);
        for z := 1 to x do
           if (TimePoint[z].Hour = qq) and (TimePoint[z].Min = ww) then begin
              r := TimePoint[z].Code;
              Loging('', r);
              Break;
           end;
        if r = 255 then begin
           for z := 1 to nDirs do begin
               FindFirst(DirList[z].Path, AnyFile-VolumeID-Directory, Rec);
               if DosError = 0 then begin
                  r := DirList[z].Code;
                  Loging(' ' + Rec.Name, r);
                  Break;
               end;
           end;
        end;
     end;
  end;
end;

Procedure ZWindow( x1,y1,x2,y2,paper,ink:Byte);
{ ��楤�� ᮧ���� ���� � ⥭��.
                        ��ࠬ����:
                x1,y1,x2,y2 - �࠭��� ࠡ�祩 ��� ���� (��� ࠬ��),
                  paper,ink - 梥� � ����,
                        mes - �������� ���� }
var
   i,j:Byte;
begin
     Window(x1-1,y1-1,x2+1,y2+1);
     TextBackGround(paper);
     TextColor(ink);
     ClrScr;
     Window(x1-2,y1-1,x2+2,y2+2);
     Write(' �'); for j:=x1 to x2 do Write('�'); Write('� ');
     for i:=y1 to y2 do Write(' �',' � ':x2-x1+3);
     Write(' �'); for j:=x1 to x2 do Write('�'); Write('� ');
     Window(x1,y1,x2,y2);
end;

Procedure ShowTime;
var
   qq,ww,ee,rr: Word;
   s1,_s2: String[6];
begin
     GetTime(qq,ww,ee,rr);

     Str(qq,s1);
     if qq<10 then
        s1 := '0' + s1;
     Str(ww,_s2);
     if ww<10 then
        _s2 := '0' + _s2;

     Scr[1,76].sym := Ord(s1[1]);
     Scr[1,77].sym := Ord(s1[2]);
     Scr[1,79].sym := Ord(_s2[1]);
     Scr[1,80].sym := Ord(_s2[2]);

end;

Function ExtrStr: String;
begin
     while (_Str[i] in [#32,';',':',',']) and (i<Length(_Str)) do
        Inc(i);
     j := i;
     while (not (_Str[i] in [#32,';',':',','])) and (i<=Length(_Str)) do
        Inc(i);
     ExtrStr := Copy(_Str,j,i-j);
end;

function Good(x: Byte): String;
begin
     if x < 10 then
        Good := '0'
     else
        Good := '';
end;

Function ZMenu( x,y,n,nn,l,p1,i1,p2,i2,p3,i3:Byte ) : Byte;
{ �ᯮ���� �������� ᯨ᮪ �㭪⮢ ����. n - � ������ ��稭���, nn - ᪮�쪮,
  l - �ਭ� ���ᢥ祭���� ����. �����頥� ����� ��࠭���� �㭪�
  p1,i1 - ᮮ⢥�ᢥ��� 梥� 䮭� � 梥� ᨬ���� ����,
  p2,i2 - 梥� 䮭� � ᨬ���� ���뤥������� �㭪� ����,
  p3,i3 - 梥� 䮭� � ᨬ���� ��lt������� �㭪� ���� }
Var
   current,last,c2,c3,t,_h:Byte;
   ch:Char;
   __m, __s: Word;

    procedure Mover( hh:Byte );
    begin
         for hh:=x to x+l do
             scr[last+y-1,hh].attr:=c2;
         for hh:=x to x+l do
             scr[current+y-1,hh].attr:=c3;
         last:=current;
    end;

begin
     current:=1;
     last:=1;
     ZWindow(x,y,x+l,y+nn-1,p1,i1);
     ClrScr;
     TextBackGround(p2);
     TextColor(i2);
     for _h:=n to (n+nn-1) do
         begin
              GoToXY(1,_h-n+1);
              Write(' ',menu[_h]);
         end;
{     Window(1,1,80,25); GoToXY(1,1); Write;}
     c3:=(p3 shl 4) or i3;
     c2:=(p2 shl 4) or i2;
     for _h:=x to x+l do
         scr[y,_h].attr := c3;
     {��砫� 横�� ��ࠡ�⪨ ����}
     GetTime(h,m,s,s100);
     r := 255; ch := #0;
     ss := False;
{     CheckTimer;  }
     ShowTime;

     Repeat
        if KeyPressed then begin   {�᫨ ����� ������}
           Repeat                 {��⠥� �� 㯮� �᫨ ᯥ檫����}
             ch := ReadKey;
           Until ord(ch)<>0;

           if (ch=#27) and not ss then begin
              r := 0;
              Break;
           end;

           if ss = True then begin { � ��⨢�� ScreenSaver}
                 ScrAndMem(1);        {� �����頥� �।��騩 ��࠭}
                 ss := False;
           end
           else begin

           if ch in ['1'..'9'] then  {�᫨ ������ ����, � ��室�� �� ���}
              r := Ord(ch)-48
           else
              if (ch=#13) or (ch=#32) then begin {�᫨ Enter|Space, � ��室�}
                 Sound(2000);
                 Delay(1);
                 NoSound;
                 r := current
              end
              else
                  if (ch=#72) or (ch=#75) then begin
                     Dec(current);
                     if current=0 then current:=nn;
                     Mover(h);
                  end
                  else
                     if (ch=#80) or (ch=#77) then begin
                        Inc(current);
                        If current=nn+1 then current:=1;
                        Mover(h);
                     end;
           end;
        end
      else
        GetTime(h2,m2,s2,s100);
        CheckTimer;
        if (s = s2) and (m <> m2) then begin
           CheckTimer;
           ShowTime;
           if not ss then begin
              for i:=1 to StarCount do begin  {���樠�����㥬 ������窨}
                 Stars[i].pos := Random(11)+1;
                 Repeat
                    Stars[i].x := Random(24)+1;
                    Stars[i].y := Random(79)+1;
                 Until (Stars[i].x <>1) and (Stars[i].y <76);
              end;
              ss := True;
              i := 1; {��砫� � ��ࢮ� ����...}
              ScrAndMem(0);
           end;
        end;

        if ss then begin
           Scr[Stars[i].x, Stars[i].y].sym := Star[Stars[i].pos];
           if Stars[i].pos = 4 then begin
              j := Random(5);
              if j=1 then       {�� �����쪠 ������}
                 Stars[i].pos := 8;
           end;
           inc(Stars[i].pos);
           if Stars[i].pos >= 13 then begin {������ ᣮ५�, ����� �����}
              Stars[i].pos := 1;
              Repeat
                Stars[i].x := Random(24)+1;
                Stars[i].y := Random(79)+1;
              Until (Stars[i].x <>1) and (Stars[i].y <76);
           end;
           inc(i);
           if i > StarCount then
              i := 1;
           Delay(StarDelay);
        end;

     Until r <> 255;
     Window(1,1,80,25);
     GotoXY(1,24);
     ZMenu:=r;
end;

BEGIN
   If ParamCount < 1 then begin
      WriteLn(logo+#13#10'���⠪��: mschedul.exe <��� 䠩�� ���䨣��樨> <����� ࠡ��� ���� 0..6>'#13#10+
      +'�ਬ��: ����� ����-�����஢騪� � ��ࠬ��ࠬ� �� 䠩�� mschedul.cfg');
      WriteLn('        ��⮬���᪨� ����樨 ⮫쪮 � �������쭨�, �।� � ��⭨��'#13#10+
      +'mschedul.exe mschedul.cfg 135');
      Halt(0);
   end;

   if ParamCount >=2 then begin
      _Str := ParamStr(2);
      for r := 1 to Length(_Str) do
         if _Str[r] in ['0'..'6'] then
            WorkDay[Ord(_Str[r])-48] := True;
   end;

   Assign(f,ParamStr(1)); {��⠥� ���� �� 䠩��}
   Reset(f);
   If IOResult <> 0 then begin
      WriteLn('�訡�� �⥭�� 䠩�� ���䨣��樨: ',ParamStr(1));
      Halt(0);
   end;
   r := 1;
   w := 0;
   While (not eof(f)) and (r<=20) do begin
         ReadLn(f,menu[r]);
         If IOResult <> 0 then begin
            WriteLn('�訡�� �⥭�� 䠩�� ���䨣��樨: ',ParamStr(1));
            Halt(0);
         end;
         if (Length(menu[r])>0) then begin
            if (menu[r][1] in [' ','#','!','@','$','%','^','&','~']) then
                Break
            else
                if menu[r][1]<>';'then begin
                   if Length(menu[r]) > w then
                      w := Length(menu[r]);
                   Inc(r);
                end;
         end;
   end;

   While (not eof(f)) and (nDirs < 32) do begin
      ReadLn(f,_Str);
      i := 1;
      If IOResult <> 0 then begin
         WriteLn('�訡�� �⥭�� 䠩�� ���䨣��樨: ',ParamStr(1));
         Halt(0);
      end;
      if (_Str[1] in [' ','#','!','@','$','%','^','&','~']) then
           Break
      else
          if _Str[1] <> ';'then begin
             Val(ExtrStr, DirList[nDirs+1].Code, Code);
             if Code = 0 then begin
                DirList[nDirs+1].Path := Copy(_Str, i+1, Length(_Str)-i);
                inc(nDirs);
             end;

          end;

   end;

   x := 0;
   while not eof(f) do begin {������ �⠥� �窨 ��室�}
      ReadLn(f,_Str);
      i := 1;
      Val(ExtrStr,TimePoint[x+1].Hour,Code);
      if (Code = 0) and (TimePoint[x+1].Hour in [0..23]) then begin
         Val(ExtrStr,TimePoint[x+1].Min,Code);
         If (Code = 0) and (TimePoint[x+1].Min in [0..59]) then begin
            Val(ExtrStr,TimePoint[x+1].Code,Code);
            if Code = 0 then
               Inc(x);
         end;
      end;
   end;
   Close(f);

{ Debug DirList
   for i := 1 to nDirs do begin
       WriteLn('=',DirList[i].Code,'=');
       WriteLn('=',DirList[i].Path,'=');
   end;}

{ Debug TimePoint
   for i := 1 to x do
      WriteLn(TimePoint[i].Hour,':',TimePoint[i].Min,' = ',TimePoint[i].Code);}

   for i:= 1 to 25 do {���࠭�� ��࠭ �� ��室�}
       for j:= 1 to 80 do begin
           Mem[i,j] := Scr[i,j];
           Scr[i,j].attr := DarkGray;
       end;

   for i := 76 to 80 do
      Scr[1,i].attr := DarkGray;
   Scr[1,78].sym := Ord(':');

   {���祬 �����}
   asm
      or ch, 00100000b
      mov ah, 01h
      int 10h
   end;
    if x > 0 then begin
       ZWindow(59,5,74,20,DarkGray,DarkGray);
       j := 0;
       GetTime(h,m,s,s100);
       for i := 1 to x do begin
          if (TimePoint[i].Hour > h) or
             ((TimePoint[i].Hour = h) and (TimePoint[i].Min > m)) then begin
               if j > 0 then WriteLn;
                Write(Good(TimePoint[i].Hour),TimePoint[i].Hour,':',Good(TimePoint[i].Min),TimePoint[i].Min,
              ' �㭪� �',TimePoint[i].Code);
             inc(j);
          end;
          if j > 15 then Break;
       end;
    end;
    r := ZMenu((65-w) div 2, (24-r) div 2, 1,r-1, w+1, Blue,Cyan, Blue,LightCyan, Cyan,White);

   {����⠭�������� �����}
   asm
      and ch, 11011111b
      mov ah,01h
      int 10h
   end;
   for i:= 1 to 25 do
       for j:= 1 to 80 do
           Scr[i,j] := Mem[i,j];
   TextColor(LightGray);
   TextBackGround(Black);
   GotoXY(1,25);
   Halt(r);
END.