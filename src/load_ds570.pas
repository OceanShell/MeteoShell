unit load_ds570;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, LCLTranslator,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Spin, ComCtrls, BufDataset, DateUtils,
  DB;

type

  { Tfrmload_ds570 }

  Tfrmload_ds570 = class(TForm)
    btnLoadData: TButton;
    Button1: TButton;
    Button2: TButton;
    chkWrite: TCheckBox;
    chkShowLog: TCheckBox;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    mLog: TMemo;
    mError: TMemo;
    mInserted: TMemo;
    mUpdated: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    seSkip: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure btnLoadDataClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

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

uses main, dm, procedures;

{$R *.lfm}


procedure Tfrmload_ds570.btnLoadDataClick(Sender: TObject);
var
ds570_id, id, yy, mn, k, md, old_id, tbl_ind, cnt, row_cnt: integer;
slp, stnp, t, prec, sun,par:real;
FileForRead, st0, st1, date1, buf_str, tbl_name:string;
DateCurr: TDate;
DBVal:Variant;
begin
  frmmain.OD.InitialDir:=GlobalPath+'data\';
 // frmmain.OD.Filter:='difference.csv|difference.csv';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  cnt:=0;
  repeat
   readln(fi_dat);
    inc(cnt);
  until eof(fi_dat);
  CloseFile(fi_dat);

 // showmessage(inttostr(cnt));

  btnLoadData.Enabled:=false;
  //btnLoadMetadata.Enabled:=false;
  Application.ProcessMessages;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);

  //skipping the first rows, if needed
  k:=0;
  if seSkip.Value>0 then
    for k:=1 to seSkip.Value-1 do
     readln(fi_dat, st1);

  row_cnt:=k;
  repeat
   readln(fi_dat, st1);
   inc(row_cnt);

 //  if copy(st1, 1, 2)<>'48' then continue;
  if copy(st1, 1, 1)='S' then continue;

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
         DateCurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));
       //  mLog.Lines.Add(inttostr(ds570_id)+'   '+datetostr(DateCurr));
     end;
     if md=3 then if TryStrToFloat(trim(buf_str), slp)  then slp   :=StrToFloat(trim(buf_str)) else slp  :=-9999;
     if md=4 then if TryStrToFloat(trim(buf_str), stnp) then stnp  :=StrToFloat(trim(buf_str)) else stnp :=-9999;
     if md=5 then if TryStrToFloat(trim(buf_str), t)    then t     :=StrToFloat(trim(buf_str)) else t    :=-9999;
     if md=6 then if TryStrToFloat(trim(buf_str), prec) then prec  :=StrToFloat(trim(buf_str)) else prec :=-9999;
     if md=7 then if trim(buf_str)<>''                  then sun   :=StrToFloat(trim(buf_str)) else sun  :=-9999;
   end;


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


   (* Station found *)
   if id>0 then begin

     for k:=1 to 5 do begin
       case k of
         1: begin par:=slp;  tbl_name:='p_sea_level_pressure_ds570'  end;
         2: begin par:=stnp; tbl_name:='p_station_level_pressure_ds570' end;
         3: begin par:=t;    tbl_name:='p_surface_air_temperature_ds570' end;
         4: begin par:=prec; tbl_name:='p_precipitation_ds570' end;
         5: begin par:=sun;  tbl_name:='p_sunshine_ds570' end;
       end;

       if par<>-9999 then begin
        with frmdm.q1 do begin
         Close;
          SQL.Clear;
          SQL.Add(' select "value" from "'+tbl_name+'" ');
          SQL.Add(' where "station_id"=:absnum and "date"=:date_');
          ParamByName('absnum').Value:=id;
          ParamByName('date_').AsDate:=DateCurr;
         Open;
          DbVal:=frmdm.q1.Fields[0].Value;
         Close;
        end;


       try
         // inserting a new value
         if VarIsNull(DBVal)=true then begin
             with frmdm.q2 do begin
              Close;
               SQL.Clear;
               SQL.Add(' insert into "'+tbl_name+'" ');
               SQL.Add(' ("station_id", "date", "value", "flag") ');
               SQL.Add(' values ');
               SQL.Add(' (:absnum, :date_, :value_, :flag_)');
               ParamByName('absnum').Value:=id;
               ParamByName('date_').AsDate:=DateCurr;
               ParamByName('value_').Value:=par;
               ParamByName('flag_').Value:=0;
              ExecSQL;
            end;
            if chkShowLog.Checked then
             mInserted.lines.add(inttostr(ds570_id)+'   '+
                             datetostr(DateCurr)+'   '+
                             floattostr(par));
       end;

       // updating existing
       if VarIsNull(DBVal)=false then begin
         if DBVal<>Par then begin
            with frmdm.q2 do begin
              Close;
                SQL.Clear;
                SQL.Add(' update "'+tbl_name+'" ');
                SQL.Add(' set "value"=:value_ ');
                SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
                ParamByName('absnum').Value:=ID;
                ParamByName('date_').AsDate:=DateCurr;
                ParamByName('value_').Value:=par;
              ExecSQL;
            end;
            if chkShowLog.Checked then
             mUpdated.lines.add(inttostr(ds570_id)+'   '+
                             datetostr(DateCurr)+'   '+
                             floattostr(par));
         end;
        end;

       frmdm.TR.CommitRetaining;
     except
       frmdm.TR.RollbackRetaining;
         mError.lines.add(inttostr(ds570_id)+'   '+
                          datetostr(DateCurr)+'   '+
                          floattostr(par));
     end;
     end; //par<>-9999
    end; //k=1:5
   end; //id>0;

   Caption:=inttostr(row_cnt);

   ProgressTaskbar(row_cnt, cnt);
   Application.ProcessMessages;

   until eof(fi_dat);
   CloseFile(fi_dat);
   frmdm.TR.Commit;

   btnLoadData.Enabled:=true;
  // btnLoadMetadata.Enabled:=true;

   if MessageDlg('Upload successfully completed. Please, update metadata'+#13+
                 '(Menu->Services->DB Administration->Update STATION_INFO)',
                  mtConfirmation, [mbOk], 0)=mrOk then exit;
end;


(* ONLY WMO STATIONS WITH TIMESERIES LONGER THAN 30 YEARS *)
procedure Tfrmload_ds570.Button1Click(Sender: TObject);
var
   k, md, wmo_id,cnt, old_id:integer;
   StLat, StLon, Elev, StLat_old, StLon_old, Elev_old: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1:integer;
   st,stName, stname_old, date1, date2:string;
   isempty:boolean;
   stdate1, stdate2, date_min, date_max:TDateTime;
begin
  mLog.clear;
  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='ds570.0_stnlibrary.csv|ds570.0_stnlibrary.csv';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  readln(fi_dat, st);
  cnt:=0;
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

    if cnt=0 then begin
      old_id:=WMO_id;
      date_min:=stdate1;
      date_max:=stdate2;
      stname_old:=stname;
      StLat_old:=StLat;
      StLon_old:=StLon;
      Elev_old:=Elev;
    end;

    if WMO_ID=old_id then begin
      if stdate1<date_min then date_min:=stdate1;
      if stdate2>date_max then date_max:=stdate2;
    end;

    if (WMO_ID<>old_id) or (eof(fi_dat)) then begin
      if (old_id<>-9) and (trim(stname_old)<>'') and
         (yearsbetween(date_max, date_min)>=20) and  //more than 30 years
         (yearsbetween(now, date_max)<=10) then begin  //active less than 10 years ago

        frmdm.q1.Close;
        frmdm.q1.SQL.Text:='Select "id" from "station" where "ds570_id"='+inttostr(old_ID)+'0';
      //  showmessage(frmdm.q1.SQL.Text);
        frmdm.q1.Open;
        if frmdm.q1.IsEmpty=true then begin

        mlog.lines.add(inttostr(old_id)+'   '+stname_old+'   '+datetostr(date_min)+'   '+datetostr(date_max));

        if chkWrite.Checked=true then begin
         frmdm.q2.Close;
         frmdm.q2.SQL.Text:='Select max("id") from "station"';
         frmdm.q2.Open;
          absnum:=frmdm.q2.Fields[0].AsInteger+1;
         frmdm.q2.Close;

      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station"  ');
         SQL.Add(' ("id", "wmocode", "latitude", "longitude", "elevation", "name", "country_id", "ds570_id") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :WMONum, :StLat, :StLon, :Elevation, :StName, :country_id, :DS570_ID)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('WMONum').AsInteger:=old_ID;
         ParamByName('StLat').AsFloat:=StLat_old;
         ParamByName('StLon').AsFloat:=StLon_old;
         ParamByName('Elevation').AsFloat:=Elev_old;
         ParamByName('StName').AsString:=stName_old;
         ParamByName('country_id').AsInteger:=0;
         ParamByName('DS570_ID').AsInteger:=strtoint(inttostr(old_ID)+'0');
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;
        end;
        end; //writing;


      end;
      old_id:=WMO_id;
      stname_old:=stname;
      date_min:=stdate1;
      date_max:=stdate2;
      StLat_old:=StLat;
      StLon_old:=StLon;
      Elev_old:=Elev;
    end;

    inc(cnt);
  until eof(fi_dat);
  CloseFile(fi_dat);
  frmdm.TR.Commit;
  showmessage('done');
end;



procedure Tfrmload_ds570.Button2Click(Sender: TObject);
var
   k, md, wmo_id, cnt:integer;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1:integer;
   st,stName, date1, date2:string;
   isempty:boolean;
   stdate1, stdate2, date_min, date_max:TDateTime;
begin
  mLog.clear;
  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='ds570.0_stnlibrary.csv|ds570.0_stnlibrary.csv';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ds570" ');
   ExecSQL;
  end;
  frmdm.TR.Commit;


  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  readln(fi_dat, st);
  cnt:=0;
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

    stdate1:=encodedate(strtoint(copy(date1,1,4)), strtoint(copy(date1, 6, 2)), 1);
    stdate2:=encodedate(strtoint(copy(date2,1,4)), strtoint(copy(date2, 6, 2)), 1);

      with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ds570"  ');
         SQL.Add(' ("id", "latitude", "longitude", "elevation", "name", "start_date", "end_date") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :StLat, :StLon, :Elevation, :StName, :Date1, :Date2)');
         ParamByName('absnum').AsInteger:=strtoint(ID);
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         ParamByName('Date1').AsDateTime:=stDate1;
         ParamByName('Date2').AsDateTime:=stDate2;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

    inc(cnt);
  until eof(fi_dat);
  CloseFile(fi_dat);
  frmdm.TR.Commit;
  showmessage('done');

end;


end.
