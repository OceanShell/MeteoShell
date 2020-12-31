unit load_ds570;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, LCLTranslator,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Spin, BufDataset, DateUtils, DB;

type

  { Tfrmload_ds570 }

  Tfrmload_ds570 = class(TForm)
    btnLoadData: TButton;
    btnLoadMetadata: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    seSkip: TSpinEdit;

    procedure btnLoadMetadataClick(Sender: TObject);
    procedure btnLoadDataClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmload_ds570: Tfrmload_ds570;
  fi_dat:text;
  old_id:string;

implementation

uses main, dm;

{$R *.lfm}

(* ONLY WMO STATIONS WITH TIMESERIES LONGER THAN 30 YEARS *)
procedure Tfrmload_ds570.btnLoadMetadataClick(Sender: TObject);
var
  k, md, wmo_id:integer;
  StLat, StLon, Elev: real;
  buf_str, ID, ds570, FileForRead :string;
  absnum, absnum1:integer;
  st,stName, date1, date2:string;
  isempty:boolean;
   stdate1, stdate2:TDateTime;
begin
 frmmain.OD.InitialDir:=GlobalPath+'data\';
 frmmain.OD.Filter:='csv|*.csv';

 if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

 label1.Visible:=true;

 AssignFile(fi_dat,FileForRead); reset(fi_dat);
 readln(fi_dat, st);
 repeat
  readln(fi_dat, st);
   k:=0;
   for md:=1 to 7 do begin
    buf_str:='';
    repeat
     inc(k);
     if st[k]<>',' then buf_str:=buf_str+st[k];
    until (st[k]=',') or (k=length(st));
     if md=1 then ID    :=trim(buf_str);
     if md=2 then stname:=trim(buf_str);
     if md=3 then stLat :=StrToFloat(trim(buf_str));
     if md=4 then StLon :=StrToFloat(trim(buf_str));
     if md=5 then Elev  :=StrToFloat(trim(buf_str));
     if md=6 then date1 :=trim(buf_str);
     if md=7 then date2 :=trim(buf_str);
   end;

   if copy(ID, 6, 1)='0' then WMO_id:=StrToInt(copy(ID, 1, 5)) else WMO_id:=-9;

   stdate1:=encodedate(strtoint(copy(date1,1,4)), strtoint(copy(date1, 6, 2)), 1);
   stdate2:=encodedate(strtoint(copy(date2,1,4)), strtoint(copy(date2, 6, 2)), 1);

   if (stlat>=-90) and (stlon>=-180) and (stName<>'') and (copy(stname, 1, 1)<>':') then begin
     frmdm.q1.Close;
     frmdm.q1.SQL.Text:='Select id from station where ds570_id='+ID;
     frmdm.q1.Open;
      isempty:=frmdm.q1.IsEmpty;
     frmdm.q1.Close;

     label1.Caption:=id;
     Application.ProcessMessages;

     if (isempty=true) and (YearsBetween(stdate1, stdate2)>=30) and (WMO_ID<>-9) then begin
        with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' select id from STATION where ');
         SQL.Add(' latitude=:stlat and longitude=:stlon and elevation=:Elev ');
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elev').AsFloat:=Elev;
        Open;
      end;

      {if frmdm.q1.IsEmpty=false then begin
         absnum1:=frmdm.q1.FieldByName('id').AsInteger;

         if frmdm.q1.FieldByName('DS570_ID').AsString='-9' then begin
          with frmdm.q2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' update station set ds570_id=:ds_ID ');
            SQL.Add(' where id=:WMO ');
            ParamByName('WMO').AsInteger:=absnum1;
            ParamByName('ds_ID').AsInteger:=StrToInt(id);
           ExecSQL;
          end;
          dm.TR.CommitRetaining;
         end;
       end;  }

       if frmdm.q1.IsEmpty=true then begin
         frmdm.q2.Close;
         frmdm.q2.SQL.Text:='Select max(id) from station';
         frmdm.q2.Open;
          absnum:=frmdm.q2.Fields[0].AsInteger+1;
         frmdm.q2.Close;

      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into station  ');
         SQL.Add(' (id, WMO, latitude, longitude, elevation, name, country_id, ds570_id) ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :WMONum, :StLat, :StLon, :Elevation, :StName, :country_id, :DS570_ID)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('WMONum').AsInteger:=wmo_id;
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         ParamByName('country_id').AsInteger:=257;
         ParamByName('DS570_ID').AsInteger:=StrToInt(ID);
        ExecSQL;
      end;

      memo1.Lines.Add(inttostr(wmo_id)+'   '+stname);
      Application.ProcessMessages;

      frmdm.TR.CommitRetaining;
     end;
   end; // is empty
  end;

 until eof(fi_dat);
 CloseFile(fi_dat);
 showmessage('done');
end;



procedure Tfrmload_ds570.btnLoadDataClick(Sender: TObject);
var
ds570_id, id, yy, mn, k, md, old_id, tbl_ind, cnt: integer;
slp, stnp, t, prec, sun,par:real;
FileForRead, st0, st1, date1, buf_str, tbl_name:string;
DateMax, DateCurr: TDate;
begin
  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='ds570.0_monthly.csv|ds570.0_monthly.csv';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  label1.Visible:=true;
  btnLoadData.Enabled:=false;
  btnLoadMetadata.Enabled:=false;
  Application.ProcessMessages;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  readln(fi_dat, st0);

  //skipping the first rows, if needed
  k:=0;
  if seSkip.Value>0 then
    for k:=1 to seSkip.Value-1 do
     readln(fi_dat, st0);

  old_id:=-9; cnt:=0;
  repeat
   readln(fi_dat, st1);

   k:=0; slp:=-9999; stnp:=-9999; t:=-9999; prec:=-9999; sun:=-9999;
   for md:=1 to 7 do begin
    buf_str:='';
    repeat
     inc(k);
     if (st1[k]<>',') and (k<=length(st1)) then buf_str:=buf_str+st1[k];
    until (st1[k]=',') or (k=length(st1));
     if md=1 then ds570_id:=StrToInt(trim(buf_str));
     if md=2 then begin
         date1 :=trim(buf_str);
         yy:=StrToInt(copy(date1, 1, 4));
         mn:=StrToInt(copy(date1, 6, 2));
         Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));
       //  memo1.Lines.Add(inttostr(ds570_id)+'   '+datetostr(DateCurr));
     end;
     if md=3 then if TryStrToFloat(trim(buf_str), slp)  then slp   :=StrToFloat(trim(buf_str)) else slp  :=-9999;
     if md=4 then if TryStrToFloat(trim(buf_str), stnp) then stnp  :=StrToFloat(trim(buf_str)) else stnp :=-9999;
     if md=5 then if TryStrToFloat(trim(buf_str), t)    then t     :=StrToFloat(trim(buf_str)) else t    :=-9999;
     if md=6 then if TryStrToFloat(trim(buf_str), prec) then prec  :=StrToFloat(trim(buf_str)) else prec :=-9999;
     if md=7 then if trim(buf_str)<>''                  then sun   :=StrToFloat(trim(buf_str)) else sun  :=-9999;
   end;

   if ds570_id<>old_id then begin
     inc(cnt);
      with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' select "id" from "station" where ');
         SQL.Add(' "ds570_id"=:ds570_id ');
         ParamByName('ds570_id').AsInteger:=ds570_id;
        Open;
        if frmdm.q1.IsEmpty=false then
          id:=frmdm.q1.Fields[0].AsInteger else id:=-9;
        Close;
      end;

      if id>0 then begin
       DateMax:=0;
       with frmdm.q1 do begin
         Close;
          SQL.Clear;
          SQL.Add(' select max("date") from "p_surface_air_temperature_ds570" where ');
          SQL.Add(' "station_id"=:ID ');
          ParamByName('ID').AsInteger:=id;
         Open;
           if frmdm.q1.isempty=false then begin
             DateMax:=frmdm.q1.Fields[0].AsDateTime;
           end;
         Close;
        end;
      end;
    old_id:=ds570_id;
   end;

   if (id>0) and (datecurr>datemax) then begin

      for k:=1 to 5 do begin
       case k of
        1: begin par:=slp;  tbl_name:='p_sea_level_pressure_ds570'  end;
        2: begin par:=stnp; tbl_name:='p_station_level_pressure_ds570' end;
        3: begin par:=t;    tbl_name:='p_surface_air_temperature_ds570' end;
        4: begin par:=prec; tbl_name:='p_precipitation_ds570' end;
        5: begin par:=sun;  tbl_name:='p_sunshine_ds570' end;
       end;

      if par<>-9999 then begin
       try
         with frmdm.q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' insert into "'+tbl_name+'" ');
           SQL.Add(' ("station_id", "date", "value", "flag") ');
           SQL.Add(' values ');
           SQL.Add(' (:absnum, :date_, :value_, :flag_)');
           ParamByName('absnum').AsInteger:=ID;
           ParamByName('date_').AsDate:=DateCurr;
           ParamByName('value_').AsFloat:=par;
           ParamByName('flag_').AsInteger:=0;
          ExecSQL;
        end;
        frmdm.TR.CommitRetaining;
       except
        frmdm.TR.RollbackRetaining;
       end;
       end;
      end;
     end; //datecurr >dateamax

   label1.Caption:=inttostr(id);
   application.ProcessMessages;

   until eof(fi_dat);

   CloseFile(fi_dat);
   frmdm.TR.Commit;

   btnLoadData.Enabled:=true;
   btnLoadMetadata.Enabled:=true;

   if MessageDlg('Upload successfully completed. Please, update metadata'+#13+
                 '(Menu->Services->DB Administration->Update STATION_INFO)',
                  mtConfirmation, [mbOk], 0)=mrOk then exit;
end;


end.
