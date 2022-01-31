unit load_ecad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Variants;

type

  { Tfrmload_ecad }

  Tfrmload_ecad = class(TForm)
    btnMetadata1: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    mLog: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure btnMetadata1Click(Sender: TObject);
    procedure btnMetadataClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    procedure GetTableName(par:string; var tbl:string; var scale:real);
  public

  end;

var
  frmload_ecad: Tfrmload_ecad;

implementation

{$R *.lfm}

uses dm, procedures;

{ Tfrmload_ecad }


procedure Tfrmload_ecad.btnMetadata1Click(Sender: TObject);
Var
 db_name, ecad_name:string;
 absnum, ecad_id, cnt:integer;
 ecad_lat, ecad_lon, diff: real;
begin
   with frmdm.q2 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select * from "station_ecad" ');
      SQL.Add(' order by "name" ');
     Open;
   end;

 while not frmdm.q2.EOF do begin
 // ecad_id:=frmdm.q2.FieldByName('id').Value;
  ecad_name:=frmdm.q2.FieldByName('name').Value;
  ecad_lat:=frmdm.q2.FieldByName('latitude').Value;
  ecad_lon:=frmdm.q2.FieldByName('longitude').Value;

     absnum:=-9;
     //diff:=60;
     diff:=60;
     with frmdm.q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select "id", "name" from "station"');
       SQL.Add(' where ');
       SQL.Add(' ("latitude">=:lat1 and "latitude"<=:lat2) and ');
       SQL.Add(' ("longitude">=:lon1 and "longitude"<=:lon2) and ');
       SQL.Add(' ("ecad_name" is null) ');
       parambyname('lat1').Value:=ecad_lat-diff/60;
       parambyname('lat2').Value:=ecad_lat+diff/60;
       parambyname('lon1').Value:=ecad_lon-diff/60;
       parambyname('lon2').Value:=ecad_lon+diff/60;
      Open;
      Last;
      First;
       if frmdm.q1.IsEmpty=false then begin
         absnum:=frmdm.q1.Fields[0].AsInteger;
         db_name:=frmdm.q1.Fields[1].AsString;
         cnt:=frmdm.q1.RecordCount;
       end else absnum:=-9;
      Close;
     end;

   if (absnum<>-9)
   and (cnt=1)
   and (copy(db_name,1,2)=copy(ecad_name,1,2))
   // and (db_name=ecad_name)
   then begin

        with frmdm.q3 do begin
            Close;
              SQL.Clear;
              SQL.Add(' update "station" set ');
              SQL.Add(' "ecad_name"='+QuotedStr(ecad_name));
              SQL.Add(' where "id"='+inttostr(absnum));
            ExecSQL;
          end;
        mLog.lines.add(ecad_name+'   '+
                       db_name+'   '+
                        floattostr(ecad_lat)+'   '+
                        floattostr(ecad_lon));
        frmdm.TR.CommitRetaining;
     end; // else mLog.lines.add(st);

   frmdm.q2.Next;
 end;
 frmdm.q2.Close;
 frmdm.TR.Commit;
end;

procedure Tfrmload_ecad.btnMetadataClick(Sender: TObject);
begin

end;

procedure Tfrmload_ecad.Button1Click(Sender: TObject);
var
vn:string;
 cnt:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select distinct("ecad_name"), count("ecad_name") ');
    SQL.Add(' from "station" group by "ecad_name"');
   Open;
  end;

   while not frmdm.q1.eof  do begin
      VN :=frmdm.q1.Fields[0].AsString;
      Cnt:=frmdm.q1.Fields[1].AsInteger;
       if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
     frmdm.q1.next;
   end;
end;


procedure Tfrmload_ecad.Button2Click(Sender: TObject);
Var
   fpath, fname, db_name, ecad_name, st, iso:string;
   pp, k, ff, absnum, ecad_id, cnt, elev:integer;
   ecad_lat, ecad_lon: real;
   datf: text;
   db_id:Variant;
   elem_id, date_start, date_stop, par_id, par_name, par: string;
begin

 fpath:='X:\Data_Oceanography\_Meteo\ECAD\';

   with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ecad" ');
   ExecSQL;
  end;
  frmdm.TR.Commit;

 for pp:=1 to 13 do begin
   case pp of
     1:  par:='cc';
     2:  par:='dd';
     3:  par:='fg';
     4:  par:='fx';
     5:  par:='hu';
     6:  par:='pp';
     7:  par:='qq';
     8:  par:='rr';
     9:  par:='sd';
     10: par:='ss';
     11: par:='tg';
     12: par:='tn';
     13: par:='tx';
   end;

 fname:=fpath+'ECA_nonblend_'+par+PathDelim+'sources.txt';
 caption:=par;



  AssignFile(datf, fname);
  reset(datf);

  for k:=1 to 24 do readln(datf, st);
 cnt:=24;

 repeat
  readln(datf, st);
  inc(cnt);

 // ecad_id:=strtoint(trim(Copy(st, 1, 6)));
 try
  ecad_name:=trim(Copy(st, 8, 39));
  if ecad_name='' then Continue;

  iso:=Copy(st, 49, 2);

  ecad_lat:=strtoint(Copy(st, 52, 3))+
            (strtofloat(Copy(st, 56, 2))/60)+
            (strtofloat(Copy(st, 59, 2))/3600);

  ecad_lon:=strtoint(Copy(st, 62, 4))+
            (strtofloat(Copy(st, 67, 2))/60)+
            (strtofloat(Copy(st, 70, 2))/3600);

  elev:=strtoint(trim(Copy(st, 73, 4)));
  elem_id:=trim(Copy(st, 78, 4));
  date_start:=trim(Copy(st, 83, 8));
  date_stop:=trim(Copy(st, 92, 8));
  par_id:=trim(Copy(st, 101, 5));
  par_name:=trim(Copy(st, 107, 50));

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from "station_ecad"  ');
    SQL.Add(' where "name"=:stname ');
    ParamByName('StName').Value:=ecad_Name;
   Open;
  end;

  except
    showmessage(inttostr(cnt));
  end;
  if frmdm.q1.IsEmpty then begin
    try
     with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ecad"  ');
         SQL.Add(' ("latitude", "longitude", "elevation", ');
         SQL.Add('  "name", "iso", "element_id", "date_start", ');
         SQL.Add('  "date_stop", "participant_id", "participant_name") ');
         SQL.Add(' values ');
         SQL.Add(' (:StLat, :StLon, :Elevation, :StName, :iso, ');
         SQL.Add('  :el_id, :dd1, :dd2, :par_id, :par_name)');
         ParamByName('StLat').AsFloat:=ecad_Lat;
         ParamByName('StLon').AsFloat:=ecad_Lon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').Value:=ecad_Name;
         ParamByName('iso').AsString:=iso;
         ParamByName('el_id').AsString:=elem_id;
         ParamByName('dd1').AsString:=date_start;
         ParamByName('dd2').AsString:=date_stop;
         ParamByName('par_id').AsString:=par_id;
         ParamByName('par_name').AsString:=par_name;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;
     except
      frmdm.TR.RollbackRetaining;
     end;

  end;

 until eof(datf);
 closefile(datf);

 end;
   frmdm.TR.Commit;
end;



procedure Tfrmload_ecad.Button3Click(Sender: TObject);
var
 dat: text;
 st, fpath, fname, par, tbl, ghcn_id, mname:string;
 k, c, yy, mn, dd, cnt, cnt_par, flag, fl:integer;
 stat_cnt, id, ecad_id, pp: integer;
 datecurr, date_max_file, date_max_db: TDateTime;
 qcf1, qcf2, qcf3, ecad_name: string;
 val0, val1, scale: real;
 par_arr: array of string;
begin

 fpath:='X:\Data_Oceanography\_Meteo\ECAD\';

   with frmdm.q1 do begin
    Close;
      SQL.Clear;
      SQL.Add(' Select "id", "ecad_name" from "station" ');
      SQL.Add(' where "ecad_name" is not null ');
      SQL.Add(' order by "id" ');
    Open;
    Last;
    First;
  end;
  stat_cnt:=frmdm.q1.RecordCount;

 for pp:=1 to 13 do begin

   case pp of
     1:  par:='cc';
     2:  par:='dd';
     3:  par:='fg';
     4:  par:='fx';
     5:  par:='hu';
     6:  par:='pp';
     7:  par:='qq';
     8:  par:='rr';
     9:  par:='sd';
     10: par:='ss';
     11: par:='tg';
     12: par:='tn';
     13: par:='tx';
   end;

  tbl:='';
  GetTableName(par, tbl, scale);

  if tbl='' then Continue;

  cnt:=0;
  frmdm.q1.First;
  while not frmdm.q1.EOF do begin
   inc(cnt);
   id:=frmdm.q1.FieldByName('id').Value;
   ecad_name:=frmdm.q1.FieldByName('ecad_name').Value;

   caption:=tbl+': '+inttostr(id)+', '+ecad_name;
   Application.ProcessMessages;

   mname:=fpath+'ECA_nonblend_'+par+PathDelim+'sources.txt';
 //  showmessage(mname);

   AssignFile(dat, mname); reset(dat);
   ecad_id:=-9;
   repeat
    readln(dat, st);
    if trim(Copy(st, 8, 39))=ecad_name then ecad_id:=strtoint(trim(Copy(st, 1, 6)));
   until (trim(Copy(st, 8, 39))=ecad_name) or (eof(dat));
   CloseFile(dat);

 //  showmessage(inttostr(ecad_id));
   fname:=fpath+'ECA_nonblend_'+par+PathDelim+par+'_SOUID'+inttostr(ecad_id)+'.txt';

   if (FileExists(fname)=true) and (ecad_id<>-9) then begin

    date_max_db:=EncodeDate(1, 1, 1);
     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select max("date") from "'+tbl+'" ');
       SQL.Add(' where "station_id"=:id ');
       ParamByName('id').Value:=id;
      Open;
        if frmdm.q2.IsEmpty=false then begin
          date_max_db:=frmdm.q2.Fields[0].AsDateTime;
        end;
      Close;
     end;


    Assignfile(dat, fname); reset(dat);
    for k:=1 to 19 do readln(dat, st);

    c:=0; cnt_par:=0;
    repeat
     readln(dat, st);

     yy:=StrToInt(copy(st,15,4));
     mn:=StrToInt(copy(st,19,2));
     dd:=StrToInt(copy(st,21,2));

     DateCurr:=EncodeDate(yy, mn, dd);

     val0:=StrToFloat(copy(st,24,5));
     flag:=StrToInt(copy(st,30,5));


     if (val0<>-9999) and (datecurr>date_max_db) then begin

       val1:=val0*scale; //10;

           with frmdm.q2 do begin
             Close;
              SQL.Clear;
              SQL.Add(' insert into "'+tbl+'" ');
              SQL.Add(' ("station_id", "date", "value", "pqf1", "pqf2") ');
              SQL.Add(' values ');
              SQL.Add(' (:absnum, :date_, :value_, :pqf1, :pqf2)');
              ParamByName('absnum').AsInteger:=id;
              ParamByName('date_').AsDate:=DateCurr;
              ParamByName('value_').AsFloat:=val1;
              ParamByName('pqf1').AsInteger:=flag;
              ParamByName('pqf2').AsInteger:=flag;
             ExecSQL;
           end;
      end;
    until eof(dat);
   end;

     frmdm.TR.CommitRetaining;
     ProgressTaskbar(cnt, stat_cnt);
     Application.ProcessMessages;

    frmdm.q1.Next;
  end;

end;
 ProgressTaskbar(0, 0);
end;

procedure Tfrmload_ecad.GetTableName(par:string; var tbl:string; var scale:real);
begin
tbl:='';
scale:=1;

  if par='cc' then begin tbl:='p_cloud_total_ecad';         scale:=1; end;
  if par='dd' then begin tbl:='p_wind_direction_ecad';      scale:=1; end;
  if par='fg' then begin tbl:='p_wind_speed_ecad';          scale:=0.1; end;
  if par='fx' then begin tbl:='p_wind_speedmax_ecad';       scale:=0.1; end;
  if par='hu' then begin tbl:='p_relative_humidity_ecad';   scale:=1; end;
  if par='pp' then begin tbl:='p_sea_level_pressure_ecad';  scale:=1; end;
  if par='qq' then begin tbl:='p_radiation_ecad';           scale:=1; end;
  if par='rr' then begin tbl:='p_precipitation_ecad';       scale:=1; end;
  if par='sd' then begin tbl:='p_snowdepth_ecad';           scale:=10; end;
  if par='ss' then begin tbl:='p_sunshine_duration_ecad';   scale:=0.1; end;
  if par='tg' then begin tbl:='p_surface_air_temp_ecad';    scale:=0.1; end;
  if par='tn' then begin tbl:='p_surface_air_tempmin_ecad'; scale:=0.1; end;
  if par='tx' then begin tbl:='p_surface_air_tempmax_ecad'; scale:=0.1; end;
end;

end.

