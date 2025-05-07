unit tool_monthlymatrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, StdCtrls, bufdataset, db, math, types, variants, IniFiles,
  LCLTranslator, DBGrids, Grids, ExtCtrls, Spin,SQLDB, lclintf,
  TAGraph, TASeries, TACustomSeries, TAChartUtils, TATools, TATypes,
  TAChartListbox, TASources;

type

  { Tfrmmonthlymatrix }

  Tfrmmonthlymatrix = class(TForm)
    btnPlotAllMonth: TMenuItem;
    CalculatedChartSource1: TCalculatedChartSource;
    Chart1: TChart;
    chkShowOutliers: TCheckBox;
    clbViewData: TChartListbox;
    cts: TChartToolset;
    ctsDPH: TDataPointHintTool;
    ctsDPC: TDataPointClickTool;
    ctsZDT: TZoomDragTool;
    GroupBox3: TGroupBox;
    pPlot: TPanel;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    MenuItem2: TMenuItem;
    btnPlotColumn: TMenuItem;
    PageControl1: TPageControl;
    Panel2: TPanel;
    Panel3: TPanel;
    PM: TPopupMenu;
    rgPlotType: TRadioGroup;
    seClip2: TSpinEdit;
    Series1: TLineSeries;
    seClip1: TSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tabValues: TTabSheet;
    tabAnomalies: TTabSheet;
    ToolBar1: TToolBar;
    btnSave: TToolButton;

    procedure btnSaveClick(Sender: TObject);
    procedure chkShowOutliersClick(Sender: TObject);
    procedure ctsDPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure ctsDPHHint(ATool: TDataPointHintTool; const APoint: TPoint;
      var AHint: String);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid2CellClick(Column: TColumn);
    procedure DBGrid2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnPlotAllMonthClick(Sender: TObject);
    procedure btnPlotColumnClick(Sender: TObject);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure MenuItem2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure PageControl1Change(Sender: TObject);
    procedure PMPopup(Sender: TObject);
    procedure rbSelectedMonthChange(Sender: TObject);
    procedure rgPlotTypeClick(Sender: TObject);
    procedure seClip1Change(Sender: TObject);
    procedure seClip2Change(Sender: TObject);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string; AWidth:integer):TLineSeries;
    procedure MoveToCol(aCol: PtrInt);
  public
    { public declarations }
    procedure GetData(table_id:integer);
    procedure CDSMatrixNavigation;
  end;

var
  frmmonthlymatrix: Tfrmmonthlymatrix;
  CDSViewValues, CDSViewAnomalies:TBufDataSet;
  DSViewValues, DSViewAnomalies:TDataSource;
  tspath, units:string;

implementation

{$R *.lfm}

{ Tfrmmonthlymatrix }

uses main, dm, procedures, script_grapher;


function Tfrmmonthlymatrix.AddLineSeries(AChart: TChart;
  ATitle: String; AColor:TColor; sName:string; AWidth:integer): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    Title := ATitle;
    ShowPoints := true;
    ShowLines := true;
    LinePen.Style := psSolid;
    LinePen.Width:=AWidth;
    SeriesColor := AColor;
    Pointer.Brush.Color := AColor;
    Pointer.Pen.Color := AColor;
    Pointer.Style := psCircle;
    Pointer.HorizSize:=AWidth+1;
    Pointer.VertSize:=AWidth+1;
    Name := sName;
    ToolTargets := [nptPoint, nptXList, nptCustom];
  end;
 AChart.AddSeries(Result);
end;


procedure Tfrmmonthlymatrix.FormShow(Sender: TObject);
Var
  k:integer;
  Ini: TIniFile;
begin
 tspath:=GlobalUnloadPath+'timeseries'+PathDelim;
   if not DirectoryExists(tspath) then CreateDir(tspath) else ClearDir(tspath);

 (* CDS for values *)
 CDSViewValues:=TBufDataSet.Create(self);
 With CDSViewValues.FieldDefs do begin
   Add('yy', ftinteger, 0, false);
     for k:=1 to 12 do Add(inttostr(k)   ,ftfloat, 0, false);
   Add('13', ftFloat  , 0, false);
 end;
 CDSViewValues.CreateDataSet;
 CDSViewValues.IndexFieldNames:='yy';

 DSViewValues:=TDataSource.Create(self);
 DSViewValues.DataSet:=CDSViewValues;

 DBGrid1.DataSource:=DSViewValues;

 (* CDS for anomalies *)
 CDSViewAnomalies:=TBufDataSet.Create(self);
 With CDSViewAnomalies.FieldDefs do begin
   Add('yy'   ,ftinteger, 0, false);
   for k:=1 to 12 do
   Add(inttostr(k)   ,ftfloat, 0, false);
   Add('13' ,ftFloat  , 0, false);
 end;
 CDSViewAnomalies.CreateDataSet;

 DSViewAnomalies:=TDataSource.Create(self);
 DSViewAnomalies.DataSet:=CDSViewAnomalies;
 DBGrid2.DataSource:=DSViewAnomalies;

 With DBGrid1 do begin
   Columns[0].Title.Caption :=SYear;
   Columns[1].Title.Caption :=SJAN;
   Columns[2].Title.Caption :=SFEB;
   Columns[3].Title.Caption :=SMAR;
   Columns[4].Title.Caption :=SAPR;
   Columns[5].Title.Caption :=SMAY;
   Columns[6].Title.Caption :=SJUN;
   Columns[7].Title.Caption :=SJUL;
   Columns[8].Title.Caption :=SAUG;
   Columns[9].Title.Caption :=SSEP;
   Columns[10].Title.Caption:=SOCT;
   Columns[11].Title.Caption:=SNOV;
   Columns[12].Title.Caption:=SDEC;
   Columns[13].Title.Caption:=SAnnual;
 end;

 With DBGrid2 do begin
   Columns[0].Title.Caption :=SYear;
   Columns[1].Title.Caption :=SJAN;
   Columns[2].Title.Caption :=SFEB;
   Columns[3].Title.Caption :=SMAR;
   Columns[4].Title.Caption :=SAPR;
   Columns[5].Title.Caption :=SMAY;
   Columns[6].Title.Caption :=SJUN;
   Columns[7].Title.Caption :=SJUL;
   Columns[8].Title.Caption :=SAUG;
   Columns[9].Title.Caption :=SSEP;
   Columns[10].Title.Caption:=SOCT;
   Columns[11].Title.Caption:=SNOV;
   Columns[12].Title.Caption:=SDEC;
   Columns[13].Title.Caption:=SAnnual;
 end;

 DBGrid1.Columns.Items[0].FieldName:='yy';
 DBGrid2.Columns.Items[0].FieldName:='yy';
 for k:=1 to 13 do begin
  DBGrid1.Columns.Items[k].FieldName:=inttostr(k);
  DBGrid2.Columns.Items[k].FieldName:=inttostr(k);
  DBGrid1.Columns.Items[k].DisplayFormat := ',0.00';
  DBGrid2.Columns.Items[k].DisplayFormat := ',0.00';
 end;

 // loading settings
 Ini := TIniFile.Create(IniFileName);
 try
   frmmonthlymatrix.Top   :=Ini.ReadInteger( 'meteo', 'viewdata_top',    50);
   frmmonthlymatrix.Left  :=Ini.ReadInteger( 'meteo', 'viewdata_left',   50);
   frmmonthlymatrix.Width :=Ini.ReadInteger( 'meteo', 'viewdata_width',  1250);
   frmmonthlymatrix.Height:=Ini.ReadInteger( 'meteo', 'viewdata_height', 750);
   pPlot.Height      :=Ini.ReadInteger( 'meteo', 'viewdata_plot_height', 380);
   rgPlotType.ItemIndex :=Ini.ReadInteger( 'meteo', 'viewdata_plot_type',  0);
   clbViewData.Height:=Ini.ReadInteger( 'meteo', 'viewdata_clb', 40);
 finally
  Ini.Free;
 end;

 Application.QueueAsyncCall(@MoveToCol, 13);
end;

procedure Tfrmmonthlymatrix.MoveToCol(aCol: PtrInt);
begin
  DBGrid1.SelectedIndex := aCol;
  DBGrid2.SelectedIndex := aCol;
end;


procedure Tfrmmonthlymatrix.GetData(table_id:integer);
Var
  k, ID, cnt:integer;
  yy_min, yy_max:integer;
  yy, mn, dd: word;
  sum, val1:real;
  mean_val:array [1..13] of real;

  TRt1, TRt2:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  tbl: string;
begin
 frmmonthlymatrix.Caption:=frmdm.CDS.FieldByName('name').AsString+': '+
                      frmdm.CDS2.FieldByName('par').AsString;
 Application.ProcessMessages;

 (* temporary transaction and query for metadata database *)
 TRt1:=TSQLTransaction.Create(nil);
 TRt1.DataBase:=frmdm.TR.DataBase;

 Qt1:=TSQLQuery.Create(nil);
 Qt1.Database:=frmdm.TR.DataBase;
 Qt1.Transaction:=TRt1;

 (* temporary transaction and query for data database *)
 TRt2:=TSQLTransaction.Create(nil);
 TRt2.DataBase:=frmdm.TR2.DataBase;

 Qt2:=TSQLQuery.Create(nil);
 Qt2.Database:=frmdm.TR2.DataBase;
 Qt2.Transaction:=TRt2;

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "table"."name" as tbl, ');
    SQL.Add(' "parameter"."name" as par, "parameter"."units" as units ');
    SQL.Add(' from "table", "parameter" ');
    SQL.Add(' where ');
    SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
    SQL.Add(' "table"."id"=:id ');
    ParamByName('id').AsInteger:=table_id;
   Open;
    tbl:=Qt1.FieldByName('tbl').AsString;
    units:=Qt1.FieldByName('units').AsString;
   Close;
  end;

  Chart1.LeftAxis.Title.Caption:=frmdm.CDS2.FieldByName('par').AsString+', '+units;
  Application.ProcessMessages;

 if CDSViewValues.Active=true then CDSViewValues.Close;
    CDSViewValues.Open;
 if CDSViewAnomalies.Active=true then CDSViewAnomalies.Close;
    CDSViewAnomalies.Open;

   ID:=frmdm.CDS.FieldByName('id').AsInteger;

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select ');
    SQL.Add(' min(Extract(Year from "date_min")), ');
    SQL.Add(' max(Extract(Year from "date_max")) ');
    SQL.Add(' from "station_info" ');
    SQL.Add(' where ');
    SQL.Add(' "station_id"=:st_id and ');
    SQL.Add(' "table_id"=:tbl ');
    ParamByName('st_id').AsInteger:=id;
    ParamByName('tbl').AsInteger:=table_id;
   Open;
    yy_min:=Qt1.Fields[0].Value;
    yy_max:=Qt1.Fields[1].Value;
   Close;
  end;
  Qt1.Close;
  Qt1.Free;
  Trt1.Commit;
  Trt1.Free;

   for yy:=yy_min to yy_max do begin
    with CDSViewValues do begin
      Append;
       FieldByName('yy').AsInteger:=yy;
      Post;
    end;
    with CDSViewAnomalies do begin
      Append;
       FieldByName('yy').AsInteger:=yy;
      Post;
    end;
  end;

    with Qt2 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select * from "'+tbl+'" ');
      SQL.Add(' where "station_id"=:id ');
      if not chkShowOutliers.Checked then
        SQL.Add(' and "pqf2"=0 ');
      SQL.Add(' order by "date" ');
      ParamByName('id').AsInteger:=id;
     Open;
    end;

  try
   DBGrid1.Enabled:=false;
   DBGrid2.Enabled:=false;
   CDSViewValues.DisableControls;
   CDSViewValues.First;
   CDSViewAnomalies.DisableControls;
   CDSViewAnomalies.First;

  sum:=0; cnt:=0;
  while not Qt2.EOF do begin
   DecodeDate(Qt2.FieldByName('date').AsDateTime, yy, mn, dd);
   val1:=Qt2.FieldByName('value').AsFloat;

   with CDSViewValues do begin
    if Locate('yy', yy, [])=true then begin
     Edit;
      FieldByName(inttostr(mn)).AsFloat:=RoundTo(val1, -2);
     Post;
    end;
   end;

   Qt2.Next;
  end;
  Qt2.Close;
  Qt2.Free;
  Trt2.Commit;
  Trt2.Free;

  CDSViewValues.First;
  while not CDSViewValues.EOF do begin
   sum:=0; cnt:=0;
   for mn:=1 to 12 do begin
    if not varisnull(CDSViewValues.FieldByName(inttostr(mn)).Value) then begin
      sum:=sum+CDSViewValues.FieldByName(inttostr(mn)).Value;
      inc(cnt);
    end;
   end;
   if cnt=12 then begin
     CDSViewValues.Edit;
     CDSViewValues.FieldByName('13').AsFloat:=RoundTo((sum/12), -2);
     CDSViewValues.Post;
   end;
   CDSViewValues.Next;
  end;


  for mn:=1 to 13 do mean_val[mn]:=0;

  for mn:=1 to 13 do begin
   CDSViewValues.First; sum:=0; cnt:=0;
   while not CDSViewValues.EOF do begin
    if not VarIsNull(CDSViewValues.FieldByName(Inttostr(mn)).AsVariant) then begin
      sum:=sum+CDSViewValues.FieldByName(Inttostr(mn)).AsFloat;
      inc(cnt);
    end;
    CDSViewValues.Next;
   end;
   if cnt>0 then mean_val[mn]:=sum/cnt;
  end;

  CDSViewValues.First;
  CDSViewAnomalies.First;
   while not CDSViewValues.EOF do begin
     for mn:=1 to 13 do begin
      if not VarIsNull(CDSViewValues.FieldByName(Inttostr(mn)).AsVariant) then begin
        CDSViewAnomalies.Edit;
        CDSViewAnomalies.FieldByName(Inttostr(mn)).AsFloat:=
          RoundTo((CDSViewValues.FieldByName(Inttostr(mn)).AsFloat-mean_val[mn]), -2);
        CDSViewAnomalies.Post;
      end;
     end;
    CDSViewValues.Next;
    CDSViewAnomalies.Next;
   end;

   for k:=yy_min to yy_max do begin
    if VarIsNull(CDSViewValues.Lookup('yy', k, 'yy')) then begin
       CDSViewValues.Append;
       CDSViewValues.FieldByName('yy').AsInteger:=k;
       CDSViewValues.Post;
    end;

   end;

  finally
    CDSViewValues.First;
    CDSViewValues.EnableControls;
    DBGrid1.Enabled:=true;
    DBGrid1.refresh;

    CDSViewAnomalies.First;
    CDSViewAnomalies.EnableControls;
    DBGrid2.Enabled:=true;
    DBGrid2.refresh;
  end;

    btnSave.Enabled := not CDSViewValues.IsEmpty ;
    DbGrid1.Enabled := not CDSViewValues.IsEmpty ;
    DbGrid2.Enabled := not CDSViewValues.IsEmpty ;

  seClip1.Value:=yy_min;
  seClip2.Value:=yy_max;

  CDSMatrixNavigation;
end;

procedure Tfrmmonthlymatrix.btnPlotAllMonthClick(Sender: TObject);
var
k,count_ts,count, YY:integer;
year,month:integer;
val,stlat,stlon,md,anom:real;
val1:variant;
tsFile,mn,GraphID,PlotID,ID,FitTitle,FitID,AxisTitleY:string;
xID,yID,txt:string;
mn_arr:array[1..13] of string;

stsource,stname,stcountry:string;
absnum,wmonum,wmonumsource:integer;
cmd, par, title, xtitle, p_type: string;
f_dat: text;
begin

for k:=1 to 13 do begin
   tsfile :=tspath+inttostr(k)+'.dat';
      if fileexists(tsfile) then DeleteFile(tsfile);

   assignfile(f_dat, tsfile);   rewrite(f_dat);
   writeln(f_dat ,'year value');

 if frmmonthlymatrix.PageControl1.PageIndex=0 then begin
   p_type:='values';
   try
    CDSViewValues.First;
    CDSViewValues.DisableControls;
       while not CDSViewValues.EOF do begin
        YY  :=CDSViewValues.FieldByName('YY').AsInteger;
        Val1:=CDSViewValues.FieldByName(inttostr(k)).AsVariant;
         if not VarIsNull(Val1) then
              writeln(f_dat, yy:5, VarToStr(Val1):8) else
              writeln(f_dat, yy:5, 'NaN':8);
        CDSViewValues.Next;
       end;
   finally
    CDSViewValues.First;
    CDSViewValues.EnableControls;
   end;
 end; //Values

 if frmmonthlymatrix.PageControl1.PageIndex=1 then begin
   p_type:='anomalies';
  try
   CDSViewAnomalies.DisableControls;
     CDSViewAnomalies.First;
      while not CDSViewAnomalies.EOF do begin
        YY  :=CDSViewAnomalies.FieldByName('YY').AsInteger;
        Val1:=CDSViewAnomalies.FieldByName(inttostr(k)).AsVariant;
        if not VarIsNull(Val1) then
             writeln(f_dat, yy:5, VarToStr(Val1):8) else
             writeln(f_dat, yy:5, 'NaN':8);
       CDSViewAnomalies.Next;
      end;
  finally
   CDSViewAnomalies.First;
   CDSViewAnomalies.EnableControls;
  end;
 end; //anomalies

 CloseFile(f_dat);
end;

 par:=frmdm.CDS2.FieldByName('par').AsString;

 title:='Monthly composition plot of '+par;
 xtitle:='';


 PlotMonthlyComposition(tspath, title, par, units, xtitle);

 cmd:='-x "'+GlobalUnloadPath+'timeseries'+PathDelim+'timeseries.bas"';
 frmmain.RunScript(3, cmd, nil);

 // (fpath, title, par, units, xtitle:string);

 {  (* Строим серии в Графере *)
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


    if chkShowOutliers.Checked then begin
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
}
end;


procedure Tfrmmonthlymatrix.btnPlotColumnClick(Sender: TObject);
Var
 YY, MN:integer;
 val1:Variant;
 fname, title, par, xtitle, cmd, p_type:string;
 f_dat: text;
begin
 fname:=tspath+'timeseries.txt';
   if fileexists(fname) then DeleteFile(fname);

 AssignFile(f_dat, fname); rewrite(f_dat);
 Writeln(f_dat, 'YY':5, 'Value':8);

 (* Plot real values *)
 if frmmonthlymatrix.PageControl1.PageIndex=0 then begin
  par:=DBGrid1.SelectedField.FieldName;
  mn:=DBGrid1.SelectedField.FieldNo-1;
  p_type:='values';
  try
   CDSViewValues.First;
   CDSViewValues.DisableControls;
      while not CDSViewValues.EOF do begin
       YY  :=CDSViewValues.FieldByName('YY').AsInteger;
       Val1:=CDSViewValues.FieldByName(inttostr(mn)).AsVariant;
        if not VarIsNull(Val1) then
             writeln(f_dat, yy:5, VarToStr(Val1):8) else
             writeln(f_dat, yy:5, 'NaN':8);
       CDSViewValues.Next;
      end;
  finally
   CDSViewValues.First;
   CDSViewValues.EnableControls;
  end;
 end; //Values

 (* Plot anomalies *)
 if frmmonthlymatrix.PageControl1.PageIndex=1 then begin
  par:=DBGrid2.SelectedField.FieldName;
  mn:=DBGrid2.SelectedField.FieldNo-1;
  p_type:='anomalies';
  try
   CDSViewAnomalies.DisableControls;
     CDSViewAnomalies.First;
      while not CDSViewAnomalies.EOF do begin
        YY  :=CDSViewAnomalies.FieldByName('YY').AsInteger;
        Val1:=CDSViewAnomalies.FieldByName(inttostr(mn)).AsVariant;
        if not VarIsNull(Val1) then
             writeln(f_dat, yy:5, VarToStr(Val1):8) else
             writeln(f_dat, yy:5, 'NaN':8);
       CDSViewAnomalies.Next;
      end;
  finally
   CDSViewAnomalies.First;
   CDSViewAnomalies.EnableControls;
  end;
 end; //Values
 CloseFile(f_dat);

 par:=frmdm.CDS2.FieldByName('par').AsString;

 if mn<=12 then title:='Monthly mean '+p_type+' of '+par+', '+GetMonthFromIndex(mn);
 if mn=13  then title:='Annual mean ' +p_type+' of '+par;
 xtitle:='';

 PlotTimeSeries(fname, title, par, units, xtitle, 2);

 cmd:='-x "'+GlobalUnloadPath+'timeseries'+PathDelim+'timeseries.bas"';
 frmmain.RunScript(3, cmd, nil);
end;


procedure Tfrmmonthlymatrix.MenuItem2Click(Sender: TObject);
Var
 mn:integer;
 val_arr:array of real;
 cnt_arr:array of integer;
 fname, title, par, xtitle, cmd:string;
 f_dat: text;
begin
 SetLength(Val_arr, CDSViewValues.RecordCount);
 SetLength(cnt_arr, CDSViewValues.RecordCount);

 fname:=tspath+frmdm.CDS.FieldByName('name').AsString+'_annual_circle.txt';
 par:=frmdm.CDS2.FieldByName('par').AsString;
 title:='Annual circle of '+par;
 xtitle:='';

 AssignFile(f_dat, fname); rewrite(f_dat);
 Writeln(f_dat, 'MN':5, 'Value':8);

 (* Plot real values *)
 if frmmonthlymatrix.PageControl1.PageIndex=0 then begin
  try
   CDSViewValues.DisableControls;
    for mn:=1 to 12 do begin
     CDSViewValues.First;
      while not CDSViewValues.EOF do begin
        val_arr[mn]:=Val_arr[mn]+CDSViewValues.FieldByName(inttostr(mn)).AsFloat;
        cnt_arr[mn]:=cnt_arr[mn]+1;
       CDSViewValues.Next;
      end;
     if cnt_arr[mn]>0 then writeln(f_dat, mn:5, FloattostrF((val_arr[mn]/cnt_arr[mn]), fffixed, 8, 2):8);
    end; // 12 month
  finally
   CDSViewValues.First;
   CDSViewValues.EnableControls;
  end;
 end; //Values

 CloseFile(f_dat);

 PlotTimeSeries(fname, title, par, units, xtitle, 2);

 cmd:='-x "'+GlobalUnloadPath+'timeseries'+PathDelim+'timeseries.bas"';
 frmmain.RunScript(3, cmd, nil);
end;



procedure Tfrmmonthlymatrix.btnSaveClick(Sender: TObject);
Var
 k, old_id:integer;
 fout:text;
 upath: string;
 ActiveCDS:TBufDataset;
begin

 upath:=tspath+StringReplace(Caption, ':', '_', [rfReplaceAll])+PathDelim;
   if not DirectoryExists(upath) then CreateDir(upath);

 ClearDir(upath);

  // Values or anomalies?
  Case PageControl1.PageIndex of
   0: ActiveCDS:=CDSViewValues;
   1: ActiveCDS:=CDSViewAnomalies;
  end;

  old_id:=ActiveCDS.FieldByName('YY').AsInteger;
  AssignFile(fout, upath+'matrix.txt'); rewrite(fout);

   try
     ActiveCDS.DisableControls;
     ActiveCDS.First;
       while not ActiveCDS.EOF do begin
        write(fout, inttostr(ActiveCDS.FieldByName('YY').AsInteger));
        for k:=1 to 13 do begin
         write(fout, #9, Vartostr(ActiveCDS.FieldByName(inttostr(k)).Value));
        end;
       writeln(fout);
    ActiveCDS.Next;
   end;
   finally
    ActiveCDS.Locate('YY', old_id, []);
    ActiveCDS.EnableControls;
   end;
  CloseFile(fout);

  Chart1.SaveToFile(TJPEGImage, upath+'plot.jpg');

 { for k:=0 to Chart1.SeriesCount-1 do begin
   AssignFile(fout, upath+Chart1.Series[k].Name+'.txt'); reset(fout);
   for pp:=0 to Chart1.Series[k].
     if Chart1.Series[k].Name=sName then begin
       TLineSeries(Chart1.Series[k]).Clear;
       mik:=k;
       break;
     end;
  end;}

  OpenDocument(upath);
end;


procedure Tfrmmonthlymatrix.chkShowOutliersClick(Sender: TObject);
begin
  GetData(frmdm.CDS2.FieldByName('id').Value);
end;


procedure Tfrmmonthlymatrix.CDSMatrixNavigation;
var
 old_id, YY, mn, mik, cnt:integer;
 Val1, Sum, mean_val: variant;
 txt, SName: string;
 sColor:TColor;
 ActiveGrid:TDBGrid;
 ActiveCDS:TBufDataset;
 date_dec:double;
begin
  // Values or anomalies?
  Case PageControl1.PageIndex of
   0: begin
       ActiveGrid:=DBGrid1;
       ActiveCDS:=CDSViewValues;
      end;
   1: begin
       ActiveGrid:=DBGrid2;
       ActiveCDS:=CDSViewAnomalies;
      end;
   end;


 try
    if ActiveGrid.SelectedField.FieldNo=1 then exit;

    old_id:=ActiveCDS.FieldByName('YY').AsInteger;

    Chart1.Series.Clear;
    clbViewData.Columns:=ActiveCDS.FieldCount-2;
    mik:=0;

    (* Plotting selected month/column *)
    if rgPlotType.ItemIndex=0 then begin

      mn:=ActiveGrid.SelectedField.FieldNo-1;

      SName:=ActiveGrid.Columns[mn].Title.Caption;
     // sColor:=GetColorFromIndex(mn);
      sColor:=clBlue;

      AddLineSeries(Chart1, sName, sColor, sName, 2);
      inc(mik);
      try
      ActiveCDS.DisableControls;
      ActiveCDS.First;
       while not ActiveCDS.EOF do begin
        YY  :=ActiveCDS.FieldByName('YY').AsInteger;
        Val1:=ActiveCDS.FieldByName(inttostr(mn)).AsVariant;
        if Val1=null then Val1:=Nan;

         txt:='Year: '+inttostr(yy)+'; Month: '+inttostr(mn)+'; Value: '+VarToStr(val1);
         TLineSeries(Chart1.Series[mik-1]).AddXY(yy, val1, txt);

        ActiveCDS.Next;
       end;
       finally
         ActiveCDS.Locate('YY', old_id, []);
         ActiveCDS.EnableControls;
       end;
      Chart1.BottomAxis.Title.Caption:='Years';
    end;


    (* Plotting ALL months *)
    if rgPlotType.ItemIndex=1 then begin
     try
     ActiveCDS.DisableControls;
     for mn:=1 to 13 do begin
      SName:=ActiveGrid.Columns[mn].Title.Caption;
      sColor:=GetColorFromIndex(mn);

      if mn<13 then
        AddLineSeries(Chart1, sName, sColor, sName, 1) else
        AddLineSeries(Chart1, sName, sColor, sName, 2);
      inc(mik);

      ActiveCDS.First;
       while not ActiveCDS.EOF do begin
        YY  :=ActiveCDS.FieldByName('YY').AsInteger;
        Val1:=ActiveCDS.FieldByName(inttostr(mn)).AsVariant;
        if Val1=null then Val1:=Nan;
      //  date_dec:=roundto(yy+(mn-1)/12, -2);

         txt:='Year: '+inttostr(yy)+'; Month: '+inttostr(mn)+'; Value: '+VarToStr(val1);
         TLineSeries(Chart1.Series[mik-1]).AddXY(yy, val1, txt);

        ActiveCDS.Next;
       end;
      end;
      finally
       ActiveCDS.Locate('YY', old_id, []);
       ActiveCDS.EnableControls;
      end;
     Chart1.BottomAxis.Title.Caption:='Years';
    end;


    (* Plotting selected year (12 values) *)
    if rgPlotType.ItemIndex=2 then begin
      SName:='Year_'+inttostr(ActiveCDS.FieldByName('YY').AsInteger);
      AddLineSeries(Chart1, SName, clBlue, sName, 2);
      inc(mik);
     for mn:=1 to 12 do begin
       Val1:=ActiveCDS.FieldByName(inttostr(mn)).AsVariant;
       if Val1=null then Val1:=Nan;

         txt:='Month: '+inttostr(mn)+'; Value: '+VarToStr(val1);
         TLineSeries(Chart1.Series[mik-1]).AddXY(mn, val1, txt);
       end;
     Chart1.BottomAxis.Title.Caption:='Months';
    end;


    if rgPlotType.ItemIndex=3 then begin
      SName:='Annual_cycle';
      AddLineSeries(Chart1, SName, clBlack, sName, 2);
      inc(mik);
     for mn:=1 to 12 do begin
      try
        ActiveCDS.DisableControls;
        ActiveCDS.First;
        mean_val:=0; sum:=0; cnt:=0;
          while not ActiveCDS.EOF do begin
            YY  :=ActiveCDS.FieldByName('YY').AsInteger;
            Val1:=ActiveCDS.FieldByName(inttostr(mn)).AsVariant;
            if Val1<>null then begin
             sum:=sum+Val1;
             inc(cnt);
            end;
           ActiveCDS.Next;
          end;
       if cnt>0 then mean_val:=sum/cnt else mean_val:=nan;
       txt:='Month: '+inttostr(mn)+'; Value: '+VarToStr(mean_val);
       TLineSeries(Chart1.Series[mik-1]).AddXY(mn,mean_val,txt);
      finally
        ActiveCDS.Locate('YY', old_id, []);
        ActiveCDS.EnableControls;
      end;
     end;
     Chart1.BottomAxis.Title.Caption:='Months';
    end;

   finally
    ActiveCDS.EnableControls;
   end;

   seClip1.OnChange(self);
   seClip2.OnChange(self);
   Application.ProcessMessages;
end;

procedure Tfrmmonthlymatrix.rgPlotTypeClick(Sender: TObject);
begin
  CDSMatrixNavigation;
end;

procedure Tfrmmonthlymatrix.DBGrid1CellClick(Column: TColumn);
begin
  CDSMatrixNavigation;
end;

procedure Tfrmmonthlymatrix.DBGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CDSMatrixNavigation;
end;

procedure Tfrmmonthlymatrix.DBGrid2CellClick(Column: TColumn);
begin
  CDSMatrixNavigation;
end;

procedure Tfrmmonthlymatrix.DBGrid2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CDSMatrixNavigation;
end;


procedure Tfrmmonthlymatrix.PageControl1Change(Sender: TObject);
begin
  CDSMatrixNavigation;
end;


procedure Tfrmmonthlymatrix.FormResize(Sender: TObject);
begin
  Toolbar1.Left:=frmmonthlymatrix.Width-Toolbar1.Width;
end;

procedure Tfrmmonthlymatrix.DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
begin
 if (column.Index=0)then TDBGrid(sender).Canvas.Brush.Color := clBtnFace;

 if (gdSelected in AState) then begin
   TDBGrid(Sender).Canvas.Brush.Color := clNavy;
   TDBGrid(Sender).Canvas.Font.Color  := clYellow;
   TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;

 if TDBGrid(Sender).SelectedField.Index = DataCol then begin
   TDBGrid(Sender).Canvas.Brush.Color := clGradientActiveCaption;
 end;

 if VarIsNull(column.Field.Value)=true then TDBGrid(sender).Canvas.Brush.Color :=clYellow;
end;


procedure Tfrmmonthlymatrix.PMPopup(Sender: TObject);
begin
  if ((frmmonthlymatrix.PageControl1.PageIndex=0) and
     (DBGrid1.SelectedField.FieldNo=1)) or
     ((frmmonthlymatrix.PageControl1.PageIndex=1) and
     (DBGrid2.SelectedField.FieldNo=1)) then Abort;
end;

procedure Tfrmmonthlymatrix.rbSelectedMonthChange(Sender: TObject);
begin
  if frmmonthlymatrix.PageControl1.PageIndex=0 then
    DBGrid1.OnCellClick(DBGrid1.SelectedColumn) else
    DBGrid2.OnCellClick(DBGrid1.SelectedColumn);
end;

procedure Tfrmmonthlymatrix.seClip1Change(Sender: TObject);
begin
 if rgPlotType.ItemIndex<2 then
  Chart1.Extent.XMin := seClip1.Value else
  Chart1.Extent.XMin:=1;

 Chart1.Extent.UseXMin := true;
end;

procedure Tfrmmonthlymatrix.seClip2Change(Sender: TObject);
begin
 if rgPlotType.ItemIndex<2 then
  Chart1.Extent.XMax := seClip2.Value else
  Chart1.Extent.XMax:=12;

 Chart1.Extent.UseXMax := true;
end;


procedure Tfrmmonthlymatrix.ctsDPCPointClick(ATool: TChartTool; APoint: TPoint);
Var
 tool: TDataPointClicktool;
 series: TLineSeries;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
    if (tool.PointIndex<>-1) then begin

     if frmmonthlymatrix.PageControl1.PageIndex=0 then
      CDSViewValues.Locate('yy', series.XValue[tool.PointIndex], []);

     if frmmonthlymatrix.PageControl1.PageIndex=1 then
      CDSViewAnomalies.Locate('yy', series.XValue[tool.PointIndex], []);

    end;
  end;
end;

procedure Tfrmmonthlymatrix.ctsDPHHint(ATool: TDataPointHintTool;
  const APoint: TPoint; var AHint: String);
begin
  AHint := TLineSeries(ATool.Series).Source.Item[ATool.PointIndex]^.Text;
end;

procedure Tfrmmonthlymatrix.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
 Ini:TIniFile;
begin

// saving settings
Ini := TIniFile.Create(IniFileName);
try
  Ini.WriteInteger( 'meteo', 'viewdata_top',         frmmonthlymatrix.Top);
  Ini.WriteInteger( 'meteo', 'viewdata_left',        frmmonthlymatrix.Left);
  Ini.WriteInteger( 'meteo', 'viewdata_width',       frmmonthlymatrix.Width);
  Ini.WriteInteger( 'meteo', 'viewdata_height',      frmmonthlymatrix.Height);
  Ini.WriteInteger( 'meteo', 'viewdata_plot_height', pPlot.Height);
  Ini.WriteInteger( 'meteo', 'viewdata_plot_type',   rgPlotType.ItemIndex);
  Ini.WriteInteger( 'meteo', 'viewdata_clb',         clbViewData.Height);
finally
 Ini.Free;
end;

 CDSViewValues.Free;
 CDSViewAnomalies.Free;

 DSViewValues.Free;
 DSViewAnomalies.Free;

 Open_monthlymatrix:=false;
end;


end.

