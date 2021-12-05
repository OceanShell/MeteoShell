unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Spin, IniFiles, LCLTranslator, ComCtrls;

type

  { Tfrmsettings }

  Tfrmsettings = class(TForm)
    btnCancel: TButton;
    btnGrapherPath: TButton;
    btnOk: TButton;
    cblanguage: TComboBox;
    chkLinear: TCheckBox;
    chkRunning: TCheckBox;
    edatabase: TEdit;
    eGrapherPath: TEdit;
    ehost: TEdit;
    epass: TEdit;
    euser: TEdit;
    gbFits: TGroupBox;
    gbGrapher: TGroupBox;
    gbLanguage: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PageControl1: TPageControl;
    rgServer: TRadioGroup;
    seRunning: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;

    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnGrapherPathClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure eGrapherPathChange(Sender: TObject);
    procedure rgServerClick(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmsettings: Tfrmsettings;

implementation

{$R *.lfm}

uses main;

{ Tfrmsettings }

procedure Tfrmsettings.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 GrapherDefault:string;
begin
 GrapherDefault:='c:\Program Files\Golden Software\Grapher 11\Scripter\Scripter.exe';

  Ini := TIniFile.Create(IniFileName);
  try
     rgServer.ItemIndex   := Ini.ReadInteger ( 'meteo',   'server',         1);
     cbLanguage.ItemIndex := Ini.ReadInteger ( 'meteo',   'language',       0);
     //rgPlotSoft.ItemIndex := Ini.ReadInteger ( 'meteo',   'plotting_soft',  0);
     eGrapherPath.Text    := Ini.ReadString  ( 'main',    'GrapherPath',    GrapherDefault);
     chkRunning.Checked   := Ini.ReadBool    ( 'Grapher', 'Running',        true);
     seRunning.Value      := Ini.ReadInteger ( 'Grapher', 'RunWindow',      5);
     chkLinear.Checked    := Ini.ReadBool    ( 'Grapher', 'Linear',         true);
  finally
    ini.Free;
  end;

  rgServer.OnClick(self);

  {$IFDEF UNIX}
     gbGrapherPath.Visible:=false;
     rgPlotSoft.ItemIndex:=1;
     TRadioButton(rgPlotSoft.Controls[0]).Enabled := False;
  {$ENDIF}

  {$IFDEF WINDOWS}
     eGrapherPath.OnChange(self);
  //   TRadioButton(rgPlotSoft.Controls[1]).Enabled := False;
  {$ENDIF}
  Application.ProcessMessages;
end;


procedure Tfrmsettings.eGrapherPathChange(Sender: TObject);
begin
  if FileExists(eGrapherPath.Text) then eGrapherPath.Font.Color:=clGreen  else eGrapherPath.Font.Color:=clRed;
end;


procedure Tfrmsettings.rgServerClick(Sender: TObject);
Var
  Ini: TIniFile;
  server: string;
begin

  Ini := TIniFile.Create(IniFileName);
  try
   if rgServer.ItemIndex=0 then server:='firebird' else server:='postgres';

      euser.Text           :=Ini.ReadString  (server,   'user',        '');
      epass.Text           :=Ini.ReadString  (server,   'pass',        '');
      ehost.Text           :=Ini.ReadString  (server,   'host',        '');
      edatabase.Text       :=Ini.ReadString  (server,   'database',    '');
    finally
      ini.Free;
    end;
end;

procedure Tfrmsettings.btnGrapherPathClick(Sender: TObject);
begin
  frmmain.OD.Filter:='Scripter.exe|Scripter.exe';
  if frmmain.OD.Execute then eGrapherPath.Text:= frmmain.OD.FileName;
end;


procedure Tfrmsettings.btnOkClick(Sender: TObject);
Var
 Ini:TIniFile;
 server: string;
begin
 Ini := TIniFile.Create(IniFileName);
  try
    if PageControl1.PageIndex<3 then begin
     Ini.WriteInteger ( 'meteo',   'server',        rgServer.ItemIndex);
     Ini.WriteInteger ( 'meteo',   'language',      cbLanguage.ItemIndex);
  //   Ini.WriteInteger ( 'meteo',   'plotting_soft', rgPlotSoft.ItemIndex);
     Ini.WriteString  ( 'main',    'GrapherPath',   eGrapherPath.Text);
     Ini.WriteBool    ( 'Grapher', 'Running',       chkRunning.Checked);
     Ini.WriteInteger ( 'Grapher', 'RunWindow',     seRunning.Value);
     Ini.WriteBool    ( 'Grapher', 'Linear',        chkLinear.Checked);


      if rgServer.ItemIndex=0 then server:='firebird' else server:='postgres';

      Ini.WriteString  ( server,   'user',       euser.Text);
      Ini.WriteString  ( server,   'pass',       epass.Text);
      Ini.WriteString  ( server,   'host',       ehost.Text);
      Ini.WriteString  ( server,   'database',   edatabase.Text);
    end;

  finally
    ini.Free;
  end;

  case cbLanguage.ItemIndex of
   0: SetDefaultLang('en');
   1: SetDefaultLang('ru');
  end;

 Close;
end;


procedure Tfrmsettings.btnCancelClick(Sender: TObject);
begin
  Close;
end;


end.

