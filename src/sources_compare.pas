unit sources_compare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, ExtCtrls,
  Variants, SQLDB, DB, BufDataset, Math, Grids, StdCtrls, Types, DateUtils,
  IniFiles, TAGraph, TASeries, TACustomSeries, TAChartUtils, TATools, TATypes,
  TAChartListbox, TAIntervalSources;

type

  { Tfrmcomparesources }

  Tfrmcomparesources = class(TForm)
    Chart1: TChart;
    chkShowOutliers: TCheckBox;
    clb1: TChartListbox;
    cts: TChartToolset;
    ctDPH: TDataPointHintTool;
    ctDPC: TDataPointClickTool;
    ctZDT: TZoomDragTool;
    DBGrid1: TDBGrid;
    dtInterval: TDateTimeIntervalChartSource;
    pGrid: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;

    procedure chkShowOutliersChange(Sender: TObject);
    procedure ctDPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure ctDPHHint(ATool: TDataPointHintTool;
      const APoint: TPoint; var AHint: String);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
  public
    procedure ChangeID;
  end;

var
  frmcomparesources: Tfrmcomparesources;
  CDSCompare:TBufDataSet;
  DSCompare:TDataSource;

implementation

{$R *.lfm}

{ Tfrmcomparesources }

uses main, dm;

function Tfrmcomparesources.AddLineSeries(AChart: TChart;
  ATitle: String; AColor:TColor; sName:string): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    Title := ATitle;
    ShowPoints := true;
    ShowLines := true;
    LinePen.Style := psSolid;
    SeriesColor := AColor;
    Pointer.Brush.Color := AColor;
    Pointer.Pen.Color := AColor;
    Pointer.Style := psCircle;
    Pointer.HorizSize:=2;
    Pointer.VertSize:=2;
    Name := sName;
    ToolTargets := [nptPoint, nptXList, nptCustom];
  end;
 AChart.AddSeries(Result);
end;


procedure Tfrmcomparesources.FormCreate(Sender: TObject);
Var
  Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
 try
   Top   :=Ini.ReadInteger( 'meteo', 'comparesources_top',    50);
   Left  :=Ini.ReadInteger( 'meteo', 'comparesources_left',   50);
   Width :=Ini.ReadInteger( 'meteo', 'comparesources_width',  1300);
   Height:=Ini.ReadInteger( 'meteo', 'comparesources_height', 550);
   pGrid.Width :=Ini.ReadInteger( 'meteo', 'comparesources_grid_width', 350);
   clb1.Height :=Ini.ReadInteger( 'meteo', 'comparesources_clb_height', 70);
 finally
  Ini.Free;
 end;
end;


procedure Tfrmcomparesources.FormShow(Sender: TObject);
begin
 ChangeID;
end;

procedure Tfrmcomparesources.ChangeID;
Var
  id, k, mn, mn_between: integer;
  SColor:TColor;
  sName, txt, par, tbl:string;
  dat1, dat0:TDateTime;
  val1: Variant;
begin

 Caption:=frmdm.CDS.FieldByName('name').AsString+': '+
          frmdm.CDS2.FieldByName('par').AsString;
 Application.ProcessMessages;

 par:=frmdm.CDS2.FieldByName('par').Value;
 id:=frmdm.CDS.FieldByName('id').Value;


  CDSCompare:=TBufDataSet.Create(self);
  CDSCompare.FieldDefs.Add('date', ftdate, 0, false);
  frmdm.CDS2.First;
   while not frmdm.CDS2.Eof do begin
     if par=frmdm.CDS2.FieldByName('par').Value then begin
       sName:=frmdm.CDS2.FieldByName('src').Value;
         CDSCompare.FieldDefs.Add(sName, ftfloat, 0, false);
     end;
     frmdm.CDS2.Next;
   end;
  CDSCompare.CreateDataSet;
  CDSCompare.IndexFieldNames:='date';

  DSCompare:=TDataSource.Create(self);
  DSCompare.DataSet:=CDSCompare;

  DBGrid1.DataSource:=DSCompare;

  try
  CDSCompare.DisableControls;

  k:=-1;
  frmdm.CDS2.First;
  while not frmdm.CDS2.Eof do begin
   if par=frmdm.CDS2.FieldByName('par').Value then begin
   sName:=frmdm.CDS2.FieldByName('src').Value;

   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "table"."name" ');
     SQL.Add(' from "table", "parameter", "source" ');
     SQL.Add(' where ');
     SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
     SQL.Add(' "table"."source_id"="source"."id" and ');
     SQL.Add(' "parameter"."name"=:p_name and "source"."name"=:p_src ');
     ParamByName('p_name').Value:=par;
     ParamByName('p_src').Value:=frmdm.CDS2.FieldByName('src').Value;
    Open;
      tbl:=frmdm.q2.Fields[0].Value;
    Close;
   end;

  // showmessage(tbl);

   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "date", "value" ');
     SQL.Add(' from "'+tbl+'" ');
     SQL.Add(' where ');
     SQL.Add(' "station_id"=:id ');
     if chkShowOutliers.Checked=false then
       SQL.Add(' and "pqf2"=0 ');
     SQL.Add(' order by "date" ');
     ParamByName('id').Value:=id;
    Open;
   end;

   While not frmdm.q2.EOF do begin
      dat1:=frmdm.q2.FieldByName('date').AsDateTime;
      val1:=frmdm.q2.FieldByName('value').Value;

     with CDSCompare do begin
       if VarIsNull(Lookup('date', dat1, 'date')) then Append else begin
         Locate('date',dat1,[]);
         Edit;
       end;
        FieldByName('date').AsDateTime:=dat1;
        FieldByName(sName).AsFloat:=val1;
       Post;
     end;
    frmdm.q2.Next;
   end;
   end;

   frmdm.CDS2.Next;
  end;


  CDSCompare.First;
  dat0:=CDSCompare.FieldByName('date').AsDateTime;

  while not CDSCompare.EOF do begin
   dat1:=CDSCompare.FieldByName('date').AsDateTime;

   mn_between:=MonthsBetween(dat1, dat0{, true});
   if mn_between>1 then begin
   //   showmessage(datetostr(dat1)+'   '+datetostr(dat0)+'   '+inttostr(mn_between));

   for mn:=1 to mn_between-1 do begin
    dat1:=IncMonth(dat0, mn);
     with CDSCompare do begin
       Append;
        FieldByName('date').AsDateTime:=dat1;
       Post;
     end;
    end;
   end;
  // showmessage(inttostr());

   dat0:=dat1;
   CDSCompare.Next;
  end;



  Chart1.Series.Clear;
 // chart1.Legend.ColumnCount:=CDSCompare.FieldCount-1;
  clb1.Columns:=CDSCompare.FieldCount-1;

  for k:=1 to CDSCompare.FieldCount-1 do begin
    case k of
      1: SColor:=clBlue;
      2: SColor:=clRed;
      3: SColor:=clMaroon;
      4: SColor:=clGreen;
      5: SColor:=clBlack;
    end;

    SName:= CDSCompare.Fields[k].FieldName;
    AddLineSeries(Chart1, sName, sColor, sName);

    CDSCompare.First;
    while not CDSCompare.EOF do begin
      dat1:=CDSCompare.FieldByName('date').AsDateTime;
      val1:=CDSCompare.Fields[k].Value;

      if val1=null then val1:=Nan;

      txt:=SName+', date: '+datetimetostr(dat1)+'; value: '+VarToStr(val1);
      TLineSeries(Chart1.Series[k-1]).AddXY(dat1,val1,txt);
     CDSCompare.Next;
    end;
  end;
 finally
   CDSCompare.First;
   CDSCompare.EnableControls;
 end;
end;

procedure Tfrmcomparesources.DBGrid1PrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
  if (column.Index=0)then TDBGrid(sender).Canvas.Brush.Color := clBtnFace;

  if (gdSelected in AState) then begin
   TDBGrid(Sender).Canvas.Brush.Color := clNavy;
   TDBGrid(Sender).Canvas.Font.Color  := clYellow;
   TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
  end;

  if VarIsNull(column.Field.Value)=true then TDBGrid(sender).Canvas.Brush.Color :=clYellow;
end;


procedure Tfrmcomparesources.ctDPCPointClick(ATool: TChartTool;
  APoint: TPoint);
Var
 tool: TDataPointClicktool;
 series: TLineSeries;
begin
 showmessage('here');
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
    showmessage(inttostr(tool.PointIndex));
    if (tool.PointIndex<>-1) then begin
      CDSCompare.Locate('date', series.XValue[tool.PointIndex], []);
    end;
  end;
end;

procedure Tfrmcomparesources.chkShowOutliersChange(Sender: TObject);
begin
  ChangeID;
end;


procedure Tfrmcomparesources.ctDPHHint(ATool: TDataPointHintTool;
  const APoint: TPoint; var AHint: String);
begin
   AHint := TLineSeries(ATool.Series).Source.Item[ATool.PointIndex]^.Text;
end;

procedure Tfrmcomparesources.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
 Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
 try
   Ini.WriteInteger( 'meteo', 'comparesources_top',        Top);
   Ini.WriteInteger( 'meteo', 'comparesources_left',       Left);
   Ini.WriteInteger( 'meteo', 'comparesources_width',      Width);
   Ini.WriteInteger( 'meteo', 'comparesources_height',     Height);
   Ini.WriteInteger( 'meteo', 'comparesources_grid_width', pGrid.Width);
   Ini.WriteInteger( 'meteo', 'comparesources_clb_height', clb1.Height);
 finally
  Ini.Free;
 end;

  DSCompare.Free;
  CDSCompare.Free;
end;


end.

