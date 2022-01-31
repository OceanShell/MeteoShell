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
 ghcn_path:='Z:\MeteoShell\data\ghcn_v3\';
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
    numsrc:=StrToInt(trim(Copy(st, 4, 5)));

    if copy(st, 9, 3)='000' then begin
   // showmessage(trim(v2_id)+'   '+inttostr(numsrc));

    absnum:=-9;
    with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select "id" from "station"');
      SQL.Add(' where "wmocode"='+inttostr(numsrc));
      SQL.Add(' and "ghcn_v3_id" is null ');
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
             SQL.Add(' "ghcn_v3_id"='+trim(v2_id));
             SQL.Add(' where "id"='+inttostr(absnum));
           ExecSQL;
         end;
    end;

    end;

  until eof(datf);
  frmdm.TR.Commit;
end;


procedure Tfrmload_ghcn_v3.btnGHCN_v3_DataClick(Sender: TObject);
Var
 fname, st, tbl, numsrc, numsrc_old:string;
 k, ff, absnum, yy, mn, flag:integer;
 temp, val0:real;
 DateCurr:TDateTime;
 qcf1, qcf2, qcf3: string;
 towrite:boolean;
begin
for ff:=0 to ListBox1.Count-1 do begin
  fname:=ListBox1.Items.Strings[ff];

//  caption:=fname;
 // Application.ProcessMessages;

 if (copy (fname, 7, 4)='tmin') and (copy (fname, 28, 3)='qcu') then tbl:='p_surface_air_tempmin_ghcn_v3';
 if (copy (fname, 7, 4)='tmax') and (copy (fname, 28, 3)='qcu') then tbl:='p_surface_air_tempmax_ghcn_v3';
 if (copy (fname, 7, 4)='tavg') and (copy (fname, 28, 3)='qcu') then tbl:='p_surface_air_temp_ghcn_v3';

  AssignFile(datf, ghcn_path+fname);
  reset(datf);

//101603550001878TAVG  890  1  950  1 1110  1 1610  1 1980  1 2240  1 2490  1 2680  1 2320  1 2680 S1 1370  1 1150  1
//101603550001879TAVG 1180  1 1170  1 1220  1 1550  1 1560  1 2270  1 2400  1 2510  1 2240  1 1750  1 1450  1  900  1
 repeat
  readln(datf, st);

   numsrc:=trim(Copy(st,1,11));

   if numsrc<>numsrc_old then begin
   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "id" from "station"');
     SQL.Add(' where "ghcn_v3_id"='+numsrc);
    Open;
     if frmdm.q1.IsEmpty=false then
       absnum:=frmdm.q1.Fields[0].AsInteger else absnum:=-9;
    Close;
   end;

   if (absnum<>-9) then begin
    with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select "station_id" from "'+tbl+'"');
      SQL.Add(' where "station_id"='+inttostr(absnum));
     Open;
      towrite:=frmdm.q1.IsEmpty;
     Close;
    end;
    end else towrite:=false;
  end;

  if towrite=true then begin
   yy:=StrToInt(copy(st,12,4));

   k:=20;
   for mn:=1 to 12 do begin
    Datecurr:=EncodeDate(yy, mn, trunc(DaysInAMonth(yy, mn)/2));

    if copy(st,k,5)<>'-9999' then begin
     temp:=Strtoint(copy(st,k,5))/100;

     qcf1:=trim(copy(st, k+5, 1));
     qcf2:=trim(copy(st, k+6, 1));
     qcf3:=trim(copy(st, k+7, 1));

     if qcf2='' then flag:=0 else flag:=1;

     if frmdm.q1.IsEmpty=true then begin
      with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' insert into "'+tbl+'"');
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
      if chkoutput.Checked=true then begin
      memo1.lines.add('INSERTED: '+inttostr(absnum)+', '+
           inttostr(yy)+' '+inttostr(mn)+', '+floattostr(temp));
      Application.ProcessMessages;

      end;
     end; // there's no value
    end;
     k:=k+8;
   end;
     frmdm.TR.CommitRetaining;
   end; //is empty


  numsrc_old:=numsrc;
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

