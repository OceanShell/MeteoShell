unit load_ghcnd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DateUtils;

type

  { Tfrmloadghcnd }

  Tfrmloadghcnd = class(TForm)
    Button1: TButton;
    mLog: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmloadghcnd: Tfrmloadghcnd;

implementation

{$R *.lfm}

uses dm, procedures;

{ Tfrmloadghcnd }

procedure Tfrmloadghcnd.Button1Click(Sender: TObject);
var
 dat: text;
 st, fpath, fname, par, tbl:string;
 k, yy, mn, dd, cnt, flag:integer;
 stat_cnt, id: integer;
 datecurr: TDateTime;
 qcf1, qcf2, qcf3: string;
 val0, val1: real;
begin

// mInserted.Clear;
// mError.Clear;
 //btnLoad.Enabled:= false;

 fpath:='X:\Data_Oceanography\_Meteo\ghcn_daily\TH\';

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
   fname:=fpath+frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value+'.dly';
  { if copy(frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value, 1,2)='TH' then
     showmessage(fname); }


   if (FileExists(fname)=true) then begin
    mLog.Lines.Add(frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value);

    Assignfile(dat, fname); reset(dat);
    repeat
     readln(dat, st);
     yy:=StrToInt(copy(st,12,4));
     mn:=StrToInt(copy(st,16,2));
     par:=copy(st,18,4);

     if par='TAVG' then tbl:='p_tavg_ghcnd';
     if par='TMIN' then tbl:='p_tmin_ghcnd';
     if par='TMAX' then tbl:='p_tmax_ghcnd';
     if par='PRCP' then tbl:='p_precipitation_ghcnd';

        k:=22;
        for dd:=1 to 31 do begin

         if (copy(st,k,5)<>'-9999') and (IsValidDate(yy, mn, dd)) then begin
          Datecurr:=EncodeDate(yy, mn, dd);
          val0:=Strtoint(copy(st, k, 5));

          (* careful with adding more elements!! *)
          val1:=val0/10;

          qcf1:=trim(copy(st, k+5, 1));
          qcf2:=trim(copy(st, k+6, 1));
          qcf3:=trim(copy(st, k+7, 1));

          if qcf2='' then flag:=0 else flag:=1;

       //   showmessage(datetimetostr(Datecurr)+'   '+tbl+'   '+floattostr(val1));

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
          k:=k+8;
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

end.

