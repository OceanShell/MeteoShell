unit dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Controls, IBConnection, sqldb, sqldblib,
  pqconnection, BufDataset, db;

type

  { Tfrmdm }

  Tfrmdm = class(TDataModule)
    CDS2: TSQLQuery;
    PGDB: TPQConnection;
    q2: TSQLQuery;
    q3: TSQLQuery;
    FBDB: TIBConnection;
    CDS: TSQLQuery;
    DBLoader: TSQLDBLibraryLoader;
    q4: TSQLQuery;
    TR: TSQLTransaction;
    q1: TSQLQuery;

    procedure DataModuleDestroy(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmdm: Tfrmdm;


implementation

{$R *.lfm}

{ Tfrmdm }


procedure Tfrmdm.DataModuleDestroy(Sender: TObject);
begin
 TR.Commit;

 if DBLoader.Enabled=true then DBLoader.Enabled:=false;

 if FBDB.Connected then FBDB.Close(true);
 if PGDB.Connected then PGDB.Close(true);
end;

end.

