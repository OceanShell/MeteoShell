unit load_ds570;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, LCLTranslator,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls, BufDataset, DateUtils,
  DB, Math, SQLDB;

type
  { Tfrmload_ds570_upd }

  Tfrmload_ds570_upd = class(TForm)
    btnLoadData: TButton;
    Button1: TButton;
    btnUpdateStationDS570: TButton;
    Button3: TButton;
    btnDuplicates: TButton;
    chkWriteLog: TCheckBox;
    chkShowLog: TCheckBox;
    chkWrite: TCheckBox;
    mLog: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure btnDuplicatesClick(Sender: TObject);
    procedure btnLoadDataClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnUpdateStationDS570Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
    procedure getvalues(st1:string; Var ds570_f: integer; Var DateCurr:TDateTime;
        Var slp, stnp, t, prec, sun:real);
  public
    { Public declarations }
  end;

const
  max_arr_length = 5000000;

var
  frmload_ds570_upd: Tfrmload_ds570_upd;
  fi_dat:text;
  old_id:string;

implementation

uses main, dm, procedures;

{$R *.lfm}

procedure Tfrmload_ds570_upd.getvalues(st1:string; Var ds570_f: integer;
    Var DateCurr:TDateTime; Var slp, stnp, t, prec, sun:real);
Var
  k, md: integer;
  buf_str, date1: string;
  yy, mn: word;
begin
k:=0; slp:=-9999; stnp:=-9999; t:=-9999; prec:=-9999; sun:=-9999;
     for md:=1 to 7 do begin
      buf_str:='';
      repeat
       inc(k);
       if (st1[k]<>',') and (k<=length(st1)) then buf_str:=buf_str+st1[k];
      until (st1[k]=',') or (k=length(st1));
       if md=1 then ds570_f:=StrToInt(trim(buf_str));
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
end;



procedure Tfrmload_ds570_upd.btnLoadDataClick(Sender: TObject);
type
   DataSample=record
     id:integer;
     dcur:TDateTime;
     slp:real;
     stnp:real;
     t:real;
     prec:real;
     sun:real;
end;
var
DS: array of DataSample;
DS_cnt, DS_cnt_max, DB_cnt, upd_cnt, DB_ID, pp:integer;
ds570_id, ID: array of integer;

ds570_f, yy, mn, k, md, old_id, tbl_ind, stn_cnt, row_cnt: integer;
slp, stnp, t, prec, sun, par, val_f:real;
val_db:Variant;
FileForRead, st0, st1, date1, buf_str, tbl_name:string;
DateCurr, old_date: TDate;
DBVal:Variant;
dat, dat_i, dat_u, dat_d:text;
TRt1, TRt2:TSQLTransaction;
db1q1, db2q1, db2q2:TSQLQuery;
begin

  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='*.csv|*.csv';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

// selecting exisiting IDs from MDB_METADATA
try
  TRt1:=TSQLTransaction.Create(nil);
  TRt1.DataBase:=frmdm.TR.DataBase;
  db1q1:=TSQLQuery.Create(nil);
  db1q1.Database:=frmdm.TR.DataBase;
  db1q1.Transaction:=TRt1;

  with db1q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id", "ds570_id" from "station" where ');
     SQL.Add(' "ds570_id" is not null ');
     SQL.Add(' order by "ds570_id" ');
    Open;
    Last;
    First;
  end;

  SetLength(id, db1q1.RecordCount);
  SetLength(ds570_id, db1q1.RecordCount);

  DB_cnt:=-1;
  while not db1q1.EOF do begin
   inc(DB_cnt);
    id[DB_cnt] := db1q1.FieldByName('id').AsInteger;
    ds570_id[DB_cnt] := db1q1.FieldByName('ds570_id').AsInteger;
   db1q1.Next;
  end;
finally
  db1q1.Close;
  db1q1.Free;
  Trt1.Commit;
  Trt1.Free;
end;


(* temporary transaction and query for data database *)
TRt2:=TSQLTransaction.Create(nil);
TRt2.DataBase:=frmdm.TR2.DataBase;
db2q1:=TSQLQuery.Create(nil);
db2q1.Database:=frmdm.TR2.DataBase;
db2q1.Transaction:=TRt2;
db2q2:=TSQLQuery.Create(nil);
db2q2.Database:=frmdm.TR2.DataBase;
db2q2.Transaction:=TRt2;

  if chkWriteLog.Checked then begin
   AssignFile(dat_i, GlobalUnloadPath+'ds570_ins.txt'); rewrite(dat_i);
   AssignFile(dat_u, GlobalUnloadPath+'ds570_upd.txt'); rewrite(dat_u);
   AssignFile(dat_d, GlobalUnloadPath+'ds570_del.txt'); rewrite(dat_d);
  end;

   AssignFile(fi_dat,FileForRead); reset(fi_dat);
   readln(fi_dat, st1);
   stn_cnt:=0;
   upd_cnt:=0;
   row_cnt:=0;
   DS_cnt:=-1;
   DS_cnt_max:=0;

   SetLength(DS, 0);
   SetLength(DS, max_arr_length);
    repeat
     inc(row_cnt);
      readln(fi_dat, st1);
      getvalues(st1, ds570_f, DateCurr, slp, stnp, t, prec, sun);

      if row_cnt=1 then begin
        old_id:=ds570_f;
        old_date:=DateCurr;
      end;

      if (old_id=ds570_f) and (DateCurr>old_date) then begin
        inc(DS_cnt);
         DS[DS_cnt].id:=old_id;
         DS[DS_cnt].dcur:=DateCurr;
         DS[DS_cnt].slp :=slp;
         DS[DS_cnt].stnp:=stnp;
         DS[DS_cnt].t:=t;
         DS[DS_cnt].prec:=prec;
         DS[DS_cnt].sun:=sun;
        old_date:=datecurr;
      end;

      if (old_id<>ds570_f) then begin
        inc(stn_cnt);

        //looking for DB ID
        for k:=0 to DB_cnt do begin
         DB_ID:=-9;
         if DS[0].id=ds570_id[k] then begin
           DB_ID:=ID[k];
           break;
         end;
        end;

        if DB_ID<>-9 then begin
          //showmessage(inttostr(DB_ID)+'   '+inttostr(ds570_id[k]));

         { for k:=0 to DS_cnt do
          mLog.lines.add(inttostr(DS[k].id)+'   '+
          datetimetostr(DS[k].dcur)+'   '+
          floattostr(DS[k].t));  }

          for pp:=1 to 5 do begin
           case pp of
             1: tbl_name:='p_sea_level_pressure_ds570';
             2: tbl_name:='p_station_level_pressure_ds570';
             3: tbl_name:='p_surface_air_temp_ds570';
             4: tbl_name:='p_precipitation_ds570';
             5: tbl_name:='p_sunshine_ds570';
           end;

          with db2q1 do begin
            Close;
             SQL.Clear;
             SQL.Add(' select "date" as date1, "value" as val1 ');
             SQL.Add(' from "'+tbl_name+'" ');
             SQL.Add(' where "station_id"=:absnum order by "date"');
             ParambyName('absnum').Value:=DB_ID;
            Open;
            Last;
            First;
          end;

          for k:=0 to DS_cnt-1 do begin

            case pp of
             1: val_f:=DS[k].slp;
             2: val_f:=DS[k].stnp;
             3: val_f:=DS[k].t;
             4: val_f:=DS[k].prec;
             5: val_f:=DS[k].sun;
            end;

          val_db:= db2q1.Lookup('date1', DS[k].dcur, 'val1');

         { if val_db<>val_f then
          showmessage(floattostr(val_db)+'   '+floattostr(val_f));  }

          //Inserted
           if varisnull(val_db) and (val_f<>-9999) then begin
             if chkWriteLog.Checked then begin
              writeln(dat_i, inttostr(DS[k].id), #9,
                             datetostr(DS[k].dcur)+#9,
                             floattostr(val_f), #9,
                             tbl_name);
              flush(dat_i);
              end;

              if chkShowLog.Checked then
                mLog.Lines.Add(
                             inttostr(DS[k].id)+'   '+
                             datetostr(DS[k].dcur)+'   '+
                             floattostr(val_f)+'   '+
                             tbl_name);
              if chkWrite.Checked then
                try
                 with db2q2 do begin
                   Close;
                    SQL.Clear;
                    SQL.Add(' insert into "'+tbl_name+'" ');
                    SQL.Add(' ("station_id", "date", "value", "pqf2") ');
                    SQL.Add(' values ');
                    SQL.Add(' (:absnum, :date_, :value_, :pqf2)');
                    ParamByName('absnum').Value:=DB_ID;
                    ParamByName('date_').AsDate:=DS[k].dcur;
                    ParamByName('value_').Value:=val_f;
                    ParamByName('pqf2').Value:=0;
                   ExecSQL;
                 end;
                TRt2.CommitRetaining;
                except
                  on e: Exception do begin
                     TRt2.RollbackRetaining;
                     if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then close;
                  end;
                end;
             end; //inserted

           // Updated
          if not varisnull(val_db) and (val_f<>-9999) and (val_db<>val_f) then begin
           if chkWriteLog.Checked then begin
            writeln(dat_u, inttostr(DS[k].id), #9,
                           datetostr(DS[k].dcur), #9,
                           floattostr(val_f), #9,
                           floattostr(val_db), #9,
                           tbl_name);
            flush(dat_u);
            end;

            if chkShowLog.Checked then
               mLog.Lines.Add(
                          inttostr(DS[k].id)+'   '+
                          datetostr(DS[k].dcur)+'  '+
                          floattostr(val_f)+'   '+
                          floattostr(val_db)+'   '+
                          tbl_name);

            if chkWrite.Checked then
            try
              with db2q2 do begin
              Close;
                SQL.Clear;
                SQL.Add(' update "'+tbl_name+'" ');
                SQL.Add(' set "value"=:value_, "pqf2"=0 ');
                SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
                ParamByName('absnum').Value:=DB_ID;
                ParamByName('date_').AsDate:=DS[k].dcur;
                ParamByName('value_').Value:=val_f;
              ExecSQL;
            end;
            TRt2.CommitRetaining;
            except
             on e: Exception do begin
              TRt2.RollbackRetaining;
              if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then close;
             end;
            end;
          end; //updated

          //Deleted
          if not varisnull(val_db) and (val_f=-9999) then begin
           if chkWriteLog.Checked then begin
            writeln(dat_d, inttostr(DS[k].id), #9,
                           datetostr(DS[k].dcur), #9,
                           floattostr(val_db), #9,
                           tbl_name);
            flush(dat_d);
            end;

            if chkShowLog.Checked then
               mLog.Lines.Add(
                          inttostr(DS[k].id)+'   '+
                          datetostr(DS[k].dcur)+'  '+
                          floattostr(val_db)+'   '+
                          tbl_name);

            if chkWrite.Checked then
            try
             with db2q2 do begin
              Close;
                SQL.Clear;
                SQL.Add(' delete from "'+tbl_name+'" ');
                SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
                ParamByName('absnum').Value:=DB_ID;
                ParamByName('date_').AsDate:=DS[k].dcur;
              ExecSQL;
            end;
              TRt2.CommitRetaining;
                except
                  on e: Exception do begin
                     TRt2.RollbackRetaining;
                     if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then close;
                  end;
                end;
          end; //deleted

        end;
        end; //loop for 5 parameters

        end; //ID exists


        DS_cnt_max:=Max(DS_cnt, DS_cnt_max);
        Caption:=inttostr(DS_cnt_max)+'   '+inttostr(row_cnt);
        Application.ProcessMessages;

        SetLength(DS, 0);
        SetLength(DS, max_arr_length);

        old_id:=ds570_f;
        old_date:=DateCurr;
       // showmessage(inttostr(old_id)+'   '+datetimetostr(old_date));

        DS_cnt:=0;
        DS[DS_cnt].id:=old_id;
        DS[DS_cnt].dcur:=DateCurr;
        DS[DS_cnt].slp :=slp;
        DS[DS_cnt].stnp:=stnp;
        DS[DS_cnt].t:=t;
        DS[DS_cnt].prec:=prec;
        DS[DS_cnt].sun:=sun;
      end;

    until eof(fi_dat);
    Closefile(fi_dat);

   if chkWriteLog.Checked then begin
    Closefile(dat_i);
    Closefile(dat_u);
    Closefile(dat_d);
   end;

  //  showmessage('here');

    db2q1.Close;
    db2q1.Free;
    db2q2.Close;
    db2q2.Free;
    Trt2.Commit;
    Trt2.Free;

    SetLength(DS, 0);


   if MessageDlg('Upload successfully completed. Please, update metadata'+#13+
                 '(Menu->Services->DB Administration->Update STATION_INFO)',
                  mtConfirmation, [mbOk], 0)=mrOk then begin
     ProgressTaskbar(0, 0);
     exit;
   end;
end;


(* ONLY WMO STATIONS WITH TIMESERIES LONGER THAN 30 YEARS *)
procedure Tfrmload_ds570_upd.Button1Click(Sender: TObject);
var
   ds_id:integer;
   date_min, date_max:TDateTime;
   yy0, mn0, dd0, yy1, mn1, dd1, yy3, mn3, dd3: word;
begin

  with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add('select distinct("id"), min("start_date"), max("end_date") ');
     SQL.Add('from "station_ds570" group by "id"');
    Open;
  end;

  while not frmdm.q1.EOF do begin
    ds_id:=frmdm.q1.Fields[0].AsInteger;
    date_min:=frmdm.q1.Fields[1].AsDateTime;
    date_max:=frmdm.q1.Fields[2].AsDateTime;

    decodedate(date_min, yy0, mn0, dd0);
    decodedate(date_max, yy1, mn1, dd1);
    decodedate(now, yy3, mn3, dd3);

    if (yy1-yy0>=30) and (yy3-yy1<=5) then begin
      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add('select "id" from "station" where ');
         SQL.Add('"ds570_id"=:ds_id');
         Parambyname('ds_id').AsInteger:=ds_id;
        Open;
      end;

      if frmdm.q2.IsEmpty then begin
        mLog.Lines.Add(inttostr(ds_id)+'   '+inttostr(yy0)+'   '+inttostr(yy1));
      end;

    end;
    frmdm.q1.Next;
  end;
  frmdm.q1.Close;
  showmessage('done');
end;



procedure Tfrmload_ds570_upd.btnUpdateStationDS570Click(Sender: TObject);
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

procedure Tfrmload_ds570_upd.Button3Click(Sender: TObject);
var
   k, md, wmo_id, cnt, ds570_wmo:integer;
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

    ds570_wmo:=StrToInt(copy(id, 1, 5));
    if copy(id, 6, 1)<>'0' then ds570_wmo:=-9;

    frmdm.q1.Close;
    frmdm.q1.SQL.Text:='Select "ds570_id" from "station" '+
    'where "wmocode"='+inttostr(ds570_wmo)+' and "ds570_id" is null';
    frmdm.q1.Open;

    if not frmdm.q1.IsEmpty then begin
     mLog.Lines.Add(inttostr(ds570_wmo));
      with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set "ds570_id"='+id);
       SQL.Add(' where "wmocode"='+inttostr(ds570_wmo));
      ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

    end;

    inc(cnt);
  until eof(fi_dat);
  CloseFile(fi_dat);
  frmdm.TR.Commit;
  showmessage('done');
end;


procedure Tfrmload_ds570_upd.btnDuplicatesClick(Sender: TObject);
type
   DataSample=record
     id:integer;
     dcur:TDateTime;
    // st1:string;
end;
var
DS: array of DataSample;
fi_dat:text;
Fileforread: string;
st1: string;
ds_cnt, cnt_dup, k, c: integer;
ds570_f: integer;
DateCurr:TDateTime;
slp, stnp, t, prec, sun: real;
begin
  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='*.csv|*.csv';

   if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;


    AssignFile(fi_dat,FileForRead); reset(fi_dat);
    readln(fi_dat, st1);

    DS_cnt:=-1;

    SetLength(DS, max_arr_length);
     repeat
       readln(fi_dat, st1);
       getvalues(st1, ds570_f, DateCurr, slp, stnp, t, prec, sun);

         inc(DS_cnt);
         DS[DS_cnt].id:=ds570_f;
         DS[DS_cnt].dcur:=DateCurr;
        // DS[DS_cnt].st1:=St1;
     until eof(fi_dat);
     CloseFile(fi_dat);


     for k:=0 to DS_cnt do begin
     // st1:=DS[k].st1;
      ds570_f:=DS[k].id;
      DateCurr:=DS[k].dcur;

      cnt_dup:=0;
      for c:=k+1 to k+500 do
         if (DS[c].id=ds570_f) and (DS[c].dcur=DateCurr) then begin
           //  mLog.Lines.Add(st1);
             mLog.Lines.Add(inttostr(DS[c].id)+' '+datetostr(DS[c].dcur));
         end;

     end;


end;



end.
