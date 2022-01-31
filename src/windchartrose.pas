unit windchartrose;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DateUtils, Buttons;

type

  { Tfrmwindchart }

  Tfrmwindchart = class(TForm)
    btnPlot: TButton;
    rgChart: TRadioGroup;
    btnOpenScript: TBitBtn;
    btnOpenFolder: TBitBtn;

    procedure FormCreate(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);

  private
    { Private declarations }
    procedure WindScript;
  public
    { Public declarations }
  end;

var
  frmwindchart: Tfrmwindchart;
  wndchartpath:string;


implementation

{$R *.lfm}

uses dm, main;



procedure Tfrmwindchart.FormCreate(Sender: TObject);
Var
 k, ID, i_id, table_id_wnd, table_id_dir:integer;
 tbl_spd, tbl_dir, src:string;
 time1:TDateTime;
 wnd, dir: real;
 wndd:text;
begin
  wndchartpath:=GlobalUnloadPath+'wnd'+PathDelim;
  if not DirectoryExists(wndchartpath) then CreateDir(wndchartpath);

  ID:=frmdm.CDS.FieldByName('id').AsInteger;

   table_id_wnd:=frmdm.CDS2.FieldByName('id').Value;
   src:=frmdm.CDS2.FieldByName('src').Value;

   try
    frmdm.CDS2.DisableControls;
    frmdm.CDS2.First;
    table_id_dir:=-9;
   while not frmdm.CDS2.EOF do begin
     if (frmdm.CDS2.FieldByName('par').Value='Wind direction') and
        (frmdm.CDS2.FieldByName('src').Value=src) then
         table_id_dir:=frmdm.CDS2.FieldByName('id').Value;
     frmdm.CDS2.Next;
   end;
   finally
    frmdm.CDS2.Locate('id', table_id_wnd, []);
    frmdm.CDS2.EnableControls;
   end;

 //  showmessage(inttostr(table_id_dir));
   if table_id_dir=-9 then
    if MessageDlg('Wind direction is not found', mtWarning, [mbOk], 0)=mrOk then begin
     btnPlot.Enabled:=false;
     Exit;
    end;

   for k:=1 to 2 do begin
     case k of
       1: i_id:=table_id_wnd;
       2: i_id:=table_id_dir;
     end;

     with frmdm.Q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select "name" from "table" where "id"=:id ');
       ParamByName('id').Value:=i_id;
      Open;
     end;
     case k of
       1: tbl_spd:=frmdm.Q1.Fields[0].Value;
       2: tbl_dir:=frmdm.Q1.Fields[0].Value;
     end;
   end;

//   showmessage(tbl_spd+'   '+tbl_dir);


   AssignFile(wndd, wndchartpath+'windchartrose.dat'); rewrite(wndd);

   with frmdm.Q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' Select ');
     SQL.Add(' "'+tbl_spd+'"."date" as dat1, ');
     SQL.Add(' "'+tbl_spd+'"."value" as wnd, ');
     SQL.Add(' "'+tbl_dir+'"."value" as dir ');
     SQL.Add(' from "'+tbl_spd+'", "'+tbl_dir+'" ');
     SQL.Add(' where ');
     SQL.Add(' "'+tbl_spd+'"."station_id"="'+tbl_dir+'"."station_id" and ');
     SQL.Add(' "'+tbl_spd+'"."date"="'+tbl_dir+'"."date" and ');
     SQL.Add(' "'+tbl_spd+'"."pqf2"=0 and ');
     SQL.Add(' "'+tbl_dir+'"."pqf2"=0 and ');
     SQL.Add(' "'+tbl_spd+'"."station_id"=:id ');
     SQL.Add(' order by "'+tbl_spd+'"."date" ');
     ParamByName('id').AsInteger:=ID;
    Open;
   end;

   frmdm.Q1.First;
   while not frmdm.Q1.Eof do begin
    time1:=frmdm.Q1.FieldByName('dat1').AsDateTime;
    wnd  :=frmdm.Q1.FieldByName('wnd').AsFloat;
    dir  :=frmdm.Q1.FieldByName('dir').AsFloat;

    writeln(wndd, FormatDateTime('dd.mm.yyyy"T"hh:mm:ss',time1), wnd:6:2, dir:4:0);

   frmdm.Q1.Next;
  end;
   frmdm.Q1.Close;
  closefile(wndd);

  btnOpenfolder.Enabled:=true;
  btnOpenScript.Enabled:=true;
end;


procedure Tfrmwindchart.btnPlotClick(Sender: TObject);
Var
  cmd: string;
begin
 WindScript;

 cmd:='-x "'+wndchartpath+'wchartscript.bas"';
 frmmain.RunScript(3, cmd, nil);
end;


procedure Tfrmwindchart.WindScript;
Var
  script:text;
begin
AssignFile(script, wndchartpath+'wchartscript.bas'); rewrite(script);

Writeln(script, 'Sub Main');
Writeln(script, '');
Writeln(script, ' Dim GrapherApp As Object');
Writeln(script, ' Dim Plot As Object');
Writeln(script, ' Dim WindGraph As Object');
Writeln(script, ' Dim WindPlot As Object');
Writeln(script, '');
Writeln(script, ' Set GrapherApp = CreateObject("Grapher.Application")');
Writeln(script, ' GrapherApp.Visible = True');
Writeln(script, '');
Writeln(script, ' Set Plot = GrapherApp.Documents.Add(grfPlotDoc)');
Writeln(script, '');
 if rgChart.ItemIndex=1 then
  Writeln(script, ' Set WindGraph = Plot.Shapes.AddRoseDiagramGraph("'+GlobalPath+'unload\wnd\windchartrose.dat", 3, 7)');
 if rgChart.ItemIndex=0 then
  Writeln(script, ' Set WindGraph = Plot.Shapes.AddWindChartGraph("'+GlobalPath+'unload\wnd\windchartrose.dat", 3, 2, 7)');
Writeln(script, '');
Writeln(script, ' Set WindPlot = WindGraph.Plots.Item(1)');
Writeln(script, '');
 if rgChart.ItemIndex=0 then begin
  Writeln(script, ' WindPlot.DeleteAllSpeedBins');
  Writeln(script, ' WindPlot.AddSpeedBin(0,2,True)');
  Writeln(script, ' WindPlot.AddSpeedBin(2,4)');
  Writeln(script, ' WindPlot.AddSpeedBin(4,6)');
  Writeln(script, ' WindPlot.AddSpeedBin(6,8)');
  Writeln(script, ' WindPlot.AddSpeedBin(8,10)');
  Writeln(script, ' WindPlot.AddSpeedBin(10,12,,True)');
  Writeln(script, '');
 end;
Writeln(script, 'Set Axes = WindGraph.Axes');
Writeln(script, '');
Writeln(script, 'Set Axis1 = Axes.Item(1)');
Writeln(script, 'Axis1.Grid.AtMajorTicks = True');
Writeln(script, 'Axis1.Grid.MajorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis1.Ticklabels.MajorOn = True');
Writeln(script, 'Axis1.Ticklabels.MajorFormat.Postfix="°"');
Writeln(script, 'Axis1.Ticklabels.MajorFont.Size=10');
Writeln(script, 'Axis1.Tickmarks.MajorLength = 0');
Writeln(script, '');
Writeln(script, 'Axis1.Grid.AtMinorTicks = True');
Writeln(script, 'Axis1.Grid.MinorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis1.Ticklabels.MinorOn = True');
Writeln(script, 'Axis1.Ticklabels.MinorFormat.Postfix="°"');
Writeln(script, 'Axis1.Ticklabels.MinorFont.Size=10');
Writeln(script, 'Axis1.Tickmarks.MinorLength = 0');
Writeln(script, '');
Writeln(script, 'Set Axis2 = Axes.Item(2)');
Writeln(script, 'Axis2.Grid.AtMajorTicks = True');
Writeln(script, 'Axis2.Grid.MajorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis2.Tickmarks.MajorLength = 0.25');
Writeln(script, '');
Writeln(script, 'Axis2.Grid.AtMinorTicks = True');
Writeln(script, 'Axis2.Grid.MinorLine.ForeColor = srfColorBlack30');
Writeln(script, 'Axis2.Tickmarks.MinorLength = 0');
Writeln(script, '');
Writeln(script, ' WindPlot.Fill.GradientType = grfGradientRadial');
Writeln(script, '');
Writeln(script, 'End Sub');

CloseFile(script);
end;



procedure Tfrmwindchart.btnOpenScriptClick(Sender: TObject);
Var
ScriptFile:string;
begin
 WindScript; // Пересоздаем скрипт
 ScriptFile:=wndchartpath+'wchartscript.bas';
  if FileExists(ScriptFile) then  OpenDocument(PChar(ScriptFile));
end;

procedure Tfrmwindchart.btnOpenFolderClick(Sender: TObject);
begin
   OpenDocument(PChar(wndchartpath));
end;

end.
