unit load_unaami;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, ExtCtrls, DateUtils;

type

  { Tfrmload_unaami }

  Tfrmload_unaami = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmload_unaami: Tfrmload_unaami;
  fpath:string;
  fi_dat:text;

implementation

uses main, dm;

{$R *.lfm}

procedure Tfrmload_unaami.FormCreate(Sender: TObject);
var
  fdb: TSearchRec;
begin
   fpath:='X:\Data_Oceanography\_Meteo\UnaamiSAT59\source\';

   ListBox1.Clear;
  if fpath<>'' then begin
   fdb.Name:='';
   listbox1.Clear;
    FindFirst(fPath+'*.d',faAnyFile, fdb);
   if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
  while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
  end;
end;


procedure Tfrmload_unaami.Button1Click(Sender: TObject);
var
k,mik, kf:integer;
absnum,wmo,WNS,elevation,countrycode,year:integer;
ln,lt,val:real;
sym:char;
st,StName,CountryName,buf, fname:string;
DateCurr:TDateTime;
begin

 for kf:=0 to listbox1.Count-1 do begin
  fname:=listbox1.Items.Strings[kf];
  wmo:=strtoint(copy(fname, 4, 5));

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

   if absnum<>-9 then begin

   assignfile(fi_dat,fpath+fname); reset(fi_dat);
   readln(fi_dat,st);

   {write data}
{d}while not EOF(fi_dat) do begin
    readln(fi_dat,st);
    Year:=strtoint(copy(st,75,4));

    buf:='';
    mik:=0;
{m}for k:=1 to 72 do begin
    sym:=st[k];
    if (sym<>',') then buf:=buf+sym
                else begin
                mik:=mik+1;
                val:=strtofloat(buf);
                buf:='';
                if val<99 then begin

              DateCurr:=EncodeDate(year, mik, trunc(DaysInAMonth(year, mik)/2));

            {    memo1.Lines.Add(inttostr(year)
                  +#9+inttostr(mik)
                 +#9+floattostr(val)
                 +#9+inttostr(0)); }

                with frmdm.q1 do begin
                      Close;
                       SQL.Clear;
                        SQL.Add(' Select * from "p_surface_air_temp_unaami" ');
                        SQL.Add(' where "station_id"=:ID and "date"=:dat1 ');
                        ParamByName('ID').AsInteger:=absnum;
                        ParamByName('dat1').Value:=DateCurr;
                      Open;
                    end;

                      if frmdm.q1.IsEmpty=true then begin
                       with frmdm.q2 do begin
                        Close;
                         SQL.Clear;
                         SQL.Add(' insert into "p_surface_air_temp_unaami" ');
                         SQL.Add(' ("station_id", "date", "value", "pqf2") ');
                         SQL.Add(' values ');
                         SQL.Add(' (:absnum, :date_, :value_, :pqf2)');
                         ParamByName('absnum').Value:=absnum;
                         ParamByName('date_').AsDate:=DateCurr;
                         ParamByName('value_').Value:=val;
                         ParamByName('pqf2').Value:=0;
                        ExecSQL;
                      end;
                    end;
                end;
                end;
{m}end;


{d}end;

   frmdm.TR.CommitRetaining;
   closefile(fi_dat);

   end else memo1.lines.add(inttostr(wmo));

 end;


end;


end.
