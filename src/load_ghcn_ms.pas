unit load_ghcn_ms;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls;

type

  { Tfrmloadghcn_ms }

  Tfrmloadghcn_ms = class(TForm)
    Button1: TButton;
    chkOutput: TCheckBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmloadghcn_ms: Tfrmloadghcn_ms;

implementation

{$R *.lfm}

uses main;

{ Tfrmloadghcn_ms }

procedure Tfrmloadghcn_ms.Button1Click(Sender: TObject);
var
yy, mn, k, md, absnum, cnt: integer;
EMXP,MXSD,TPCP,TSNW,EMXT,EMNT,MMXT,MMNT,MNTM,par:real;
ID, ID_OLD, FileForRead, st0, st1, date1, buf_str, tbl, stname:string;
begin
{  memo1.Clear;
  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='csv|*.csv';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  readln(fi_dat, st0);
  cnt:=0; ID_OLD:='';
  repeat
  st1:='';
  readln(fi_dat, st1);
   k:=0;
   EMXP:=-9999; MXSD:=-9999; TPCP:=-9999; TSNW:=-9999; EMXT:=-9999;
   EMNT:=-9999; MMXT:=-9999; MMNT:=-9999; MNTM:=-9999;
   for md:=1 to 12 do begin
    buf_str:='';
    repeat
     inc(k);
     if st1[k]<>',' then buf_str:=buf_str+st1[k];
    until (st1[k]=',') or (k=length(st1));
     if md=1 then ID:=trim(copy(buf_str, 7, length(buf_str)));
     if md=2 then stname:=trim(buf_str);
     if md=3 then begin
         date1 :=trim(buf_str);
         yy:=StrToInt(copy(date1, 1, 4));
         mn:=StrToInt(copy(date1, 5, 2));
     end;
     if md=4  then if TryStrToFloat(trim(buf_str), EMXP)  then EMXP :=StrToFloat(trim(buf_str)) else EMXP :=-9999;
     if md=5  then if TryStrToFloat(trim(buf_str), MXSD)  then MXSD :=StrToFloat(trim(buf_str)) else MXSD :=-9999;
     if md=6  then if TryStrToFloat(trim(buf_str), TPCP)  then TPCP :=StrToFloat(trim(buf_str)) else TPCP :=-9999;
     if md=7  then if TryStrToFloat(trim(buf_str), TSNW)  then TSNW :=StrToFloat(trim(buf_str)) else TSNW :=-9999;
     if md=8  then if TryStrToFloat(trim(buf_str), EMXT)  then EMXT :=StrToFloat(trim(buf_str)) else EMXT :=-9999;
     if md=9  then if TryStrToFloat(trim(buf_str), EMNT)  then EMNT :=StrToFloat(trim(buf_str)) else EMNT :=-9999;
     if md=10 then if TryStrToFloat(trim(buf_str), MMXT)  then MMXT :=StrToFloat(trim(buf_str)) else MMXT :=-9999;
     if md=11 then if TryStrToFloat(trim(buf_str), MMNT)  then MMNT :=StrToFloat(trim(buf_str)) else MMNT :=-9999;
     if md=12 then if TryStrToFloat(trim(buf_str), MNTM)  then MNTM :=StrToFloat(trim(buf_str)) else MNTM :=-9999;
   end;
   inc(cnt);

 {  if ID<>ID_OLD then begin
     with dm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' select absnum from STATION where ');
         SQL.Add(' GHCN_V4_ID=:ID ');
         ParamByName('ID').AsString:=ID;
        Open;
         if dm.q1.IsEmpty=false then
             absnum:=dm.q1.Fields[0].AsInteger else absnum:=-9;
        Close;
      end;
     ID_OLD:=ID;
   end; }

     if absnum=-9 then begin
         memo1.Lines.Add(id+'   '+stname);
          application.ProcessMessages;;
     end;


     if md=4  then if TryStrToFloat(trim(buf_str), EMXP)  then EMXP :=StrToFloat(trim(buf_str)) else EMXP :=-9999;
     if md=5  then if TryStrToFloat(trim(buf_str), MXSD)  then MXSD :=StrToFloat(trim(buf_str)) else MXSD :=-9999;
     if md=6  then if TryStrToFloat(trim(buf_str), TPCP)  then TPCP :=StrToFloat(trim(buf_str)) else TPCP :=-9999;
     if md=7  then if TryStrToFloat(trim(buf_str), TSNW)  then TSNW :=StrToFloat(trim(buf_str)) else TSNW :=-9999;
     if md=8  then if TryStrToFloat(trim(buf_str), EMXT)  then EMXT :=StrToFloat(trim(buf_str)) else EMXT :=-9999;
     if md=9  then if TryStrToFloat(trim(buf_str), EMNT)  then EMNT :=StrToFloat(trim(buf_str)) else EMNT :=-9999;
     if md=10 then if TryStrToFloat(trim(buf_str), MMXT)  then MMXT :=StrToFloat(trim(buf_str)) else MMXT :=-9999;
     if md=11 then if TryStrToFloat(trim(buf_str), MMNT)  then MMNT :=StrToFloat(trim(buf_str)) else MMNT :=-9999;
     if md=12 then if TryStrToFloat(trim(buf_str), MNTM)  then MNTM :=StrToFloat(trim(buf_str)) else MNTM :=-9999;

     if absnum<>-9 then begin
      for k:=1 to 9 do begin
       case k of
        1: begin par:=EMXP;  tbl:='P_PRECIPITATION_MAX_E'; end;
        2: begin par:=MXSD;  tbl:='P_SNOW_DEPTH_MAX'; end;
        3: begin par:=TPCP;  tbl:='P_PRECIPITATION'; end;
        4: begin par:=TSNW;  tbl:='P_SNOW_FALL'; end;
        5: begin par:=EMXT;  tbl:='P_SURFACE_AIR_TEMPERATURE_MAX_E'; end;
        6: begin par:=EMNT;  tbl:='P_SURFACE_AIR_TEMPERATURE_MIN_E'; end;
        7: begin par:=MMXT;  tbl:='P_SURFACE_AIR_TEMPERATURE_MAX'; end;
        8: begin par:=MMNT;  tbl:='P_SURFACE_AIR_TEMPERATURE_MIN'; end;
        9: begin par:=MNTM;  tbl:='P_SURFACE_AIR_TEMPERATURE'; end;
       end;

      if par<>-9999 then begin
     {  with dm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' select absnum from '+tbl+' where ');
         SQL.Add(' absnum=:absnum and year_=:yy and month_=:mn ');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('yy').AsInteger:=yy;
         ParamByName('mn').AsInteger:=mn;
        Open;
       end;   }

     {  if dm.q1.IsEmpty=true then begin;
         with dm.q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' insert into '+tbl);
           SQL.Add(' (absnum, year_, month_, val_, fl_) ');
           SQL.Add(' values ');
           SQL.Add(' (:absnum, :year_, :month_, :val_, :fl_)');
           ParamByName('absnum').AsInteger:=absnum;
           ParamByName('year_').AsInteger:=yy;
           ParamByName('month_').AsInteger:=mn;
           ParamByName('val_').AsFloat:=par;
           ParamByName('fl_').AsInteger:=0;
          ExecSQL;
        end;
        dm.TR.CommitRetaining;
       end;  }
      end;
     end;
   end; //date range

   application.ProcessMessages;
   until eof(fi_dat);

   CloseFile(fi_dat);
   frmdm.TR.Commit;
   showmessage('done');  }
end;

end.

