program MeteoShell;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, icons, dm, comparesources, metadata_sources;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrmmain, frmmain);
  Application.CreateForm(Tfrmicons, frmicons);
  Application.CreateForm(Tfrmdm, frmdm);
  Application.CreateForm(Tfrmmetadata_sources, frmmetadata_sources);
  Application.Run;
end.

