unit editdata;

{$mode objfpc}{$H+}

interface

uses SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, DB, DbCtrls, ExtCtrls, ComCtrls,
     sqldb, LCLTranslator, DBGrids, TAGraph, TADbSource, TASeries;

type

  { Tfrmeditdata }

  Tfrmeditdata = class(TForm)
    btnCommit: TToolButton;
    Chart1: TChart;
    dbs: TDbChartSource;
    DBGrid1: TDBGrid;

    ds: TDataSource;
    ibq: TSQLQuery;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;

    procedure btnCommitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
{
    procedure DBChart1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGridEh1CellClick(Column: TColumnEh);
    procedure DBGridEh1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);     }
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmeditdata: Tfrmeditdata;
  new_series : TLineSeries;

implementation

{$R *.lfm}

uses main, dm;


procedure Tfrmeditdata.FormShow(Sender: TObject);
Var
 ID:integer;
begin
 ID:=frmdm.CDS.FieldByName('id').AsInteger;
 with ibq do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select value.id, value.date_, value.value_, value.flag_ ');
    SQL.Add(' from value, parameter ');
    SQL.Add(' where value.parameter_id=parameter.id ');
    SQL.Add(' and value.id=:id and parameter.name=:par ');
    SQL.Add(' order by value.date_ ');
    ParamByName('id').AsInteger:=id;
    ParamByName('par').AsString:=frmdm.CDS2.FieldByName('par').AsString;
   Open;
   Last;
   First;
  end;

   With DBGrid1 do begin
    Columns[0].Visible:=false;
    Columns[1].Title.Caption:=SDate;
    Columns[2].Title.Caption:=SValue;
    Columns[3].Title.Caption:=SFlag;
  end;

  new_series := TLineSeries.Create(nil);

   (* link between value and line *)
  new_series.Marks.LinkPen.Color := clBlack;
  new_series.Marks.LinkPen.Width := 1;
  new_series.Marks.LinkPen.EndCap := pecRound;
  new_series.Marks.LinkPen.JoinStyle := pjsRound;
  (* points *)
  new_series.Pointer.Brush.Color := clRed;
  new_series.Pointer.Visible := True;
 // new_series.Pointer.Style := psCircle;
  new_series.Pointer.HorizSize := 2;
  new_series.Pointer.VertSize := 2;
  new_series.ShowPoints := True;

  new_series.Marks.Clipped := True;
  new_series.Marks.LabelBrush.Color := clSkyBlue;
  new_series.Marks.LabelBrush.Style := bsSolid;
  new_series.Marks.Frame.Color := clBlack;
  new_series.Marks.Frame.Width := 1;
  new_series.Marks.Frame.Mode := pmCopy;

  new_series.Source:=dbs;

  chart1.AddSeries(new_series);

end;

{

procedure Tfrmeditdata.DBChart1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
Num_Clicked:int64;
LVar:array[0..2] of Variant;
begin
{series2.Clear;
with series1 do
  begin
  Num_Clicked:=Clicked(X,Y);
    if Num_Clicked<>-1 then
     begin
       DbGridEh1.DataSource.DataSet.RecNo:=trunc(XValues[Num_clicked])+1;
      DBChart1.Series[1].AddXY(XValues[Num_Clicked],YValues[Num_Clicked]);
     end;
  end;  }
end;

procedure Tfrmeditdata.DBGridEh1CellClick(Column: TColumnEh);
begin
 if not VarIsNull(ibq.FieldByName('Val_').AsVariant) then begin
 // series2.Clear;
 //  Series2.AddXY(cds.RecNo,cds.FieldValues['Val_']);
 end;
end;

procedure Tfrmeditdata.DBGridEh1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumnEh;
  State: TGridDrawState);
begin
if (Rect.Top = DBGridEh1.CellRect(DBGridEh1.Col,DBGridEh1.Row).Top) and
   (not (gdFocused in State) or not DBGridEh1.Focused) then begin
    DBGridEh1.Canvas.Brush.Color := clNavy;
    DBGridEh1.Canvas.Font.Color:= clWhite;
    DBGridEh1.Canvas.Font.Style:=[fsBold];
 end;
  DBGridEh1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
end;

procedure Tfrmeditdata.DBGridEh1GetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
begin
if DBGridEh1.SumList.RecNo mod 2=1 then
       Background:=$00CFFFF6 else Background:=$00CFEFE6;
end;

procedure Tfrmeditdata.DBGridEh1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//series2.Clear;
// if (cds.FieldValues['VAL_']<>null) then Series2.AddXY(cds.RecNo,cds.FieldValues['Val_']);
end;
}

procedure Tfrmeditdata.ToolButton1Click(Sender: TObject);
begin
  ibq.Insert;
end;

procedure Tfrmeditdata.ToolButton2Click(Sender: TObject);
begin
  ibq.Delete;
end;

procedure Tfrmeditdata.ToolButton3Click(Sender: TObject);
begin
  ibq.CancelUpdates;
end;

procedure Tfrmeditdata.btnCommitClick(Sender: TObject);
begin
  ibq.ApplyUpdates(0);
end;

end.
