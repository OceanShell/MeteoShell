unit tool_random_single_use_scripts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, DB, SQLDB, main, dm;

procedure UpdateICAOCodes;
procedure ECADTransferNames;

implementation

procedure UpdateICAOCodes;
Var
  k, md, id:integer;
  fname,icao,wmo,ghcn, st1, buf_str, ghcnd_id:string;
  fi_dat:text;
  TRt1:TSQLTransaction;
  db1q1, db1q2:TSQLQuery;
begin
  fname:='Z:\MeteoShell\data\_wmo\master-location-identifier-database-202401_standard_AS1.csv';

  try
    TRt1:=TSQLTransaction.Create(nil);
    TRt1.DataBase:=frmdm.TR.DataBase;
    db1q1:=TSQLQuery.Create(nil);
    db1q1.Database:=frmdm.TR.DataBase;
    db1q1.Transaction:=TRt1;
    db1q2:=TSQLQuery.Create(nil);
    db1q2.Database:=frmdm.TR.DataBase;
    db1q2.Transaction:=TRt1;

     AssignFile(fi_dat, fname); reset(fi_dat);
     readln(fi_dat, st1);
     repeat
       readln(fi_dat,st1);

       k:=0;
       for md:=1 to 3 do begin
        buf_str:='';
         repeat
           inc(k);
           if (st1[k]<>',') and (k<=length(st1)) then buf_str:=buf_str+st1[k];
         until (st1[k]=',') or (k=length(st1));
         if md=1 then icao:=trim(buf_str);
         if md=2 then wmo:=trim(buf_str);
         if md=3 then ghcn:=trim(buf_str);
       end;

       with db1q1 do begin
         Close;
           SQL.Clear;
           SQL.Add(' select "id", "ghcnd_id" from "station" where ');
           SQL.Add(' "wmocode"=:wmo ');
           Parambyname('wmo').Value:=StrToInt(wmo);
        Open;
       end;

       if not db1q1.IsEmpty then begin
         id := db1q1.FieldByName('id').Value;

         with db1q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' update "station" set "icao"=:icao where ');
           SQL.Add(' "wmocode"=:wmo ');
           Parambyname('icao').Value:=icao;
           Parambyname('wmo').Value:=StrToInt(wmo);
          ExecSQL;
        end;

       end;

     {    if (ghcn<>'') and (ghcn<>ghcnd_id) then
         showmessage(wmo+'   '+ghcn+'   '+ghcnd_id);
       end; }

     until eof(fi_dat);
     close(fi_dat);

  finally
    db1q1.Close;
    db1q1.Free;
    db1q2.Close;
    db1q2.Free;
    Trt1.Commit;
    Trt1.Free;
  end;
end;


procedure ECADTransferNames;
Var
  id:integer;
  ecad:string;

  TRt1:TSQLTransaction;
  db1q1, db1q2:TSQLQuery;
begin
  try
    TRt1:=TSQLTransaction.Create(nil);
    TRt1.DataBase:=frmdm.TR.DataBase;
    db1q1:=TSQLQuery.Create(nil);
    db1q1.Database:=frmdm.TR.DataBase;
    db1q1.Transaction:=TRt1;
    db1q2:=TSQLQuery.Create(nil);
    db1q2.Database:=frmdm.TR.DataBase;
    db1q2.Transaction:=TRt1;

        with db1q1 do begin
         Close;
           SQL.Clear;
           SQL.Add(' select "id", "ecad_name" from "temp" where ');
           SQL.Add(' "ecad_name" is not null ');
        Open;
       end;

       while not db1q1.EOF do begin
         id := db1q1.FieldByName('id').Value;
         ecad := db1q1.FieldByName('ecad_name').Value;
         with db1q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' update "station" set "ecad_name"=:ecad where ');
           SQL.Add(' "id"=:id ');
           Parambyname('ecad').Value:=ecad;
           Parambyname('id').Value:=id;
          ExecSQL;
        end;
        db1q1.Next;
       end;


  finally
    db1q1.Close;
    db1q1.Free;
    db1q2.Close;
    db1q2.Free;
    Trt1.Commit;
    Trt1.Free;
  end;

end;

end.

