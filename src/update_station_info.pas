unit update_station_info;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DateUtils, Math, dm, procedures, Dialogs;

function UpdateStation_Info:boolean;


implementation


function UpdateStation_Info:boolean;
var
station_id, parameter_id, rcnt, MonthTotal:integer;
vmin, vmax, RowComp:real;
dmin, dmax:TDateTime;
yy_min, mn_min, dd_min, yy_max, mn_max, dd_max:word;

tbl_name: string;
cnt_stn, cnt_tot: integer;

TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
begin

try
(* temporary transaction for support database *)
TRt:=TSQLTransaction.Create(nil);
TRt.DataBase:=frmdm.TR.DataBase;

(* temporary query for main database *)
Qt1 :=TSQLQuery.Create(nil);
Qt1.Database:=TRt.DataBase;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(nil);
Qt2.Database:=TRt.DataBase;
Qt2.Transaction:=TRt;

Qt3 :=TSQLQuery.Create(nil);
Qt3.Database:=TRt.DataBase;
Qt3.Transaction:=TRt;

(* Cleaning up station_info *)
  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' delete from "station_info"');
   ExecSQL;
  end;
  Trt.Commit;

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' update "station" set "empty"=false ');
   ExecSQL;
  end;
  Trt.Commit;


  with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select * from "parameter" ');
    Open;
  end;

  with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station" order by "id" ');
    Open;
    Last;
    First;
  end;

  cnt_tot:=Qt1.RecordCount;

try
  cnt_stn:=0;
  while not Qt1.eof do begin
    inc(cnt_stn);
    station_id:=Qt1.FieldByName('id').AsInteger;

    Qt2.First;
    while not Qt2.eof do begin
      tbl_name:=Qt2.FieldByName('table').AsString;
      parameter_id:=Qt2.FieldByName('id').AsInteger;

     MonthTotal:=0;  rcnt:=0;
     with Qt3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select count("station_id") as rcnt, ');
       SQL.Add(' min("date") as dmin, max("date") as dmax, ');
       SQL.Add(' min("value") as vmin, max("value") as vmax ');
       SQL.Add(' from "'+tbl_name+'" where ');
       SQL.Add(' "station_id"=:id ');
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

    MonthTotal:=MonthsBetween(dmin, dmax);
    if MonthTotal=0 then MonthTotal:=1;

    if (rcnt>0) {and (MonthTotal>0)} then begin

      if MonthTotal>1 then RowComp:=100*(rcnt/(MonthTotal+2)) else RowComp:=100;

       With Qt3 do begin
         Close;
          SQL.Clear;
          SQL.Add(' insert into "station_info" ');
          SQL.Add(' ("station_id", "parameter_id", "yy_min", "mn_min", ');
          SQL.Add('  "yy_max", "mn_max", "val_min", "val_max", "cnt", "perc") ');
          SQL.Add(' values ');
          SQL.Add(' (:station_id, :parameter_id, :YY_MIN, :MN_MIN, :YY_MAX, :MN_MAX, ');
          SQL.Add('  :VAL_MIN, :VAL_MAX, :CNT, :PERC) ');
          ParamByName('station_id').asInteger:=station_id;
          ParamByName('parameter_id').asInteger:=parameter_id;
          ParamByName('YY_MIN').asInteger:=yy_min;
          ParamByName('MN_MIN').asInteger:=mn_min;
          ParamByName('YY_MAX').asInteger:=yy_max;
          ParamByName('MN_MAX').asInteger:=mn_max;
          ParamByName('VAL_MIN').asFloat:=vmin;
          ParamByName('VAL_MAX').asFloat:=vmax;
          ParamByName('CNT').asInteger:=rcnt;
          ParamByName('PERC').asFloat:=RoundTo(RowComp, -2);
         ExecSQL;
       end;
      end; //row cnt
     Qt2.Next;
    end;
    TRt.CommitRetaining;

    with Qt3 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select "station_id" from "station_info" ');
      SQL.Add(' where "station_id"='+inttostr(station_id));
     Open;
    end;

    if Qt3.IsEmpty=true then begin
     with Qt3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set "empty"=true where ');
       SQL.Add(' "id"='+inttostr(station_id));
      ExecSQL;
     end;
     TRt.CommitRetaining;
    end;

    ProgressTaskbar(cnt_stn, cnt_tot);


   Qt1.next;
  end;
 finally
  TRt.Commit;

  Qt1.Close;
  Qt2.Close;
  Qt3.Close;

  Qt1.Free;
  Qt2.Free;
  Qt3.Free;

  TRt.Free;

  ProgressTaskbar(0, 0);
  Result:=true;
 end;
except
 Result:=false;
end;
end;


end.

