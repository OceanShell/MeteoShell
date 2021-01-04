unit table_management;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqldb, Forms, Controls, Graphics, Dialogs, DBGrids,
  ComCtrls, StdCtrls, DBCtrls, IniFiles;

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

    procedure FormShow(Sender: TObject);
    procedure cbtableDropDown(Sender: TObject);
    procedure cbtableSelect(Sender: TObject);
    procedure btnaddClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure btncommitClick(Sender: TObject);
    procedure btndeleteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

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
Var
  Ini:TIniFile;
begin
  try
    Ini := TIniFile.Create(IniFileName);

    Top   :=Ini.ReadInteger( 'table_management', 'top',    50);
    Left  :=Ini.ReadInteger( 'table_management', 'left',   50);
    Width :=Ini.ReadInteger( 'table_management', 'width',  900);
    Height:=Ini.ReadInteger( 'table_management', 'height', 500);

  finally
    Ini.Free;
  end;
  cbtable.OnSelect(self);
end;

procedure Tfrmtablemanagement.cbtableSelect(Sender: TObject);
Var
  Ini:TIniFile;
  k: integer;
begin
 with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add('Select * from "'+lowercase(cbTable.Text)+'"');
   Open;
  end;

 Ini := TIniFile.Create(IniFileName);
 try
   for k:=0 to DBGrid1.Columns.Count-1 do
     DBGrid1.Columns[k].Width:=Ini.ReadInteger(cbTable.Text, 'DBGrid1_'+inttostr(k), 100);
 finally
   Ini.Free;
 end;
end;

procedure Tfrmtablemanagement.cbtableDropDown(Sender: TObject);
Var
  Ini:TIniFile;
  k: integer;
begin
  if DBGrid1.Columns.Count>0 then begin
    Ini := TIniFile.Create(IniFileName);
    try
      for k:=0 to DBGrid1.Columns.Count-1 do
        Ini.WriteInteger(cbTable.Text, 'DBGrid1_'+inttostr(k), DBGrid1.Columns[k].Width);
    finally
      Ini.Free;
    end;
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

procedure Tfrmtablemanagement.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger('table_management', 'top',    Top);
    Ini.WriteInteger('table_management', 'left',   Left);
    Ini.WriteInteger('table_management', 'width',  Width);
    Ini.WriteInteger('table_management', 'height', Height);
  finally
    Ini.Free;
  end;
end;

end.

