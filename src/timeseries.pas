unit timeseries;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DB, sqldb, DBGrids, IniFiles,
  Menus, ComObj, CheckLst, Buttons, FileUtil, LCLTranslator;

type
  Tfrmtimeseries = class(TForm)
    rgPlotType: TRadioGroup;
    btnPlot: TButton;
    CheckListBox1: TCheckListBox;
    btnShowData: TBitBtn;


    procedure btnPlotClick(Sender: TObject);
    procedure rgPlotTypeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnShowDataClick(Sender: TObject);

  private

    { Private declarations }
    // procedure PlotAnnualMean;
     procedure GetMonthComposition;
     procedure GetSelectedMonth;

  public
    { Public declarations }
  end;

var
  frmtimeseries: Tfrmtimeseries;
  f_dat:text;
  tspath:string;

implementation

uses main, datamodule, viewdata, procedures, grapher;

{$R *.lfm}


procedure Tfrmtimeseries.FormShow(Sender: TObject);
begin
 tspath:=GlobalPath+'unload\timeseries\';
 //if frmViewData.PageControl1.PageIndex=1 then rgPlotType.;
end;

procedure Tfrmtimeseries.btnPlotClick(Sender: TObject);
begin
 case rgPlotType.ItemIndex of
//  0: PlotAnnualMean;
  1: GetSelectedMonth;
  2: GetMonthComposition;
 end;
end;


procedure Tfrmtimeseries.rgPlotTypeClick(Sender: TObject);
begin
 case rgPlotType.ItemIndex of
  0: CheckListBox1.Enabled:=false;
  1: CheckListBox1.Enabled:=true;
  2: CheckListBox1.Enabled:=false;
  3: CheckListBox1.Enabled:=false;
 end;
btnPlot.Enabled:=true;
Application.ProcessMessages;
end;


procedure Tfrmtimeseries.btnShowDataClick(Sender: TObject);
begin
  OpenDocument(PChar(tspath));
end;



procedure Tfrmtimeseries.GetMonthComposition;
var
k,count_ts,count:integer;
year,month:integer;
val,stlat,stlon,md,anom:real;
tsFile,tsFileA,mn,SetColor,GraphID,PlotID,ID,FitTitle,FitID,AxisTitleY:string;
xID,yID,txt:string;
mn_arr:array[1..12] of string;

stsource,stname,stcountry:string;
absnum,wmonum,wmonumsource:integer;
begin
{
 absnum:=MDBDM.CDS.FieldByName('ABSNUM').AsInteger;

   with MDBDM.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from ');
    SQL.Add(tblCurrent);
    SQL.Add(' where absnum=:absnum ');
    SQL.Add(' and month_=:month ');
    SQL.Add(' order by year_ ');
    Prepare;
   end;

    count_ts:=0;
for k:=1 to 12 do begin
    md:=0;
    count:=0;

   case k of
   1:  mn:='JAN';
   2:  mn:='FEB';
   3:  mn:='MAR';
   4:  mn:='APR';
   5:  mn:='MAY';
   6:  mn:='JUN';
   7:  mn:='JUL';
   8:  mn:='AUG';
   9:  mn:='SEP';
   10: mn:='OCT';
   11: mn:='NOV';
   12: mn:='DEC';
   end;


   with MDBDM.ib1q2 do begin
    ParamByName('absnum').AsInteger:=Absnum;
    ParamByName('month').AsInteger:=k;
    Open;
   end;

if MDBDM.ib1q2.IsEmpty=false then begin

   tsfile :=tspath+mn+'.dat';
   tsfileA:=tspath+mn+'a.dat';

   Application.ProcessMessages;

   assignfile(f_dat, tsfile);   rewrite(f_dat);
   assignfile(fA_dat,tsfileA); rewrite(fA_dat);
   writeln(f_dat ,'year value');
   writeln(fA_dat,'year anomaly');

   count_ts:=count_ts+1;
   mn_arr[count_ts]:=mn;

   while not MDBDM.ib1q2.Eof do begin
    year:=MDBDM.ib1q2.FieldByName('year_').AsInteger;
    val:=MDBDM.ib1q2.FieldByName('val_').AsFloat;
    Count:=Count+1;
    md:=md+val;

    writeln(f_dat,year:4,val:9:3);
    MDBDM.ib1q2.Next;
   end;
    MDBDM.ib1q2.Close;
    closefile(f_dat);

end;

if count>0 then begin
     md:=md/count;
     reset(f_dat);
     readln(f_dat);
    while not EOF(f_dat) do begin
     readln(f_dat, year, val);
     anom:=val-md;
     writeln(fA_dat,year:6,anom:9:4);
    end;
     closefile(f_dat);
     closefile(fA_dat);
end;
end;
    MDBDM.ib1q2.UnPrepare;

    {

   (* Строим серии в Графере *)
   if chkplottimeseries.Checked=true then begin
    if count_ts=0 then showmessage('There are no valid time series at station!')
  else begin


    Grapher:=CreateOLEObject('Grapher.Application');
    Grapher.Visible(1);
    Plot:=Grapher.Documents.Add(0);
    GraphID:='g1';

for k:=1 to count_ts do begin

    if CheckBox5.Checked then
     tsfile:=tspath+mn_arr[k]+'a.dat' else
     tsfile:=tspath+mn_arr[k]+'.dat';


    assignfile(f_dat,tsfile); reset(f_dat);


    case k of
    1: SetColor:='50% Black';
    2: SetColor:='30% Black';
    3: SetColor:='Brown';
    4: SetColor:='Green';
    5: SetColor:='Pink';
    6: SetColor:='Magenta';
    7: SetColor:='Red';
    8: SetColor:='Purple';
    9: SetColor:='Deep Yellow';
   10: SetColor:='Cyan';
   11: SetColor:='Blue';
   12: SetColor:='Black';
    end;

    GraphID:='MonthComp';
    PlotID:=mn_arr[k];
    ID:=concat(GraphID,':',PlotID);

    if CheckBox1.Checked then begin
    Plot.CreateLinePlot(GraphID,PlotID,tsfile,,1,2,,,,,,,,,1,,0.001,10,SetColor);
    Plot.SetObjectLineProps(ID,SetColor,'.1 in. Dash',0.005);
    end
    else begin
    Plot.CreateLinePlot(GraphID,PlotID,tsfile,,1,2,,,,,,,,,0,,0.001,10,SetColor);
    Plot.SetObjectLineProps(ID,SetColor,'Invisible',0.005);
    end;


    if CheckBox2.Checked then begin
    FitTitle:=concat(PlotID,'_RAv',inttostr(RunAvStep));
    FitID:=concat(GraphID,':',FitTitle);
    Plot.CreateFit(ID,FitTitle,1,8,5);
    Plot.SetObjectLineProps(FitID,SetColor,'Solid',0.03);
    end;

    //lenear fit
    if CheckBox3.Checked then begin
    FitTitle:=concat(PlotID,'_L');
    FitID:=concat(GraphID,':',FitTitle);
    Plot.CreateFit(ID,FitTitle,1,0);
    Plot.SetObjectLineProps(FitID,SetColor,'.1 in. Dash',0.03);
    end;

     xID:=concat(GraphID,':','X Axis 1');
     yID:=concat(GraphID,':','Y Axis 1');
     Plot.PositionAxis(xID,0,12,3,3);
     Plot.PositionAxis(yID,0,20,3,3);

     if CheckBox5.Checked
     then
     AxisTitleY:=copy(tblCurrent,3,length(tblCurrent))+' Anomalies'
     else
     AxisTitleY:=copy(tblCurrent,3,length(tblCurrent));

     Plot.EditAxis(xID,1,,'Years',   'Times New Roman',12,,1);
     Plot.EditAxis(yID,1,,AxisTitleY,'Times New Roman',12,,1);

    closefile(f_dat);
end;

    WMOnum      :=MDBDM.CDS.FieldByName('wmonum').AsInteger;
    WMOnumSource:=MDBDM.CDS.FieldByName('wmonum').AsInteger;
    StSource    :=MDBDM.CDS.FieldByName('StSource').AsString;
    StLat       :=MDBDM.CDS.FieldByName('StLat').AsFloat;
    StLon       :=MDBDM.CDS.FieldByName('StLon').AsFloat;
    StName      :=MDBDM.CDS.FieldByName('StName').AsString;
    StCountry   :=MDBDM.CDS.FieldByName('StCountry').AsString;


    txt:='wmonum : '+inttostr(WMOnum)+'  wmonum (datasource): '+inttostr(WMOnumSource);
    Plot.DrawText(2.5,26.5,txt);
    txt:='StName :  '+StName;
    Plot.DrawText(2.5,26,txt);
    txt:='Country:  '+StCountry;
    Plot.DrawText(2.5,25.5,txt);
    txt:='Source :  '+StSource;
    Plot.DrawText(2.5,25,txt);
    txt:='Lat    :  '+floattostr(StLat);
    Plot.DrawText(2.5,24.5,txt);
    txt:='Lon    :  '+floattostr(StLon);
    Plot.DrawText(2.5,24,txt);
    Plot.DrawRectangle(2.3,26.6,15,23.5,'TextBox1');

    Plot.Select(GraphID);
    Plot.AddLegendEntry('Legend','JAN',,,,,'Custom',0.2);
    Plot.CreateLegend(ID,'Legend',18,14);
    Plot.AddLegendEntry('Legend','FEB',,,,,'Custom',0.2);
    Plot.Maximize;
    Plot.ViewFitToWindow;
end;
end;
(* Конец построения серий *)   }
end;



procedure Tfrmtimeseries.GetSelectedMonth;
var
i,ky,km,count,countYear,countMonth,count_md:integer;
month,currentYear,currentMonth,year:integer;
md,md_ts,val,anom,stlat,stlon:real;
abbr,ID,AxisTitleY:string;
Month_arr :array[0..12] of integer; {first month - december last year}
stsource,stname,stcountry, tsfile, tsfilea, clr:string;
currentabsnum, wmonum,wmonumsource, ymax, ymin, ci, RunAvStep:integer;
begin
 //  RunAvStep:=strtoint(edit1.Text);
   currentabsnum:=dm.CDS.FieldByName('ABSNUM').AsInteger;

//   ci:=frmselection.StringGrid1.Row;
 //  ymax:=StrToInt(frmselection.StringGrid1.Cells[3,ci]);
 //  ymin:=StrToInt(frmselection.StringGrid1.Cells[2,ci]);

{
   with dm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from ');
    SQL.Add(tblCurrent);
    SQL.Add(' where absnum=:absnum and year_=:year ');
    Prepare;
   end;

   with dm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from ');
    SQL.Add(tblCurrent);
    SQL.Add(' where absnum=:absnum and year_=:LastYear ');
    SQL.Add(' and month_=12 ');
    Prepare;
   end;

    count:=0;
    count_md:=0;
    abbr:='';
for i:=0 to CheckListBox1.Items.Count-1 do begin
   if CheckListBox1.Checked[i] then begin
    count:=count+1;
    month_arr[count-1]:=i;   // {last december -> zero index

    abbr:=abbr+copy(CheckListBox1.Items.Strings[i],1,1);

   end;
end;
   //label1.Caption:=inttostr(count);
  // label2.Caption:=abbr;
   Application.ProcessMessages;
   if count=0 then begin
    showmessage('Month not selected!');
    exit;
   end;

    WMOnum      :=dm.CDS.FieldByName('wmonum').AsInteger;
    WMOnumSource:=dm.CDS.FieldByName('wmonum').AsInteger;
    StSource    :=dm.CDS.FieldByName('StSource').AsString;
    StLat       :=dm.CDS.FieldByName('StLat').AsFloat;
    StLon       :=dm.CDS.FieldByName('StLon').AsFloat;
    StName      :=dm.CDS.FieldByName('StName').AsString;
    StCountry   :=dm.CDS.FieldByName('StCountry').AsString;


   if not DirectoryExistsUTF8(tsPath)  then CreateDirUTF8(tsPath);

   stname:=stringreplace(stname, '/', '_', [rfReplaceAll, rfIgnoreCase]);
   stname:=stringreplace(stname, '\', '_', [rfReplaceAll, rfIgnoreCase]);

   tsFile :=concat(tspath,inttostr(wmonum),'_',StName,'_',abbr,'.dat');
   tsFileA:=concat(tspath,inttostr(wmonum),'_',StName,'_',abbr,'_anom.dat');
  // showmessage(tsfile);

   //lboutput.Caption:='Output: '+tsFile;
   Application.ProcessMessages;

   assignfile(f_dat,tsFile); rewrite(f_dat);
   assignfile(fA_dat,tsFileA); rewrite(fA_dat);
   writeln(f_dat, 'year':5, 'md':10);
   writeln(fA_dat,'year':5, 'mdAnomaly':10, 'colour':10);

    CountYear:=ymax-ymin+1;
for ky:=1 to CountYear do begin
    CurrentYear:=ymin+(ky-1);

   with dm.Ib1q2 do begin
    ParamByName('absnum').AsInteger:=CurrentAbsnum;
    ParamByName('lastyear').AsInteger:=CurrentYear-1;
    Open;
   end;

   with dm.ib1q2 do begin
    ParamByName('absnum').AsInteger:=CurrentAbsnum;
    ParamByName('year').AsInteger:=CurrentYear;
    Open;
   end;

    countMonth:=0;
    md:=0;

   if dm.Ib1q2.IsEmpty=false then begin
   for km:=0 to count-1 do begin
   if (month_arr[km]=0) then begin
     CountMonth:=CountMonth+1;
    md:=md+dm.Ib1q2.FieldByName('val_').asFloat;
   end;
   end;
   end;
    dm.Ib1q2.Close;

   while not dm.ib1q2.Eof do begin
    month:=dm.ib1q2.FieldByName('month_').asInteger;
   for km:=0 to count-1 do begin
   if month_arr[km]=month then begin
    countMonth:=countMonth+1;
    md:=md+dm.ib1q2.FieldByName('val_').asFloat;
   end;
   end;
    dm.ib1q2.Next;
   end;
    dm.ib1q2.Close;

   if countMonth=count then begin
    md:=md/count;
    count_md:=count_md+1;
    md_ts:=md_ts+md;
   // memo1.Lines.Add(inttostr(currentYear)+#9+floattostrF(md,ffFixed,7,3));
    writeln(f_dat,currentYear:5,md:10:4);
   end;

end;
    closefile(f_dat);
    dm.ib1q2.UnPrepare;
    dm.Ib1q3.UnPrepare;


if count_md>0 then begin
     md_ts:=md_ts/count_md;
     reset(f_dat);
     readln(f_dat);
    while not EOF(f_dat) do begin
     readln(f_dat, year, val);
     anom:=val-md_ts;
      if anom>=0 then clr:='red' else clr:='blue';
     writeln(fA_dat,year:5, anom:10:4, clr:10);
    end;
    closefile(f_dat);
    closefile(fA_dat);
end;
}
end;


end.
