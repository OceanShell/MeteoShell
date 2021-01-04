unit spatialaveraging;

{$mode objfpc}{$H+}

interface

uses
  Lclintf, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, ComObj, Buttons;

type
  Tfrmspatialaveraging = class(TForm)
    GroupBox1: TGroupBox;
    seymin: TSpinEdit;
    seymax: TSpinEdit;
    Label1: TLabel;
    btnCalculate: TButton;
    Label3: TLabel;
    Label4: TLabel;
    semmin: TSpinEdit;
    semmax: TSpinEdit;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    ComboBox1: TComboBox;
    btnPlot: TButton;
    RadioGroup2: TRadioGroup;
    GroupBox3: TGroupBox;
    seNorma1: TSpinEdit;
    seNorma2: TSpinEdit;
    Label2: TLabel;
    Label6: TLabel;
    btnShowData: TBitBtn;

    procedure FormShow(Sender: TObject);
    procedure btnCalculateClick(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure btnShowDataClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmspatialaveraging: Tfrmspatialaveraging;
  Out_f:text;

implementation

uses dm, main;

{$R *.lfm}

procedure Tfrmspatialaveraging.FormShow(Sender: TObject);
begin
 Combobox1.Items:=frmMain.chlParameters.Items;
 //RadioGroup1.ItemIndex:=0;
 RadioGroup2.ItemIndex:=1;
end;


procedure Tfrmspatialaveraging.btnCalculateClick(Sender: TObject);
Var
absnum, C:integer;
k, k_year, k_mn, y_min, y_max, m_min, m_max, count:integer;
Sum, Par, Aver, Norma, Lat, Sum_p, anom:real;
Aver_arr:array[1..2000] of real;
tsFile, clr:string;
begin
{y_min:=seymin.Value; y_max:=seymax.Value;
m_min:=semmin.Value; m_max:=semmax.Value;

for k:=1 to 2000 do Aver_arr[k]:=0;

 MDBDM.CDS.DisableControls;
  c:=0;
  for k_year:=CurYearMin to CurYearMax do begin
   inc(c); count:=0;
    par:=0; Sum_p:=0;
     MDBDM.CDS.First;
      While not MDBDM.CDS.Eof do begin
       absnum:=MDBDM.CDS.FieldByName('Absnum').AsInteger;
       Lat:=MDBDM.CDS.FieldByName('StLat').AsFloat;
         with MDBDM.ib1q1 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Select count(Val_), Avg(Val_) from ');
           SQL.Add(ComboBox1.Text);
           SQL.Add(' where absnum='+inttostr(absnum));
           if m_min<=m_max then begin
             SQL.Add(' and year_='+inttostr(k_year));
             SQL.Add(' and month_ between :mmin and :mmax ');
           end;
           if m_min>m_max then begin
             SQL.Add(' and ((year_='+inttostr(k_year-1)+' and month_>=:mmin) ');
             SQL.Add(' or (year_='+inttostr(k_year)+' and month_<=:mmax))');
           end;
           ParamByName('mmin').AsInteger:=m_min;
           ParamByName('mmax').AsInteger:=m_max;
          Open;
           if MDBDM.ib1q1.Fields[0].AsInteger>0 then begin
              Par:=Par+MDBDM.ib1q1.Fields[1].AsFloat*cos(Pi*Lat/180);
              Sum_p:=Sum_p+cos(Pi*Lat/180);
              inc(count);
           end;
          Close;
         end;
       MDBDM.CDS.Next;
     end;
   if count>0 then Aver_arr[c]:=Par/Sum_p else Aver_arr[c]:=-9999;
   // showmessage(inttostr(k_year)+#9+inttostr(count)+#9+floattostr(aver_arr[c]));
  end; //Year

  Norma:=0;
  if RadioGroup1.ItemIndex=0 then begin
    c:=0; count:=0;
    for k_year:=CurYearMin to CurYearMax do begin
      inc(c);
      if (k_year>=seNorma1.Value) and (k_year<=seNorma2.Value) then
        if Aver_arr[c]<>-9999 then begin
            Norma:=Norma+Aver_arr[c];
            inc(count);
        end;
    end;
    Norma:=Norma/(count);
  //  StatusBar1.Panels[0].Text:='Norma: '+floattostrF(norma, fffixed, 8, 3);
  end;

  tsFile:=GlobalPath+'Unload\TimeSeries\RegionalAveraging\Yearanomalies.dat';
  AssignFile(out_f, tsFile ); Rewrite (out_f);
  writeln(out_f, 'year':10, 'value':10, 'anomaly':10, 'color':10);
  try
   c:=0;
   for k_year:=CurYearMin to CurYearMax do begin
     inc(c);
    if Aver_arr[c]<>-9999 then begin
     anom:=Aver_arr[c]-norma;
     if anom<=0 then clr:='blue' else clr:='red';
     writeln(out_f, k_year:10, Aver_arr[c]:10:3, anom:10:3, clr:10);
    end;
   end;
  finally
   CloseFile(out_f)
  end;
  MDBDM.CDS.EnableControls;
 btnShowData.Enabled:=true;
 btnPlot.Enabled:=true;    }
end;


procedure Tfrmspatialaveraging.ComboBox1Select(Sender: TObject);
Var
abs_str:string;
begin
{
try
  MDBDM.CDS.DisableControls;
  OldID:=MDBDM.CDS.FieldByName('ABSNUM').AsInteger;

  MDBDM.CDS.First;
    while not MDBDM.CDS.Eof do begin
    if abs_str='' then abs_str:=Inttostr(MDBDM.CDS.FieldByName('ABSNUM').AsInteger) else
       abs_str:=abs_str+','+Inttostr(MDBDM.CDS.FieldByName('ABSNUM').AsInteger);
     MDBDM.CDS.Next;
    end;
  finally
   MDBDM.CDS.Locate('Absnum', OldID, []);
   MDBDM.CDS.EnableControls;
  end;

  with MDBDM.ib1q1 do begin
    Close;
      SQL.Clear;
      SQL.Add(' select min(year_) as ymin, max(year_) as ymax from ');
      SQL.Add(ComboBox1.Text);
      SQL.Add('where absnum in ('+abs_str+')');
    Open;
      CurYearMin:=MDBDM.ib1q1.FieldByName('ymin').AsInteger;
      CurYearMax:=MDBDM.ib1q1.FieldByName('ymax').AsInteger;
    Close;
   end;
 seymin.Value:=CurYearMin;
 seymax.Value:=CurYearMax;

 seymin.MinValue:=CurYearMin;
 seymin.MaxValue:=CurYearMax;

 seymax.MinValue:=CurYearMin;
 seymax.MaxValue:=CurYearMax;  }
end;


procedure Tfrmspatialaveraging.btnPlotClick(Sender: TObject);
Var
lineT:integer;
Grapher,Plot:OleVariant;
AxisTitleY, tsFile:string;
begin
tsFile:=GlobalPath+'Unload\TimeSeries\RegionalAveraging\Yearanomalies.dat';
 if RadioGroup2.ItemIndex=0 then lineT:=2 else lineT:=3;
    Grapher:=CreateOLEObject('Grapher.Application');
    Grapher.Visible(1);

    Plot:=Grapher.Documents.Add(0);  //documents collection
    Plot.PageSetup.Orientation:=2;  // Orientation

    Plot.CreateLinePlot('g1','SpatAv',tsFile,,1,LineT,,,,,,,,,1,,0.001,10,'Black');
    Plot.SetObjectLineProps('g1:SpatAv','Black','.1 in. Solid',0.005);

    Plot.CreateFit('g1:SpatAv','RunAv',1,8,5);
    Plot.SetObjectLineProps('g1:RunAv','Red','Solid',0.08);

    Plot.CreateFit('g1:SpatAv','Linear',1,0);
    Plot.SetObjectLineProps('g1:Linear','Blue','.1 in. Dash',0.05);

    Plot.Select('g1');
 //   Plot.CreateLegend(ID,'Legend',18,14);
    Plot.Maximize;
    Plot.ViewFitToWindow;
end;


procedure Tfrmspatialaveraging.btnShowDataClick(Sender: TObject);
begin
   OpenDocument(PChar(GlobalPath+'Unload\TimeSeries\RegionalAveraging\Yearanomalies.dat'));
end;

end.
