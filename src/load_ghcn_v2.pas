unit load_ghcn_v2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Variants, DateUtils;

type

  { Tfrmload_ghcn_v2 }

  Tfrmload_ghcn_v2 = class(TForm)
    btnGHCN_v3_Data: TButton;
    btnGHCN_v3_MD: TButton;
    Button5: TButton;
    chkOutput: TCheckBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Splitter2: TSplitter;

    procedure btnGHCN_v3_DataClick(Sender: TObject);

  private

  public

  end;

var
  frmload_ghcn_v2: Tfrmload_ghcn_v2;


implementation

{$R *.lfm}

{ Tfrmload_ghcn_v2 }

uses dm;


procedure Tfrmload_ghcn_v2.btnGHCN_v3_DataClick(Sender: TObject);
Var
 fname, st, tbl:string;
 k, ff, absnum, yy, mn, numsrc:integer;
 temp, val0:real;
 DateCurr:TDateTime;
 datf:text;
begin
  fname:='Z:\MeteoShell\data\ghcn_v2\v2.prcp';
  AssignFile(datf, fname);
  reset(datf);


 repeat
  readln(datf, st);

   numsrc:=StrToInt(trim(Copy(st,4, 5)));
 //  showmessage(inttostr(numsrc));

   absnum:=-9;
   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station"');
     SQL.Add(' where "wmocode"='+inttostr(numsrc));
    Open;
     if frmdm.q1.IsEmpty=false then
       absnum:=frmdm.q1.Fields[0].AsInteger else absnum:=-9;
    Close;
   end;

   if (absnum<>-9) and (copy(st,9,3)='000')  then begin
   yy:=StrToInt(copy(st,13,4));
   memo1.lines.add(inttostr(numsrc));

   k:=17;
   for mn:=1 to 12 do begin
    Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

    if (copy(st,k,5)<>'-9999') and (copy(st,k,5)<>'-8888') then begin
     temp:=Strtoint(copy(st,k,5))/10;
  //   showmessage(floattostr(temp));

      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "p_precipitation_ghcn_v2"');
         SQL.Add(' ("station_id", "date", "value", "flag") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :date_, :value_, :flag_)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('date_').AsDate:=DateCurr;
         ParamByName('value_').AsFloat:=temp;
         ParamByName('flag_').AsInteger:=0;
        ExecSQL;
       Close;
      end;
      if chkoutput.Checked=true then
      memo1.lines.add('INSERTED: '+inttostr(absnum)+', '+
           inttostr(yy)+' '+inttostr(mn)+', '+floattostr(temp));
     end; // there's no value
     k:=k+5;
    end;
   end;//12 months

  frmdm.TR.CommitRetaining;
 until eof(datf);
 closefile(datf);
end;


end.

