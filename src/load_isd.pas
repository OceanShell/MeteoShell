unit Load_isd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, fphttpclient,
  DateUtils, Opensslsockets;

type

  { Tfrmload_isd }

  Tfrmload_isd = class(TForm)
    Button1: TButton;
    btnData: TButton;
    Memo1: TMemo;
    procedure btnDataClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure writepar(tbl:string; absnum: integer; DateCurr:TDateTime; val1:real);
  public

  end;

var
  frmload_isd: Tfrmload_isd;

implementation

{$R *.lfm}

uses dm, procedures;

{ Tfrmload_isd }

procedure Tfrmload_isd.Button1Click(Sender: TObject);
Var
  Client: TFPHttpClient;
  Response : TStream;
  dat: text;
  fpath, fname, url0, url, fout, st, wmo_st,ccode: string;
  yy, wmo, cnt, row_cnt: integer;
begin
try
  Client := TFPHttpClient.Create(nil);
  with Client do begin
    AddHeader('User-Agent','Mozilla/5.0 (compatible; fpweb)');
    AddHeader('Content-Type','application/json; charset=UTF-8');
    AddHeader('Accept', 'application/json');
    AllowRedirect := true;
  end;

   fpath:='x:\Data_Meteorology\ISD\data\';
   url0:='https://www.ncei.noaa.gov/pub/data/noaa/isd-lite/';

 //  ccode:='168,';

   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "wmocode" from "station" where ');
     SQL.Add(' "wmocode" is not null ');
     SQL.Add(' and "latitude">=60 ');
     SQL.Add(' order by "wmocode" ');
    Open;
   end;

   row_cnt:=0;
   for yy:=1901 to 1931 do begin    // there's no data before 1931
     inc(row_cnt);
    caption:=inttostr(yy);

   frmdm.q1.First;
   while not frmdm.q1.Eof do begin


    wmo:=frmdm.q1.Fields[0].Value;


    if wmo<10000 then wmo_st:='0'+inttostr(wmo)+'0' else wmo_st:=inttostr(wmo)+'0';

    fname:=wmo_st+'-99999-'+inttostr(yy)+'.gz';

    url:=url0+inttostr(yy)+'/'+fname;

    fout:=fpath+inttostr(yy)+PathDelim;
    if not DirectoryExists(fout) then CreateDir(fout);


    Response := TFileStream.Create(fout+fname, fmCreate);

      try
         Client.Get(url, Response);
       except on E:Exception do

       end;
    Response.Free;

  //  exit;

    AssignFile(dat, fout+fname); reset(dat);
    readln(dat, st);
    if trim(st)='' then begin
      CloseFile(dat);
      DeleteFile(fout+fname);
    end else CloseFile(dat);

    frmdm.q1.Next;
   end;


      ProgressTaskbar(row_cnt, (2023-1931));
      application.ProcessMessages;
     // frmdm.TR.CommitRetaining;
   end; //years

  finally
    Client.Free;
    ProgressTaskbar(0,0);

  end;
end;



procedure Tfrmload_isd.btnDataClick(Sender: TObject);
Var
  fpath0, fpath, fname, st:string;
  fdb:TSearchRec;
  flist:TStringList;
  dat: text;
  yy, mn, dd, hh, mm, ss:word;
  dat1:TDateTime;
  yy_i, wmo, ff, absnum, cnt: integer;
  t2m, td, slp, wdir, wspd, cld: real;
begin
  fpath0:='X:\Data_Oceanography\_Meteo\ISD\unzip\';
  flist:=TStringList.Create;

    flist.Clear;
    fdb.Name:='';
    FindFirst(fPath0+'*.*',faAnyFile, fdb);
     if (fdb.Name<>'') and (fdb.Name<>'.') then flist.Add(fdb.Name);
     while findnext(fdb)=0 do if (fdb.Name<>'..') then flist.Add(fdb.Name);

    for ff:=0 to flist.Count-1 do begin
      fname:=flist.Strings[ff];
      caption:=fname;
     // showmessage(fname);
      wmo:=StrToInt(copy(fname,1,5));

      with frmdm.q1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' select "id" from "station" where ');
         SQL.Add(' "wmocode"=:wmo ');
         ParamByName('wmo').AsInteger:=wmo;
       Open;
        if frmdm.q1.IsEmpty=false then
          absnum:=frmdm.q1.Fields[0].AsInteger else absnum:=-9;
       Close;
      end;

      if absnum=-9 then Continue;

      AssignFile(dat, fpath0+fname); reset(dat);
      repeat
        readln(dat, st);
        yy:=StrToInt(copy(st, 1, 4));
        mn:=StrToInt(copy(st, 6, 2));
        dd:=StrToInt(copy(st, 9, 2));
        hh:=StrToInt(copy(st, 12, 2));
        dat1:=EncodeDateTime(yy, mn, dd, hh, 0, 0, 0);

        t2m := StrToFloat(copy(st, 14, 6));
        if t2m<>-9999 then writepar('p_surface_air_temp_isd',absnum,dat1,t2m/10);

        td  := StrToFloat(copy(st, 20, 6));
        if td<>-9999 then writepar('p_dew_point_temp_isd',absnum,dat1,td/10);

        slp := StrToFloat(copy(st, 26, 6));
        if slp<>-9999 then writepar('p_sea_level_pressure_isd',absnum,dat1,slp/10);

        wdir:= StrToFloat(copy(st, 32, 6));
        if wdir<>-9999 then writepar('p_wind_direction_isd',absnum,dat1,wdir);

        wspd:= StrToFloat(copy(st, 38, 6));
        if wspd<>-9999 then writepar('p_wind_speed_isd',absnum,dat1,wspd/10);

        cld := StrToFloat(copy(st, 44, 6));
        if cld<>-9999 then writepar('p_cloud_code_isd',absnum,dat1,cld);

      until eof(dat);
      CloseFile(dat);
      frmdm.TR.commitretaining;

      ProgressTaskbar(ff, flist.Count);
      application.ProcessMessages;
    end;

 flist.Free;
 frmdm.TR.Commit;
 ProgressTaskbar(0,0);
end;


Procedure Tfrmload_isd.writepar(tbl:string; absnum: integer; DateCurr:TDateTime; val1:real);
begin
 { with frmdm.q1 do begin
       Close;
        SQL.Clear;
         SQL.Add(' Select * from "'+tbl+'"');
         SQL.Add(' where "station_id"=:ID and "date"=:dat1 ');
         ParamByName('ID').AsInteger:=absnum;
         ParamByName('dat1').Value:=DateCurr;
       Open;
     end;

       if frmdm.q1.IsEmpty=true then begin }
     try
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

     except
     end;
   //  end;
 // frmdm.TR.CommitRetaining;
end;


end.

