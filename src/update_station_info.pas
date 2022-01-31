unit update_station_info;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  DateUtils, Math;

type

  { Tfrmupdate_station_info }

  Tfrmupdate_station_info = class(TForm)
    btnUpdate: TButton;
    cgSource: TCheckGroup;
    lbAll: TLabel;

    procedure btnUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbAllClick(Sender: TObject);

  private

  public

  end;

var
  frmupdate_station_info: Tfrmupdate_station_info;

implementation

{$R *.lfm}

uses main, dm, procedures;

{ Tfrmupdate_station_info }


procedure Tfrmupdate_station_info.FormShow(Sender: TObject);
begin
  with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select distinct("source"."name") ');
      SQL.Add(' from "source", "table", "timestep" ');
      SQL.Add(' where ');
      SQL.Add(' "table"."source_id"="source"."id" and ');
      SQL.Add(' "table"."timestep_id"="timestep"."id" ');
      SQL.Add(' order by "source"."name" ');
     Open;
   end;

   cgSource.Items.clear;
   while not frmdm.q1.EOF do begin
     cgSource.Items.Add(frmdm.q1.Fields[0].AsString);
    frmdm.q1.Next;
   end;
   frmdm.q1.Close;
end;

procedure Tfrmupdate_station_info.lbAllClick(Sender: TObject);
var
  fl:boolean;
  k: integer;
begin
  fl:=cgSource.Checked[0];
  for k:=0 to cgSource.Items.Count-1 do
    cgSource.Checked[k]:= not fl;
end;

procedure Tfrmupdate_station_info.btnUpdateClick(Sender: TObject);
var
station_id, table_id, rcnt, tot_cnt, timestep, src_id,k:integer;
vmin, vmax, RowComp:real;
dmin, dmax:TDateTime;
yy_min, mn_min, dd_min, yy_max, mn_max, dd_max:word;

tbl_name, src_str, tbl_str: string;
cnt_stn, cnt_tot: integer;
begin
  btnUpdate.Enabled:=false;

  src_str:='';
  for k:=0 to cgSource.Items.Count-1 do
    if cgSource.Checked[k] = true then
      src_str:=src_str+','+QuotedStr(cgSource.Items.Strings[k]);
  src_str:=copy(src_str, 2, length(src_str));
 // showmessage(src_str);


  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "table"."id" from "table", "source" ');
    SQL.Add(' where ');
    SQL.Add(' "table"."source_id"="source"."id" and ');
    SQL.Add(' "source"."name" in ('+src_str+') ');
   Open;
  end;

  tbl_str:='';
  while not frmdm.q1.EOF do begin
    tbl_str:=tbl_str+','+Inttostr(frmdm.q1.Fields[0].Value);
    frmdm.q1.Next;
  end;
  tbl_str:=copy(tbl_str, 2, length(tbl_str));
 // showmessage(tbl_str);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' delete from "station_info" ');
    SQL.Add(' where "table_id" in ('+tbl_str+')');
   ExecSQL;
  end;
  frmdm.TR.CommitRetaining;


  with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id", "name", "timestep_id" ');
     SQL.Add(' from "table" ');
     SQL.Add(' where "id" in ('+tbl_str+') ');
     SQL.Add(' order by "id" ');
    Open;
  end;

  with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station" order by "id" ');
    Open;
    Last;
    First;
  end;

  cnt_tot:=frmdm.q1.RecordCount;

  cnt_stn:=0;
  while not frmdm.q1.eof do begin
    inc(cnt_stn);
    station_id:=frmdm.q1.FieldByName('id').AsInteger;

    frmdm.q2.First;
    while not frmdm.q2.eof do begin
      table_id:=frmdm.q2.FieldByName('id').AsInteger;
      tbl_name:=frmdm.q2.FieldByName('name').AsString;
      timestep:=frmdm.q2.FieldByName('timestep_id').AsInteger;


     tot_cnt:=0; rcnt:=0;
     with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select count("station_id") as rcnt, ');
       SQL.Add(' min("date") as dmin, max("date") as dmax, ');
       SQL.Add(' min("value") as vmin, max("value") as vmax ');
       SQL.Add(' from "'+tbl_name+'" where ');
       SQL.Add(' "station_id"=:id and "pqf2"=0 '); //only good values
       ParamByName('id').AsInteger:=station_id;
      Open;
       rcnt :=FieldByName('rcnt').AsInteger;
       dmin :=FieldByName('dmin').AsDateTime;
       dmax :=FieldByName('dmax').AsDateTime;
       vmin :=FieldByName('vmin').AsFloat;
       vmax :=FieldByName('vmax').AsFloat;
      Close;
     end;

    DecodeDate(dmin, yy_min, mn_min, dd_min);
    DecodeDate(dmax, yy_max, mn_max, dd_max);

    case timestep of
      1: tot_cnt:=YearsBetween(dmin, dmax);
      2: tot_cnt:=MonthsBetween(dmin, dmax);
      3: tot_cnt:=DaysBetween(dmin, dmax);
     // 4: tot_cnt:=trunc(HoursBetween(dmin, dmax)/3);
    end;

    if tot_cnt=0 then tot_cnt:=1;
    if tot_cnt>1 then RowComp:=100*(rcnt/(tot_cnt+2)) else RowComp:=100;

    if tot_cnt=4 then RowComp:=-1;


    if (rcnt>0) {and (MonthTotal>0)} then begin
       With frmdm.q3 do begin
         Close;
          SQL.Clear;
          SQL.Add(' insert into "station_info" ');
          SQL.Add(' ("station_id", "table_id", "date_min", "date_max", ');
          SQL.Add('  "val_min", "val_max", "cnt", "perc") ');
          SQL.Add(' values ');
          SQL.Add(' (:station_id, :table_id, :date_min, :date_max, ');
          SQL.Add('  :VAL_MIN, :VAL_MAX, :CNT, :PERC) ');
          ParamByName('station_id').asInteger:=station_id;
          ParamByName('table_id').asInteger:=table_id;
          ParamByName('date_min').asDateTime:=dmin;
          ParamByName('date_max').asDateTime:=dmax;
          ParamByName('VAL_MIN').asFloat:=vmin;
          ParamByName('VAL_MAX').asFloat:=vmax;
          ParamByName('CNT').asInteger:=rcnt;
          ParamByName('PERC').asFloat:=RoundTo(RowComp, -2);
         ExecSQL;
       end;
      end; //row cnt
     frmdm.q2.Next;
    end;
    frmdm.TR.CommitRetaining;

    with frmdm.q3 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select "station_id" from "station_info" ');
      SQL.Add(' where "station_id"='+inttostr(station_id));
     Open;
    end;

    if frmdm.q3.IsEmpty=true then begin
     with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set "empty"=true where ');
       SQL.Add(' "id"='+inttostr(station_id));
      ExecSQL;
     end;
     frmdm.TR.CommitRetaining;
    end;

    ProgressTaskbar(cnt_stn, cnt_tot);


   frmdm.q1.next;
  end;

  frmdm.TR.Commit;
  if MessageDlg('Station_info has been successfully updated', mtInformation,
    [mbOk], 0)=mrOk then begin
      ProgressTaskbar(0, 0);
      Close;
  end;
end;

end.

