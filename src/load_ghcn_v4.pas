unit load_ghcn_v4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  DateUtils;

type

  { Tfrmload_ghcnv4 }

  Tfrmload_ghcnv4 = class(TForm)
    btnLoad: TButton;
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button2: TButton;
    Button3: TButton;
    btnDuplicates: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    chkShowLog: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mLog: TMemo;
    mError: TMemo;
    mInserted: TMemo;
    mUpdated: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure btnDuplicatesClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);

  private

  public

  end;

var
  frmload_ghcnv4: Tfrmload_ghcnv4;

implementation

{$R *.lfm}

uses main, dm, procedures;

{ Tfrmload_ghcnv4 }

procedure Tfrmload_ghcnv4.btnLoadClick(Sender: TObject);
Var
 fi_dat: text;
 st, fileforread, numsrc:string;
 k, absnum, yy, mn, cnt, row_cnt, flag:integer;
 temp:real;
 datecurr: TDateTime;
 qcf1, qcf2, qcf3: string;
begin

 mInserted.Clear;
 mError.Clear;
 btnLoad.Enabled:= false;

 try
  frmmain.OD.InitialDir:=GlobalPath+'data\';
 // frmmain.OD.Filter:='difference.qcu.dat|difference.qcu.dat';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  cnt:=0;
  repeat
   readln(fi_dat);
    inc(cnt);
  until eof(fi_dat);
  CloseFile(fi_dat);

  AssignFile(fi_dat,FileForRead); reset(fi_dat);

//ACW000116041961TAVG -142  k  183  k  419  k  720  k 1075  k 1546  k 1517  k 1428  k 1360  k 1121  k  457  k  -92  k
//ACW000116041962TAVG   60  k   32  k -207  k  582  k  855  k 1328  k 1457  k 1340  k 1110  k  941  k  270  k -179  k
 row_cnt:=0;
 repeat
  readln(fi_dat, st);
  inc(row_cnt);

   numsrc:=trim(Copy(st,1,11));
   //label1.caption:=numsrc;
  // application.ProcessMessages;

   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station" ');
     SQL.Add(' where "ghcn_v4_id"='+QuotedStr(numsrc));
    Open;
      if frmdm.q1.IsEmpty=false then
        absnum:=frmdm.q1.FieldByName('id').AsInteger else absnum:=-9;
    Close;
   end;


  if absnum<>-9 then begin
   yy:=StrToInt(copy(st,12,4));

   k:=20;
   for mn:=1 to 12 do begin
    Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

    if copy(st,k,5)<>'-9999' then begin
     temp:=Strtoint(copy(st, k, 5))/100;

     qcf1:=trim(copy(st, k+5, 1));
     qcf2:=trim(copy(st, k+6, 1));
     qcf3:=trim(copy(st, k+7, 1));

     if qcf2='' then flag:=0 else flag:=1;

     with frmdm.q1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' select "value" from "p_tavg_qcu_ghcnm_v401" ');
        SQL.Add(' where "station_id"=:absnum and "date"=:date_');
        ParamByName('absnum').AsInteger:=absnum;
        ParamByName('date_').AsDate:=DateCurr;
       Open;
     end;

    try
    // inserting a new value
    if frmdm.q1.IsEmpty=true then begin
      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "p_tavg_qcu_ghcnm_v401" ');
         SQL.Add(' ("station_id", "date", "value", "pqf1", "pqf2") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :date_, :value_, :pqf1, :pqf2)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('date_').AsDate:=DateCurr;
         ParamByName('value_').AsFloat:=temp;
         ParamByName('pqf1').AsInteger:=flag;
         ParamByName('pqf2').AsInteger:=flag;
        ExecSQL;
      end;
      if chkShowLog.Checked then
       mInserted.lines.add(inttostr(absnum)+'   '+
                       datetostr(DateCurr)+'   '+
                       floattostr(temp));
     end;

    // updating existing
    if frmdm.q1.IsEmpty=false then begin
     if frmdm.q1.Fields[0].Value<>temp then begin
      with frmdm.q2 do begin
        Close;
          SQL.Clear;
          SQL.Add(' update "p_tavg_qcu_ghcnm_v401" ');
          SQL.Add(' set "value"=:value_, "pqf1"=:fl, "pqf2"=:fl  ');
          SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
          ParamByName('absnum').AsInteger:=absnum;
          ParamByName('date_').AsDate:=DateCurr;
          ParamByName('value_').AsFloat:=temp;
          ParamByName('pqf1').AsInteger:=flag;
          ParamByName('pqf2').AsInteger:=flag;
         // showmessage(frmdm.q2.SQL.Text);
        ExecSQL;
      end;
      if chkShowLog.Checked then
       mUpdated.lines.add(inttostr(absnum)+'   '+
                       datetostr(DateCurr)+'   '+
                       floattostr(temp));
     end;
    end;

     frmdm.TR.CommitRetaining;
    except
      frmdm.TR.RollbackRetaining;
       mError.lines.add(inttostr(absnum)+'   '+
                       datetostr(DateCurr)+'   '+
                       floattostr(temp));
    end;

     k:=k+8;
    end;
   end;

  end; //absnum<>-9

  Caption:=inttostr(row_cnt);
  ProgressTaskbar(row_cnt, cnt);
  application.ProcessMessages;

 until eof(fi_dat);
 closefile(fi_dat);

 if MessageDlg('Upload successfully completed. Please, update metadata'+#13+
                 '(Menu->Services->Update Station_info)',
                  mtConfirmation, [mbOk], 0)=mrOk then exit;

 finally
  frmdm.TR.Commit;
  btnLoad.Enabled:=true;
 end;
end;

procedure Tfrmload_ghcnv4.Button10Click(Sender: TObject);
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
    SQL.Add(' Select "ghcn_v4_prcp_id" from "station" ');
    SQL.Add(' where "ghcn_v4_prcp_id" is not null and ');
    SQL.Add(' "ghcn_v4_id" is null');
   Open;
  end;

  while not frmdm.q1.eof do begin
   id_prcp:=frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value;

   assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcnm.v4.0.1.20211203\ghcnm.tavg.v4.0.1.20211203.qcu.inv');
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
       SQL.Add(' "ghcn_v4_id"='+Quotedstr(id_prcp));
       SQL.Add(' where "ghcn_v4_prcp_id"='+Quotedstr(id_prcp));
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



procedure Tfrmload_ghcnv4.Button12Click(Sender: TObject);
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
    SQL.Add(' "ghcn_v4_prcp_id" is null');
   Open;
  end;

  while not frmdm.q1.eof do begin
   id_prcp:=frmdm.q1.FieldByName('ghcn_v4_id').Value;

   assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcn-m_v4_prcp_inventory.txt');
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
       SQL.Add(' "ghcn_v4_prcp_id"='+Quotedstr(id_prcp));
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

procedure Tfrmload_ghcnv4.Button13Click(Sender: TObject);
var
 absnum, id_ds570, country_id: integer;
 dat: text;
 st, id_ghcn, id_ds570_st, id_ghcn_st, stname, stname_ghcn:string;
 fl:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select * from "station" ');
    SQL.Add(' where "ghcn_v4_prcp_id" is null ');
    SQL.Add(' order by "id"');
   Open;
  end;

  while not frmdm.q1.eof do begin
   absnum:=frmdm.q1.FieldByName('id').Value;
   stname:=frmdm.q1.FieldByName('name').Value;

   assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcn-m_v4_prcp_inventory.txt');
   reset(dat);

 //  showmessage(id_ds570_st);

   fl:=0;
   repeat
    readln(dat, st);
    stname_ghcn:=trim(copy(st, 39, 39));
    id_ghcn_st:=copy(st, 1, 11);

    if stname=stname_ghcn then fl:=1;

   until (fl=1) or (eof(dat));

   if fl=1 then begin
     mLog.Lines.add(inttostr(absnum)+'   '+stname+'   '+id_ghcn_st);

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set ');
       SQL.Add(' "ghcn_v4_prcp_id"='+Quotedstr(id_ghcn_st));
       SQL.Add(' where "id"='+inttostr(absnum));
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

procedure Tfrmload_ghcnv4.Button14Click(Sender: TObject);
var
 elev: real;
 id_db, id_file, st: string;
 absnum, fl:integer;
 dat: text;
begin
mLog.Clear;

 with frmdm.q1 do begin
  Close;
   SQL.Clear;
   SQL.Add(' Select * from "station" ');
   SQL.Add(' where "ghcn_v4_id" is not null and "elevation"=-999.90 ');
   SQL.Add(' order by "id"');
  Open;
 end;

 while not frmdm.q1.eof do begin
  absnum:=frmdm.q1.FieldByName('id').Value;
  id_db:=frmdm.q1.FieldByName('ghcn_v4_id').Value;

  assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcnm.v4.0.1.20211231\ghcnm.tavg.v4.0.1.20211231.qcu.inv');
  reset(dat);

  fl:=0;
  repeat
   readln(dat, st);
   id_file:=copy(st, 1, 11);

   if id_db=id_file then begin
     fl:=1;
     elev:=StrToFloat(copy(st, 32, 6));
    // showmessage(floattostr(elev));
   end;

  until (fl=1) or (eof(dat));

  if fl=1 then begin
    mLog.Lines.add(id_db+ '   '+floattostr(elev));
    with frmdm.q2 do begin
     Close;
      SQL.Clear;
      SQL.Add(' update "station" set "elevation"='+floattostr(elev));
      SQL.Add(' where "id"='+inttostr(absnum));
     ExecSQL;

    end;
  end;

  closefile(dat);
  frmdm.q1.Next;
 end;
 frmdm.q1.Close;
 frmdm.TR.CommitRetaining;
 showmessage('done');
end;



procedure Tfrmload_ghcnv4.Button15Click(Sender: TObject);
Var
 fi_dat: text;
 st, fileforread, numsrc:string;
 k, absnum, yy, mn, cnt, row_cnt, flag:integer;
 temp:real;
 datecurr: TDateTime;
 qcf1, qcf2, qcf3: string;
begin

 mInserted.Clear;
 mError.Clear;
 btnLoad.Enabled:= false;

 try
  frmmain.OD.InitialDir:=GlobalPath+'data\';
 // frmmain.OD.Filter:='difference.qcu.dat|difference.qcu.dat';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  cnt:=0;
  repeat
   readln(fi_dat);
    inc(cnt);
  until eof(fi_dat);
  CloseFile(fi_dat);

  AssignFile(fi_dat,FileForRead); reset(fi_dat);
  row_cnt:=0;
 repeat
  readln(fi_dat, st);
  inc(row_cnt);

   numsrc:=trim(Copy(st,1,11));

   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station" ');
     SQL.Add(' where "ghcn_v4_id"='+QuotedStr(numsrc));
    Open;
      if frmdm.q1.IsEmpty=false then
        absnum:=frmdm.q1.FieldByName('id').AsInteger else absnum:=-9;
    Close;
   end;


  if absnum<>-9 then begin
   yy:=StrToInt(copy(st,12,4));

   k:=20;
   for mn:=1 to 12 do begin
    Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

    if copy(st,k,5)<>'-9999' then begin
     temp:=Strtoint(copy(st, k, 5))/100;

     qcf1:=trim(copy(st, k+5, 1));
     qcf2:=trim(copy(st, k+6, 1));
     qcf3:=trim(copy(st, k+7, 1));

     if qcf2<>'' then begin
      with frmdm.q2 do begin
        Close;
          SQL.Clear;
          SQL.Add(' update "p_tavg_qcu_ghcnm_v401" ');
          SQL.Add(' set "pqf1"=:fl, "pqf2"=:fl ');
          SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
          ParamByName('absnum').AsInteger:=absnum;
          ParamByName('date_').AsDate:=DateCurr;
          ParamByName('fl').AsInteger:=1;
        ExecSQL;
      end;
    // mLog.Lines.Add(numsrc+'   '+Datetostr(datecurr)+'   '+qcf2);
     end;

     k:=k+8;
    end;
   end;

  end; //absnum<>-9

    ProgressTaskbar(row_cnt, cnt);
  application.ProcessMessages;

 until eof(fi_dat);
 closefile(fi_dat);

 if MessageDlg('Upload successfully completed. Please, update metadata'+#13+
                 '(Menu->Services->Update Station_info)',
                  mtConfirmation, [mbOk], 0)=mrOk then exit;

 finally
  frmdm.TR.Commit;
  btnLoad.Enabled:=true;
 end;
end;


procedure Tfrmload_ghcnv4.Button16Click(Sender: TObject);
var
   fpath, fname, st: string;
   dat:text;
   id, cnt, stat_cnt, mn, yy: integer;
   dat1:TDateTime;
   val1:real;
    qcf1, qcf2, qcf3: string;
begin

 fpath:='z:\MeteoShell\data\ghcn_v4\ghcn-m_v4.00.00_prcp\';

  with frmdm.q1 do begin
    Close;
      SQL.Clear;
      SQL.Add(' Select "id", "ghcn_v4_prcp_id" from "station" ');
      SQL.Add(' where "ghcn_v4_prcp_id" is not null ');
    Open;
    Last;
    First;
  end;

  stat_cnt:=frmdm.q1.RecordCount;

  cnt:=0;
  while not frmdm.q1.EOF do begin
   inc(cnt);
   id:=frmdm.q1.FieldByName('id').Value;
   fname:=fpath+frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value+'.csv';

      with frmdm.q3 do begin
        Close;
         SQL.Clear;
         SQL.Add(' select "station_id" from "p_precipitation_ghcn_v4" ');
         SQL.Add(' where "station_id"='+inttostr(id));
        Open;
      end;

   if (FileExists(fname)=true)then begin
  //  mLog.Lines.Add(frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value);

    Assignfile(dat, fname); reset(dat);
    repeat
      readln(dat, st);
      yy:=strtoint(copy(st, 84, 4));
      mn:=strtoint(copy(st, 88, 2));
      val1:=strtoint(trim(copy(st, 91, 6)))/10;

      qcf1:=trim(copy(st, 98, 1));
      qcf2:=trim(copy(st, 100, 1));
      qcf3:=trim(copy(st, 102, 1));

      dat1:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

      if qcf2<>'' then begin
       with frmdm.q2 do begin
        Close;
          SQL.Clear;
          SQL.Add(' update "p_precipitation_ghcn_v4" ');
          SQL.Add(' set "pqf1"=:fl, "pqf2"=:fl ');
          SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
          ParamByName('absnum').AsInteger:=id;
          ParamByName('date_').AsDate:=dat1;
          ParamByName('fl').AsInteger:=1;
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

  ProgressTaskbar(0, 0);
end;



procedure Tfrmload_ghcnv4.Button11Click(Sender: TObject);
var
id1, id2: string;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select * from "station" ');
    SQL.Add(' where "ghcn_v4_prcp_id" is not null and ');
    SQL.Add(' "ghcn_v4_id" is not null');
   Open;
  end;

  while not frmdm.q1.eof do begin
   id1:=frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value;
   id2:=frmdm.q1.FieldByName('ghcn_v4_id').Value;

   if copy(id1,1,2)<>copy(id2,1,2) then mLog.Lines.Add(id1+'   '+id2);

   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
  frmdm.TR.Commit;
end;




procedure Tfrmload_ghcnv4.Button1Click(Sender: TObject);
var
 absnum, id_ds570, country_id: integer;
 dat: text;
 st, id_ghcn, id_ds570_st, id_ghcn_st:string;
 fl:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select * from "station" ');
    SQL.Add(' where "ghcn_v4_id" is null and "wmocode"<>-9 ');
    SQL.Add(' order by "id"');
   Open;
  end;

  while not frmdm.q1.eof do begin
   absnum:=frmdm.q1.FieldByName('id').Value;
   id_ds570:=frmdm.q1.FieldByName('wmocode').Value;
   id_ds570_st:=inttostr(id_ds570);

   assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcnm.v4.0.1.20211203\ghcnm.tavg.v4.0.1.20211203.qcu.inv');
   reset(dat);

  // showmessage(id_ds570_st);

   fl:=0;
   repeat
    readln(dat, st);
    id_ghcn_st:=copy(st, 1, 11);
    id_ghcn:=copy(st, 6, 6);
    if copy(id_ghcn, 1, 1)='0' then id_ghcn:=copy(id_ghcn, 2, length(id_ghcn));

  //  mlog.lines.add(id_ghcn);

    if id_ds570_st= id_ghcn then fl:=1;

   until (fl=1) or (eof(dat));

   if fl=1 then begin
     mLog.Lines.add(inttostr(absnum)+'   '+inttostr(id_ds570)+'   '+id_ghcn_st);
    { with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Select "id" from "country" ');
       SQL.Add(' where "iso"='+quotedstr(copy(id_ghcn_st, 1, 2)));
      Open;
       country_id:=frmdm.q2.Fields[0].AsInteger;
      Close;
     end; }

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set ');
       SQL.Add(' "ghcn_v4_id"='+Quotedstr(id_ghcn_st)); //+',');
     //  SQL.Add(' "country_id"='+inttostr(country_id));
       SQL.Add(' where "id"='+inttostr(absnum));
      ExecSQL;
     end;
    frmdm.TR.CommitRetaining;
   end;


   closefile(dat);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
  frmdm.TR.Commit;
  showmessage('done');
end;



procedure Tfrmload_ghcnv4.Button2Click(Sender: TObject);
var
 absnum, id_ds570, country_id: integer;
 dat: text;
 st, id_ghcn, id_ds570_st, id_ghcn_st, stname, stname_ghcn:string;
 fl:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select * from "station" ');
    SQL.Add(' where "ghcn_v4_id" is null ');
    SQL.Add(' order by "id"');
   Open;
  end;

  while not frmdm.q1.eof do begin
   absnum:=frmdm.q1.FieldByName('id').Value;
   stname:=frmdm.q1.FieldByName('name').Value;

   assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcnm.v4.0.1.20211203\ghcnm.tavg.v4.0.1.20211203.qcu.inv');
   reset(dat);

 //  showmessage(id_ds570_st);

   fl:=0;
   repeat
    readln(dat, st);
    stname_ghcn:=trim(copy(st, 39, length(st)));
    id_ghcn_st:=copy(st, 1, 11);

    if stname=stname_ghcn then fl:=1;

   until (fl=1) or (eof(dat));

   if fl=1 then begin
     mLog.Lines.add(inttostr(absnum)+'   '+stname+'   '+id_ghcn_st);
     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Select "id" from "country" ');
       SQL.Add(' where "iso"='+quotedstr(copy(id_ghcn_st, 1, 2)));
      Open;
       country_id:=frmdm.q2.Fields[0].AsInteger;
      Close;
     end;

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set ');
       SQL.Add(' "ghcn_v4_id"='+Quotedstr(id_ghcn_st)+',');
       SQL.Add(' "country_id"='+inttostr(country_id));
       SQL.Add(' where "id"='+inttostr(absnum));
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



procedure Tfrmload_ghcnv4.Button3Click(Sender: TObject);
var
 absnum, id_ds570, country_id: integer;
 dat: text;
 st, id_ghcn_db, id_ds570_st, id_ghcn_st, stname, stname_ghcn:string;
 fl:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select "ghcn_v4_id" from "station" ');
    SQL.Add(' where "ghcn_v4_id" is not null ');
    SQL.Add(' order by "ghcn_v4_id"');
   Open;
  end;

  while not frmdm.q1.eof do begin
   id_ghcn_db:=frmdm.q1.FieldByName('ghcn_v4_id').Value;

   assignfile(dat, 'Z:\MeteoShell\data\ghcn_v4\ghcnm.v4.0.1.20211203\ghcnm.tavg.v4.0.1.20211203.qcu.inv');
   reset(dat);

   fl:=0;
   repeat
    readln(dat, st);
    id_ghcn_st:=copy(st, 1, 11);

    if id_ghcn_db=id_ghcn_st then fl:=1;

   until (fl=1) or (eof(dat));

   if fl=0 then begin
     mLog.Lines.add(id_ghcn_db);
    { with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Select "id" from "country" ');
       SQL.Add(' where "iso"='+quotedstr(copy(id_ghcn_st, 1, 2)));
      Open;
       country_id:=frmdm.q2.Fields[0].AsInteger;
      Close;
     end;

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set ');
       SQL.Add(' "ghcn_v4_id"='+Quotedstr(id_ghcn_st)+',');
       SQL.Add(' "country_id"='+inttostr(country_id));
       SQL.Add(' where "id"='+inttostr(absnum));
      ExecSQL;
     end;
    frmdm.TR.CommitRetaining; }
   end;


   closefile(dat);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
  frmdm.TR.Commit;

end;

procedure Tfrmload_ghcnv4.Button4Click(Sender: TObject);
Var
   fname, st, v2_id:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
begin
 frmmain.OD.InitialDir:=GlobalPath+'data\';
 frmmain.OD.Filter:='*.inv|*.inv';

 if frmmain.OD.Execute then fname:=frmmain.OD.FileName else exit;

    AssignFile(datf, fname);
    reset(datf);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ghcn_v4" ');
   ExecSQL;
  end;
  frmdm.TR.Commit;


   repeat
    readln(datf, st);

     v2_id :=Copy(st, 1, 11);
     stname:=trim(Copy(st, 39, length(st)-39));
     stlat:=strtofloat(trim(Copy(st, 13, 8)));
     stlon:=strtofloat(trim(Copy(st, 22, 9)));
     elev:= strtofloat(trim(Copy(st, 32, 6)));


     with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ghcn_v4"  ');
         SQL.Add(' ("id", "latitude", "longitude", "elevation", "name") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :StLat, :StLon, :Elevation, :StName)');
         ParamByName('absnum').AsString:=v2_id;
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         //ParamByName('country').AsString:=stcountry;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

   until eof(datf);
   frmdm.TR.Commit;
end;


procedure Tfrmload_ghcnv4.btnDuplicatesClick(Sender: TObject);
var
vn:string;
 cnt:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select distinct("ghcn_v4_id"), count("ghcn_v4_id") ');
    SQL.Add(' from "station" group by "ghcn_v4_id"');
    //SQL.Add(' Select distinct("ghcn_v4_prcp_id"), count("ghcn_v4_prcp_id") ');
    //SQL.Add(' from "station" group by "ghcn_v4_prcp_id"');
   Open;
  end;

   while not frmdm.q1.eof  do begin
      VN :=frmdm.q1.Fields[0].AsString;
      Cnt:=frmdm.q1.Fields[1].AsInteger;
       if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
     frmdm.q1.next;
   end;
end;


procedure Tfrmload_ghcnv4.Button5Click(Sender: TObject);
Var
   fname, st, v2_id, name_state:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1, wmo, yy1, yy2:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
begin
 frmmain.OD.InitialDir:=GlobalPath+'data\';
 frmmain.OD.Filter:='*.txt|*.txt';

 if frmmain.OD.Execute then fname:=frmmain.OD.FileName else exit;

    AssignFile(datf, fname);
    reset(datf);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ghcn_v4" ');
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
     wmo:=  strtoInt(trim(Copy(st, 81, 5)));
     yy1:=  strtoInt(trim(Copy(st, 87, 4)));
     yy2:=  strtoInt(trim(Copy(st, 92, 4)));


     with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ghcn_v4_prcp"  ');
         SQL.Add(' ("id", "latitude", "longitude", "elevation", ');
         SQL.Add(' "name", "name_state", "wmo", "year_beg", "year_end") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :StLat, :StLon, :Elevation, :StName, :state, ');
         SQL.Add('  :wmo, :year_beg, :year_end)');
         ParamByName('absnum').AsString:=v2_id;
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         ParamByName('state').AsString:=name_state;
         ParamByName('wmo').AsInteger:=wmo;
         ParamByName('year_beg').AsInteger:=yy1;
         ParamByName('year_end').AsInteger:=yy2;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

   until eof(datf);
   frmdm.TR.Commit;
end;

procedure Tfrmload_ghcnv4.Button6Click(Sender: TObject);
var
  wmo:integer;
   ghcn_id:string;
begin

   with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select "id", "wmo" from "station_ghcn_v4_prcp" ');
    SQL.Add(' where "wmo"<>99999 ');
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
       SQL.Add(' where "ghcn_v4_prcp_id" is null and "wmocode"='+inttostr(wmo));
      Open;
    end;

     if not frmdm.q2.IsEmpty  then begin
      with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' update "station" set "ghcn_v4_prcp_id"='+QuotedStr(ghcn_id));
       SQL.Add(' where "wmocode"='+inttostr(wmo));
      ExecSQL;
      end;
       mLog.Lines.Add(inttostr(wmo)+'   '+ghcn_id);
     end;

    frmdm.q1.Next;
  end;
  frmdm.TR.CommitRetaining;
end;

procedure Tfrmload_ghcnv4.Button7Click(Sender: TObject);
Var
   fname, st, v2_id, name_state:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1, wmo, yy1, yy2, country_id:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
begin
 frmmain.OD.InitialDir:=GlobalPath+'data\';
 frmmain.OD.Filter:='*.txt|*.txt';

 if frmmain.OD.Execute then fname:=frmmain.OD.FileName else exit;

    AssignFile(datf, fname);
    reset(datf);

   repeat
    readln(datf, st);

     v2_id :=Copy(st, 1, 11);
     stlat:=strtofloat(trim(Copy(st, 13, 8)));
     stlon:=strtofloat(trim(Copy(st, 22, 9)));
     elev:= strtofloat(trim(Copy(st, 32, 6)));
     name_state:=trim(Copy(st, 39, 2));
     stname:=trim(Copy(st, 42, 39));
     wmo:=  strtoInt(trim(Copy(st, 81, 5)));
     yy1:=  strtoInt(trim(Copy(st, 87, 4)));
     yy2:=  strtoInt(trim(Copy(st, 92, 4)));

     if (wmo<>99999) {and (yy2-yy1>=30)} then begin
         frmdm.q1.Close;
         frmdm.q1.SQL.Text:='Select "wmocode" from "station" '+
         'where "wmocode"='+inttostr(wmo);
         frmdm.q1.Open;

      if frmdm.q1.IsEmpty=true then begin
       mLog.Lines.Add(inttostr(wmo)+'   '+inttostr(yy1)+'   '+inttostr(yy2));

         frmdm.q2.Close;
         frmdm.q2.SQL.Text:='Select max("id") from "station"';
         frmdm.q2.Open;
          absnum:=frmdm.q2.Fields[0].AsInteger+1;
         frmdm.q2.Close;

         country_id:=0;
         with frmdm.q2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Select "id" from "country" ');
           SQL.Add(' where "iso"='+quotedstr(copy(v2_id, 1, 2)));
          Open;
            country_id:=frmdm.q2.Fields[0].AsInteger;
          Close;
        end;

       with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station"  ');
         SQL.Add(' ("id", "wmocode", "latitude", "longitude", "elevation", "name", "country_id", "ghcn_v4_prcp_id") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :WMONum, :StLat, :StLon, :Elevation, :StName, :country_id, :ghcn_v4_prcp_id)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('WMONum').AsInteger:=wmo;
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         ParamByName('country_id').AsInteger:=country_id;
         ParamByName('ghcn_v4_prcp_id').AsString:=v2_id;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;
    end; //writing;
   end;



   until eof(datf);
  // frmdm.TR.Commit;
end;

procedure Tfrmload_ghcnv4.Button8Click(Sender: TObject);
var
   fpath, fname, st: string;
   dat:text;
   id, cnt, stat_cnt, mn, yy: integer;
   dat1:TDateTime;
   val1:real;
begin

 fpath:='z:\MeteoShell\data\ghcn_v4\ghcn-m_v4.00.00_prcp\';

  with frmdm.q1 do begin
    Close;
      SQL.Clear;
      SQL.Add(' Select "id", "ghcn_v4_prcp_id" from "station" ');
      SQL.Add(' where "ghcn_v4_prcp_id" is not null ');
    Open;
    Last;
    First;
  end;

  stat_cnt:=frmdm.q1.RecordCount;

  cnt:=0;
  while not frmdm.q1.EOF do begin
   inc(cnt);
   id:=frmdm.q1.FieldByName('id').Value;
   fname:=fpath+frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value+'.csv';

      with frmdm.q3 do begin
        Close;
         SQL.Clear;
         SQL.Add(' select "station_id" from "p_precipitation_ghcn_v4" ');
         SQL.Add(' where "station_id"='+inttostr(id));
        Open;
      end;

   if (FileExists(fname)=true) and (frmdm.q3.IsEmpty=true) then begin
    mLog.Lines.Add(frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value);

    Assignfile(dat, fname); reset(dat);
    repeat
      readln(dat, st);
      yy:=strtoint(copy(st, 84, 4));
      mn:=strtoint(copy(st, 88, 2));
      val1:=strtoint(trim(copy(st, 91, 6)))/10;

      dat1:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "p_precipitation_ghcn_v4" ');
         SQL.Add(' ("station_id", "date", "value", "pqf1", "pqf2") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :date_, :value_, :pqf1, :pqf2)');
         ParamByName('absnum').AsInteger:=id;
         ParamByName('date_').AsDate:=Dat1;
         ParamByName('value_').AsFloat:=val1;
         ParamByName('pqf1').AsInteger:=0;
         ParamByName('pqf2').AsInteger:=0;
        ExecSQL;
      end;

    until eof(dat);
   end;
     frmdm.TR.CommitRetaining;
     ProgressTaskbar(cnt, stat_cnt);
     Application.ProcessMessages;

   frmdm.q1.Next;
  end;

  ProgressTaskbar(0, 0);
end;


procedure Tfrmload_ghcnv4.Button9Click(Sender: TObject);
Var
   ghcn_id, cc: string;
   country_id, country_db: integer;
begin
 with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' Select "ghcn_v4_prcp_id", "country_id" from "station" ');
     SQL.Add(' where "ghcn_v4_prcp_id" is not null ');
   Open;
 end;

 while not frmdm.q1.eof do begin
  ghcn_id:=frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value;
  country_db:=frmdm.q1.FieldByName('country_id').Value;

  cc:=copy(ghcn_id, 1, 2);
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
           SQL.Add(' where "ghcn_v4_prcp_id"='+quotedstr(ghcn_id));
          ExecSQL;
        end;
         mLog.Lines.add(ghcn_id+'   '+inttostr(country_db)+'->'+inttostr(country_id));;
    end;


   frmdm.q1.Next;
 end;
end;


end.

