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
    Button1: TButton;
    Button2: TButton;
    chkOutput: TCheckBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Splitter2: TSplitter;

    procedure btnGHCN_v3_DataClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

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
 fname, st, tbl, numsrc, numsrc_old:string;
 k, ff, absnum, yy, mn:integer;
 temp, val0:real;
 DateCurr:TDateTime;
 datf:text;
 towrite: boolean;
begin
  fname:='Z:\MeteoShell\data\ghcn_v2\v2.prcp';
  AssignFile(datf, fname);
  reset(datf);

  numsrc_old:='';
 repeat
  readln(datf, st);

   numsrc:=trim(Copy(st, 1, 11));

   if numsrc<>numsrc_old then begin
     absnum:=-9;
     with frmdm.q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select "id" from "station"');
       SQL.Add(' where "ghcn_v2_id"='+numsrc);
      Open;
       if frmdm.q1.IsEmpty=false then
         absnum:=frmdm.q1.Fields[0].AsInteger else absnum:=-9;
      Close;
     end;

     if (absnum<>-9) then begin
     with frmdm.q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select "station_id" from "p_precipitation_ghcn_v2"');
       SQL.Add(' where "station_id"='+inttostr(absnum));
      Open;
       towrite:=frmdm.q1.IsEmpty;
      Close;
     end;
     end else towrite:=false;
   end;

   if towrite=true then begin
   yy:=StrToInt(copy(st,13,4));

   k:=17;
   for mn:=1 to 12 do begin
    Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

    if (copy(st,k,5)<>'-9999') and (copy(st,k,5)<>'-8888') then begin
     temp:=Strtoint(copy(st,k,5))/10;

      with frmdm.q3 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "p_precipitation_ghcn_v2"');
         SQL.Add(' ("station_id", "date", "value", "pqf2") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :date_, :value_, :pqf2)');
         ParamByName('absnum').AsInteger:=absnum;
         ParamByName('date_').AsDate:=DateCurr;
         ParamByName('value_').AsFloat:=temp;
         ParamByName('pqf2').AsInteger:=0;
        ExecSQL;
       Close;
      end;
      if chkoutput.Checked=true then
      memo1.lines.add('INSERTED: '+inttostr(absnum)+', '+
           inttostr(yy)+' '+inttostr(mn)+', '+floattostr(temp));
      Application.ProcessMessages;
     end; // inserting

     k:=k+5;
    end;//12 months

     frmdm.TR.CommitRetaining;
   end; // is empty

  numsrc_old:=numsrc;
 until eof(datf);
 closefile(datf);
end;



procedure Tfrmload_ghcn_v2.Button1Click(Sender: TObject);
 Var
  fname, st, v2_id:string;
  numsrc,  absnum: integer;
  datf:text;
 begin
   fname:='Z:\MeteoShell\data\ghcn_v2\v2.prcp.inv';
   AssignFile(datf, fname);
   reset(datf);


  repeat
   readln(datf, st);

    v2_id :=Copy(st, 1, 11);
    numsrc:=StrToInt(trim(Copy(st, 4, 5)));

    if copy(st, 9, 3)='000' then begin
   // showmessage(trim(v2_id)+'   '+inttostr(numsrc));

    absnum:=-9;
    with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select "id" from "station"');
      SQL.Add(' where "wmocode"='+inttostr(numsrc));
      SQL.Add(' and "ghcn_v2_id" is null ');
     Open;
      if frmdm.q1.IsEmpty=false then begin
       absnum:=frmdm.q1.Fields[0].AsInteger;
      end;
    end;

    if (absnum<>-9)  then begin
     memo1.lines.add(v2_id);
            with frmdm.q2 do begin
           Close;
             SQL.Clear;
             SQL.Add(' update "station" set ');
             SQL.Add(' "ghcn_v2_id"='+trim(v2_id));
             SQL.Add(' where "id"='+inttostr(absnum));
           ExecSQL;
         end;
    end;

    end;


  until eof(datf);
  frmdm.TR.Commit;
end;


procedure Tfrmload_ghcn_v2.Button2Click(Sender: TObject);
Var
   fname, st, v2_id:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
begin
    fname:='Z:\MeteoShell\data\ghcn_v2\v2.prcp.inv';
    AssignFile(datf, fname);
    reset(datf);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ghcn_v2" ');
   ExecSQL;
  end;
  frmdm.TR.Commit;


   repeat
    readln(datf, st);

     v2_id :=Copy(st, 1, 11);
     stname:=trim(Copy(st, 13, 30));
    // stcountry:=trim(Copy(st, 33, 11));
     stlat:=strtofloat(trim(Copy(st, 44, 6)));
     stlon:=strtofloat(trim(Copy(st, 51, 8)));
     elev:= strtofloat(trim(Copy(st, 59, 4)));


     with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ghcn_v2"  ');
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


end.

