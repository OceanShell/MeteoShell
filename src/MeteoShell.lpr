program MeteoShell;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, icons, dm, load_ghcnd, timeseries, datetimectrls,
  update_station_info, load_ghcnv4_prcp, load_ecad, Load_isd, windchartrose;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrmmain, frmmain);
  Application.CreateForm(Tfrmicons, frmicons);
  Application.CreateForm(Tfrmdm, frmdm);
  Application.Run;
end.

