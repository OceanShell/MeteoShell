unit qc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, lclintf;

type

  { Tfrmqc }

  Tfrmqc = class(TForm)
    btnStart: TButton;
    cbTable: TComboBox;
    chkDropQCFlag: TCheckBox;
    chkWrite: TCheckBox;
    chkEveryTable: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    lbCurrentTbl: TLabel;
    rbSigma: TRadioButton;
    seSigma: TSpinEdit;

    procedure btnStartClick(Sender: TObject);
    procedure cbTableSelect(Sender: TObject);
    procedure chkEveryTableClick(Sender: TObject);
  //  procedure chkEveryTableClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    procedure RunChecks(tbl: string);
    procedure DropQCFlag(tbl: string);
  public

  end;

var
  frmqc: Tfrmqc;

implementation

{$R *.lfm}

uses main, dm, qc_sigma;

{ Tfrmqc }

procedure Tfrmqc.FormCreate(Sender: TObject);
begin
  cbTable.Items:=frmmain.ListBox1.Items;
  lbCurrentTbl.Caption:='';
end;

procedure Tfrmqc.cbTableSelect(Sender: TObject);
begin
  btnStart.Enabled:=true;
end;

procedure Tfrmqc.chkEveryTableClick(Sender: TObject);
begin
  cbTable.Enabled:= not chkEveryTable.Enabled;
  if chkEveryTable.Enabled=true then btnStart.Enabled:=true;
end;


procedure Tfrmqc.btnStartClick(Sender: TObject);
Var
  pp:integer;
  tbl: string;
begin
  try
    btnStart.Enabled:=false;

    if chkEveryTable.Checked=true then begin
      for pp:=0 to cbTable.Items.Count-1 do begin
        tbl:=cbTable.Items.Strings[pp];

        lbCurrentTbl.Caption:=tbl;
        Application.ProcessMessages;

        if chkDropQCFlag.Checked=true then DropQCFlag(tbl);
        RunChecks(tbl);
      end;
    end;

    if chkEveryTable.Checked=false then begin
      if chkDropQCFlag.Checked=true then DropQCFlag(cbTable.Text);
      RunChecks(cbTable.Text);
    end;
  finally
    btnStart.Enabled:=true;
    OpenDocument(GlobalUnloadPath+'qc'+PathDelim);
  end;
end;


procedure Tfrmqc.RunChecks(tbl: string);
begin
  if rbSigma.Checked then begin
    qc_sigma.SigmaCheck(tbl, seSigma.Value, chkWrite.Checked);
  end;
end;

procedure Tfrmqc.DropQCFlag(tbl: string);
begin
  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' update "'+tbl+'" ');
    SQL.Add(' set "pqf2"=0 ');
   ExecSQL;
  end;
  frmdm.TR.CommitRetaining;
end;

end.

