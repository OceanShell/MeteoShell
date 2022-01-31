unit load_amca;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBGrids, DateUtils;

type

  { Tfrmload_amca }

  Tfrmload_amca = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;

    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
    procedure writepar(tbl:string; absnum: integer; DateCurr:TDateTime; val1:real);

  public
    { Public declarations }
  end;

var
  frmload_amca: Tfrmload_amca;
  fpath:string;

implementation

uses main, dm;


{$R *.lfm}


procedure Tfrmload_amca.Button1Click(Sender: TObject);
var
k,mik_line, kf:integer;
absnum,wmonum,flag:integer;
CST_WMONum,CST_Year,CST_Month,CST_Day,CST_Position :integer;
CST_Sensor_Elevation,CST_Elevation,CST_WMOCountryCode :integer;
CST_Lat,CST_Lon,CST_AirTemp,CST_SeaLevPressure,CST_WindDir,CST_WindSpeed :real;
CST_CloudTotal,CST_CloudLow,CST_RelHumidity,CST_DewPoint,CST_Time :real;
CST_VaporPressure,CST_Precipitation,CST_SurfTemp,CST_SeaSurfTemp :real;
CST_WetBlobTemp :real;
CST_CSTWMOName,CST_CSTSourceName :string;
WMOLat,WMOLon:real;
WMOStationName,WMOCountryName,WMOType:string;
WMOElevation,WMOElevationSensor:integer;
empty:boolean;
fname:string;
wmo:integer;
fi_dat:text;
DateCurr:TDateTime;
begin
for kf:=0 to listbox1.Count-1 do begin
  fname:=listbox1.Items.Strings[kf];
  wmo:=strtoint(copy(fname, length(fname)-8, 5));

    absnum:=-9;
    with frmdm.q1 do begin
      Close;
       SQL.Clear;
        SQL.Add('Select "id" from "station" ');
        SQL.Add('where "wmocode"='+quotedstr(inttostr(WMO)));
      Open;
       if frmdm.q1.IsEmpty=false then absnum:=frmdm.q1.Fields[0].AsInteger;
      Close;
    end;

  if absnum<>-9 then begin
  Assignfile(fi_dat, fpath+fname); reset(fi_dat);
  mik_line:=0;

  while not EOF(fi_dat) do begin
   mik_line:=mik_line+1;
   readln(fi_dat,CST_WMONum,
                 CST_Year,
                 CST_Month,
                 CST_Day,
                 CST_Time,
                 CST_Position,
                 CST_LAT,
                 CST_LON,
                 CST_AirTemp,
                 CST_SeaLevPressure,
                 CST_WindDir,
                 CST_WindSpeed,
                 CST_CloudTotal,
                 CST_CloudLow,
                 CST_RelHumidity,
                 CST_DewPoint,
                 CST_WetBlobTemp,
                 CST_VaporPressure,
                 CST_Precipitation,
                 CST_SurfTemp,
                 CST_SeaSurfTemp,
                 CST_CSTSourceName);

   DateCurr:=EncodeDate(cst_year, cst_month, trunc(DaysInAMonth(cst_year, cst_month)/2));

   if cst_AirTemp<999 then
   writepar('p_surface_air_temp_amca',absnum,DateCurr,cst_AirTemp);

   if cst_SeaLevPressure<9999 then
   writepar('p_sea_level_pressure_amca',absnum,DateCurr,cst_SeaLevPressure);

   if cst_WindDir<999 then
   writepar('p_wind_direction_amca',absnum,DateCurr,cst_WindDir);


   if cst_WindSpeed<999 then
   writepar('p_wind_speed_amca',absnum,DateCurr,cst_WindSpeed);

   if (cst_Precipitation<999) and (cst_Precipitation>0) then
   writepar('p_precipitation_amca',absnum,DateCurr,cst_Precipitation);


   if cst_CloudTotal<99 then
   writepar('p_cloud_total_amca',absnum,DateCurr,cst_CloudTotal);

   if cst_CloudLow<99 then
   writepar('p_cloud_low_amca',absnum,DateCurr,cst_CloudLow);

   if cst_RelHumidity<999 then
   writepar('p_relative_humidity_amca',absnum,DateCurr,cst_RelHumidity);

   if cst_DewPoint<999 then
   writepar('p_dew_point_amca',absnum,DateCurr,cst_DewPoint);

   if cst_WetBlobTemp<999 then
   writepar('p_wet_bulb_temperature_amca',absnum,DateCurr,cst_WetBlobTemp);


   if cst_VaporPressure<9999 then
   writepar('p_vapor_pressure_amca',absnum,DateCurr,cst_VaporPressure);

{!}end;
 end else memo1.Lines.Add(inttostr(wmo));

 end;
end;

procedure Tfrmload_amca.FormCreate(Sender: TObject);
var
  fdb: TSearchRec;
begin
 //  fpath:='X:\Data_Oceanography\_Meteo\amsa\US_Russian_Arctic_Atlas_Arctic_Climatology_Project_Arctic_Meteorology_Climate_Atlas\DATA\COASTAL_STATIONS\RUSSIAN_STATIONS\';
    fpath:='X:\Data_Oceanography\_Meteo\amsa\US_Russian_Arctic_Atlas_Arctic_Climatology_Project_Arctic_Meteorology_Climate_Atlas\DATA\COASTAL_STATIONS\WESTERN_STATIONS\';

   ListBox1.Clear;
  if fpath<>'' then begin
   fdb.Name:='';
   listbox1.Clear;
    FindFirst(fPath+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
  while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
  end;
end;


Procedure Tfrmload_amca.writepar(tbl:string; absnum: integer; DateCurr:TDateTime; val1:real);
begin
  with frmdm.q1 do begin
       Close;
        SQL.Clear;
         SQL.Add(' Select * from "'+tbl+'"');
         SQL.Add(' where "station_id"=:ID and "date"=:dat1 ');
         ParamByName('ID').AsInteger:=absnum;
         ParamByName('dat1').Value:=DateCurr;
       Open;
     end;

       if frmdm.q1.IsEmpty=true then begin
        with frmdm.q2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' insert into "'+tbl+'" ');
          SQL.Add(' ("station_id", "date", "value", "pqf2") ');
          SQL.Add(' values ');
          SQL.Add(' (:absnum, :date_, :value_, :pqf2)');
          ParamByName('absnum').Value:=absnum;
          ParamByName('date_').AsDate:=DateCurr;
          ParamByName('value_').Value:=val1;
          ParamByName('pqf2').Value:=0;
         ExecSQL;
       end;
     end;
  frmdm.TR.CommitRetaining;
end;


end.
