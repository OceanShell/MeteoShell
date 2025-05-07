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
    FBDB2: TIBConnection;
    PGDB: TPQConnection;
    PGDB2: TPQConnection;
    FBDB: TIBConnection;
    CDS: TSQLQuery;
    DBLoader: TSQLDBLibraryLoader;
    q2: TSQLQuery;
    q3: TSQLQuery;
    TR: TSQLTransaction;
    q1: TSQLQuery;
    TR2: TSQLTransaction;

    procedure CDSAfterEdit(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
    procedure ConnectMetadataDB(DBUser, DBPass, DBHost, DBName:string);
    procedure ConnectDataDB(DBName:string);
  end;

var
  frmdm: Tfrmdm;

implementation

{$R *.lfm}

uses main;

{ Tfrmdm }

procedure Tfrmdm.ConnectMetadataDB(DBUser, DBPass, DBHost, DBName:string);
begin
if TR.Active then TR.Commit;

try
  case server_ind of
    0: begin (* Firebird *)
      with DBLoader do begin
        {$IFDEF WINDOWS}
          LibraryName:=GlobalPath+'fbclient.dll';
        {$ENDIF}
        {$IFDEF LINUX}
          LibraryName:=GlobalPath+'libfbclient.so.3.0.5';
        {$ENDIF}
        {$IFDEF DARWIN}
          LibraryName:=GlobalPath+'libfbclient.dylib';
        {$ENDIF}
        Enabled:=true;
      end;

      FBDB.Connected:=false;
      FBDB.UserName:=DBUser;
      FBDB.Password:=DBPass;
      FBDB.HostName:=DBHost;
      FBDB.DatabaseName:=DBName;
      FBDB.Connected:=true;
      TR.DataBase:=FBDB;
      CDS.DataBase:=FBDB;
      CDS2.DataBase:=FBDB;
      q1.DataBase:=FBDB;
      q2.DataBase:=FBDB;
      q3.DataBase:=FBDB;
    end; (* Firebird *)

    1: begin (* PostgreSQL *)
      DBLoader.Enabled:=false;
      PGDB.Connected:=false;
      PGDB.UserName:=DBUser;
      PGDB.Password:=DBPass;
      PGDB.HostName:=DBHost;
      PGDB.DatabaseName:=DBName;
      PGDB.Connected:=true;
      TR.DataBase:=PGDB;
      CDS.DataBase:=PGDB;
      CDS2.DataBase:=PGDB;
      q1.DataBase:=PGDB;
      q2.DataBase:=PGDB;
      q3.DataBase:=PGDB;
    end; (* PostgreSQL *)
  end;
except
  on e: Exception do begin
    if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then exit;
  end;
end;
end;


procedure Tfrmdm.ConnectDataDB(DBName:string);
begin
try
  case server_ind of
    0: begin (* Firebird *)
      DBLoader.Enabled:=true;
      FBDB2.Connected:=false;
      FBDB2.UserName:=FBDB.UserName;
      FBDB2.Password:=FBDB.Password;
      FBDB2.HostName:=FBDB.HostName;
      FBDB2.DatabaseName:=DBName;
      FBDB2.Connected:=true;
      TR2.DataBase:=FBDB2;
    end; (* Firebird *)

    1: begin (* PostgreSQL *)
      DBLoader.Enabled:=false;
      PGDB2.Connected:=false;
      PGDB2.UserName:=PGDB.UserName;
      PGDB2.Password:=PGDB.Password;
      PGDB2.HostName:=PGDB.HostName;
      PGDB2.DatabaseName:=DBName;
      PGDB2.Connected:=true;
      TR2.DataBase:=PGDB2;
    end; (* PostgreSQL *)
  end;
except
  on e: Exception do begin
    if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then exit;
  end;
end;
end;

procedure Tfrmdm.DataModuleDestroy(Sender: TObject);
begin
 TR.Commit;

 if DBLoader.Enabled=true then DBLoader.Enabled:=false;

 if FBDB.Connected then FBDB.Close(true);
 if FBDB2.Connected then FBDB2.Close(true);

 if PGDB.Connected then PGDB.Close(true);
end;

procedure Tfrmdm.CDSAfterEdit(DataSet: TDataSet);
begin
   frmmain.btncommit.Enabled:=true;
end;

end.

