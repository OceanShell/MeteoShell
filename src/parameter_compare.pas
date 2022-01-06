unit parameter_compare;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBGrids, TAGraph;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    ComboBox1: TComboBox;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

