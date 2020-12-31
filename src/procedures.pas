unit procedures;

{$mode objfpc}{$H+}

interface

uses
{$ifdef WINDOWS}
  Windows,
{$endif}
  SysUtils, Variants, Dialogs, DateUtils, Classes, Forms, math, main;

function CheckKML:boolean;
function GetMonthFromIndex(ind:integer):string;
procedure RunProc(cmd:string);


implementation

const
  // ASSOCF enumerated values mapped to integer constants
  ASSOCF_INIT_NOREMAPCLSID = $00000001;
  ASSOCF_INIT_BYEXENAME = $00000002;
  ASSOCF_OPEN_BYEXENAME = $00000002;
  ASSOCF_INIT_DEFAULTTOSTAR = $00000004;
  ASSOCF_INIT_DEFAULTTOFOLDER = $00000008;
  ASSOCF_NOUSERSETTINGS = $00000010;
  ASSOCF_NOTRUNCATE = $00000020;
  ASSOCF_VERIFY = $00000040;
  ASSOCF_REMAPRUNDLL = $00000080;
  ASSOCF_NOFIXUPS = $00000100;
  ASSOCF_IGNOREBASECLASS = $00000200;

{$MINENUMSIZE 4}
type
  TAssocStr = (
    ASSOCSTR_COMMAND = 1,
    ASSOCSTR_EXECUTABLE,
    ASSOCSTR_FRIENDLYDOCNAME,
    ASSOCSTR_FRIENDLYAPPNAME,
    ASSOCSTR_NOOPEN,
    ASSOCSTR_SHELLNEWVALUE,
    ASSOCSTR_DDECOMMAND,
    ASSOCSTR_DDEIFEXEC,
    ASSOCSTR_DDEAPPLICATION,
    ASSOCSTR_DDETOPIC );
const
  AssocStrDisplaystrings : array [ASSOCSTR_COMMAND..ASSOCSTR_DDETOPIC]
    of string =  (
    'ASSOCSTR_COMMAND',
    'ASSOCSTR_EXECUTABLE',
    'ASSOCSTR_FRIENDLYDOCNAME',
    'ASSOCSTR_FRIENDLYAPPNAME',
    'ASSOCSTR_NOOPEN',
    'ASSOCSTR_SHELLNEWVALUE',
    'ASSOCSTR_DDECOMMAND',
    'ASSOCSTR_DDEIFEXEC',
    'ASSOCSTR_DDEAPPLICATION',
    'ASSOCSTR_DDETOPIC' );

function AssocQueryString( Flags: Integer; StrType: TAssocStr;
   pszAssoc, pszExtra: PChar; pszOut: PChar; Var pcchPut: DWORD
 ): HRESULT; stdcall; external 'shlwapi.dll' name 'AssocQueryStringA';

function CheckKML:boolean;
var
 Buf: array[0..1024] of Char;
 BufSize: LongWord;
begin
Result:=false;
  BufSize := Sizeof(Buf);
   if Succeeded(AssocQueryString(ASSOCF_NOTRUNCATE, ASSOCSTR_EXECUTABLE, '.kml',
      'open', Buf, BufSize)) then Result:=true;
end;


procedure RunProc(cmd:string);
 Var
  StartupInfo:  TStartupInfo;
  ProcessInfo:  TProcessInformation;
begin
  Fillchar(startupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb:=Sizeof(StartupInfo);
   if CreateProcess(nil, Pchar(cmd), nil, nil, false, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then begin
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
   end;
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


end.
