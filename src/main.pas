unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, sqldb, pqconnection, DBGrids, DB, ComCtrls, Spin, IniFiles, LCLIntf,
  LCLTranslator, Grids, ActnList, Buttons, Process, Math;

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
    btnadd: TToolButton;
    btncommit: TToolButton;
    btndelete: TToolButton;
    btnSelect: TButton;
    btnmonthlymatrix: TMenuItem;
    cbCountry: TComboBox;
    cbStation: TComboBox;
    cbWMO: TComboBox;
    cgSource: TCheckGroup;
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
    iLoadGHCNv2: TMenuItem;
    btnInfo: TMenuItem;
    lbResetID: TLabel;
    ListBox1: TListBox;
    MenuItem1: TMenuItem;
    iLoadGHCN_v4_prcp: TMenuItem;
    btnload_isd: TMenuItem;
    btnWindChartRose: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    iQCProcedures: TMenuItem;
    MenuItem6: TMenuItem;
    iLoadGHCND: TMenuItem;
    iShowTimeseries: TMenuItem;
    btnLoadAARI: TMenuItem;
    MenuItem8: TMenuItem;
    btnload_unaami: TMenuItem;
    btnload_amca: TMenuItem;
    iLoadGHCN_v4_t2m: TMenuItem;
    btnLoad_ECAD: TMenuItem;
    MenuItem9: TMenuItem;
    N5: TMenuItem;
    N1: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    btnCompareSources: TMenuItem;
    iUpdateStationInfo: TMenuItem;
    iLoadGHCNv3: TMenuItem;
    iLoadGHCN_v4: TMenuItem;
    MenuItem4: TMenuItem;
    iDatabaseTables: TMenuItem;
    iDeleteEmptyStations: TMenuItem;
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
    seYY1: TSpinEdit;
    seYY2: TSpinEdit;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    tbFastAccess: TToolBar;
    tbSelection: TTabSheet;
    tbData: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;

    procedure amapExecute(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btncommitClick(Sender: TObject);
    procedure btnInfoClick(Sender: TObject);
    procedure btnLoadAARIClick(Sender: TObject);
    procedure btnload_amcaClick(Sender: TObject);
    procedure btnLoad_ECADClick(Sender: TObject);
    procedure btnload_isdClick(Sender: TObject);
    procedure btnload_unaamiClick(Sender: TObject);
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
    procedure iLoadGHCNv2Click(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnmonthlymatrixClick(Sender: TObject);
    procedure cbCountryDropDown(Sender: TObject);
    procedure cbStationDropDown(Sender: TObject);
    procedure cbWMODropDown(Sender: TObject);
    procedure ds5701Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iLoadGHCN_v4_prcpClick(Sender: TObject);
    procedure iLoadGHCN_v4_t2mClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iQCProceduresClick(Sender: TObject);
    procedure iShowTimeseriesClick(Sender: TObject);
    procedure iUpdateStationInfoClick(Sender: TObject);
    procedure lbCoordResetClick(Sender: TObject);
    procedure lbResetIDClick(Sender: TObject);
    procedure lbResetMDClick(Sender: TObject);
    procedure iLoadGHCNv3Click(Sender: TObject);
    procedure iDatabaseTablesClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PM1Popup(Sender: TObject);
    procedure RegionalAveraging1Click(Sender: TObject);
    procedure rgTimestepClick(Sender: TObject);
    procedure SelectedMonthComposition1Click(Sender: TObject);
    procedure btnaddClick(Sender: TObject);
    procedure btndeleteClick(Sender: TObject);

  private
    { private declarations }
  public
    procedure CDSNavigation;
    procedure CDSStatistics;
    procedure UpdateIBContent;
    procedure CDSInfoNavigation;
    procedure RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
    procedure OpenSettings(tab_ind:integer);
  end;

var
  frmmain: Tfrmmain;
  GlobalPath, GlobalUnloadPath, GlobalSupportPath: string;
  IBName, IniFileName, DB_str: string;
  IDMin, IDMax, DBType, IBCount:integer;

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

uses dm, sortbufds, monthlymatrix, plottimeseries_old, map,
     sources_compare, timeseries, parameter_compare,
     settings,  info, qc,
     sources_merge, windchartrose,
     spatialaveraging, table_management, update_station_info,

     (* load *)
     load_ghcnd,load_ds570,load_aari, load_russian_arctic,
     load_ghcn_v2, load_ghcn_v4, load_ghcn_v3, load_unaami,
     load_amca, load_ghcnv4_prcp, load_ecad, load_isd;


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
      Columns[2].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_2', 260);
      Columns[3].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_3', 70);
      Columns[4].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_4', 80);
      Columns[5].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_5', 75);
      Columns[6].Width:=Ini.ReadInteger( 'meteo', 'DBGrid1_6', 210);
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
    Columns[2].Title.Caption:=SStation;
    Columns[3].Title.Caption:=SLatitude;
    Columns[4].Title.Caption:=SLongitude;
    Columns[5].Title.Caption:=SElevation;
    Columns[6].Title.Caption:=SCountry;
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


procedure Tfrmmain.iDeleteEmptyStationsClick(Sender: TObject);
Var
  absnum, cnt:integer;
begin
 frmdm.CDS.First; cnt:=0;
 While not frmdm.CDS.Eof do begin
  absnum:=frmdm.CDS.FieldByName('absnum').AsInteger;

   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select absnum from station_info ');
     SQL.Add(' where absnum='+IntToStr(absnum));
    Open;
     if frmdm.q1.IsEmpty=true then begin
       with frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' delete from station ');
         SQL.Add(' where absnum='+IntToStr(absnum));
        ExecSQL;
       end;
       //memo1.lines.add(inttostr(absnum));
       inc(cnt);
     end;
    Close;
   end;
  frmdm.CDS.Next;
 end;
 frmdm.TR.Commit;
 Showmessage('Stations removed: '+inttostr(cnt));
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
    SQL.Add(' select distinct("name") from "timestep" order by "id" ');
  Open;
 end;

 rgTimestep.Items.clear;
 while not frmdm.q1.EOF do begin
   rgTimestep.Items.Add(frmdm.q1.Fields[0].AsString);
  frmdm.q1.Next;
 end;
 rgTimestep.Columns:=frmdm.q1.RecordCount;
 frmdm.q1.Close;
 rgTimestep.ItemIndex:=1;
 rgTimestep.OnClick(self);


 for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=true;
 Application.ProcessMessages;
end;


procedure Tfrmmain.rgTimestepClick(Sender: TObject);
begin
  with frmdm.q1 do begin
  Close;
    SQL.Clear;
    SQL.Add(' select distinct("parameter"."name") ');
    SQL.Add(' from "parameter", "table", "timestep" ');
    SQL.Add(' where ');
    SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
    SQL.Add(' "table"."timestep_id"="timestep"."id" and ');
    SQL.Add(' "timestep"."name"='+QuotedStr(rgTimestep.Items.Strings[rgTimestep.ItemIndex]));
    SQL.Add(' order by "name" ');
  Open;
 end;

 chlParameters.Items.clear;
 while not frmdm.q1.EOF do begin
   chlParameters.Items.Add(frmdm.q1.Fields[0].AsString);
  frmdm.q1.Next;
 end;
 frmdm.q1.Close;


  with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select distinct("source"."name") ');
     SQL.Add(' from "source", "table", "timestep" ');
     SQL.Add(' where ');
     SQL.Add(' "table"."source_id"="source"."id" and ');
     SQL.Add(' "table"."timestep_id"="timestep"."id" and ');
     SQL.Add(' "timestep"."name"='+QuotedStr(rgTimestep.Items.Strings[rgTimestep.ItemIndex]));
     SQL.Add(' order by "source"."name" ');
    Open;
  end;

  cgSource.Items.clear;
  while not frmdm.q1.EOF do begin
    cgSource.Items.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
end;


procedure Tfrmmain.btnSelectClick(Sender: TObject);
Var
Lat1, Lat2, Lon1, Lon2:real;
k:integer;
tbl_str, timestep_str, src_str, timestep_name:string;
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
     SQL.Add('"timestep"."name"='+QuotedStr(rgTimestep.Items.Strings[rgTimestep.ItemIndex]));
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
     'select "station_id" from "station_info" where "table_id" in ('+
     'select "table"."id" from "table", "timestep" '+
     'where "table"."timestep_id"="timestep"."id" and '+
     '"timestep"."name"='+QuotedStr(rgTimestep.Items.Strings[rgTimestep.ItemIndex])+')))';
     //'"timestep"."name" in('+timestep_name+'))))' else timestep_str:='';
//showmessage(timestep_str);  }


src_str:='';
for k:=0 to cgSource.Items.Count-1 do
  if cgSource.Checked[k]=true then
    src_str:=src_str+QuotedStr(cgSource.Items.Strings[k])+',';

src_str:=copy(src_str, 1, length(src_str)-1);

if trim(src_str)<>'' then
src_str:=' and ("station"."id" in ( '+
     'select "station_id" from "station_info" where "table_id" in ('+
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
    SQL.Add(' "country"."name" as countryname ');
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


procedure Tfrmmain.SelectedMonthComposition1Click(Sender: TObject);
begin
  //
end;

procedure Tfrmmain.btnaddClick(Sender: TObject);
begin
 //
end;

procedure Tfrmmain.btndeleteClick(Sender: TObject);
begin
  frmdm.CDS.Delete;
end;

procedure Tfrmmain.btncommitClick(Sender: TObject);
begin
  frmdm.CDS.ApplyUpdates(0);
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
  DBUser, DBPass, DBHost, DBName, server: string;
  k: integer;
  TempList:TListBox;
begin
  try
    Ini := TIniFile.Create(IniFileName);

      //0-firebird; 1-postgres
      server:='';
      if Ini.ReadInteger('meteo', 'server', 0)=0 then
        server:='firebird' else server:='postgres';

      DBUser :=Ini.ReadString(server, 'user',     '');
      DBPass :=Ini.ReadString(server, 'pass',     '');
      DBHost :=Ini.ReadString(server, 'host',     '');
      DBName :=Ini.ReadString(server, 'database', '');


    // if database isn't specified
    if (trim(DBName)='') or (server='') then begin
      if MessageDlg(SNoDatabase, mtwarning, [mbOk], 0)=mrOk then
        iSettings.OnClick(self);
      exit;
    end;

    if frmdm.TR.Active then frmdm.TR.Commit;

    case Ini.ReadInteger( 'meteo', 'server', 1) of
      (* Firebird *)
      0: begin

        with frmdm.DBLoader do begin
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

  (* permanent list for parameter tables *)
   ListBox1.Clear;
   TempList:=TListBox.Create(self);
       try
        frmdm.FBDB.UserName:=DBUser;
        frmdm.FBDB.Password:=DBPass;
        frmdm.FBDB.HostName:=DBHost;
        frmdm.FBDB.DatabaseName:=DBName;
        frmdm.FBDB.Connected:=true;
        frmdm.TR.DataBase:=frmdm.FBDB;
        frmdm.CDS.DataBase:=frmdm.FBDB;
        frmdm.CDS2.DataBase:=frmdm.FBDB;
        frmdm.q1.DataBase:=frmdm.FBDB;
        frmdm.q2.DataBase:=frmdm.FBDB;
        frmdm.q3.DataBase:=frmdm.FBDB;
        frmdm.q4.DataBase:=frmdm.FBDB;

        frmdm.FBDB.GetTableNames(TempList.Items,False);

        UpdateIBContent;
        except
          on e: Exception do begin
            if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then close;
          end;
        end;
      end;

      (* PostgreSQL *)
      1: begin
       frmdm.DBLoader.Enabled:=false;
        try
         frmdm.PGDB.UserName:=DBUser;
         frmdm.PGDB.Password:=DBPass;
         frmdm.PGDB.HostName:=DBHost;
         frmdm.PGDB.DatabaseName:=DBName;
         frmdm.PGDB.Connected:=true;
         frmdm.TR.DataBase:=frmdm.PGDB;
         frmdm.CDS.DataBase:=frmdm.PGDB;
         frmdm.CDS2.DataBase:=frmdm.PGDB;
         frmdm.q1.DataBase:=frmdm.PGDB;
         frmdm.q2.DataBase:=frmdm.PGDB;
         frmdm.q3.DataBase:=frmdm.PGDB;
         frmdm.q4.DataBase:=frmdm.PGDB;

         frmdm.PGDB.GetTableNames(TempList.Items,False);

         UpdateIBContent;
        except
          on e: Exception do begin
            if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then close;
          end;
        end;
      end;
    end;

    for k:=0 to TempList.Items.Count-1 do
     if (copy(TempList.Items.Strings[k], 1, 2)='p_') then
       ListBox1.Items.Add(TempList.Items.Strings[k]);

 finally
  ini.Free;
  TempList.Free;
 end;
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



procedure Tfrmmain.btnLoadAARIClick(Sender: TObject);
begin
  frmLoadAARI := TfrmLoadAARI.Create(Self);
try
 if not frmLoadAARI.ShowModal = mrOk then exit;
finally
  frmLoadAARI.Free;
  frmLoadAARI := nil;
end
end;

procedure Tfrmmain.btnload_amcaClick(Sender: TObject);
begin
frmload_amca := Tfrmload_amca.Create(Self);
try
 if not frmload_amca.ShowModal = mrOk then exit;
finally
  frmload_amca.Free;
  frmload_amca := nil;
end
end;

procedure Tfrmmain.btnload_unaamiClick(Sender: TObject);
begin
 frmload_unaami := Tfrmload_unaami.Create(Self);
try
 if not frmload_unaami.ShowModal = mrOk then exit;
finally
  frmload_unaami.Free;
  frmload_unaami := nil;
end
end;

procedure Tfrmmain.MenuItem8Click(Sender: TObject);
begin
frmload_russian_arctic := Tfrmload_russian_arctic.Create(Self);
try
 if not frmload_russian_arctic.ShowModal = mrOk then exit;
finally
  frmload_russian_arctic.Free;
  frmload_russian_arctic := nil;
end
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

procedure Tfrmmain.btnLoad_ECADClick(Sender: TObject);
begin
frmload_ecad := Tfrmload_ecad.Create(Self);
try
 if not frmload_ecad.ShowModal = mrOk then exit;
finally
  frmload_ecad.Free;
  frmload_ecad := nil;
end
end;


procedure Tfrmmain.iLoadGHCNv2Click(Sender: TObject);
begin
frmload_ghcn_v2 := Tfrmload_ghcn_v2.Create(Self);
 try
  if not frmload_ghcn_v2.ShowModal = mrOk then exit;
 finally
   frmload_ghcn_v2.Free;
   frmload_ghcn_v2 := nil;
 end;
end;



procedure Tfrmmain.iLoadGHCNv3Click(Sender: TObject);
begin
  frmload_ghcn_v3 := Tfrmload_ghcn_v3.Create(Self);
   try
    if not frmload_ghcn_v3.ShowModal = mrOk then exit;
   finally
     frmload_ghcn_v3.Free;
     frmload_ghcn_v3 := nil;
   end;
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

procedure Tfrmmain.btnload_isdClick(Sender: TObject);
begin
 frmload_isd := Tfrmload_isd.Create(Self);
 try
  if not frmload_isd.ShowModal = mrOk then exit;
 finally
   frmload_isd.Free;
   frmload_isd := nil;
 end
end;


procedure Tfrmmain.iDatabaseTablesClick(Sender: TObject);
begin
  frmtablemanagement := Tfrmtablemanagement.Create(Self);
  try
   if not frmtablemanagement.ShowModal = mrOk then exit;
  finally
    frmtablemanagement.Free;
    frmtablemanagement := nil;
  end;
end;

procedure Tfrmmain.MenuItem2Click(Sender: TObject);
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

procedure Tfrmmain.PageControl1Change(Sender: TObject);
begin
  if PageControl1.PageIndex=1 then Toolbar1.Visible:=true else Toolbar1.Visible:=false;
end;

procedure Tfrmmain.PM1Popup(Sender: TObject);
begin
  if frmdm.CDS2.FieldByName('timestep').AsString='Month' then begin
    btnmonthlymatrix.Enabled:=true;
   // btnCompareSources.Enabled:=true;
  end else begin
    btnmonthlymatrix.Enabled:=false;
  //  btnCompareSources.Enabled:=false;
  end;

  if copy(frmdm.CDS2.FieldByName('par').AsString, 1, 10)='Wind speed' then begin
    btnWindChartRose.Enabled:=true;
  end else begin
    btnWindChartRose.Enabled:=false;
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
                '© 2011-2021';

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

