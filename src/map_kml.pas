unit map_kml;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
  Win32Int, ShlObj, InterfaceBase, ComObj,
  {$ENDIF}
  Classes, SysUtils, LCLIntf, Dialogs, main, dm;

procedure ExportKML_;


implementation


procedure ExportKML_;
Var
{$IFDEF WINDOWS}
  FTaskBarList: ITaskbarList3;
  AppHandle: THandle;
{$ENDIF}

f_out:text;
descr, coord, sep, stname, tbl_str, tbl, DataFile: string;
ID, WMO, yy1, yy2, cnt_tot, cnt_stn:integer;
prc:real;
bookmark:TBytes;
empty_fl:boolean;
begin

 {$IFDEF WINDOWS}
  AppHandle := TWin32WidgetSet(WidgetSet).AppHandle;
  FTaskBarList := CreateComObject(CLSID_TaskbarList) as ITaskbarList3;
 {$ENDIF}

 if not DirectoryExists(GlobalUnloadPath+'kml'+PathDelim) then
        CreateDir(GlobalUnloadPath+'kml'+PathDelim);

 try
  DataFile:=GlobalUnloadPath+'kml'+PathDelim+'stations.kml';
  AssignFile(f_out, DataFile); rewrite(f_out);

  Writeln(f_out, '<?xml version="1.0" encoding="UTF-8"?>');
  Writeln(f_out, '<kml xmlns="http://earth.google.com/kml/2.2">');
  Writeln(f_out, ' <Document>');
  Writeln(f_out, '   <Style id="WMO">');
  Writeln(f_out, '    <BalloonStyle>');
  Writeln(f_out, '      <text><![CDATA[');
  Writeln(f_out, '      <p><b><font color="red">$[name]</b></font></p>]]>');
  Writeln(f_out, '       $[description]');
  Writeln(f_out, '       </text>');
  Writeln(f_out, '    </BalloonStyle>');
  Writeln(f_out, '    <IconStyle>');
  Writeln(f_out, '      <color>#FF1400FF</color>'); //
  Writeln(f_out, '      <Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon>');
  Writeln(f_out, '    </IconStyle>');
  Writeln(f_out, '    <LabelStyle>');
  Writeln(f_out, '     <scale>0</scale>');
  Writeln(f_out, '    </LabelStyle>');
  Writeln(f_out, '   </Style>');
  Writeln(f_out, '   <Style id="NONWMO">');
  Writeln(f_out, '    <BalloonStyle>');
  Writeln(f_out, '      <text><![CDATA[');
  Writeln(f_out, '      <p><b><font color="red">$[name]</b></font></p>]]>');
  Writeln(f_out, '       $[description]');
  Writeln(f_out, '       </text>');
  Writeln(f_out, '    </BalloonStyle>');
  Writeln(f_out, '    <IconStyle>');
  Writeln(f_out, '      <color>#FF14F0FF</color>');
  Writeln(f_out, '      <Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon>');
  Writeln(f_out, '    </IconStyle>');
  Writeln(f_out, '    <LabelStyle>');
  Writeln(f_out, '     <scale>0</scale>');
  Writeln(f_out, '    </LabelStyle>');
  Writeln(f_out, '   </Style>');
  Writeln(f_out, '   <Style id="EMPTY">');
   Writeln(f_out, '    <BalloonStyle>');
   Writeln(f_out, '      <text><![CDATA[');
   Writeln(f_out, '      <p><b><font color="red">$[name]</b></font></p>]]>');
   Writeln(f_out, '       $[description]');
   Writeln(f_out, '       </text>');
   Writeln(f_out, '    </BalloonStyle>');
   Writeln(f_out, '    <IconStyle>');
   Writeln(f_out, '      <color>#50FFFFFF</color>');
   Writeln(f_out, '      <Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon>');
   Writeln(f_out, '    </IconStyle>');
   Writeln(f_out, '    <LabelStyle>');
   Writeln(f_out, '     <scale>0</scale>');
   Writeln(f_out, '    </LabelStyle>');
   Writeln(f_out, '   </Style>');

  bookmark:=frmdm.CDS.bookmark;
  frmdm.CDS.DisableControls;
  frmdm.CDS2.DisableControls;

  cnt_tot:=frmdm.CDS.RecordCount;

  cnt_stn:=0;
  frmdm.CDS.First;
  While not frmdm.CDS.Eof do begin
   ID:=frmdm.CDS.FieldByName('id').AsInteger;
   WMO:=frmdm.CDS.FieldByName('wmocode').AsInteger;
   stname:=frmdm.CDS.FieldByName('name').AsString;
   stname:=Stringreplace(stname,'<','',[rfReplaceAll]);
   stname:=Stringreplace(stname,'>','',[rfReplaceAll]);
   stname:=Stringreplace(stname,'&','',[rfReplaceAll]);

   frmmain.CDSNavigation;
   inc(cnt_stn);

  sep:=' &lt;br/&gt;';

  descr:='WMO code = '+inttostr(WMO)+sep+
         'ID = '+inttostr(ID)+sep+
         'Latitude = '    +Floattostr(frmdm.CDS.FieldByName('latitude').AsFloat)       +sep+
         'Longitude = '   +Floattostr(frmdm.CDS.FieldByName('longitude').AsFloat)      +sep+
         'Elevation = '   +Floattostr(frmdm.CDS.FieldByName('elevation').AsFloat)      +sep+
         'Country = '     +frmdm.CDS.FieldByName('countryname').AsString;


  coord:=Floattostr(frmdm.CDS.FieldByName('longitude').AsFloat)+', '+
         Floattostr(frmdm.CDS.FieldByName('latitude').AsFloat)+', '+
         Floattostr(frmdm.CDS.FieldByName('elevation').AsFloat);

  empty_fl:=true;
  if frmdm.CDS2.RecordCount>0 then begin
   tbl_str:='';
   frmdm.CDS2.First;
    While not frmdm.CDS2.Eof do begin
      tbl:=frmdm.CDS2.FieldByName('par').AsString;
      yy1:=frmdm.CDS2.FieldByName('yy_min').AsInteger;
      yy2:=frmdm.CDS2.FieldByName('yy_max').AsInteger;
      prc:=frmdm.CDS2.FieldByName('perc').AsFloat;
      tbl_str:=tbl_str+tbl+sep+Inttostr(yy1)+'->'+inttostr(yy2)+', '+floattostr(prc)+' %'+sep;
     frmdm.CDS2.Next;
    end;
   empty_fl:=false;
  end;

  if empty_fl=false then descr:=descr+sep+'==============='+sep+tbl_str;

  Writeln(f_out, '   <Placemark>');
  Writeln(f_out, '    <name>'+stname+'</name>');
  if WMO<>-9 then Writeln(f_out, '    <styleUrl>#WMO</styleUrl>');
  if WMO= -9 then Writeln(f_out, '    <styleUrl>#NONWMO</styleUrl>');
  if empty_fl=true then Writeln(f_out, '    <styleUrl>#EMPTY</styleUrl>');
  Writeln(f_out, '    <description>'+descr+'</description>');
  Writeln(f_out, '     <Point>');
  Writeln(f_out, '      <coordinates>'+coord+', 0</coordinates>');
  Writeln(f_out, '     </Point>');
  Writeln(f_out, '   </Placemark>');

  {$IFDEF WINDOWS}
  FTaskBarList.SetProgressState(AppHandle, TBPF_Normal);
  FTaskBarList.SetProgressValue(AppHandle, trunc(cnt_stn/cnt_tot*100), 100);
  {$ENDIF}

 frmdm.CDS.Next;
 end;
  Writeln(f_out, ' </Document>');
  Writeln(f_out, '</kml>');
  Closefile(f_out);
  OpenDocument(DataFile);
 Finally
  frmdm.CDS.bookmark:=bookmark;
  frmdm.CDS.EnableControls;
 end;
end;

end.

