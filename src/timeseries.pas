unit timeseries;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, DBGrids,
  StdCtrls, Spin, TAGraph, TASeries, TATools, TADbSource, TAIntervalSources,
  DateTimePicker, DB, SQLDB, BufDataset, DateUtils, Math, Grids, Variants,
  Types;

type

  { Tfrmtimeseries }

  Tfrmtimeseries = class(TForm)
    btnGetTimeseries: TButton;
    Chart1: TChart;
    chkHideOutliers: TCheckBox;
    ctDPC: TDataPointClickTool;
    ctDPH: TDataPointHintTool;
    cts: TChartToolset;
    ctZDT: TZoomDragTool;
    DS: TDataSource;
    dtInterval: TDateTimeIntervalChartSource;
    dtp_max: TDateTimePicker;
    dtp_min: TDateTimePicker;
    GroupBox1: TGroupBox;
    rgClipping: TRadioGroup;
    Series1: TLineSeries;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Splitter1: TSplitter;

    procedure btnGetTimeseriesClick(Sender: TObject);
    procedure ctDPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure ctDPHHint(ATool: TDataPointHintTool; const APoint: TPoint;
      var AHint: String);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private

  public
    procedure GetData(table_id:integer);
  end;

var
  frmtimeseries: Tfrmtimeseries;
  CDSTimeseries:TBufDataset;

implementation

{$R *.lfm}

uses main, dm;

{ Tfrmtimeseries }


procedure Tfrmtimeseries.FormShow(Sender: TObject);
begin

  CDSTimeseries:=TBufDataSet.Create(self);
  with CDSTimeseries do begin
    FieldDefs.Add('date', ftdate, 0, false);
    FieldDefs.Add('val', ftfloat, 0, false);
    FieldDefs.Add('flag', ftinteger, 0, false);
    CreateDataSet;
    IndexFieldNames:='date';
  end;


 dtp_min.Date:=frmdm.CDS2.FieldByName('date_min').AsDateTime;
 dtp_min.MinDate:=frmdm.CDS2.FieldByName('date_min').AsDateTime;
 dtp_min.MaxDate:=frmdm.CDS2.FieldByName('date_max').AsDateTime;

 dtp_max.Date:=dtp_min.MaxDate;
 dtp_max.MinDate:=dtp_min.MinDate;
 dtp_min.MaxDate:=dtp_min.MaxDate;

end;


procedure Tfrmtimeseries.GetData(table_id:integer);
begin
 Caption:=frmdm.CDS.FieldByName('name').AsString+': '+
          frmdm.CDS2.FieldByName('par').AsString;
 Application.ProcessMessages;


end;


procedure Tfrmtimeseries.DBGrid1PrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
  if (column.Index=2) and (column.Field.AsString='1') then begin
     TDBGrid(Sender).Canvas.Brush.Color := clRed;
     TDBGrid(Sender).Canvas.Font.Color  := clWhite;
     TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
  end;

 if (gdSelected in AState) then begin
   TDBGrid(Sender).Canvas.Brush.Color := clNavy;
   TDBGrid(Sender).Canvas.Font.Color  := clYellow;
   TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;

  if VarIsNull(column.Field.Value)=true then TDBGrid(sender).Canvas.Brush.Color :=clYellow;
end;

procedure Tfrmtimeseries.btnGetTimeseriesClick(Sender: TObject);
Var
  k, ID, cnt, table_id:integer;
  yy_min, yy_max:integer;
  yy1, mn1, dd1, yy2, mn2, dd2: word;

  dat1: TDateTime;

  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
  tbl, units, step, txt: string;

  steps_between:integer;
  val1, pqf2: Variant;
  clr:TColor;
begin
 table_id:=frmdm.CDS2.FieldByName('id').Value;

  (* temporary transaction for support database *)
 TRt:=TSQLTransaction.Create(nil);
 TRt.DataBase:=frmdm.TR.DataBase;

 (* temporary query for main database *)
 Qt1:=TSQLQuery.Create(nil);
 Qt1.Database:=frmdm.TR.DataBase;
 Qt1.Transaction:=TRt;

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "table"."name" as tbl, "timestep"."name" as step, ');
    SQL.Add(' "parameter"."name" as par, "parameter"."units" as units ');
    SQL.Add(' from "table", "parameter", "timestep" ');
    SQL.Add(' where ');
    SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
    SQL.Add(' "table"."timestep_id"="timestep"."id" and ');
    SQL.Add(' "table"."id"=:id ');
    ParamByName('id').AsInteger:=table_id;
   Open;
    tbl:=Qt1.FieldByName('tbl').AsString;
    units:=Qt1.FieldByName('units').AsString;
    step:=Qt1.FieldByName('step').AsString;
   Close;
  end;

  Chart1.LeftAxis.Title.Caption:=frmdm.CDS2.FieldByName('par').AsString+', '+units;
  Application.ProcessMessages;

  ID:=frmdm.CDS.FieldByName('id').AsInteger;

 //     showmessage('here2');

  try

  if CDSTimeseries.Active=true then CDSTimeseries.Close;
     CDSTimeseries.Open;

    DBGrid1.Enabled:=false;
    CDSTimeseries.DisableControls;
    CDSTimeseries.First;



  {if step='Month' then begin
   steps_between:=MonthsBetween(dtp_min.Date, dtp_max.Date)+2;
  // showmessage(inttostr(steps_between));
    for k:=0 to steps_between-1 do begin
     with CDSTimeseries do begin
      Append;
       FieldByName('date').Value:=IncMonth(dtp_min.Date, k);
      Post;
     end;
    end;
  end;

  if step='Day' then begin
   steps_between:=DaysBetween(dtp_min.Date, dtp_max.Date)+2;
    for k:=0 to steps_between-1 do begin
     with CDSTimeseries do begin
      Append;
       FieldByName('date').Value:=IncDay(dtp_min.Date, k);
      Post;
     end;
    end;
  end;        }
  DecodeDate(dtp_min.Date, yy1, mn1, dd1);
  DecodeDate(dtp_max.Date, yy2, mn2, dd2);

 //  showmessage('here2');

    with Qt1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select * from "'+tbl+'" ');
      SQL.Add(' where "station_id"=:id ');
      if rgClipping.ItemIndex=0 then
        SQL.Add(' and "date" between :date_min and :date_max ');
      if rgClipping.ItemIndex=1 then begin
        SQL.Add(' and Extract(Year from "date") between :yy1 and :yy2 ');
        SQL.Add(' and Extract(Month from "date") between :mn1 and :mn2 ');
        SQL.Add(' and Extract(Day from "date") between :dd1 and :dd2 ');
      end;
      if chkHideOutliers.Checked then
        SQL.Add(' and "pqf2"=0 ');

      SQL.Add(' order by "date" ');
      ParamByName('id').Value:=id;
      if rgClipping.ItemIndex=0 then begin
        ParamByName('date_min').Value:=dtp_min.Date;
        ParamByName('date_max').Value:=dtp_max.Date;
      end;
      if rgClipping.ItemIndex=1 then begin
        ParamByName('yy1').Value:=yy1;
        ParamByName('yy2').Value:=yy2;
        ParamByName('mn1').Value:=mn1;
        ParamByName('mn2').Value:=mn2;
        ParamByName('dd1').Value:=dd1;
        ParamByName('dd2').Value:=dd2;
      end;
    // showmessage(sql.text);
     Open;
    end;

   //  showmessage('here2');

  Qt1.First;
  while not Qt1.EOF do begin
   dat1:=Qt1.FieldByName('date').Value;
   val1:=Qt1.FieldByName('value').Value;
   pqf2:=Qt1.FieldByName('pqf2').Value;

     with CDSTimeseries do begin
      Append;
      { if VarIsNull(Lookup('date', dat1, 'date')) then Append else begin
         Locate('date',dat1,[]);
         Edit;
       end;  }
        FieldByName('date').AsDateTime:=dat1;
        FieldByName('val').AsFloat:=val1;
        FieldByName('flag').AsInteger:=pqf2;
       Post;
     end;

   Qt1.Next;
  end;
  Qt1.First;

 //  showmessage('here0');
  Series1.Clear;
  CDSTimeseries.First;
  while not CDSTimeseries.EOF do begin
    dat1:=CDSTimeseries.FieldByName('date').AsDateTime;
    val1:=CDSTimeseries.FieldByName('val').Value;
    pqf2:=CDSTimeseries.FieldByName('flag').Value;

    if Val1=null then Val1:=Nan;

    if pqf2=0 then clr:=clBlue else clr:=clRed;

    txt:='Date: '+datetimetostr(dat1)+'; Value: '+VarToStr(val1);
    Series1.AddXY(dat1, val1, txt, clr);
    CDSTimeseries.Next;
  end;
  DS.DataSet:=CDSTimeseries;


  finally
    Qt1.Close;
    Qt1.Free;
    Trt.Commit;
    Trt.Free;
    CDSTimeseries.First;
    CDSTimeseries.EnableControls;
    DBGrid1.Enabled:=true;
    DBGrid1.refresh;
  end;
end;

procedure Tfrmtimeseries.ctDPCPointClick(ATool: TChartTool; APoint: TPoint);
Var
 tool: TDataPointClicktool;
 series: TLineSeries;
begin
 showmessage('here');
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
    //showmessage(inttostr(tool.PointIndex));
    if (tool.PointIndex<>-1) then begin
      //CDSTimeseries.Locate('date', series.XValue[tool.PointIndex], []);
    end;
  end;
end;

procedure Tfrmtimeseries.ctDPHHint(ATool: TDataPointHintTool;
  const APoint: TPoint; var AHint: String);
begin
  AHint := TLineSeries(ATool.Series).Source.Item[ATool.PointIndex]^.Text;
end;


procedure Tfrmtimeseries.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  open_timeseries:=false;
end;


end.

