unit comparesources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, ExtCtrls,
  Variants, SQLDB, DB, BufDataset, Math, Grids, Types,
  TAGraph, TASeries, TACustomSeries, TAChartUtils, TATools, TATypes,
  TAChartListbox;

type

  { Tfrmcomparesources }

  Tfrmcomparesources = class(TForm)
    Chart1: TChart;
    ChartListbox1: TChartListbox;
    ChartToolset1: TChartToolset;
    ctDataPointHint: TDataPointHintTool;
    ctZoomMouseWheel: TZoomMouseWheelTool;
    ctZoomDrag: TZoomDragTool;
    DBGrid1: TDBGrid;
    Panel2: TPanel;
    Splitter1: TSplitter;

    procedure ctDataPointClickPointClick(ATool: TChartTool; APoint: TPoint);
    procedure ctDataPointHintHint(ATool: TDataPointHintTool;
      const APoint: TPoint; var AHint: String);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
  public

  end;

var
  frmcomparesources: Tfrmcomparesources;
  CDSCompare:TBufDataSet;
  DSCompare:TDataSource;

implementation

{$R *.lfm}

{ Tfrmcomparesources }

uses dm;

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

procedure Tfrmcomparesources.FormShow(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  id, k: integer;
  SColor:TColor;
  sName, txt:string;
  dat1:TDateTime;
  val1: Variant;
begin
  (* temporary transaction for support database *)
 TRt:=TSQLTransaction.Create(nil);
 TRt.DataBase:=frmdm.TR.DataBase;

 (* temporary query for main database *)
 Qt1:=TSQLQuery.Create(nil);
 Qt1.Database:=frmdm.TR.DataBase;
 Qt1.Transaction:=TRt;

 Qt2:=TSQLQuery.Create(nil);
 Qt2.Database:=frmdm.TR.DataBase;
 Qt2.Transaction:=TRt;

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "table", "source" from "parameter" ');
    SQL.Add(' where "parameter"."name"=:par_name ');
    ParamByName('par_name').Value:=frmdm.CDS2.FieldByName('par').Value;
   Open;
   Last;
   First;
  end;

  if Qt1.RecordCount=1 then
    if MessageDlg('There is nothing to compare', mtWarning, [mbOk], 0)=mrOk then exit;

  id:=frmdm.CDS.FieldByName('id').Value;


  CDSCompare:=TBufDataSet.Create(self);
  CDSCompare.FieldDefs.Add('date', ftdate, 0, false);
   while not Qt1.Eof do begin
     sName:=StringReplace(Qt1.FieldByName('source').Value, ' ', '_', [rfReplaceAll]);
     CDSCompare.FieldDefs.Add(sName, ftfloat, 0, false);
     Qt1.Next;
   end;
  CDSCompare.CreateDataSet;
  CDSCompare.IndexFieldNames:='date';

  DSCompare:=TDataSource.Create(self);
  DSCompare.DataSet:=CDSCompare;

  DBGrid1.DataSource:=DSCompare;

  try
  CDSCompare.DisableControls;

  k:=-1;
  Qt1.First;
  while not Qt1.Eof do begin
   inc(k);

   sName:=StringReplace(Qt1.FieldByName('source').Value, ' ', '_', [rfReplaceAll]);

   with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select "date", "value" ');
     SQL.Add(' from "'+Qt1.FieldByName('table').Value+'" ');
     SQL.Add(' where "station_id"=:id order by "date" ');
     ParamByName('id').Value:=id;
    Open;
   end;

   While not Qt2.EOF do begin
      dat1:=Qt2.FieldByName('date').AsDateTime;
      val1:=Qt2.FieldByName('value').Value;

     with CDSCompare do begin
       if VarIsNull(Lookup('date', dat1, 'date')) then Append else begin
         Locate('date',dat1,[]);
         Edit;
       end;
        FieldByName('date').AsDateTime:=dat1;
        FieldByName(sName).AsFloat:=val1;
       Post;
     end;
    Qt2.Next;
   end;

   Qt1.Next;
  end;


  Chart1.Series.Clear;
 // chart1.Legend.ColumnCount:=CDSCompare.FieldCount-1;
  ChartListBox1.Columns:=CDSCompare.FieldCount-1;

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

      txt:='date: '+datetimetostr(dat1)+'; value: '+VarToStr(val1);
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


procedure Tfrmcomparesources.ctDataPointClickPointClick(ATool: TChartTool;
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


procedure Tfrmcomparesources.ctDataPointHintHint(ATool: TDataPointHintTool;
  const APoint: TPoint; var AHint: String);
begin
  showmessage('here');
   AHint := TLineSeries(ATool.Series).Source.Item[ATool.PointIndex]^.Text;
end;

procedure Tfrmcomparesources.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DSCompare.Free;
  CDSCompare.Free;
end;


end.

