unit tool_parameter_compare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBGrids, Spin, TAGraph, TASeries, Variants;

type

  { Tfrmcompare_parameters }

  Tfrmcompare_parameters = class(TForm)
    btnCompare: TButton;
    cbParameter1: TComboBox;
    cbParameter2: TComboBox;
    cbTimeStep: TComboBox;
    Chart1: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    DBGrid1: TDBGrid;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    seID1: TSpinEdit;
    seID2: TSpinEdit;
    Splitter1: TSplitter;

    procedure btnCompareClick(Sender: TObject);
    procedure cbTimeStepSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure seID1Change(Sender: TObject);
    procedure seID2Change(Sender: TObject);

  private

  public

  end;

var
  frmcompare_parameters: Tfrmcompare_parameters;

implementation

{$R *.lfm}

uses dm;

{ Tfrmcompare_parameters }

procedure Tfrmcompare_parameters.FormShow(Sender: TObject);
begin
 seID1.Value:=frmdm.CDS.FieldByName('id').Value;
 seID2.Value:=seID1.Value;

 seID1.OnChange(self);
end;


procedure Tfrmcompare_parameters.btnCompareClick(Sender: TObject);
begin

end;



procedure Tfrmcompare_parameters.seID1Change(Sender: TObject);
begin
  if not VarIsNull(frmdm.CDS.Lookup('id', seID1.Value, 'id')) then begin

 //  showmessage(vartostr(seID1.Value));
    with frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' select distinct("timestep"."name") ');
       SQL.Add(' from "timestep", "table", "station_info" ');
       SQL.Add(' where ');
       SQL.Add(' "station_info"."station_id"=:id and ');
       SQL.Add(' "station_info"."table_id"="table"."id" and ');
       SQL.Add(' "table"."timestep_id"="timestep"."id" ');
       ParamByName('id').Value:=seID1.Value;
    Open;
   end;

   cbTimestep.Clear;
   while not frmdm.q1.eof do begin
      cbTimestep.Items.Add(frmdm.q1.Fields[0].AsString);
     frmdm.q1.Next;
   end;
   cbTimestep.Enabled:=true;
  end else begin
    cbTimestep.Enabled:=false;
  end;

  seID2.Enabled:=false;

  cbParameter1.Enabled:=false;
  cbParameter2.Enabled:=false;
end;

procedure Tfrmcompare_parameters.cbTimeStepSelect(Sender: TObject);
begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("parameter"."name") ');
     SQL.Add(' from "parameter", "table", "station_info", "timestep" ');
     SQL.Add(' where ');
     SQL.Add(' "station_info"."station_id"=:id and ');
     SQL.Add(' "timestep"."name"=:step and ');
     SQL.Add(' "station_info"."table_id"="table"."id" and ');
     SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
     SQL.Add(' "table"."timestep_id"="timestep"."id" ');
     ParamByName('id').Value:=seID1.Value;
     ParamByName('step').Value:=cbTimestep.Text;
   Open;
  end;

  cbParameter1.Clear;
  while not frmdm.q1.eof do begin
    cbParameter1.Items.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
  cbParameter1.Enabled:=true;
  seID2.Enabled:=true;
  seID2.OnChange(self);
end;


procedure Tfrmcompare_parameters.seID2Change(Sender: TObject);
begin
 if not VarIsNull(frmdm.CDS.Lookup('id', seID2.Value, 'id')) then begin
  with frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' select distinct("parameter"."name") ');
       SQL.Add(' from "parameter", "table", "station_info", "timestep" ');
       SQL.Add(' where ');
       SQL.Add(' "station_info"."station_id"=:id and ');
       SQL.Add(' "timestep"."name"=:step and ');
       SQL.Add(' "station_info"."table_id"="table"."id" and ');
       SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
       SQL.Add(' "table"."timestep_id"="timestep"."id" ');
       ParamByName('id').Value:=seID2.Value;
       ParamByName('step').Value:=cbTimestep.Text;
     Open;
    end;

    cbParameter2.Clear;
    while not frmdm.q1.eof do begin
      cbParameter2.Items.Add(frmdm.q1.Fields[0].AsString);
     frmdm.q1.Next;
    end;
  cbParameter2.Enabled:=true;
 end;
end;

end.

