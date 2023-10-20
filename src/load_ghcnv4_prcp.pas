unit load_ghcnv4_prcp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  DateUtils;

type

  { Tfrmload_ghcn_v4_prcp }

  Tfrmload_ghcn_v4_prcp = class(TForm)
    btnDuplicates: TButton;
    btnLoad: TButton;
    Button1: TButton;
    Button10: TButton;
    Button13: TButton;
    Button2: TButton;
    btnNewLongTimeseries: TButton;
    Button5: TButton;
    Button9: TButton;
    chkShowLog: TCheckBox;
    mLog: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure btnDuplicatesClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnNewLongTimeseriesClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private

  public

  end;

var
  frmload_ghcn_v4_prcp: Tfrmload_ghcn_v4_prcp;

implementation

{$R *.lfm}

uses main, dm, procedures;

{ Tfrmload_ghcn_v4_prcp }

procedure Tfrmload_ghcn_v4_prcp.btnLoadClick(Sender: TObject);
var
   fpath, fname, st: string;
   qcf1, qcf2, qcf3: string;
   dat:text;
   id, cnt, stat_cnt, mn, yy, fl: integer;
   dat1,date_max_db:TDateTime;
   val1:real;
begin

 if frmmain.ODD.Execute then fpath:=frmmain.ODD.FileName else exit;
// showmessage(fpath);

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
   fname:=fpath+PathDelim+frmdm.q1.FieldByName('ghcn_v4_prcp_id').Value+'.csv';

  // showmessage(fname);

   if (FileExists(fname)=true) then begin

   date_max_db:=EncodeDate(1, 1, 1);
    with frmdm.q3 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select max("date") from "p_precipitation_ghcn_v4" ');
      SQL.Add(' where "station_id"=:id ');
      ParamByName('id').Value:=id;
     Open;
       if frmdm.q3.IsEmpty=false then begin
         date_max_db:=frmdm.q3.Fields[0].AsDateTime;
       end;
     Close;
    end;

 //   showmessage(datetimetostr(date_max_db));

    Assignfile(dat, fname); reset(dat);
    repeat
      readln(dat, st);
      yy:=strtoint(copy(st, 84, 4));
      mn:=strtoint(copy(st, 88, 2));
      val1:=strtoint(trim(copy(st, 91, 6)))/10;

      qcf1:=trim(copy(st, 98, 1));
      qcf2:=trim(copy(st, 100, 1));
      qcf3:=trim(copy(st, 102, 1));

      if qcf2<>'' then fl:=1 else fl:=0;

      dat1:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

      if dat1>date_max_db then begin

//       showmessage(datetimetostr(dat1)+'   '+datetimetostr(date_max_db));

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
         ParamByName('pqf1').AsInteger:=fl;
         ParamByName('pqf2').AsInteger:=fl;
        ExecSQL;
      end;
      if chkShowLog.Checked then
       mLog.lines.add(inttostr(id)+'   '+
                       datetostr(dat1)+'   '+
                       floattostr(val1));
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

procedure Tfrmload_ghcn_v4_prcp.btnNewLongTimeseriesClick(Sender: TObject);
var
   k, md, wmo_id,cnt, old_id, wmo:integer;
   StLat, StLon, Elev, StLat_old, StLon_old, Elev_old: real;
   buf_str, ds570, FileForRead, ds_id :string;
   absnum, absnum1:integer;
   st,stName, stname_old, date1, date2:string;
   isempty:boolean;
   stdate1, stdate2, date_min, date_max:TDateTime;
   yy0, mn0, dd0, yy1, mn1, dd1, yy3, mn3, dd3: word;
begin

  with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add('select "id", "year_beg", "year_end", "wmo" ');
     SQL.Add('from "station_ghcn_v4_prcp" where "wmo"<>99999');
    Open;
  end;

  while not frmdm.q1.EOF do begin
    ds_id:=frmdm.q1.Fields[0].AsString;
    yy0:=frmdm.q1.Fields[1].AsInteger;
    yy1:=frmdm.q1.Fields[2].AsInteger;
    wmo:=frmdm.q1.Fields[3].AsInteger;

    decodedate(now, yy3, mn3, dd3);

    if (yy1-yy0>=30) and (yy3-yy1<=5) then begin

      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add('select "wmocode" from "station" where ');
         SQL.Add('"wmocode"=:wmo and "ghcn_v4_prcp_id"=:ds_id');
         SQL.Add('order by "wmocode"');
         Parambyname('wmo').AsInteger:=wmo;
         Parambyname('ds_id').AsString:=ds_id;
        Open;
      end;

      if frmdm.q2.IsEmpty then begin
       // showmessage(ds_id+'   '+inttostr(yy0)+'   '+inttostr(yy1));
        mLog.Lines.Add(inttostr(wmo)+'   '+ds_id+'   '+inttostr(yy0)+'   '+inttostr(yy1));
      end;

    end;
    frmdm.q1.Next;
  end;
  frmdm.q1.Close;
end;


procedure Tfrmload_ghcn_v4_prcp.Button10Click(Sender: TObject);
var
 dat: text;
 st, id_ghcn_st, id_prcp, fpath:string;
 fl:integer;
begin
  mLog.Clear;

  if frmmain.ODD.Execute then fpath:=frmmain.ODD.FileName else exit;
 showmessage(fpath);

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

   assignfile(dat, fpath);
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

procedure Tfrmload_ghcn_v4_prcp.Button13Click(Sender: TObject);
var
 absnum, id_ds570, country_id: integer;
 dat: text;
 st, id_ghcn, id_ds570_st, id_ghcn_st, stname, stname_ghcn, fpath:string;
 fl:integer;
begin
  mLog.Clear;

   if frmmain.ODD.Execute then fpath:=frmmain.ODD.FileName else exit;
 showmessage(fpath);

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

   assignfile(dat, fpath);
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


procedure Tfrmload_ghcn_v4_prcp.Button1Click(Sender: TObject);
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

procedure Tfrmload_ghcn_v4_prcp.Button2Click(Sender: TObject);
var
  wmo, absnum, country_id:integer;
   ghcn_id, wmo_st:string;
begin
  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select * from "station_ghcn_v4_prcp" ');
    SQL.Add(' where "wmo"<>-9 ');
   Open;
  end;

        frmdm.q2.Close;
      frmdm.q2.SQL.Text:='Select max("id") from "station"';
      frmdm.q2.Open;
       absnum:=frmdm.q2.Fields[0].AsInteger;
      frmdm.q2.Close;


  frmdm.q1.First;
  while not frmdm.q1.eof do begin
    ghcn_id:=frmdm.q1.FieldByName('id').Value;
    wmo:=frmdm.q1.FieldByName('wmo').Value;

    wmo_st:=inttostr(wmo);

   // showmessage(copy(ghcn_id, length(ghcn_id)-length(wmo_st), length(wmo_st)));

    if (copy(ghcn_id, length(ghcn_id)-length(wmo_st)+1, length(wmo_st)))=wmo_st then begin
     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Select "id" from "station" ');
       SQL.Add(' where "wmocode"='+inttostr(wmo));
      Open;
    end;

    if frmdm.q2.IsEmpty  then begin

    inc(absnum);

      country_id:=0;
      with frmdm.q2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select "id" from "country" ');
        SQL.Add(' where "ghcn"='+quotedstr(copy(ghcn_id, 1, 2)));
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
      ParamByName('WMONum').AsInteger:=frmdm.q1.FieldByName('wmo').Value;
      ParamByName('StLat').AsFloat:=frmdm.q1.FieldByName('latitude').Value;
      ParamByName('StLon').AsFloat:=frmdm.q1.FieldByName('longitude').Value;
      ParamByName('Elevation').AsFloat:=frmdm.q1.FieldByName('elevation').Value;
      ParamByName('StName').AsString:=frmdm.q1.FieldByName('name').Value;
      ParamByName('country_id').AsInteger:=country_id;
      ParamByName('ghcn_v4_prcp_id').AsString:=ghcn_id;
     ExecSQL;
   end;
     mLog.Lines.Add(inttostr(wmo)+'   '+ghcn_id);
   frmdm.TR.CommitRetaining;
 end; //writing;



    end;

    frmdm.q1.Next;
  end;
  frmdm.TR.CommitRetaining;


end;


procedure Tfrmload_ghcn_v4_prcp.btnDuplicatesClick(Sender: TObject);
var
vn:string;
 cnt:integer;
begin
  mLog.Clear;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select distinct("ghcn_v4_prcp_id"), count("ghcn_v4_prcp_id") ');
    SQL.Add(' from "station" group by "ghcn_v4_prcp_id"');
   Open;
  end;

   while not frmdm.q1.eof  do begin
      VN :=frmdm.q1.Fields[0].AsString;
      Cnt:=frmdm.q1.Fields[1].AsInteger;
       if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
     frmdm.q1.next;
   end;
end;

procedure Tfrmload_ghcn_v4_prcp.Button5Click(Sender: TObject);
Var
   fname, st, v2_id, name_state:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1, wmo, yy1, yy2:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
begin
 frmmain.OD.InitialDir:=GlobalPath+'data\';
 frmmain.OD.Filter:='ghcn-m_v4_prcp_inventory.txt|ghcn-m_v4_prcp_inventory.txt';

 if frmmain.OD.Execute then fname:=frmmain.OD.FileName else exit;

    AssignFile(datf, fname);
    reset(datf);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ghcn_v4_prcp" ');
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


procedure Tfrmload_ghcn_v4_prcp.Button9Click(Sender: TObject);
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

