unit load_ghcn_v4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils;

type

  { Tfrmload_ghcnv4 }

  Tfrmload_ghcnv4 = class(TForm)
    btnLoad: TButton;
    chkShowLog: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mInserted: TMemo;
    mError: TMemo;
    mUpdated: TMemo;

    procedure btnLoadClick(Sender: TObject);

  private

  public

  end;

var
  frmload_ghcnv4: Tfrmload_ghcnv4;

implementation

{$R *.lfm}

uses main, dm;

{ Tfrmload_ghcnv4 }

procedure Tfrmload_ghcnv4.btnLoadClick(Sender: TObject);
Var
 fi_dat: text;
 st, fileforread, numsrc:string;
 k, absnum, yy, mn:integer;
 temp:real;
 datecurr: TDateTime;
begin

 mInserted.Clear;
 mError.Clear;
 btnLoad.Enabled:= false;

 try
  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='difference.qcu.dat|difference.qcu.dat';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;

  AssignFile(fi_dat,FileForRead); reset(fi_dat);

//ACW000116041961TAVG -142  k  183  k  419  k  720  k 1075  k 1546  k 1517  k 1428  k 1360  k 1121  k  457  k  -92  k
//ACW000116041962TAVG   60  k   32  k -207  k  582  k  855  k 1328  k 1457  k 1340  k 1110  k  941  k  270  k -179  k

 repeat
  readln(fi_dat, st);

   numsrc:=trim(Copy(st,1,11));
   //label1.caption:=numsrc;
   application.ProcessMessages;

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
         SQL.Add(' ("station_id", "date", "value", "flag") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :date_, :value_, :flag_)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('date_').AsDate:=DateCurr;
         ParamByName('value_').AsFloat:=temp;
         ParamByName('flag_').AsInteger:=0;
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
          SQL.Add(' set "value"=:value_ ');
          SQL.Add(' where "station_id"=:absnum and "date"=:date_ ');
          ParamByName('absnum').AsInteger:=absnum;
          ParamByName('date_').AsDate:=DateCurr;
          ParamByName('value_').AsFloat:=temp;
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

end.

