unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, sqldb, pqconnection, DBGrids, DB, ComCtrls, Spin, IniFiles, LCLIntf,
  LCLTranslator, Grids, ActnList, Buttons, Process, Math, DateUtils;

type
   MapDS=record
     ID:int64;
     Latitude:real;
     Longitude:real;
     x:int64;
     y:int64;
end;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    amap: TAction;
    AL: TActionList;
    BitBtn1: TBitBtn;
    btnSelect: TButton;
    btnmonthlymatrix: TMenuItem;
    cbCountry: TComboBox;
    cbStation: TComboBox;
    cbWMO: TComboBox;
    cgSource: TCheckGroup;
    chkEmpty: TCheckBox;
    chkShowSQL: TCheckBox;
    chkStActive: TCheckBox;
    chlParameters: TCheckGroup;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DS1: TDataSource;
    DS2: TDataSource;
    ds5701: TMenuItem;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Exit1: TMenuItem;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    iFile: TMenuItem;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    IL: TImageList;
    Label2: TLabel;
    lblatmax: TLabel;
    Label4: TLabel;
    lblonmin: TLabel;
    lblatmin: TLabel;
    lblonmax: TLabel;
    Label5: TLabel;
    lbCoordReset: TLabel;
    lbResetMD: TLabel;
    iLoad: TMenuItem;
    iSettings: TMenuItem;
    iMap: TMenuItem;
    iHelp: TMenuItem;
    iAbout: TMenuItem;
    btnInfo: TMenuItem;
    lbResetID: TLabel;
    ListBox1: TListBox;
    iLoadGHCN_v4_prcp: TMenuItem;
    btnload_isd: TMenuItem;
    btnWindChartRose: TMenuItem;
    itest: TMenuItem;
    MenuItem3: TMenuItem;
    iQCProcedures: TMenuItem;
    MenuItem6: TMenuItem;
    iLoadGHCND: TMenuItem;
    iShowTimeseries: TMenuItem;
    iLoadGHCN_v4_t2m: TMenuItem;
    btnLoad_ECAD: TMenuItem;
    iUpdateStationInfo: TMenuItem;
    iMergeParameterFromSources: TMenuItem;
    MenuItem9: TMenuItem;
    N5: TMenuItem;
    N4: TMenuItem;
    btnCompareSources: TMenuItem;
    iLoadGHCN_v4: TMenuItem;
    MenuItem7: TMenuItem;
    MM: TMainMenu;
    N2: TMenuItem;
    iTools: TMenuItem;
    OD: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    PM1: TPopupMenu;
    PM2: TPopupMenu;
    ProgressBar1: TProgressBar;
    rgTimestep: TRadioGroup;
    RegionalAveraging1: TMenuItem;
    SD: TSaveDialog;
    seIDMin: TSpinEdit;
    seIDMax: TSpinEdit;
    ODD: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    seYY1: TSpinEdit;
    seYY2: TSpinEdit;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    tbFastAccess: TToolBar;
    tbSelection: TTabSheet;
    tbData: TTabSheet;
    btncommit: TToolButton;
    ToolButton5: TToolButton;

    procedure amapExecute(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btncommitClick(Sender: TObject);
    procedure btnInfoClick(Sender: TObject);
    procedure btnWindChartRoseClick(Sender: TObject);
    procedure chkStActiveChange(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid2CellClick(Column: TColumn);
    procedure DBGrid2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid2PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure btnCompareSourcesClick(Sender: TObject);
    procedure iDeleteEmptyStationsClick(Sender: TObject);
    procedure iLoadGHCNDClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnmonthlymatrixClick(Sender: TObject);
    procedure cbCountryDropDown(Sender: TObject);
    procedure cbStationDropDown(Sender: TObject);
    procedure cbWMODropDown(Sender: TObject);
    procedure ds5701Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iLoadGHCN_v4_prcpClick(Sender: TObject);
    procedure iLoadGHCN_v4_t2mClick(Sender: TObject);
    procedure iMarkEmptyStationsClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iQCProceduresClick(Sender: TObject);
    procedure iShowTimeseriesClick(Sender: TObject);
    procedure itestClick(Sender: TObject);
    procedure iUpdateStationInfoClick(Sender: TObject);
    procedure lbCoordResetClick(Sender: TObject);
    procedure lbResetIDClick(Sender: TObject);
    procedure lbResetMDClick(Sender: TObject);
    procedure iLoadGHCNv3Click(Sender: TObject);
    procedure iMergeParameterFromSourcesClick(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure PM1Popup(Sender: TObject);
    procedure RegionalAveraging1Click(Sender: TObject);
    procedure rgTimestepClick(Sender: TObject);

  private
    { private declarations }
  public
    procedure CDSNavigation;
    procedure CDSStatistics;
    procedure UpdateIBContent;
    procedure UpdateTimeStep;
    procedure CDSInfoNavigation;
    procedure RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
    procedure OpenSettings(tab_ind:integer);
  end;

var
  frmmain: Tfrmmain;
  GlobalPath, GlobalUnloadPath, GlobalSupportPath: string;
  DBName, IniFileName, DB_str: string;
  IDMin, IDMax, DBType, IBCount:integer;

  server_ind: integer; //Firebird or PostgreSQL?
  time_step: string;

  IBLtMin, IBLtMax, IBLnMin, IBLnMax:real;
  SMinLat, SMaxLat, SMinLon, SMaxLon:real;

  NavigationOrder:boolean=true;
  DBGrid1LastColumn: TColumn;

  MapDataset: array of MapDS;

  StCount: integer;
  open_monthlymatrix, frmmap_open, Open_metadata_sources:boolean;
  open_timeseries:boolean;

resourcestring
  SNoDatabase= 'Please, specify the database and try to connect again';
  SAbsnum    = 'ID';
  SWMO       = 'WMO';
  SICAO      = 'ICAO';
  SStation   = 'Station';
  SStations  = 'Stations';
  SLatitude  = 'Latitude';
  SLatMin    = 'Lat. min.';
  SLatMax    = 'Lat. max.';
  SLongitude = 'Longitude';
  SLonMin    = 'Lon. min.';
  SLonMax    = 'Lon. max.';
  SElevation = 'Elevation';
  SCountry   = 'Country';
  SParameter = 'Parameter';
  SAdjusted  = 'Adj.';
  SSource    = 'Source';
  STimestep  = 'Time step';
  SDateMin   = 'Date min';
  SDateMax   = 'Date max';
  SCount     = 'Count';
  SDate      = 'Date';
  SValueMin  = 'Value min';
  SValueMax  = 'Value max';
  SYear      = 'Year';
  SJAN       = 'JAN';
  SFEB       = 'FEB';
  SMAR       = 'MAR';
  SAPR       = 'APR';
  SMAY       = 'MAY';
  SJUN       = 'JUN';
  SJUL       = 'JUL';
  SAUG       = 'AUG';
  SSEP       = 'SEP';
  SOCT       = 'OCT';
  SNOV       = 'NOV';
  SDEC       = 'DEC';
  SAnnual    = 'Annual';
  SDone      = 'Done!';
  SError     = 'Something went wrong...';
  SMonth     = 'Month';
  SValue     = 'Value';
  SFlag      = 'Flag';

  SNoPython = 'Python is not found';
  SNoSurfer = 'Surfer is not found';
  SNoGrapher = 'Grapher is not found';
  SNoCDO = 'CDO is not found';


const
  buf_len      = 3000;

implementation

{$R *.lfm}

{ Tfrmmain }

uses dm, sortbufds, update_station_info, map, settings, qc,

     (* load *)
     load_ghcnd,load_ds570,load_ghcn_v4_t2m, load_ghcnv4_prcp,

     (* tools *)
     tool_monthlymatrix, tool_sources_compare, tool_timeseries,
     tool_parameter_compare, tool_info_sources,
     tool_sources_merge, tool_windchartrose,
     tool_spatial_averaging, tool_random_single_use_scripts;


procedure Tfrmmain.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 k:integer;
begin
 (* Определяем глобальный путь к папке с программой *)
  GlobalPath:=ExtractFilePath(Application.ExeName);

  DefaultFormatSettings.DecimalSeparator := '.';

  IniFileName:=GetUserDir+'.MeteoShell';
  if not FileExists(IniFileName) then begin
    Ini:=TIniFile.Create(IniFileName);
    Ini.WriteInteger('meteo', 'language', 0);
    Ini.Free;
  end;

  try
    Ini := TIniFile.Create(IniFileName);
     case Ini.ReadInteger ( 'meteo',    'language',   0)  of
      0: SetDefaultLang('en');
      1: SetDefaultLang('ru');
     end;

    Top   :=Ini.ReadInteger( 'meteo', 'main_top',    50);
    Left  :=Ini.ReadInteger( 'meteo', 'main_left',   50);
    Width :=Ini.ReadInteger( 'meteo', 'main_width',  900);
    Height:=Ini.ReadInteger( 'meteo', 'main_height', 500);

    (* * Check for existing essencial program folders *)
    GlobalSupportPath := Ini.ReadString('meteo', 'SupportPath', GlobalPath+'support'+PathDelim);
      if not DirectoryExists(GlobalSupportPath) then CreateDir(GlobalSupportPath);
    GlobalUnloadPath  := Ini.ReadString('meteo', 'UnloadPath', GlobalPath+'unload'+PathDelim);
      if not DirectoryExists(GlobalUnloadPath) then CreateDir(GlobalUnloadPath);

    With DBGrid1 do begin
      Columns[0].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_0', 50);
      Columns[1].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_1', 65);
      Columns[2].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_2', 65);
      Columns[3].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_3', 260);
      Columns[4].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_4', 70);
      Columns[5].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_5', 80);
      Columns[6].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_6', 75);
      Columns[7].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_7', 210);
    end;

    With DBGrid2 do begin
      Columns[0].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_0', 225);
      Columns[1].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_1', 50);
      Columns[2].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_2', 64);
      Columns[3].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_3', 70);
      Columns[4].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_4', 64);
      Columns[5].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_5', 70);
      Columns[6].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_6', 64);
      Columns[7].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_7', 64);
      Columns[8].Width:=Ini.ReadInteger( 'meteo', 'DBGrid2_8', 50);
    end;

  finally
   ini.Free;
  end;

  With DBGrid1 do begin
    Columns[0].Title.Caption:=SAbsnum;
    Columns[1].Title.Caption:=SWMO;
    Columns[2].Title.Caption:=SICAO;
    Columns[3].Title.Caption:=SStation;
    Columns[4].Title.Caption:=SLatitude;
    Columns[5].Title.Caption:=SLongitude;
    Columns[6].Title.Caption:=SElevation;
    Columns[7].Title.Caption:=SCountry;
  end;

  With DBGrid2 do begin
    Columns[0].Title.Caption:=SParameter;
    Columns[1].Title.Caption:=SSource;
    Columns[2].Title.Caption:=STimestep;
    Columns[3].Title.Caption:=SDateMin;
    Columns[4].Title.Caption:=SDateMax;
    Columns[5].Title.Caption:=SValueMin;
    Columns[6].Title.Caption:=SValueMax;
    Columns[7].Title.Caption:=SCount;
  end;

  lblatmin.Caption:=SLatMin;
  lblatmax.Caption:=SLatMax;
  lblonmin.Caption:=SLonMin;
  lblonmax.Caption:=SLonMax;

  for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=false;

  open_monthlymatrix:=false; frmmap_open:=false;
  open_timeseries:=false;

  OnResize(Self);
  SetFocus;

  {$IFDEF WINDOWS}
    ProgressBar1.Visible:=false;
  {$ENDIF}

  Application.ProcessMessages;
end;


procedure Tfrmmain.CDSNavigation;
Var
ID:integer;
begin
ID:=frmdm.CDS.FieldByName('id').AsInteger;
if (ID=0) or (NavigationOrder=false) then exit;

 If NavigationOrder=true then begin
  NavigationOrder:=false; //Блокируем перемещение, пока все не завершим

  with frmdm.CDS2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ');
     SQL.Add(' "table"."id" as id, "parameter"."name" as par, ');
     SQL.Add(' "source"."name" as src, ');
     SQL.Add(' "timestep"."name" as timestep, ');
     SQL.Add(' "date_min", "date_max",  ');
     SQL.Add(' "val_min", "val_max", "cnt", "perc" ');
     SQL.Add(' from "station_info", "table", "parameter", "source", "timestep" ');
     SQL.Add(' where ');
     SQL.Add(' "station_info"."station_id"=:station_id and ');
     SQL.Add(' "timestep"."name"=:timestep_name and ');
     SQL.Add(' "station_info"."table_id"="table"."id" and ');
     SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
     SQL.Add(' "table"."source_id"="source"."id" and ');
     SQL.Add(' "table"."timestep_id"="timestep"."id" ');
     SQL.Add(' order by "table"."parameter_id", "timestep"."id", ');
     SQL.Add(' "table"."source_id" ');
     ParamByName('station_id').AsInteger:=ID;
     ParamByName('timestep_name').AsString:=rgTimestep.Items.Strings[rgTimestep.ItemIndex];
    Open;
  end;

  DBGrid2.Refresh;
  Application.ProcessMessages;

  if frmmap_open=true then frmmap.ChangeID;
  if Open_metadata_sources then frmmetadata_sources.ChangeID;

  if open_monthlymatrix=true then
    frmmonthlymatrix.GetData(frmdm.CDS2.FieldByName('id').AsInteger);

  if open_timeseries=true then
    frmtimeseries.GetData(frmdm.CDS2.FieldByName('id').AsInteger);

  NavigationOrder:=true; //Завершили, открываем доступ к навигации
 end;
end;



procedure Tfrmmain.CDSInfoNavigation;
begin
 if (NavigationOrder=false) then exit;

 if NavigationOrder=true then begin
   NavigationOrder:=false; //Блокируем перемещение, пока все не завершим

  if Open_monthlymatrix=true then
       frmmonthlymatrix.GetData(frmdm.CDS2.FieldByName('id').AsInteger);

  if Open_timeseries=true then
       frmtimeseries.GetData(frmdm.CDS2.FieldByName('id').AsInteger);

   NavigationOrder:=true;
 end;
end;


procedure Tfrmmain.UpdateIBContent;
var
  k :Integer;
begin
 frmdm.CDS.Filtered:=false;
 if frmdm.CDS.Active=true then begin
   frmdm.CDS.Close;
 end;

with frmdm.q1 do begin
  Close;
    SQL.Clear;
    SQL.Add(' select count("id") as StCount, ');
    SQL.Add(' min("id") as IDMin, max("id") as IDMax, ');
    SQL.Add(' min("latitude") as StLatMin, max("latitude") as StLatMax, ');
    SQL.Add(' min("longitude") as StLonMin, max("longitude") as StLonMax ');
    SQL.Add(' from "station"');
    Open;
    IBCount:=FieldByName('StCount').AsInteger;
    if IBCount>0 then begin
     IDMin:=FieldByName('IDMin').Value;
     IDMax:=FieldByName('IDMax').Value;

     IBLtMin:=FieldByName('StLatMin').AsFloat;
     IBLtMax:=FieldByName('StLatMax').AsFloat;
     IBLnMin:=FieldByName('StLonMin').AsFloat;
     IBLnMax:=FieldByName('StLonMax').AsFloat;

     StatusBar1.Panels[1].Text:=SLatMin  +': '+floattostr(IBLtMin);
     StatusBar1.Panels[2].Text:=SLatMax  +': '+floattostr(IBLtMax);
     StatusBar1.Panels[3].Text:=SLonMin  +': '+floattostr(IBLnMin);
     StatusBar1.Panels[4].Text:=SLonMax  +': '+floattostr(IBLnMax);
     StatusBar1.Panels[5].Text:=SStations+': '+inttostr(IBCount);

     PageControl1.Enabled:=true;
     lbCoordReset.OnClick(self);
     lbResetID.OnClick(self);
    end else for k:=1 to 5 do frmMain.statusbar2.Panels[k].Text:='---';
  Close;
 end;


  with frmdm.q1 do begin
  Close;
    SQL.Clear;
    SQL.Add(' select distinct("name") ');
    SQL.Add(' from "timestep" where ');
    SQL.Add(' "timestep"."database_available"=true ');
    SQL.Add(' order by "id" ');
  Open;
 end;

 rgTimestep.Items.clear;
 while not frmdm.q1.EOF do begin
    rgTimestep.Items.Add(frmdm.q1.Fields[0].AsString);
  frmdm.q1.Next;
 end;
 rgTimestep.Columns:=frmdm.q1.RecordCount;
 frmdm.q1.Close;
 rgTimestep.ItemIndex:=0;

 for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=true;
 Application.ProcessMessages;
end;


procedure Tfrmmain.rgTimestepClick(Sender: TObject);
begin
  UpdateTimeStep;
end;

procedure Tfrmmain.UpdateTimeStep;
Var
  DB2Name: string;
  TRt1:TSQLTransaction;
  db1q1:TSQLQuery;
begin

 time_step:=rgTimestep.Items.Strings[rgTimestep.ItemIndex];

 try
  TRt1:=TSQLTransaction.Create(nil);
  TRt1.DataBase:=frmdm.TR.DataBase;
  db1q1:=TSQLQuery.Create(nil);
  db1q1.Database:=frmdm.TR.DataBase;
  db1q1.Transaction:=TRt1;

  with db1q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "database_path" from "timestep" where ');
    SQL.Add(' "timestep"."name"='+QuotedStr(time_step));
   Open;
      DB2Name:=db1q1.Fields[0].AsString;
   Close;
  end;

//  showmessage(DB2Name);

  case server_ind of
    0: frmdm.ConnectDataDB(ExtractFilePath(DBName)+DB2Name);
    1: frmdm.ConnectDataDB(DB2Name);
  end;

  with db1q1 do begin
  Close;
    SQL.Clear;
    SQL.Add(' select distinct("parameter"."name") ');
    SQL.Add(' from "parameter", "table", "timestep" ');
    SQL.Add(' where ');
    SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
    SQL.Add(' "table"."timestep_id"="timestep"."id" and ');
    SQL.Add(' "timestep"."name"='+QuotedStr(time_step));
    SQL.Add(' order by "name" ');
  Open;
 end;

 chlParameters.Items.clear;
 while not db1q1.EOF do begin
   chlParameters.Items.Add(db1q1.Fields[0].AsString);
  db1q1.Next;
 end;
 db1q1.Close;


  with db1q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select distinct("source"."name") ');
     SQL.Add(' from "source", "table", "timestep" ');
     SQL.Add(' where ');
     SQL.Add(' "table"."source_id"="source"."id" and ');
     SQL.Add(' "table"."timestep_id"="timestep"."id" and ');
     SQL.Add(' "timestep"."name"='+QuotedStr(time_step));
     SQL.Add(' order by "source"."name" ');
    Open;
  end;

  cgSource.Items.clear;
  while not db1q1.EOF do begin
    cgSource.Items.Add(db1q1.Fields[0].AsString);
   db1q1.Next;
  end;
  db1q1.Close;

  (* Min and Max dates for the selected database *)
    with db1q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ');
     SQL.Add(' min("station_info"."date_min") as DMin, ');
     SQL.Add(' max("station_info"."date_max") as DMax ');
     SQL.Add(' from "station_info", "table", "timestep" ');
     SQL.Add(' where ');
     SQL.Add(' "station_info"."table_id"="table"."id" and ');
     SQL.Add(' "table"."timestep_id"="timestep"."id" and ');
     SQL.Add(' "timestep"."name"='+QuotedStr(time_step));
    Open;
      seYY1.Value:=YearOf(db1q1.FieldByName('DMin').Value);
      seYY2.Value:=YearOf(db1q1.FieldByName('DMax').Value);
    Close;
  end;

 finally
  db1q1.Close;
  db1q1.Free;
  Trt1.Commit;
  Trt1.Free;
 end;
end;


procedure Tfrmmain.btnSelectClick(Sender: TObject);
Var
Lat1, Lat2, Lon1, Lon2:real;
k:integer;
tbl_str, timestep_str, src_str:string;
begin
Lat1:=strtofloat(edit1.Text);
Lat2:=strtofloat(edit2.Text);
Lon1:=strtofloat(edit3.Text);
Lon2:=strtofloat(edit4.Text);

// closing active transaction
if frmdm.TR.Active then frmdm.TR.Commit;

tbl_str:='';
for k:=0 to chlParameters.Items.Count-1 do begin
  if chlParameters.Checked[k]=true then begin
   tbl_str:=tbl_str+' and (';
   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add('select "table"."id" from "table", "parameter", "timestep" ');
     SQL.Add('where');
     SQL.Add('"table"."parameter_id"="parameter"."id" and ');
     SQL.Add('"table"."timestep_id"="timestep"."id" and ');
     SQL.Add('"parameter"."name"='+QuotedStr(chlParameters.Items.Strings[k])+' and ');
     SQL.Add('"timestep"."name"='+QuotedStr(time_step));
    Open;
   end;
   while not frmdm.q1.EOF do begin
    tbl_str:=tbl_str+'("station"."id" in ('+
           'select "station_id" from "station_info" '+
           'where "table_id"='+inttostr(frmdm.q1.Fields[0].Value);
        if chkStActive.Checked=true then
          tbl_str:=tbl_str+' group by "station_id" having '+
                   'min(extract(year from "date_min"))<='+seYY1.Text+' and '+
                   'max(extract(year from "date_max"))>='+seYY2.Text+'))'
        else
          tbl_str:=tbl_str+'))';
     tbl_str:=tbl_str+' or ';
    frmdm.q1.Next;
   end;
   tbl_str:=copy(tbl_str, 1, length(tbl_str)-4)+')';
  end;
end;
//showmessage(tbl_str);

{timestep_name:='';
for k:=0 to rgTimestep.Items.Count-1 do
  if cgTimestep.Checked[k]=true then
    timestep_name:=timestep_name+QuotedStr(cgTimestep.Items.Strings[k])+',';

timestep_name:=copy(timestep_name, 1, length(timestep_name)-1);

if trim(timestep_name)<>'' then }
timestep_str:=' and ("station"."id" in ( '+
     'select "station_id" from "station_info" '+
     'where "table_id" in ('+
     'select "table"."id" from "table", "timestep" '+
     'where "table"."timestep_id"="timestep"."id" and '+
     '"timestep"."name"='+QuotedStr(time_step)+')))';
     //'"timestep"."name" in('+timestep_name+'))))' else timestep_str:='';
//showmessage(timestep_str);  }


src_str:='';
for k:=0 to cgSource.Items.Count-1 do
  if cgSource.Checked[k]=true then
    src_str:=src_str+QuotedStr(cgSource.Items.Strings[k])+',';

src_str:=copy(src_str, 1, length(src_str)-1);

if trim(src_str)<>'' then
src_str:=' and ("station"."id" in ( '+
     'select "station_id" from "station_info" '+
     'where "table_id" in ('+
     'select "table"."id" from "table", "source" '+
     'where "table"."source_id"="source"."id" and '+
     '"source"."name" in('+src_str+'))))' else src_str:='';
//showmessage(timestep_str);  }

try
  with frmdm.CDS do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "station"."id", "station"."latitude",  "station"."longitude", ');
    SQL.Add(' "station"."elevation", "station"."name", "station"."wmocode", ');
    SQL.Add(' "station"."icao", "country"."name" as countryname ');
    SQL.Add(' from "station", "country" ');
    SQL.Add(' where ');
    SQL.Add(' "station"."country_id"="country"."id" and ');
    SQL.Add(' "station"."id" between :idmin and :idmax and ');
    SQL.Add(' "station"."latitude">=:ltmin and "station"."latitude"<=:ltmax and ');
    if (Lon1<=Lon2) then
      SQL.Add(' "station"."longitude">=:lnmin and "station"."longitude"<=:lnmax ');
    if (Lon1>Lon2) then begin
      SQL.Add(' (("station"."longitude">=:lnmin and "station"."longitude"<=180) or ');
      SQL.Add('  ("station"."longitude"<=:lnmax and "station"."longitude">=-180)) ');
    end;

    if cbWMO.Text<>''     then SQL.Add(' and "station"."wmocode"='+QuotedStr(cbWMO.Text));
    if cbCountry.Text<>'' then SQL.Add(' and "country"."name"='+QuotedStr(cbCountry.Text));
    if cbStation.Text<>'' then SQL.Add(' and "station"."name"='+QuotedStr(cbStation.Text));
    if chkEmpty.Checked = false then SQL.Add(' and "station"."empty"=false ');

    SQL.Add(timestep_str);
    SQL.Add(tbl_str);
    SQL.Add(src_str);

      SQL.Add(' order by "station"."wmocode" ');
      if chkShowSQL.Checked=true then showmessage(SQL.Text);
      ParamByName('ltmin').AsFloat:=Lat1;
      ParamByName('ltmax').AsFloat:=Lat2;
      ParamByName('lnmin').AsFloat:=Lon1;
      ParamByName('lnmax').AsFloat:=Lon2;
      ParamByName('idmin').Value:=seIDMin.Value;
      ParamByName('idmax').Value:=seIDMax.Value;

    Open;
    Last;
    First;
  end;
except
   on e: Exception do begin
      if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then begin
        frmdm.CDS.Close;
        frmdm.TR.Rollback;
      end;
   end;
end;

DBGrid1.Repaint;
CDSStatistics;
//amapExecute(Sender: TObject);
end;

procedure Tfrmmain.CDSStatistics;
Var
k:integer;
Lat, Lon:real;
begin
 if frmdm.CDS.RecordCount>0 then begin
  SMinLat:=90; SMaxLat:=-90; SMinLon:=180; SMaxLon:=-180;
  frmdm.CDS.DisableControls;
  try
   frmdm.CDS.First;

   StCount:=frmdm.CDS.RecordCount;
   SetLength(MapDataset, StCount+1);
   k:=-1;
   while not frmdm.CDS.eof do begin
     inc(k);
      Lat:=frmdm.CDS.FieldByName('latitude').AsFloat;
      Lon:=frmdm.CDS.FieldByName('longitude').AsFloat;

     if Lat<SMinLat then SMinLat:=Lat;
     if Lat>SMaxLat then SMaxLat:=Lat;
     if Lon<SMinLon then SMinLon:=Lon;
     if Lon>SMaxLon then SMaxLon:=Lon;

     MapDataset[k].ID:=frmdm.CDS.FieldByName('ID').Value;
     MapDataset[k].Latitude :=lat;
     MapDataset[k].Longitude:=lon;

    frmdm.CDS.next;
   end;
  finally
    frmdm.CDS.First;
    frmdm.CDS.EnableControls;
  end;

  With frmmain.StatusBar2 do begin
   Panels[1].Text:=floattostr(SMinLat);
   Panels[2].Text:=floattostr(SMaxLat);
   Panels[3].Text:=floattostr(SMinLon);
   Panels[4].Text:=floattostr(SMaxLon);
   Panels[5].Text:='                '+inttostr(StCount);
  end;

  for k:=2 to MM.Items.Count-1 do MM.Items[k].Enabled:=true;

   tbData.TabVisible:=true;
 end else begin
  StCount:=0;
  for k:=1 to 5 do frmMain.statusbar2.Panels[k].Text:='---';
  for k:=3 to MM.Items.Count-1 do MM.Items[k].Enabled:=false;
  tbData.TabVisible:=false;
 end;

 amap.Enabled:=true;
 if frmmap_open=true then amapExecute(self);
 Application.ProcessMessages;
end;


procedure Tfrmmain.RegionalAveraging1Click(Sender: TObject);
begin
  frmspatialaveraging:= Tfrmspatialaveraging.Create(Self);
   try
    if not frmspatialaveraging.ShowModal = mrOk then exit;
   finally
     frmspatialaveraging.Free;
     frmspatialaveraging := nil;
   end;
end;

procedure Tfrmmain.btncommitClick(Sender: TObject);
begin
  frmdm.CDS.ApplyUpdates(0);
  btncommit.Enabled:=false;
end;

procedure Tfrmmain.btnInfoClick(Sender: TObject);
begin
if Open_metadata_sources=false then begin
   frmmetadata_sources := Tfrmmetadata_sources.Create(Self);
   frmmetadata_sources.Show;
end else frmmetadata_sources.SetFocus;

Open_metadata_sources:=true;
CDSInfoNavigation;
end;


procedure Tfrmmain.BitBtn1Click(Sender: TObject);
Var
  Ini: TIniFile;
  DBUser, DBPass, DBHost, server_str: string;
begin
try
  Ini := TIniFile.Create(IniFileName);

  //0-firebird; 1-postgres
  server_ind:=0;
  server_str:='';
  case Ini.ReadInteger('meteo', 'server', 0) of
   0: begin
     server_ind:=0;
     server_str:='Firebird';
   end;
   1: begin
     server_ind:=1;
     server_str:='Postgres';
   end;
  end;

  DBUser :=Ini.ReadString(server_str, 'user',     '');
  DBPass :=Ini.ReadString(server_str, 'pass',     '');
  DBHost :=Ini.ReadString(server_str, 'host',     '');
  DBName :=Ini.ReadString(server_str, 'database', '');
finally
  ini.Free;
end;

// if database isn't specified
if (trim(DBName)='') or (server_str='') then begin
 if MessageDlg(SNoDatabase, mtwarning, [mbOk], 0)=mrOk then
   iSettings.OnClick(self);
 exit;
end;

//Connecting to the metadata database
frmdm.ConnectMetadataDB(DBUser, DBPass, DBHost, DBName);

//Statistics
UpdateIBContent;
end;


procedure Tfrmmain.lbCoordResetClick(Sender: TObject);
begin
  Edit1.Text:=floattostr(IBLtMin);
  Edit2.Text:=floattostr(IBLtMax);
  Edit3.Text:=floattostr(IBLnMin);
  Edit4.Text:=floattostr(IBLnMax);
end;

procedure Tfrmmain.lbResetIDClick(Sender: TObject);
begin
  seIDMin.Value:=IDMin;
  seIDMax.Value:=IDMax;
end;

procedure Tfrmmain.lbResetMDClick(Sender: TObject);
begin
  cbWMO.Clear;
  cbCountry.Clear;
  cbStation.Clear;
end;

procedure Tfrmmain.iLoadGHCNv3Click(Sender: TObject);
begin

end;

procedure Tfrmmain.btnmonthlymatrixClick(Sender: TObject);
begin
 if open_monthlymatrix=false then begin
    frmmonthlymatrix := Tfrmmonthlymatrix.Create(Self);
    frmmonthlymatrix.Show;
 end else frmmonthlymatrix.SetFocus;

 open_monthlymatrix:=true;
 CDSInfoNavigation;
end;


procedure Tfrmmain.iShowTimeseriesClick(Sender: TObject);
begin
 if Open_timeseries=false then begin
    frmtimeseries := Tfrmtimeseries.Create(Self);
    frmtimeseries.Show;
 end else frmtimeseries.SetFocus;

 Open_timeseries:=true;
 CDSInfoNavigation;
end;

procedure Tfrmmain.itestClick(Sender: TObject);
begin
  //UpdateICAOCodes;
ECADTransferNames;
end;


procedure Tfrmmain.btnWindChartRoseClick(Sender: TObject);
begin
  frmwindchart := Tfrmwindchart.Create(Self);
 try
  if not frmwindchart.ShowModal = mrOk then exit;
 finally
   frmwindchart.Free;
   frmwindchart := nil;
 end;
end;

procedure Tfrmmain.amapExecute(Sender: TObject);
begin
 if frmmap_open=true then frmmap.SetFocus else
    begin
       frmmap := Tfrmmap.Create(Self);
       frmmap.Show;
    end;
  frmmap.btnShowSelectedClick(self);
  frmmap_open:=true;
  frmmap.btnShowAllStationsClick(self);
end;


procedure Tfrmmain.cbCountryDropDown(Sender: TObject);
begin
 if cbCountry.Items.Count>0 then exit;

 if (cbStation.Text='') and (cbCountry.text='') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("name") from "country" ');
     SQL.Add(' order by "name"');
   Open;
  end;
 end;

 if (cbStation.Text<>'') and (cbWMO.Text='') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("name") from "country" ');
     SQL.Add(' where "country"."id" in ');
     SQL.Add('(select "country_id" from "station" where ');
     SQL.Add(' "station"."name"=:st_name) ');
     SQL.Add(' order by "name"');
     ParamByName('st_name').Value:=cbStation.Text;
   Open;
  end;
 end;

 if (cbStation.Text='') and (cbWMO.Text<>'') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("name") from "country" ');
     SQL.Add(' where "country"."id" in ');
     SQL.Add('(select "country_id" from "station" where ');
     SQL.Add(' "station"."wmocode"=:wmo) ');
     SQL.Add(' order by "name"');
     ParamByName('wmo').Value:=cbWMO.Text;
   Open;
  end;
 end;
   cbCountry.Clear;
  while not frmdm.q1.Eof do begin
   cbCountry.Items.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
   frmdm.q1.Close;

end;


procedure Tfrmmain.cbStationDropDown(Sender: TObject);
begin
 if cbStation.Items.Count>0 then exit;

 if (cbCountry.Text='') and (cbWMO.Text='') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("name") from "station" ');
     SQL.Add(' order by "name"');
   Open;
  end;
 end;

 if (cbCountry.Text<>'') and (cbWMO.Text='') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("name") from "station" ');
     SQL.Add(' where "country_id" in ');
     SQL.Add('(select "country"."id" from "country" where ');
     SQL.Add(' "country"."name"=:country_name) ');
     SQL.Add(' order by "name"');
     ParamByName('country_name').Value:=cbCountry.Text;
   Open;
  end;
 end;

 if (cbWMO.Text<>'') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("name") from "station" ');
     SQL.Add(' where "wmocode"=:wmo_code ');
     SQL.Add(' order by "name"');
     ParamByName('wmo_code').Value:=cbWMO.Text;
   Open;
  end;
 end;

   cbStation.Clear;
  while not frmdm.q1.Eof do begin
   cbStation.Items.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
   frmdm.q1.Close;

end;

procedure Tfrmmain.cbWMODropDown(Sender: TObject);
begin
  if cbWMO.Items.Count>0 then exit;

  if (cbCountry.Text='') and (cbStation.Text='') then begin
    with frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' select distinct("wmocode") from "station" ');
       SQL.Add(' order by "wmocode"');
     Open;
    end;
  end;

  if (cbCountry.Text<>'') and (cbStation.Text='') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("wmocode") from "station" ');
     SQL.Add(' where "country_id" in ');
     SQL.Add('(select "country"."id" from "country" where ');
     SQL.Add(' "country"."name"=:country_name) ');
     SQL.Add(' order by "name"');
     ParamByName('country_name').Value:=cbCountry.Text;
   Open;
  end;
 end;

 if (cbStation.Text<>'') then begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select distinct("wmocode") from "station" ');
     SQL.Add(' where "station"."name"=:st_name ');
     SQL.Add(' order by "name"');
     ParamByName('st_name').Value:=cbStation.Text;
   Open;
  end;
 end;

  cbWMO.Clear;
  while not frmdm.q1.Eof do begin
   cbWMO.Items.Add(inttostr(frmdm.q1.Fields[0].AsInteger));
   frmdm.q1.Next;
  end;
   frmdm.q1.Close;
end;


procedure Tfrmmain.DBGrid1TitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(frmdm.CDS, Column.FieldName);

  column.tag := not column.tag;
  if boolean(column.tag) then
  begin
    Column.Title.ImageIndex:=133;
  end else
  begin
    Column.Title.ImageIndex:=131;
  end;
  // Remove the sort arrow from the previous column we sorted
  if (DBGrid1LastColumn <> nil) and (DBGrid1LastColumn <> Column) then
    DBGrid1LastColumn.Title.ImageIndex:=-1;
  DBGrid1LastColumn:=column;
end;


procedure Tfrmmain.DBGrid1CellClick(Column: TColumn);
begin
  CDSNavigation;
end;

procedure Tfrmmain.DBGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CDSNavigation;
end;

procedure Tfrmmain.DBGrid2CellClick(Column: TColumn);
begin
  CDSInfoNavigation;
end;

procedure Tfrmmain.DBGrid2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CDSInfoNavigation;
end;


procedure Tfrmmain.ds5701Click(Sender: TObject);
begin
  frmload_ds570_upd := Tfrmload_ds570_upd.Create(Self);
   try
    if not frmload_ds570_upd.ShowModal = mrOk then exit;
   finally
     frmload_ds570_upd.Free;
     frmload_ds570_upd := nil;
   end;
end;


procedure Tfrmmain.iLoadGHCNDClick(Sender: TObject);
begin
frmloadghcnd := Tfrmloadghcnd.Create(Self);
try
 if not frmloadghcnd.ShowModal = mrOk then exit;
finally
  frmloadghcnd.Free;
  frmloadghcnd := nil;
end
end;


procedure Tfrmmain.iLoadGHCN_v4_t2mClick(Sender: TObject);
begin
frmload_ghcnv4 := Tfrmload_ghcnv4.Create(Self);
 try
  if not frmload_ghcnv4.ShowModal = mrOk then exit;
 finally
   frmload_ghcnv4.Free;
   frmload_ghcnv4 := nil;
 end
end;

procedure Tfrmmain.iMarkEmptyStationsClick(Sender: TObject);
begin

end;

procedure Tfrmmain.iLoadGHCN_v4_prcpClick(Sender: TObject);
begin
frmload_ghcn_v4_prcp := Tfrmload_ghcn_v4_prcp.Create(Self);
 try
  if not frmload_ghcn_v4_prcp.ShowModal = mrOk then exit;
 finally
   frmload_ghcn_v4_prcp.Free;
   frmload_ghcn_v4_prcp := nil;
 end
end;

procedure Tfrmmain.iMergeParameterFromSourcesClick(Sender: TObject);
begin
frmsourcesmerge := Tfrmsourcesmerge.Create(Self);
 try
  if not frmsourcesmerge.ShowModal = mrOk then exit;
 finally
   frmsourcesmerge.Free;
   frmsourcesmerge := nil;
 end;
end;


procedure Tfrmmain.MenuItem6Click(Sender: TObject);
begin
  frmcompare_parameters := Tfrmcompare_parameters.Create(Self);
 try
  if not frmcompare_parameters.ShowModal = mrOk then exit;
 finally
   frmcompare_parameters.Free;
   frmcompare_parameters := nil;
 end;
end;

procedure Tfrmmain.PM1Popup(Sender: TObject);
begin
  if frmdm.CDS2.FieldByName('timestep').AsString='Month' then begin
    btnmonthlymatrix.Visible:=true;
   // btnCompareSources.Enabled:=true;
  end else begin
    btnmonthlymatrix.Visible:=false;
  //  btnCompareSources.Enabled:=false;
  end;

  //Only for wind speed
  if copy(frmdm.CDS2.FieldByName('par').AsString, 1, 10)='Wind speed' then begin
    btnWindChartRose.Visible:=true;
  end else begin
    btnWindChartRose.Visible:=false;
  end;
end;


procedure Tfrmmain.OpenSettings(tab_ind:integer);
begin
frmsettings := Tfrmsettings.Create(self);
frmsettings.PageControl1.PageIndex:=tab_ind;
 try
  if not frmsettings.ShowModal = mrOk then exit;
 finally
   frmsettings.Free;
   frmsettings := nil;
 end;
end;


procedure Tfrmmain.iSettingsClick(Sender: TObject);
begin
 OpenSettings(0);
end;


procedure Tfrmmain.iQCProceduresClick(Sender: TObject);
begin
frmqc := Tfrmqc.Create(Self);
 try
  if not frmqc.ShowModal = mrOk then exit;
 finally
   frmqc.Free;
   frmqc := nil;
 end;
end;


procedure Tfrmmain.btnCompareSourcesClick(Sender: TObject);
begin
frmcomparesources := Tfrmcomparesources.Create(Self);
 try
  if not frmcomparesources.ShowModal = mrOk then exit;
 finally
   frmcomparesources.Free;
   frmcomparesources := nil;
 end;
end;

procedure Tfrmmain.iDeleteEmptyStationsClick(Sender: TObject);
begin

end;


procedure Tfrmmain.iUpdateStationInfoClick(Sender: TObject);
begin
  frmupdate_station_info := Tfrmupdate_station_info.Create(Self);
   try
    if not frmupdate_station_info.ShowModal = mrOk then exit;
   finally
     frmupdate_station_info.Free;
     frmupdate_station_info := nil;
   end;
end;


procedure Tfrmmain.DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
begin
  if (column.FieldName='id') then begin
     TDBGrid(Sender).Canvas.Brush.Color := clBtnFace;
     TDBGrid(Sender).Canvas.Font.Color  := clBlack;
  end;

  if (gdRowHighlight in AState) then begin
    TDBGrid(Sender).Canvas.Brush.Color := clNavy;
    TDBGrid(Sender).Canvas.Font.Color  := clYellow;
    TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
  end;
end;


procedure Tfrmmain.DBGrid2PrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
begin
  if (column.Field.AsString='merged') then begin
     TDBGrid(Sender).Canvas.Font.Color  := clRed;
     TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
  end;

  if (gdRowHighlight in AState) then begin
    TDBGrid(Sender).Canvas.Brush.Color := clNavy;
    TDBGrid(Sender).Canvas.Font.Color  := clYellow;
    TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
  end;
end;


procedure Tfrmmain.chkStActiveChange(Sender: TObject);
Var
  k, fl:integer;
begin
  fl:=0;
  for k:=0 to  chlParameters.Items.Count-1 do
    if chlParameters.Checked[k]=true then fl:=1;

  if (fl=0) and (chkStActive.Checked=true) then
   if MessageDlg('Select at least one parameter', mtWarning, [mbOk], 0)=mrOk then
      chkStActive.Checked:=false;
end;


procedure Tfrmmain.iAboutClick(Sender: TObject);
Var
  winver, AboutProgram:string;
begin
 {$ifdef WINDOWS}
   {$ifdef WIN32}
     winver:='i386-win32';
   {$endif}

   {$ifdef WIN64}
     winver:='x86_64-win64';
   {$endif}
 {$endif}

 {$ifdef Linux}
   {$ifdef CPU32}
     winver:='i386-linux';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-linux';
   {$endif}
 {$endif}

  {$ifdef DARWIN}
   {$ifdef CPU32}
     winver:='i386-darwin';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-darwin';
   {$endif}
 {$endif}

  AboutProgram:='MeteoShell ('+winver+')'+LineEnding+LineEnding+
                'Alexander Smirnov'+LineEnding+
                '© 2011-'+IntToStr(YearOf(now));

  if messagedlg(AboutProgram, mtInformation, [mbOk], 0)=mrOk then exit;
end;


(* Launching scripts *)
procedure Tfrmmain.RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
Var
  Ini:TIniFile;
  P:TProcess;
  ExeName, buf, s: string;
  WaitOnExit:boolean;
  i, j: integer;
begin
(*
  ExeFlag = 0 /Random executable file
  ExeFlag = 1 /Python
  ExeFlag = 2 /Surfer
  ExeFlag = 3 /Grapher
  ExeFlag = 4 /CDO
  ExeFlag = 5 /NCO
*)

{$IFDEF WINDOWS}
  Ini := TIniFile.Create(IniFileName);
  try
    case ExeFlag of
     0: begin
        ExeName:='';
        WaitOnExit:=false;
     end;
     1: begin
        ExeName:=Ini.ReadString('main', 'PythonPath', '');
        WaitOnExit:=false;
        if not FileExists(ExeName) then
           if Messagedlg(SNoPython, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     2: begin
        ExeName:=Ini.ReadString('main', 'SurferPath',  '');
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoSurfer, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     3: begin
        ExeName:=Ini.ReadString('main', 'GrapherPath', '');
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoGrapher, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     4: begin
        ExeName:=GlobalSupportPath+'cdo'+PathDelim+'cdo.exe';
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoCDO,    mtwarning, [mbOk], 0)=mrOk then exit;
     end;
    end;
  finally
   ini.Free;
  end;
{$ENDIF}

{$IFDEF UNIX}
  Case ExeFlag of
    1: ExeName :='python3';
    4: ExeName :='cdo';
    5: ExeName :='nco';
  end;
{$ENDIF}

 try
  P:=TProcess.Create(Nil);
  P.Commandline:=trim(ExeName+' '+cmd);
  //showmessage(P.CommandLine);
  P.Options:=[poUsePipes, poNoConsole];
  if WaitOnExit=true then P.Options:=P.Options+[poWaitOnExit];
  P.Execute;

  repeat
   SetLength(buf, buf_len);
   SetLength(buf, p.output.Read(buf[1], length(buf))); //waits for the process output
   // cut the incoming stream to lines:
   s:=s + buf; //add to the accumulator
   repeat //detect the line breaks and cut.
     i:=Pos(#13, s);
     j:=Pos(#10, s);
     if i=0 then i:=j;
     if j=0 then j:=i;
     if j = 0 then Break; //there are no complete lines yet.
     if (Sender<> nil) then begin
       Sender.Lines.Add(Copy(s, 1, min(i, j) - 1)); //return the line without the CR/LF characters
       Application.ProcessMessages;
     end;
     s:=Copy(s, max(i, j) + 1, length(s) - max(i, j)); //remove the line from accumulator
   until false;
 until buf = '';
 if (s <> '') and (Sender<>nil) then begin
   Sender.Lines.Add(s);
   Application.ProcessMessages;
 end;
finally
 P.Free;
end;
end;

procedure Tfrmmain.FormResize(Sender: TObject);
begin
  tbFastAccess.Top:=PageControl1.Top;
  tbFastAccess.Left:=Width-tbFastAccess.Width;
end;

procedure Tfrmmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
  try
    Ini := TIniFile.Create(IniFileName);
    Ini.WriteInteger( 'meteo', 'main_top',    Top);
    Ini.WriteInteger( 'meteo', 'main_left',   Left);
    Ini.WriteInteger( 'meteo', 'main_width',  Width);
    Ini.WriteInteger( 'meteo', 'main_height', Height);

    With DBGrid1 do begin
      Ini.WriteInteger( 'meteo', 'DBGrid1_0', Columns[0].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_1', Columns[1].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_2', Columns[2].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_3', Columns[3].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_4', Columns[4].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_5', Columns[5].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_6', Columns[6].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid1_7', Columns[7].Width);
    end;

    With DBGrid2 do begin
      Ini.WriteInteger( 'meteo', 'DBGrid2_0', Columns[0].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_1', Columns[1].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_2', Columns[2].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_3', Columns[3].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_4', Columns[4].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_5', Columns[5].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_6', Columns[6].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_7', Columns[7].Width);
      Ini.WriteInteger( 'meteo', 'DBGrid2_8', Columns[8].Width);
    end;
  finally
   Ini.Free;
  end;
end;

end.

