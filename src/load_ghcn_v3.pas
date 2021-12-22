unit load_ghcn_v3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, BufDataset, DB, LCLTranslator, ExtCtrls, DateUtils;

type

  { Tfrmload_ghcn_v3 }

  Tfrmload_ghcn_v3 = class(TForm)
    btnGHCN_v3_Data: TButton;
    btnGHCN_v3_MD: TButton;
    Button1: TButton;
    Button5: TButton;
    Button6: TButton;
    chkOutput: TCheckBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Splitter1: TSplitter;

    procedure btnGHCN_v3_DataClick(Sender: TObject);
    procedure btnGHCN_v3_MDClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmload_ghcn_v3: Tfrmload_ghcn_v3;
  fi_dat:text;
  datf,datf2:text;
  ghcn_path:string;

implementation

{$R *.lfm}

uses main, dm, procedures;

{ Tfrmload_ghcn_v3 }


procedure Tfrmload_ghcn_v3.FormShow(Sender: TObject);
Var
fdb:TSearchRec;
begin
 ghcn_path:='Y:\MeteoShell\data\ghcn\v3\ghcnm.v3.3.0.20190817\'; //GlobalPath+'data\ghcn_monthly\v3\';
   fdb.Name:='';
   listbox1.Clear;
    FindFirst(ghcn_path+'*.dat',faAnyFile, fdb);
    if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
     while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
   FindClose(fdb);

   if listbox1.Count>0 then btnGHCN_v3_Data.Enabled:=true else btnGHCN_v3_Data.Enabled:=false;
end;




procedure Tfrmload_ghcn_v3.btnGHCN_v3_MDClick(Sender: TObject);
Var
 st, st2, stname, country, source, ccode, buf_str:string;
 k, i, int_id, wmssc, wmonum, absnum, numsrc:integer;
 stlat, stlon, elev:real;
begin

  { CDS:=TClientDataSet.Create(nil);
   with CDS.FieldDefs do begin
    Add('int_id',  ftInteger ,0,true);
    Add('stname',  ftString  , 40);
    Add('country', ftString  , 40);
    Add('stlat',   ftFloat   ,0,true);
    Add('stlon',   ftFloat   ,0,true);
    Add('elev' ,   ftFloat   ,0,true);
    Add('wmonum',  ftInteger ,0,true);
   end;
    CDS.CreateDataSet;
    CDS.LogChanges:=false;

//10160355000  36.9300    6.9500    7.0 SKIKDA                           18U  107HIxxCO 1x-9WARM DECIDUOUS  C
//10160360000  36.8300    7.8200    4.0 ANNABA                           33U  256FLxxCO 1A 7WARM CROPS      C

 repeat
  readln(datf, st);
  inc(k);

   ccode:=trim(Copy(st,1,3));
   numsrc:=StrToInt(trim(Copy(st,4,8)));
   if Copy(st,9,3)='000' then  wmonum:=StrToInt(trim(Copy(st,4,5))) else wmonum:=-9;

    AssignFile(datf2, GlobalPath+'\Data\ghcn\country-codes'); reset(datf2);
    repeat
      readln(datf2, st2);
      if copy(st2,1,3)=ccode then country:=trim(copy(st2, 5,40));
    until (copy(st2,1,3)=ccode) or eof(datf2);
    CloseFile(datf2);

   stlat  :=StrToFloat(trim(Copy(st,13,8)));
   stlon  :=StrToFloat(trim(Copy(st,22,9)));
   elev   :=StrToFloat(trim(Copy(st,32,6)));

   i:=38; stname:='';
   repeat
    inc(i);
    stname:=stname+st[i];
   until (copy(stname, length(stname)-2, 2)='  ') or (i=69);
   stname:=Uppercase(trim(stname));

   CDS.Append;
    CDS.FieldByName('int_id').AsInteger:=numsrc;
    CDS.FieldByName('stname').Asstring:=UpperCase(stname);
    CDS.FieldByName('country').Asstring:=UpperCase(country);
    CDS.FieldByName('stlat').AsFloat:=stlat;
    CDS.FieldByName('stlon').AsFloat:=stlon;
    CDS.FieldByName('elev').AsFloat:=elev;
    CDS.FieldByName('wmonum').AsInteger:=wmonum;
   CDS.Post;
 //  end;
  until eof(datf);
 CloseFile(datf);

// showmessage('good');

 if chkOutput.Checked=true then begin
   absnum:=0;
   CDS.First;
   for k:=0 to CDS.RecordCount-1 do begin
   inc(absnum);
    with dm.ib1qq1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' insert into STATION  ');
      SQL.Add(' (absnum, WMONum, WMONumSource, StSource, StLat, StLon, ');
      SQL.Add('  StName, StCountry, elevation) ');
      SQL.Add(' values ');
      SQL.Add(' (:absnum, :WMONum, :WMONumSource, :StSource, :StLat, :StLon, ');
      SQL.Add('  :StName, :StCountry, :elevation) ');
      ParamByName('absnum').AsInteger  :=absnum;
      ParamByName('WMONum').AsInteger  :=CDS.FieldByName('wmonum').AsInteger;
      ParamByName('WMONumSource').AsInteger:=CDS.FieldByName('int_id').AsInteger;
      ParamByName('StSource').AsString :='GHCN';
      ParamByName('StLat').AsFloat     :=CDS.FieldByName('stlat').AsFloat;
      ParamByName('StLon').AsFloat     :=CDS.FieldByName('stlon').AsFloat;
      ParamByName('Elevation').AsFloat :=CDS.FieldByName('elev').AsFloat;
      ParamByName('StName').AsString   :=CDS.FieldByName('stname').Asstring;
      ParamByName('StCountry').AsString:=CDS.FieldByName('country').Asstring;
     ExecQuery;
   end;
    CDS.Next;
   end;
    dm.IBTransaction1.CommitRetaining;  }
end;


procedure Tfrmload_ghcn_v3.btnGHCN_v3_DataClick(Sender: TObject);
Var
 fname, st, tbl:string;
 k, ff, absnum, yy, mn, numsrc:integer;
 temp, val0:real;
 DateCurr:TDateTime;
begin
for ff:=0 to ListBox1.Count-1 do begin
  fname:=ListBox1.Items.Strings[ff];

//  caption:=fname;
 // Application.ProcessMessages;


   if (copy (fname, 7, 4)='tmin') and (copy (fname, 28, 3)='qca') then tbl:='p_tmin_qca_ghcn_v330';
   if (copy (fname, 7, 4)='tmin') and (copy (fname, 28, 3)='qcu') then tbl:='p_tmin_qcu_ghcn_v330';
   if (copy (fname, 7, 4)='tmax') and (copy (fname, 28, 3)='qca') then tbl:='p_tmax_qca_ghcn_v330';
   if (copy (fname, 7, 4)='tmax') and (copy (fname, 28, 3)='qcu') then tbl:='p_tmax_qcu_ghcn_v330';

  AssignFile(datf, ghcn_path+fname);
  reset(datf);

//101603550001878TAVG  890  1  950  1 1110  1 1610  1 1980  1 2240  1 2490  1 2680  1 2320  1 2680 S1 1370  1 1150  1
//101603550001879TAVG 1180  1 1170  1 1220  1 1550  1 1560  1 2270  1 2400  1 2510  1 2240  1 1750  1 1450  1  900  1
 repeat
  readln(datf, st);

   numsrc:=StrToInt(trim(Copy(st,4,8)));

   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station"');
     SQL.Add(' where "ghcn_v3_id"='+inttostr(numsrc));
    Open;
     if frmdm.q1.IsEmpty=false then
       absnum:=frmdm.q1.Fields[0].AsInteger else absnum:=-9;
    Close;
   end;

   if absnum<>-9 then begin
   yy:=StrToInt(copy(st,12,4));

   k:=20;
   for mn:=1 to 12 do begin
    Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

    if copy(st,k,5)<>'-9999' then begin
     temp:=Strtoint(copy(st,k,5))/100;

     if frmdm.q1.IsEmpty=true then begin
      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "'+tbl+'"');
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
    end;
     k:=k+8;
   end;
   end; // station is in the DB

  frmdm.TR.CommitRetaining;
 until eof(datf);
 closefile(datf);
end;
end;


procedure Tfrmload_ghcn_v3.Button3Click(Sender: TObject);
Var
  CDS:TBufDataSet;
  code1, name1, fileforread, buf_str, ID:string;
begin
{  frmmain.OD.InitialDir:=GlobalPath+'data\';
  frmmain.OD.Filter:='txt|*.txt';

  if frmmain.OD.Execute then FileForRead:=frmmain.OD.FileName else exit;


 CDS:=TBufDataSet.Create(self);
 With CDS.FieldDefs do begin
   Add('code' ,ftstring, 2, false);
   Add('name' ,ftstring, 256, false);
 end;
 CDS.CreateDataSet;

 AssignFile(fi_dat,FileForRead); reset(fi_dat);
  repeat
  readln(fi_dat, buf_str);
    CDS.Append;
     CDS.FieldByName('code').AsString:=trim(copy(buf_str, 1, 2));
     CDS.FieldByName('name').AsString:=UpperCase(trim(copy(buf_str, 3, length(buf_str))));
    CDS.Post;
  until eof(fi_dat);
 CloseFile(fi_dat);

  with dm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from STATION where ');
    SQL.Add(' GHCN_V4_ID<>'+quotedstr('-9')+' order by absnum ');
   Open;
  end;

  dm.q1.First;
  while not dm.q1.EOF do begin
   //  showmessage(dm.q1.FieldByName('GHCN_V4_ID').AsVariant);
   ID:=dm.q1.FieldByName('GHCN_V4_ID').AsString;
   code1:=copy(ID, 1, 2);


  if CDS.Locate('code',code1, [loCaseInsensitive])=true then begin
      with dm.q2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' update STATION set stcountry=:name1 ');
        SQL.Add(' where absnum=:absnum ');
        ParamByName('absnum').AsInteger:=dm.q1.FieldByName('absnum').AsInteger;
        ParamByName('name1').AsString:=CDS.FieldByName('name').asstring;
       ExecSQL;
      end;
     dm.TR.CommitRetaining;
   end;

    dm.q1.next;
   end;
 { if TryStrToInt(trim(copy(buf_str, 81, 5)), wmo)  then wmo:=StrToInt(trim(copy(buf_str, 81, 5))) else wmo :=-9;
          if wmo<>-9 then begin
            with dm.q1 do begin
             Close;
              SQL.Clear;
              SQL.Add(' select * from STATION where ');
              SQL.Add(' wmonum=:wmo ');
              ParamByName('wmo').Asinteger:=wmo;
             Open;
         end;
   //  if (dm.q1.isempty=false) and (dm.q1.Fields[0].AsString<>ID) then
     if (dm.q1.isempty=false) and (dm.q1.FieldByName('GHCN_v4_ID').AsString='-9') then begin
         with dm.q2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' update STATION set GHCN_V4_ID=:ID ');
            SQL.Add(' where absnum=:absnum ');
            ParamByName('absnum').AsInteger:=dm.q1.FieldByName('absnum').AsInteger;
            ParamByName('ID').AsString:=id;
           ExecSQL;
          end;
          dm.IBTransaction1.CommitRetaining;
         end;

      if (dm.q1.isempty=false) and (dm.q1.FieldByName('ELEVATION').AsFloat=-999) then begin
         with dm.q2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' update STATION set ELEVATION=:elev ');
            SQL.Add(' where absnum=:absnum ');
            ParamByName('absnum').AsInteger:=dm.q1.FieldByName('absnum').AsInteger;
            ParamByName('elev').AsFloat:=elev;
           ExecSQL;
          end;
          dm.IBTransaction1.CommitRetaining;
         end;

      //  memo1.lines.add(inttostr(WMO)+'   '+ID+'   '+dm.q1.Fields[0].AsString);
     //  if dm.q1.isempty=true then memo1.lines.add(inttostr(WMO)+'   '+ID);
    end; }      }
end;



procedure Tfrmload_ghcn_v3.Button5Click(Sender: TObject);
Var
 wmo_id, ghcn_id:integer;
begin
{  with dm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from station where ');
    SQL.Add(' ghcn_v3_id<>-9 ');
   Open;
  end;

  while not dm.q1.eof do begin
    wmo_id :=dm.q1.FieldByName('WMONUM').AsInteger;
    ghcn_id:=dm.q1.FieldByName('GHCN_V3_ID').AsInteger;
     if wmo_id*1000<>ghcn_id then
      memo1.lines.add(inttostr(wmo_id)+'->'+inttostr(ghcn_id));
    dm.q1.Next;
  end;
  dm.q1.Close;
end;



procedure Tfrmload_ghcn_v3.Button6Click(Sender: TObject);
Var
 wmo_id, ghcn_id:integer;
 ghcn_id_str: utf8string;
begin
  with dm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from station where ');
    SQL.Add(' ghcn_v4_id<>'+Quotedstr('-9'));
   Open;
  end;

  while not dm.q1.eof do begin
    wmo_id :=dm.q1.FieldByName('WMONUM').AsInteger;
    ghcn_id_str:=copy(dm.q1.FieldByName('GHCN_V4_ID').AsString, 4, 8);
    ghcn_id:=strtoint(ghcn_id_str);
     if wmo_id<>ghcn_id then
      memo1.lines.add(inttostr(wmo_id)+'->'+ghcn_id_str);
    dm.q1.Next;
  end;
  dm.q1.Close;  }
end;



procedure Tfrmload_ghcn_v3.Button1Click(Sender: TObject);
Var
   fname, st, v2_id:string;
   StLat, StLon, Elev: real;
   buf_str, ID, ds570, FileForRead :string;
   absnum, absnum1:integer;
   stName, date1, date2, stcountry:string;
   datf:text;
   grelev, popsiz, ocndis, towndis:integer;
   popcls, topo, stveg, stloc, airstn, grveg, popcss   : string;
begin
    fname:='Z:\MeteoShell\data\ghcn_v3\ghcnm.tavg.v3.3.0.20181115.qca.inv';
    AssignFile(datf, fname);
    reset(datf);

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Delete from "station_ghcn_v3" ');
   ExecSQL;
  end;
  frmdm.TR.Commit;

   repeat
    readln(datf, st);

     v2_id :=Copy(st, 1, 11);
     stlat:=strtofloat(trim(Copy(st, 13, 7)));
     stlon:=strtofloat(trim(Copy(st, 22, 8)));
     elev:= strtofloat(trim(Copy(st, 32, 6)));
     stname:=trim(Copy(st, 39, 30));

     popcls:=trim(Copy(st, 74, 1));
     topo:=trim(Copy(st, 80, 2));
     stveg:=trim(Copy(st, 82, 2));
     stloc:=trim(Copy(st, 84, 2));
     airstn:=trim(Copy(st, 88, 1));
     grveg:=trim(Copy(st, 91, 16));
     popcss:=trim(Copy(st, 107, 1));

     if trystrtoint(trim(Copy(st, 75, 5)), grelev) then grelev:= strtoint(trim(Copy(st, 70, 4))) else grelev :=-9;
     if trystrtoint(trim(Copy(st, 75, 5)), popsiz) then popsiz:= strtoint(trim(Copy(st, 75, 5))) else popsiz :=-9;
     if trystrtoint(trim(Copy(st, 86, 2)), ocndis) then ocndis:= strtoint(trim(Copy(st, 86, 2))) else ocndis :=-9;
     if trystrtoint(trim(Copy(st, 89, 2)), towndis) then towndis:= strtoint(trim(Copy(st, 89, 2))) else towndis :=-9;

     with frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "station_ghcn_v3"  ');
         SQL.Add(' ("id", "latitude", "longitude", "elevation", "name", ');
         SQL.Add(' "grelev", "popcls", "topo", "stveg", "stloc", "airstn", "grveg", ');
         SQL.Add(' "popcss", "popsiz", "ocndis", "towndis") ');
         SQL.Add(' values ');
         SQL.Add(' (:absnum, :StLat, :StLon, :Elevation, :StName, ');
         SQL.Add('  :grevel, :popcls, :topo, :stveg, :stloc, :airstn, :grveg, ');
         SQL.Add('  :popcss, :popsiz, :ocndis, :towndis) ');
         ParamByName('absnum').AsString:=v2_id;
         ParamByName('StLat').AsFloat:=StLat;
         ParamByName('StLon').AsFloat:=StLon;
         ParamByName('Elevation').AsFloat:=Elev;
         ParamByName('StName').AsString:=stName;
         ParamByName('grevel').Value:=grelev;
         ParamByName('popcls').Value:=popcls;
         ParamByName('topo').Value:=topo;
         ParamByName('stveg').Value:=stveg;
         ParamByName('stloc').Value:=stloc;
         ParamByName('airstn').Value:=airstn;
         ParamByName('grveg').Value:=grveg;
         ParamByName('popcss').Value:=popcss;
         ParamByName('popsiz').Value:=popsiz;
         ParamByName('ocndis').Value:=ocndis;
         ParamByName('towndis').Value:=towndis;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

   until eof(datf);
   frmdm.TR.Commit;
end;



procedure Tfrmload_ghcn_v3.Button6Click(Sender: TObject);
Var
 fname, st, v2_id:string;
 numsrc,  absnum: integer;
 datf:text;
begin
  fname:='Z:\MeteoShell\data\ghcn_v3\ghcnm.tavg.v3.3.0.20181115.qca.inv';

  AssignFile(datf, fname);
  reset(datf);


 repeat
  readln(datf, st);

   v2_id :=Copy(st, 1, 11);
   numsrc:=StrToInt(trim(Copy(st, 4, 8)));

   absnum:=-9;
   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station"');
     SQL.Add(' where "ghcn_v3_id"='+inttostr(numsrc));
    Open;
     if frmdm.q1.IsEmpty=false then begin
      absnum:=frmdm.q1.Fields[0].AsInteger;
     end;
   end;

   if (absnum<>-9)  then begin
    // showmessage(inttostr(absnum));
           with frmdm.q2 do begin
          Close;
            SQL.Clear;
            SQL.Add(' update "station" set ');
            SQL.Add(' "ghcn_v3_id"='+trim(v2_id));
            SQL.Add(' where "id"='+inttostr(absnum));
          ExecSQL;
        end;
   end;


 until eof(datf);
 frmdm.TR.Commit;
end;

end.

