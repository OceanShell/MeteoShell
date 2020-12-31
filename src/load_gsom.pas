unit load_gsom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfrmloadgsom }

  Tfrmloadgsom = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  frmloadgsom: Tfrmloadgsom;
  path:string;

implementation

{$R *.lfm}

{ Tfrmloadgsom }

procedure Tfrmloadgsom.Button1Click(Sender: TObject);
Var
fdb:TSearchRec;
begin
//SelectDirectory('Select folder', '' , path);
path:='X:\MDB\data\gsom\';
if path<>'' then begin
   Path:=Path+'\';
   fdb.Name:='';
   listbox1.Clear;
    FindFirst(Path+'*.csv',faAnyFile, fdb);
   if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
  while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
end;
end;

procedure Tfrmloadgsom.Button2Click(Sender: TObject);
begin
 { for c:=0 to ListBox1.count-1 do begin
    fin :=path+Listbox1.Items.Strings[c];

    AssignFile(dat, fin); Reset(dat);
    repeat

    until eof(dat);
  end;  }
end;

end.

