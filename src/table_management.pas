unit table_management;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqldb, Forms, Controls, Graphics, Dialogs, DBGrids,
  ComCtrls, StdCtrls, DBCtrls;

type

  { Tfrmtablemanagement }

  Tfrmtablemanagement = class(TForm)
    btnadd: TToolButton;
    btncommit: TToolButton;
    btndelete: TToolButton;
    cbtable: TComboBox;
    DBGrid1: TDBGrid;
    DS: TDataSource;
    ToolBar1: TToolBar;
    ToolButton4: TToolButton;

    procedure cbtableSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnaddClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure btncommitClick(Sender: TObject);
    procedure btndeleteClick(Sender: TObject);

  private

  public

  end;

var
  frmtablemanagement: Tfrmtablemanagement;

implementation

{$R *.lfm}

uses main, dm;

{ Tfrmtablemanagement }

procedure Tfrmtablemanagement.FormShow(Sender: TObject);
begin
  cbtable.OnSelect(self);
end;

procedure Tfrmtablemanagement.cbtableSelect(Sender: TObject);
begin
 with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add('Select * from "'+lowercase(cbTable.Text)+'"');
   Open;
  end;
end;

procedure Tfrmtablemanagement.btnaddClick(Sender: TObject);
begin
  frmdm.q1.Append;
end;

procedure Tfrmtablemanagement.btndeleteClick(Sender: TObject);
begin
  frmdm.q1.Delete;
end;

procedure Tfrmtablemanagement.btncancelClick(Sender: TObject);
begin
  frmdm.q1.Cancel;
end;

procedure Tfrmtablemanagement.btncommitClick(Sender: TObject);
begin
 frmdm.q1.ApplyUpdates(0);
 frmdm.TR.CommitRetaining;
 frmdm.q1.Refresh;
end;

end.

