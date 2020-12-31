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
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
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

  try
   Ini := TIniFile.Create(IniFileName);
     cbLanguage.ItemIndex := Ini.ReadInteger ( 'meteo',   'language',   0);

     eGrapherPath.Text    := Ini.ReadString  ( 'Grapher', 'Path',       GrapherDefault);
     chkRunning.Checked   := Ini.ReadBool    ( 'Grapher', 'Running',    true);
     seRunning.Value      := Ini.ReadInteger ( 'Grapher', 'RunWindow',  5);
     chkLinear.Checked    := Ini.ReadBool    ( 'Grapher', 'Linear',     true);

     Ini := TIniFile.Create(IniFileName);
     rgServer.ItemIndex   :=Ini.ReadInteger ( 'meteo',   'server',      1);
  finally
    ini.Free;
  end;

  rgServer.OnClick(self);

  eGrapherPath.OnChange(self);
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
  try
   Ini := TIniFile.Create(IniFileName);
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
   Ini.WriteInteger ( 'meteo',   'language',   cbLanguage.ItemIndex);
   Ini.WriteString  ( 'Grapher', 'Path',       eGrapherPath.Text);
   Ini.WriteString  ( 'Grapher', 'Path',       eGrapherPath.Text);
   Ini.WriteBool    ( 'Grapher', 'Running',    chkRunning.Checked);
   Ini.WriteInteger ( 'Grapher', 'RunWindow',  seRunning.Value);
   Ini.WriteBool    ( 'Grapher', 'Linear',     chkLinear.Checked);

    Ini.WriteInteger ( 'meteo',   'server',     rgServer.ItemIndex);
     if rgServer.ItemIndex=0 then server:='firebird' else server:='postgres';

    Ini.WriteString  ( server,   'user',       euser.Text);
    Ini.WriteString  ( server,   'pass',       epass.Text);
    Ini.WriteString  ( server,   'host',       ehost.Text);
    Ini.WriteString  ( server,   'database',   edatabase.Text);

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

