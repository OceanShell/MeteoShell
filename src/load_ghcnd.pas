unit load_ghcnd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  DateUtils;

type

  { Tfrmloadghcnd }

  Tfrmloadghcnd = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    mLog: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);

  private
    procedure GetTableName(par:string; var tbl:string);
  public

  end;

var
  frmloadghcnd: Tfrmloadghcnd;

implementation

{$R *.lfm}

uses dm, main, procedures;

{ Tfrmloadghcnd }

procedure Tfrmloadghcnd.Button1Click(Sender: TObject);
var
 dat: text;
 st, fpath, fname, par, tbl, ghcn_id:string;
 k, c, yy, mn, dd, cnt, cnt_par, flag, fl:integer;
 stat_cnt, id: integer;
 datecurr, date_max_file, date_max_db: TDateTime;
 qcf1, qcf2, qcf3: string;
 val0, val1: real;
 par_arr: array of string;
begin

 fpath:='X:\Data_Oceanography\_Meteo\ghcn_daily\ghcnd_all\';

   with frmdm.q1 do begin
    Close;
      SQL.Clear;
      SQL.Add(' Select "id", "ghcnd_id" from "station" ');
      SQL.Add(' where "ghcnd_id" is not null ');
      SQL.Add(' order by "id" ');
    Open;
    Last;
    First;
  end;

  stat_cnt:=frmdm.q1.RecordCount;

  cnt:=0;
  while not frmdm.q1.EOF do begin
   inc(cnt);
   id:=frmdm.q1.FieldByName('id').Value;
   ghcn_id:=frmdm.q1.FieldByName('ghcnd_id').Value;

   caption:=inttostr(id)+': '+ghcn_id;
   Application.ProcessMessages;

   fname:=fpath+ghcn_id+'.dly';

   SetLength(par_arr,0);
   SetLength(par_arr,100);

   if (FileExists(fname)=true) then begin

    Assignfile(dat, fname); reset(dat);
    c:=0; cnt_par:=0;
    repeat
     readln(dat, st);
     yy:=StrToInt(copy(st,12,4));
     mn:=StrToInt(copy(st,16,2));
     par:=copy(st,18,4);

     fl:=0;
     for c:=0 to high(par_arr) do
      if par=par_arr[c] then fl:=1;

     if fl=0 then begin
       par_arr[cnt_par]:=par;
       inc(cnt_par);
     end;
    until eof(dat);
    CloseFile(dat);

   SetLength(par_arr, cnt_par);
   for c:=0 to high(par_arr) do begin

    GetTableName(par_arr[c], tbl);

    if tbl='' then Continue;

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
    repeat
     readln(dat, st);
     yy:=StrToInt(copy(st,12,4));
     mn:=StrToInt(copy(st,16,2));
     par:=copy(st,18,4);

     if (par=par_arr[c]) then begin
        k:=22;
        for dd:=1 to 31 do begin

         if (copy(st,k,5)<>'-9999') and (IsValidDate(yy, mn, dd)) then begin
          Datecurr:=EncodeDate(yy, mn, dd);
          val0:=Strtoint(copy(st, k, 5));

          if (datecurr>date_max_db) then begin

          (* careful with adding more elements!! *)
          if (par='TAVG') or (par='TMIN') or (par='TMAX') or (par='AWND') then
            val1:=val0/10 else val1:=val0;

          qcf1:=trim(copy(st, k+5, 1));
          qcf2:=trim(copy(st, k+6, 1));
          qcf3:=trim(copy(st, k+7, 1));

          if qcf2='' then flag:=0 else flag:=1;

         // showmessage(datetimetostr(Datecurr)+'   '+tbl+'   '+floattostr(val1));

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
          end; //new values

          k:=k+8;
         end;
      end; //tbl<>'';
    until eof(dat);
   end;

     frmdm.TR.CommitRetaining;
     ProgressTaskbar(cnt, stat_cnt);
     Application.ProcessMessages;
   //  if cnt>10 then exit;

   end;
    frmdm.q1.Next;
  end;
  ProgressTaskbar(0, 0);
end;


procedure Tfrmloadghcnd.Button2Click(Sender: TObject);
Var
   fname, st, v2_id, name_state:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1, wmo:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
   gsn, hcn: string;
begin

(*
ID            1-11   Character
LATITUDE     13-20   Real
LONGITUDE    22-30   Real
ELEVATION    32-37   Real
STATE        39-40   Character
NAME         42-71   Character
GSN FLAG     73-75   Character
HCN/CRN FLAG 77-79   Character
WMO ID       81-85   Character
*)

 frmmain.OD.InitialDir:=GlobalPath+'data\';
 frmmain.OD.Filter:='*.txt|*.txt';

 if frmmain.OD.Execute then fname:=frmmain.OD.FileName else exit;

    AssignFile(datf, fname);
    reset(datf);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ghcnd" ');
   ExecSQL;
  end;
  frmdm.TR.Commit;


   repeat
    readln(datf, st);

     v2_id :=Copy(st, 1, 11);
     stlat:=strtofloat(trim(Copy(st, 13, 8)));
     stlon:=strtofloat(trim(Copy(st, 22, 9)));
     elev:= strtofloat(trim(Copy(st, 32, 6)));
     name_state:=trim(Copy(st, 39, 2));
     stname:=trim(Copy(st, 42, 39));

     gsn:=  trim(Copy(st, 73, 3));
     hcn:=  trim(Copy(st, 77, 3));
     if trim(Copy(st, 81, 5))<>'' then wmo:=StrToInt(trim(Copy(st, 81, 5))) else wmo:=-9;

     with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ghcnd"  ');
         SQL.Add(' ("id", "latitude", "longitude", "elevation", ');
         SQL.Add(' "name", "name_state", "wmo", "gsn_flag", "hcn_flag") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :StLat, :StLon, :Elevation, :StName, :state, ');
         SQL.Add('  :wmo, :gsn_flag, :hcn_flag)');
         ParamByName('absnum').AsString:=v2_id;
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         ParamByName('state').AsString:=name_state;
         ParamByName('wmo').Value:=wmo;
         ParamByName('gsn_flag').Value:=gsn;
         ParamByName('hcn_flag').Value:=hcn;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

   until eof(datf);
   frmdm.TR.Commit;
end;

procedure Tfrmloadghcnd.Button3Click(Sender: TObject);
var
  wmo:integer;
   ghcn_id:string;
begin

   with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select "id", "wmo" from "station_ghcnd" ');
    SQL.Add(' where "wmo"<>-9 ');
   Open;
   Last;
   First;
  end;

   showmessage(inttostr(frmdm.q1.RecordCount));

  frmdm.q1.First;
  while not frmdm.q1.eof do begin
    ghcn_id:=frmdm.q1.FieldByName('id').Value;
    wmo:=frmdm.q1.FieldByName('wmo').Value;

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Select "id" from "station" ');
       SQL.Add(' where "ghcnd_id" is null and "wmocode"='+inttostr(wmo));
      Open;
    end;

     if not frmdm.q2.IsEmpty  then begin
      with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set "ghcnd_id"='+QuotedStr(ghcn_id));
       SQL.Add(' where "wmocode"='+inttostr(wmo));
      ExecSQL;
      end;
       mLog.Lines.Add(inttostr(wmo)+'   '+ghcn_id);
     end;

    frmdm.q1.Next;
  end;
  frmdm.TR.CommitRetaining;
end;

procedure Tfrmloadghcnd.Button4Click(Sender: TObject);
var
  wmo, absnum, country_id:integer;
   ghcn_id, wmo_st:string;
begin
  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select * from "station_ghcnd" ');
    SQL.Add(' where "wmo"<>-9 ');
   Open;
  end;

        frmdm.q2.Close;
      frmdm.q2.SQL.Text:='Select max("id") from "station"';
      frmdm.q2.Open;
       absnum:=frmdm.q2.Fields[0].AsInteger;
      frmdm.q2.Close;


  frmdm.q1.First;
  while not frmdm.q1.eof do begin
    ghcn_id:=frmdm.q1.FieldByName('id').Value;
    wmo:=frmdm.q1.FieldByName('wmo').Value;

    wmo_st:=inttostr(wmo);

   // showmessage(copy(ghcn_id, length(ghcn_id)-length(wmo_st), length(wmo_st)));

    if (copy(ghcn_id, length(ghcn_id)-length(wmo_st)+1, length(wmo_st)))=wmo_st then begin
     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Select "id" from "station" ');
       SQL.Add(' where "wmocode"='+inttostr(wmo));
      Open;
    end;

    if frmdm.q2.IsEmpty  then begin

    inc(absnum);

      country_id:=0;
      with frmdm.q2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select "id" from "country" ');
        SQL.Add(' where "ghcn"='+quotedstr(copy(ghcn_id, 1, 2)));
       Open;
         country_id:=frmdm.q2.Fields[0].AsInteger;
       Close;
     end;

    with frmdm.q2 do begin
     Close;
      SQL.Clear;
      SQL.Add(' insert into "station"  ');
      SQL.Add(' ("id", "wmocode", "latitude", "longitude", "elevation", "name", "country_id", "ghcnd_id") ');
      SQL.Add(' values ');
      SQL.Add(' (:absnum, :WMONum, :StLat, :StLon, :Elevation, :StName, :country_id, :ghcnd_id)');
      ParamByName('absnum').AsInteger:=absnum;
      ParamByName('WMONum').AsInteger:=frmdm.q1.FieldByName('wmo').Value;
      ParamByName('StLat').AsFloat:=frmdm.q1.FieldByName('latitude').Value;
      ParamByName('StLon').AsFloat:=frmdm.q1.FieldByName('longitude').Value;
      ParamByName('Elevation').AsFloat:=frmdm.q1.FieldByName('elevation').Value;
      ParamByName('StName').AsString:=frmdm.q1.FieldByName('name').Value;
      ParamByName('country_id').AsInteger:=country_id;
      ParamByName('ghcnd_id').AsString:=ghcn_id;
     ExecSQL;
   end;
     mLog.Lines.Add(inttostr(wmo)+'   '+ghcn_id);
   frmdm.TR.CommitRetaining;
 end; //writing;



    end;

    frmdm.q1.Next;
  end;
  frmdm.TR.CommitRetaining;


end;

procedure Tfrmloadghcnd.Button5Click(Sender: TObject);
var
vn:string;
 cnt:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select distinct("ghcnd_id"), count("ghcnd_id") ');
    SQL.Add(' from "station" group by "ghcnd_id"');
   Open;
  end;

   while not frmdm.q1.eof  do begin
      VN :=frmdm.q1.Fields[0].AsString;
      Cnt:=frmdm.q1.Fields[1].AsInteger;
       if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
     frmdm.q1.next;
   end;
end;

procedure Tfrmloadghcnd.Button6Click(Sender: TObject);
Var
   ghcn_id, cc: string;
   country_id, country_db: integer;
begin
 with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' Select "ghcnd_id", "country_id" from "station" ');
     SQL.Add(' where "ghcnd_id" is not null ');
   Open;
   Last;
   First;
 end;

 showmessage(inttostr(frmdm.q1.RecordCount));

 while not frmdm.q1.eof do begin
  ghcn_id:=frmdm.q1.FieldByName('ghcnd_id').Value;
  country_db:=frmdm.q1.FieldByName('country_id').Value;

  cc:=copy(ghcn_id, 1, 2);
 // showmessage(cc);

  country_id:=0;
         with frmdm.q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Select "id" from "country" ');
           SQL.Add(' where "ghcn"='+quotedstr(cc));
          Open;
            country_id:=frmdm.q2.Fields[0].AsInteger;
          Close;
        end;


         if (country_id>0) and (country_id<>country_db) then begin
         with frmdm.q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Update "station" set "country_id"='+inttostr(country_id));
           SQL.Add(' where "ghcnd_id"='+quotedstr(ghcn_id));
          ExecSQL;
        end;
         mLog.Lines.add(ghcn_id+'   '+inttostr(country_db)+'->'+inttostr(country_id));;
    end;


   frmdm.q1.Next;
 end;
end;

procedure Tfrmloadghcnd.Button7Click(Sender: TObject);
var
 absnum, id_ds570, country_id, id: integer;
 dat: text;
 st, id_ghcn, id_ds570_st, id_ghcn_st, stname, stname_ghcn, id_prcp:string;
 fl:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select "ghcn_v4_id" from "station" ');
    SQL.Add(' where "ghcn_v4_id" is not null and ');
    SQL.Add(' "ghcnd_id" is null');
   Open;
  end;

  while not frmdm.q1.eof do begin
   id_prcp:=frmdm.q1.FieldByName('ghcn_v4_id').Value;

   assignfile(dat, 'Z:\MeteoShell\data\ghcnd\ghcnd-stations.txt');
   reset(dat);

 //  showmessage(id_ds570_st);

   fl:=0;
   repeat
    readln(dat, st);
    id_ghcn_st:=copy(st, 1, 11);

    if id_prcp=id_ghcn_st then fl:=1;

   until (fl=1) or (eof(dat));

   if fl=1 then begin
     mLog.Lines.add(id_prcp+'   '+id_ghcn_st);

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set ');
       SQL.Add(' "ghcnd_id"='+Quotedstr(id_prcp));
       SQL.Add(' where "ghcn_v4_id"='+Quotedstr(id_prcp));
      ExecSQL;
     end;

    frmdm.TR.CommitRetaining;
   end;


   closefile(dat);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
  frmdm.TR.Commit;

end;


procedure Tfrmloadghcnd.GetTableName(par:string; var tbl:string);
begin
tbl:='';
  if par='TAVG' then tbl:='p_tavg_ghcnd';
  if par='TMIN' then tbl:='p_tmin_ghcnd';
  if par='TMAX' then tbl:='p_tmax_ghcnd';
  if par='PRCP' then tbl:='p_precipitation_ghcnd';
  if par='SNOW' then tbl:='p_snowfall_ghcnd';
  if par='SNWD' then tbl:='p_snowdepth_ghcnd';
  if par='AWDR' then tbl:='p_wind_direction_ghcnd';
  if par='AWND' then tbl:='p_wind_speed_ghcnd';
end;

end.

