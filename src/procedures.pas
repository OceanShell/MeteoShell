unit procedures;

{$mode objfpc}{$H+}

interface

uses
{$ifdef WINDOWS}
  Registry, ShlObj, comobj, Win32Int, InterfaceBase,
{$ENDIF}

  SysUtils, Variants, Dialogs, DateUtils, Forms, Graphics, Math, main;

function CheckKML:boolean;
function ClearDir(Dir:string ): boolean;


(* ProgressBar on taskbar in WINDOWS / regular on other systems *)
procedure ProgressTaskbar(k, max_k : integer);

procedure Distance(ln0,ln1,lt0,lt1:real; var Dist:real);
procedure PositionByDistance(Lat0, Lon0, Dist: real; var dlat, dlon:real);

function GetMonthFromIndex(ind:integer):string;
function GetColorFromIndex(ind:integer):TColor;


implementation


procedure ProgressTaskbar(k, max_k : integer);
{$ifdef WINDOWS}
Var
 FTaskBarList: ITaskbarList3;
 AppHandle: THandle;
{$ENDIF}
begin
 {$ifdef WINDOWS}
   AppHandle := TWin32WidgetSet(WidgetSet).AppHandle;
   FTaskBarList := CreateComObject(CLSID_TaskbarList) as ITaskbarList3;
   FTaskBarList.SetProgressState(AppHandle, TBPF_Normal);
   FTaskBarList.SetProgressValue(AppHandle, k, max_k);
 {$ENDIF}

 {$ifdef UNIX}
   frmmain.ProgressBar1.Position:=trunc(k/max_k)*100;
 {$ENDIF}
end;



function CheckKML:boolean;
var
 FileClass: string;
 {$IFDEF WINDOWS}
  Reg: TRegistry;
 {$ENDIF}
begin
{$IFDEF WINDOWS}
  Reg := TRegistry.Create(KEY_EXECUTE);
  Reg.RootKey := HKEY_CLASSES_ROOT;
  FileClass := '';
  if Reg.OpenKeyReadOnly('.kml') then
  begin
    FileClass := Reg.ReadString('');
    Reg.CloseKey;
  end;
  if FileClass <> '' then begin
    if Reg.OpenKeyReadOnly(FileClass + '\Shell\Open\Command') then
    begin
      if trim(Reg.ReadString(''))<>'' then Result := true else Result := false;
      Reg.CloseKey;
    end;
  end;
  Reg.Free;
  {$ENDIF}
end;


(* Erasing content of the given folder *)
function ClearDir( Dir: string ): boolean;
var  isFound: boolean;
sRec: TSearchRec;
begin
 Result := false;
 ChDir( Dir );
  if IOResult <> 0 then Exit;
  if Dir[Length(Dir)] <> PathDelim then Dir := Dir + PathDelim;

  isFound := FindFirst(Dir + '*.*',faAnyFile,sRec ) = 0;
  while isFound do  begin
   if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
    if ( sRec.Attr and faDirectory ) = faDirectory then  begin
     if not ClearDir( Dir + sRec.Name ) then  Exit;
     if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
      if ( Dir + sRec.Name ) <> Dir then  begin  ChDir( '..' );
        RmDir( Dir + sRec.Name );
      end;
    end else if not SysUtils.DeleteFile(Dir + sRec.Name) then Exit;
   isFound := FindNext(sRec ) = 0;
  end;
 SysUtils.FindClose(sRec);
 Result := IOResult = 0;
end;


{ Distance [km] calculation between two points input}
{ Initial coordinates in degres decimal}
Procedure Distance(ln0,ln1,lt0,lt1:real; var Dist:real);
var
lnd,ltd,lnkm,ltkm,m,r:real;
begin
{ Coordinates in decimal reprisentation }
 lnd:=abs(ln1-ln0);
  if lnd>180 then lnd:=abs(360-lnd);
 ltd:=abs(lt1-lt0);
 r:=2*pi*6378.137/360;  {equatorial radius Hayford 1909 [km] 6378.137}
 m:=1.8532; {mile}
 lnkm:=r*cos((lt0+lt1)/2*(pi/180))*lnd;
 ltkm:=r*ltd;
Dist:=sqrt(lnkm*lnkm+ltkm*ltkm);
end;


procedure PositionByDistance(Lat0, Lon0, Dist: real; var dlat, dlon:real);
Var
  theta, a, b, c, d: double;
  lat, lon :double;
begin
  // convert to radians
  lat0 := lat0*Pi/180;
  lon0 := lon0*Pi/180;
  dist := dist/6371;
  theta:= 270*Pi/180;

  lat := arcsin(sin(lat0)*cos(dist)+cos(lat0)*sin(dist)*cos(0));
  d:= arctan2(sin(theta)*sin(dist)*cos(lat0), cos(dist)-sin(lat0)*sin(lat));

  a:=lon0-d+pi;
  b:=2*pi;
  c:= a - b * Int(a / b);

  lon := c - pi;

  dlat:=(lat-lat0)*180/pi;
  dlon:=(lon-lon0)*180/pi;
end;


function GetMonthFromIndex(ind:integer):string;
begin
 Case ind of
   1: result:='January';
   2: result:='February';
   3: result:='March';
   4: result:='April';
   5: result:='May';
   6: result:='June';
   7: result:='July';
   8: result:='August';
   9: result:='September';
  10: result:='October';
  11: result:='November';
  12: result:='December';
 end;
end;

function GetColorFromIndex(ind:integer):TColor;
begin
  case ind of
    1:  result:=RGBToColor(  0, 204, 204);
    2:  result:=RGBToColor(153, 204, 255);
    3:  result:=RGBToColor(  0, 204,   0);
    4:  result:=RGBToColor(128, 255,   0);
    5:  result:=RGBToColor(204, 204,   0);
    6:  result:=RGBToColor(255, 128,   0);
    7:  result:=RGBToColor(255,   0,   0);
    8:  result:=RGBToColor(255,   0, 128);
    9:  result:=RGBToColor(255,   0, 255);
    10: result:=RGBToColor(153, 153, 255);
    11: result:=RGBToColor(  0,   0, 255);
    12: result:=RGBToColor(  0,   0, 153);
    13: result:=RGBToColor(  0,   0,   0);
  end;
end;

end.
