unit metadata_sources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqldb, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids;

type

  { Tfrmmetadata_sources }

  Tfrmmetadata_sources = class(TForm)
    DBGrid_ghcn_v2: TDBGrid;
    DBGrid_ghcn_v3: TDBGrid;
    DBGrid_ghcn_v4: TDBGrid;
    DBGrid_ghcn_v4_prcp: TDBGrid;
    DS_ds570: TDataSource;
    DBGrid_ds570: TDBGrid;
    DS_ghcn_v2: TDataSource;
    DS_ghcn_v3: TDataSource;
    DS_ghcn_v4: TDataSource;
    DS_ghcn_v4_prcp: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    q_ds570: TSQLQuery;
    q_ghcn_v2: TSQLQuery;
    q_ghcn_v3: TSQLQuery;
    q_ghcn_v4: TSQLQuery;
    q_ghcn_v4_prcp: TSQLQuery;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private

  public
    procedure ChangeID;
  end;

var
  frmmetadata_sources: Tfrmmetadata_sources;

implementation

{$R *.lfm}

uses main, dm;

{ Tfrmmetadata_sources }

procedure Tfrmmetadata_sources.FormShow(Sender: TObject);
begin
  ChangeID;
end;

procedure Tfrmmetadata_sources.ChangeID;
var
  id: integer;
begin
  ID:=frmdm.CDS.FieldByName('id').AsInteger;

  with q_ds570 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from "station_ds570" ');
    SQL.Add(' where "id" in (select "ds570_id" from "station" ');
    SQL.Add(' where "id"='+inttostr(id)+')');
   Open;
  end;

  with q_ghcn_v2 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from "station_ghcn_v2" ');
    SQL.Add(' where "id" in (select "ghcn_v2_id" from "station" ');
    SQL.Add(' where "id"='+inttostr(id)+')');
   Open;
  end;

  with q_ghcn_v3 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from "station_ghcn_v3" ');
    SQL.Add(' where "id" in (select "ghcn_v3_id" from "station" ');
    SQL.Add(' where "id"='+inttostr(id)+')');
   Open;
  end;

  with q_ghcn_v4 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from "station_ghcn_v4" ');
    SQL.Add(' where "id" in (select "ghcn_v4_id" from "station" ');
    SQL.Add(' where "id"='+inttostr(id)+')');
   Open;
  end;

  with q_ghcn_v4_prcp do begin
   Close;
    SQL.Clear;
    SQL.Add(' select * from "station_ghcn_v4_prcp" ');
    SQL.Add(' where "id" in (select "ghcn_v4_prcp_id" from "station" ');
    SQL.Add(' where "id"='+inttostr(id)+')');
   Open;
  end;

end;


procedure Tfrmmetadata_sources.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  Open_metadata_sources:=false;

  q_ds570.Close;
  q_ghcn_v2.Close;
  q_ghcn_v3.Close;
  q_ghcn_v4.Close;
end;

end.

