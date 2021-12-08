unit grapher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Main, IniFiles;

procedure PlotTimeSeries(fname, title, par, units, xtitle:string; col:integer);
procedure PlotMonthlyComposition(fpath, title, par, units, xtitle:string);

implementation

procedure PlotTimeSeries(fname, title, par, units, xtitle:string; col:integer);
Var
 Ini:TIniFile;
 Script:text;
 running, linear, timeseries:boolean;
 run_wnd:integer;
begin

 try
 Ini := TIniFile.Create(IniFileName);
   timeseries:=Ini.ReadBool( 'Grapher', 'Timeseries', true);
   running:=Ini.ReadBool   ( 'Grapher', 'Running',    true);
   run_wnd:=Ini.ReadInteger( 'Grapher', 'RunWindow',    5);
   linear :=Ini.ReadBool   ( 'Grapher', 'Linear',     true);
 finally
  ini.Free;
 end;

AssignFile(script, GlobalPath+'unload\timeseries\timeseries.bas'); rewrite(script);

Writeln(script, 'Sub Main');
Writeln(script, '');
Writeln(script, ' Dim Grapher, Plot, Graph As Object');
Writeln(script, '');
Writeln(script, ' Set Grapher = CreateObject("Grapher.Application")');
Writeln(script, ' Grapher.Visible = True');
Writeln(script, '');
Writeln(script, ' Set Plot = Grapher.Documents.Add(grfPlotDoc)');
Writeln(script, '     Plot.PageSetup.Orientation = grfPortrait');
Writeln(script, '');
Writeln(script, 'Set Diagram = Plot.Windows(1)');
Writeln(script, '');
Writeln(script, ' Set Graph = Plot.Shapes.AddLinePlotGraph("'+fname+'", 1, '+inttostr(col)+', "'+Utf8ToAnsi(par)+'")');
Writeln(script, ' Graph.title.text = "'+Utf8ToAnsi(title)+'"');
Writeln(script, ' Graph.title.line.style = "Invisible"');
Writeln(script, ' Graph.title.Font.size=12');
Writeln(script, '');
Writeln(script, ' Graph.Plots.Item(1).Name = "Time series"');
Writeln(script, ' Graph.Plots.Item(1).Line.ForeColor = grfColorBlack60');
Writeln(script, ' Graph.Plots.Item(1).Clipping.Continuous = False ');
if timeseries=false then
  Writeln(script, '  Graph.Plots.Item(1).Visible = False ');
Writeln(script, '');
 if linear=true then begin
  Writeln(script, ' Set FitCurve1 = Graph.Plots.Item(1).AddFit(0, "Linear averaging")');
  Writeln(script, '       FitCurve1.Line.ForeColor=grfColorRed');
  Writeln(script, '       FitCurve1.Line.Width = 6E-2');
  Writeln(script, '');
 end;
 if running=true then begin
  Writeln(script, ' Set FitCurve2 = Graph.Plots.Item(1).AddFit(8, "Running averagind")');
  Writeln(script, '       FitCurve2.Option = '+InttoStr(run_wnd));
  Writeln(script, '       FitCurve2.Line.ForeColor=grfColorBlue');
  Writeln(script, '       FitCurve2.Line.Width = 6E-2');
  Writeln(script, '');
 end;
Writeln(script, 'Set Axes = Graph.Axes');
Writeln(script, '');
Writeln(script, 'Set Axis1 = Axes.Item(1)');
Writeln(script, 'Axis1.Title.Text = '+Utf8ToAnsi('"'+xtitle+'"'));
Writeln(script, 'Axis1.Grid.AtMajorTicks = False');
Writeln(script, 'Axis1.Grid.MajorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis1.Ticklabels.MajorOn = True');
Writeln(script, 'Axis1.Ticklabels.MajorFont.Size=10');
Writeln(script, 'Axis1.Tickmarks.MajorLength = 0.25');
Writeln(script, 'Axis1.Grid.AtMinorTicks = False');
Writeln(script, 'Axis1.Grid.MinorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis1.Ticklabels.MinorOn = True');
Writeln(script, 'Axis1.Ticklabels.MinorFont.Size=10');
Writeln(script, 'Axis1.Tickmarks.MinorLength = 0.25');
Writeln(script, '');
Writeln(script, 'Set Axis2 = Axes.Item(2)');
if units<>'' then
Writeln(script, 'Axis2.Title.Text = "'+{Utf8ToAnsi(par)+',} '['+Utf8ToAnsi(units)+']"');
Writeln(script, 'Axis2.Grid.AtMajorTicks = False');
Writeln(script, 'Axis2.Grid.MajorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis2.Ticklabels.MajorOn = True');
Writeln(script, 'Axis2.Ticklabels.MajorFont.Size=10');
Writeln(script, 'Axis2.Tickmarks.MajorLength = 0.25');
Writeln(script, 'Axis2.Grid.AtMinorTicks = False');
Writeln(script, 'Axis2.Grid.MinorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis2.Ticklabels.MinorOn = True');
Writeln(script, 'Axis2.Ticklabels.MinorFont.Size=10');
Writeln(script, 'Axis2.Tickmarks.MinorLength = 0.25');
Writeln(script, '');
Writeln(script, 'Diagram.zoom(grfZoomFitToWindow)');
Writeln(script, '');
Writeln(script, 'End Sub');

CloseFile(script);
end;


procedure PlotMonthlyComposition(fpath, title, par, units, xtitle:string);
Var
 Ini:TIniFile;
 Script:text;
 running, linear, timeseries:boolean;
 run_wnd, k, plt_cnt, c:integer;
 SetColor, mn: string;
begin

 try
 Ini := TIniFile.Create(IniFileName);
   timeseries:=Ini.ReadBool( 'Grapher', 'Timeseries', true);
   running:=Ini.ReadBool   ( 'Grapher', 'Running',    true);
   run_wnd:=Ini.ReadInteger( 'Grapher', 'RunWindow',    5);
   linear :=Ini.ReadBool   ( 'Grapher', 'Linear',     true);
 finally
  ini.Free;
 end;

AssignFile(script, GlobalPath+'unload\timeseries\timeseries.bas'); rewrite(script);

Writeln(script, 'Sub Main');
Writeln(script, '');
Writeln(script, ' Dim Grapher, Plot, Graph As Object');
Writeln(script, '');
Writeln(script, ' Set Grapher = CreateObject("Grapher.Application")');
Writeln(script, ' Grapher.Visible = True');
Writeln(script, '');
Writeln(script, ' Set Plot = Grapher.Documents.Add(grfPlotDoc)');
Writeln(script, '     Plot.PageSetup.Orientation = grfLandscape');
Writeln(script, '');
Writeln(script, 'Set Diagram = Plot.Windows(1)');
Writeln(script, '');

plt_cnt:=0;
for k:=1 to 13 do begin
  case k of
    1: begin mn:='January'; SetColor:='grfColorBlack50'; end;
    2: begin mn:='February'; SetColor:='grfColorBlack30'; end;
    3: begin mn:='March'; SetColor:='grfColorBrown'; end;
    4: begin mn:='April'; SetColor:='grfColorGreen'; end;
    5: begin mn:='May'; SetColor:='grfColorPink'; end;
    6: begin mn:='June'; SetColor:='grfColorMagenta'; end;
    7: begin mn:='July'; SetColor:='grfColorRed'; end;
    8: begin mn:='August'; SetColor:='grfColorPurple'; end;
    9: begin mn:='September'; SetColor:='grfColorForestGreen'; end;
   10: begin mn:='October'; SetColor:='grfColorCyan'; end;
   11: begin mn:='November'; SetColor:='grfColorBlue'; end;
   12: begin mn:='December'; SetColor:='grfColorBlack80'; end;
   13: begin mn:='Annual'; SetColor:='grfColorBlack'; end;
  end;

  if k=1 then begin
    Writeln(script, ' Set Graph = Plot.Shapes.AddLinePlotGraph("'+fpath+inttostr(k)+'.dat'+'", 1, 2, "'+Utf8ToAnsi(par)+'")');
    Writeln(script, ' Graph.title.text = "'+Utf8ToAnsi(title)+'"');
    Writeln(script, ' Graph.title.line.style = "Invisible"');
    Writeln(script, ' Graph.title.Font.size=12');
    plt_cnt:=k;
  end;

  if k>1 then begin
    Writeln(script, ' Graph.AddLinePlot("'+fpath+inttostr(k)+'.dat'+'", 1, 2)');
    inc(plt_cnt);
  end;

    Writeln(script, ' Graph.Plots.Item('+inttostr(plt_cnt)+').Name = "'+mn+'"');
    Writeln(script, ' Graph.Plots.Item('+inttostr(plt_cnt)+').Line.ForeColor = '+SetColor);
    Writeln(script, ' Graph.Plots.Item('+inttostr(plt_cnt)+').Clipping.Continuous = False ');

  if timeseries=false then
     Writeln(script, '  Graph.Plots.Item('+inttostr(plt_cnt)+').Visible = False ');

  c:=0;
  if linear=true then begin
    Writeln(script, ' Set FitCurve1 = Graph.Plots.Item('+inttostr(plt_cnt)+').AddFit(0, "'+mn+'_linear")');
    Writeln(script, '       FitCurve1.Line.ForeColor = '+SetColor);
    Writeln(script, '       FitCurve1.Line.Width = 6E-2');
    inc(c);
  end;
  if running=true then begin
    Writeln(script, ' Set FitCurve2 = Graph.Plots.Item('+inttostr(plt_cnt)+').AddFit(8, "'+mn+'_run_avg")');
    Writeln(script, '       FitCurve2.Option = '+InttoStr(run_wnd));
    Writeln(script, '       FitCurve2.Line.ForeColor = '+SetColor);
    Writeln(script, '       FitCurve2.Line.Width = 6E-2');
    inc(c);
  end;
  plt_cnt:=plt_cnt+c;
  Writeln(script, '');
end;
Writeln(script, 'Set Axes = Graph.Axes');
Writeln(script, '');
Writeln(script, 'Set Axis1 = Axes.Item(1)');
Writeln(script, 'Axis1.Title.Text = '+Utf8ToAnsi('"'+xtitle+'"'));
Writeln(script, 'Axis1.Grid.AtMajorTicks = False');
Writeln(script, 'Axis1.Grid.MajorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis1.Ticklabels.MajorOn = True');
Writeln(script, 'Axis1.Ticklabels.MajorFont.Size=10');
Writeln(script, 'Axis1.Tickmarks.MajorLength = 0.25');
Writeln(script, 'Axis1.Grid.AtMinorTicks = False');
Writeln(script, 'Axis1.Grid.MinorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis1.Ticklabels.MinorOn = True');
Writeln(script, 'Axis1.Ticklabels.MinorFont.Size=10');
Writeln(script, 'Axis1.Tickmarks.MinorLength = 0.25');
Writeln(script, '');
Writeln(script, 'Set Axis2 = Axes.Item(2)');
if units<>'' then
Writeln(script, 'Axis2.Title.Text = "'+{Utf8ToAnsi(par)+',} '['+Utf8ToAnsi(units)+']"');
Writeln(script, 'Axis2.Grid.AtMajorTicks = False');
Writeln(script, 'Axis2.Grid.MajorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis2.Ticklabels.MajorOn = True');
Writeln(script, 'Axis2.Ticklabels.MajorFont.Size=10');
Writeln(script, 'Axis2.Tickmarks.MajorLength = 0.25');
Writeln(script, 'Axis2.Grid.AtMinorTicks = False');
Writeln(script, 'Axis2.Grid.MinorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis2.Ticklabels.MinorOn = True');
Writeln(script, 'Axis2.Ticklabels.MinorFont.Size=10');
Writeln(script, 'Axis2.Tickmarks.MinorLength = 0.25');
Writeln(script, '');
//Writeln(script, 'Set Legend = Graph.AddLegend(True)');

Writeln(script, 'Diagram.zoom(grfZoomFitToWindow)');
Writeln(script, '');
Writeln(script, 'End Sub');

CloseFile(script);
end;

end.

