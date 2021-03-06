unit map_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ColorBox,
  StdCtrls, ComCtrls, Spin, IniFiles, map_globctrl;

type

  { Tfrmmap_settings }

  Tfrmmap_settings = class(TForm)
    btnSave: TButton;
    btnReset: TButton;
    chkShowStars: TCheckBox;
    ColorPointerBorder: TColorBox;
    ColorPointerInner: TColorBox;
    ColorMapBackground: TColorBox;
    ColorLand: TColorBox;
    ColorLandContour: TColorBox;
    ColorGlobeDisc: TColorBox;
    ColorSelectionCross: TColorBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    PageControl1: TPageControl;
    rgPointerSize: TRadioGroup;
    seZoomStep: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet5: TTabSheet;

    procedure btnResetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);

  private

  public

  end;

var
  frmmap_settings: Tfrmmap_settings;

implementation

{$R *.lfm}

uses main;

{ Tfrmmap_settings }

procedure Tfrmmap_settings.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
begin
   Ini := TIniFile.Create(IniFileName);
  try
    seZoomStep.Value            :=Ini.ReadInteger( 'osmap', 'zoom_step', 50);
    chkShowStars.Checked        :=Ini.ReadBool   ( 'osmap', 'show_stars', true);

    rgPointerSize.ItemIndex     :=Ini.ReadInteger( 'osmap', 'pointer_size', 2);
    ColorPointerInner.Selected  :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color',   'clRed'));
    ColorPointerBorder.Selected :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color',  'clBlack'));

    ColorSelectionCross.Selected:=StringToColor(Ini.ReadString( 'osmap', 'selection_cross_color', 'clRed'));
    ColorMapBackground.Selected :=StringToColor(Ini.ReadString( 'osmap', 'map_background_color',  'clNavy'));
    ColorGlobeDisc.Selected     :=StringToColor(Ini.ReadString( 'osmap', 'globe_disc_color',      'clAqua'));
    ColorLand.Selected          :=StringToColor(Ini.ReadString( 'osmap', 'land_color',            '$00D000')); //Light Green
    ColorLandContour.Selected   :=StringToColor(Ini.ReadString( 'osmap', 'land_contour_color',    '$004000')); //Dark Green
  finally
    Ini.Free;
  end;
end;


procedure Tfrmmap_settings.btnResetClick(Sender: TObject);
begin
  seZoomStep.Value            :=50;
  chkShowStars.Checked        :=true;

  rgPointerSize.ItemIndex     :=2;
  ColorPointerInner.Selected  :=clRed;
  ColorPointerBorder.Selected :=clBlack;

  ColorSelectionCross.Selected:=clRed;
  ColorMapBackground.Selected :=clNavy;
  ColorGlobeDisc.Selected     :=clAqua;
  ColorLand.Selected          :=TColor($00D000); //Light Green
  ColorLandContour.Selected   :=TColor($004000); //Dark Green
end;



procedure Tfrmmap_settings.btnSaveClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
   Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'osmap', 'zoom_step',             seZoomStep.Value);
    Ini.WriteBool   ( 'osmap', 'show_stars',            chkShowStars.Checked);

    Ini.WriteInteger( 'osmap', 'pointer_size',          rgPointerSize.ItemIndex);
    Ini.WriteString ( 'osmap', 'pointer_inner_color',   ColorToString(ColorPointerInner.Selected));
    Ini.WriteString ( 'osmap', 'pointer_border_color',  ColorToString(ColorPointerBorder.Selected));

    Ini.WriteString ( 'osmap', 'selection_cross_color', ColorToString(ColorSelectionCross.Selected));
    Ini.WriteString ( 'osmap', 'map_background_color',  ColorToString(ColorMapBackground.Selected));
    Ini.WriteString ( 'osmap', 'globe_disc_color',      ColorToString(ColorGlobeDisc.Selected));
    Ini.WriteString ( 'osmap', 'land_color',            ColorToString(ColorLand.Selected));
    Ini.WriteString ( 'osmap', 'land_contour_color',    ColorToString(ColorLandContour.Selected));

  finally
    Ini.Free;
  end;
  Close;
end;


end.

