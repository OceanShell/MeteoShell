unit load_aari;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateUtils;

type

  { TfrmLoadAARI }

  TfrmLoadAARI = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;


    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLoadAARI: TfrmLoadAARI;

implementation

{$R *.lfm}

uses main, dm;


procedure TfrmLoadAARI.Button1Click(Sender: TObject);
Var
  kf, k, pp:integer;
  WMO, yy, absnum, mn:integer;
  fname, st, tbl:string;
  val1:real;
  fdb:TSearchRec;
  DateCurr:TDateTime;
  fpath, lpath: string;
  ldat:text;
begin

  fpath:='x:\Data_Oceanography\_Meteo\Arctic_AARI\';

  for pp:=1 to 6 do begin

    case pp of
      1: begin
          lpath:=fpath+'t\';
          tbl:='p_surface_air_temperature_aari';
         end;
      2: begin
          lpath:=fpath+'tmin\';
          tbl:='p_surface_air_temp_min_aari';
         end;
      3: begin
          lpath:=fpath+'tmax\';
          tbl:='p_surface_air_temp_max_aari';
         end;
      4: begin
          lpath:=fpath+'r\';
          tbl:='p_precipitation_aari';
         end;
      5: begin
          lpath:=fpath+'w\';
          tbl:='p_wind_speed_aari';
         end;
      6: begin
          lpath:=fpath+'wmax\';
          tbl:='p_wind_speed_max_aari';
         end;
    end;

  ListBox1.Clear;
  if lpath<>'' then begin
   fdb.Name:='';
   listbox1.Clear;
    FindFirst(lPath+'*.txt',faAnyFile, fdb);
   if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
  while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
  end;

//  showmessage(tbl);

  for kf:=0 to listbox1.Count-1 do begin
   fname:=listbox1.Items.Strings[kf];
   WMO:=StrToInt(copy(fname, 1, length(fname)-4));

     absnum:=-9;
     with frmdm.q1 do begin
       Close;
        SQL.Clear;
         SQL.Add('Select "id" from "station" ');
         SQL.Add('where "wmocode"='+quotedstr(inttostr(WMO)));
       Open;
        if frmdm.q1.IsEmpty=false then absnum:=frmdm.q1.Fields[0].AsInteger;
       Close;
     end;

 //  showmessage(inttostr(wmo)+'   '+inttostr(absnum));

   if absnum<>-9 then begin
   AssignFile(ldat, lpath+fname); reset(ldat);
   readln(ldat, st);

   repeat
    readln(ldat, st);

    try
     yy :=StrToInt(copy(st, 1, 4));
     except
      showmessage(fname+'   '+st);
     end;

    k:=5;
    for mn:=1 to 12 do begin
     DateCurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));
     try
      val1:=StrToFloat(copy(st, k,  5));
     except
      Val1:=999.9;
      showmessage(fname+'   '+st);
     end;

     if val1<999 then  begin
     with frmdm.q1 do begin
       Close;
        SQL.Clear;
         SQL.Add(' Select * from "'+tbl+'"');
         SQL.Add(' where "station_id"=:ID and "date"=:dat1 ');
         ParamByName('ID').AsInteger:=absnum;
         ParamByName('dat1').Value:=DateCurr;
       Open;
     end;

       if frmdm.q1.IsEmpty=true then begin
        with frmdm.q2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' insert into "'+tbl+'" ');
          SQL.Add(' ("station_id", "date", "value", "pqf2") ');
          SQL.Add(' values ');
          SQL.Add(' (:absnum, :date_, :value_, :pqf2)');
          ParamByName('absnum').Value:=absnum;
          ParamByName('date_').AsDate:=DateCurr;
          ParamByName('value_').Value:=val1;
          ParamByName('pqf2').Value:=0;
         ExecSQL;
       end;
     end;

     end; // not 999.9

      k:=k+5;

     frmdm.TR.CommitRetaining;
    end;

   until eof(ldat);
   Closefile(ldat);

   end else memo1.Lines.Add(inttostr(wmo));//id<>-9

   end;

  end;  //parameters
  frmdm.TR.Commit;
end;

end.
