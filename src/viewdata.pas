unit viewdata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, StdCtrls, bufdataset, db, math, types, variants,
  IniFiles, LCLTranslator, DBGrids, Grids, ExtCtrls, SQLDB;

type

  { Tfrmviewdata }

  Tfrmviewdata = class(TForm)
    btnPlotAllMonth: TMenuItem;
    btnPlot: TMenuItem;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    iEditData: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    btnPlotColumn: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PM: TPopupMenu;
    tabValues: TTabSheet;
    tabAnomalies: TTabSheet;
    ToolBar1: TToolBar;
    btnSave: TToolButton;

    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPlotAllMonthClick(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure btnPlotColumnClick(Sender: TObject);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure iEditDataClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
    { private declarations }
  public
    { public declarations }
    procedure GetData(parameter_id:integer);
  end;

var
  frmviewdata: Tfrmviewdata;
  CDSViewValues, CDSViewAnomalies:TBufDataSet;
  DSViewValues, DSViewAnomalies:TDataSource;
  tspath:string;

implementation

{$R *.lfm}

{ Tfrmviewdata }

uses main, dm, timeseries, procedures, grapher, editdata;

procedure Tfrmviewdata.FormShow(Sender: TObject);
Var
  k:integer;
begin
 tspath:=GlobalPath+'unload\timeseries\';

 (* CDS for values *)
 CDSViewValues:=TBufDataSet.Create(self);
 With CDSViewValues.FieldDefs do begin
   Add('yy', ftinteger, 0, false);
     for k:=1 to 12 do Add(inttostr(k)   ,ftfloat, 0, false);
   Add('13', ftFloat  , 0, false);
 end;
 CDSViewValues.CreateDataSet;
 CDSViewValues.IndexFieldNames:='yy';

 DSViewValues:=TDataSource.Create(self);
 DSViewValues.DataSet:=CDSViewValues;

 DBGrid1.DataSource:=DSViewValues;

 (* CDS for anomalies *)
 CDSViewAnomalies:=TBufDataSet.Create(self);
 With CDSViewAnomalies.FieldDefs do begin
   Add('yy'   ,ftinteger, 0, false);
   for k:=1 to 12 do
   Add(inttostr(k)   ,ftfloat, 0, false);
   Add('13' ,ftFloat  , 0, false);
 end;
 CDSViewAnomalies.CreateDataSet;

 DSViewAnomalies:=TDataSource.Create(self);
 DSViewAnomalies.DataSet:=CDSViewAnomalies;
 DBGrid2.DataSource:=DSViewAnomalies;

 With DBGrid1 do begin
   Columns[0].Title.Caption :=SYear;
   Columns[1].Title.Caption :=SJAN;
   Columns[2].Title.Caption :=SFEB;
   Columns[3].Title.Caption :=SMAR;
   Columns[4].Title.Caption :=SAPR;
   Columns[5].Title.Caption :=SMAY;
   Columns[6].Title.Caption :=SJUN;
   Columns[7].Title.Caption :=SJUL;
   Columns[8].Title.Caption :=SAUG;
   Columns[9].Title.Caption :=SSEP;
   Columns[10].Title.Caption:=SOCT;
   Columns[11].Title.Caption:=SNOV;
   Columns[12].Title.Caption:=SDEC;
   Columns[13].Title.Caption:=SAnnual;
 end;

 With DBGrid2 do begin
   Columns[0].Title.Caption :=SYear;
   Columns[1].Title.Caption :=SJAN;
   Columns[2].Title.Caption :=SFEB;
   Columns[3].Title.Caption :=SMAR;
   Columns[4].Title.Caption :=SAPR;
   Columns[5].Title.Caption :=SMAY;
   Columns[6].Title.Caption :=SJUN;
   Columns[7].Title.Caption :=SJUL;
   Columns[8].Title.Caption :=SAUG;
   Columns[9].Title.Caption :=SSEP;
   Columns[10].Title.Caption:=SOCT;
   Columns[11].Title.Caption:=SNOV;
   Columns[12].Title.Caption:=SDEC;
   Columns[13].Title.Caption:=SAnnual;
 end;

 DBGrid1.Columns.Items[0].FieldName:='yy';
 DBGrid2.Columns.Items[0].FieldName:='yy';
 for k:=1 to 13 do begin
  DBGrid1.Columns.Items[k].FieldName:=inttostr(k);
  DBGrid2.Columns.Items[k].FieldName:=inttostr(k);
  DBGrid1.Columns.Items[k].DisplayFormat := ',0.00';
  DBGrid2.Columns.Items[k].DisplayFormat := ',0.00';
 end;
end;


procedure Tfrmviewdata.GetData(parameter_id:integer);
Var
  k, ID, cnt, tot_cnt:integer;
  yy_min, yy_max:integer;
  yy, mn, dd, yy_old, mn_old, dd_old: word;
  sum, val1, valn:real;
  mean_val:array [1..13] of real;

  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
  tbl: string;
begin
 frmviewdata.Caption:=frmdm.CDS.FieldByName('name').AsString+': '+
                      frmdm.CDS2.FieldByName('par').AsString;
 Application.ProcessMessages;

 (* temporary transaction for support database *)
 TRt:=TSQLTransaction.Create(nil);
 TRt.DataBase:=frmdm.TR.DataBase;

 (* temporary query for main database *)
 Qt1:=TSQLQuery.Create(nil);
 Qt1.Database:=frmdm.TR.DataBase;
 Qt1.Transaction:=TRt;

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "table" from "parameter" ');
    SQL.Add(' where "parameter"."id"=:id ');
    ParamByName('id').AsInteger:=parameter_id;
   Open;
    tbl:=Qt1.Fields[0].AsString;
   Close;
  end;

 if CDSViewValues.Active=true then CDSViewValues.Close;
    CDSViewValues.Open;
 if CDSViewAnomalies.Active=true then CDSViewAnomalies.Close;
    CDSViewAnomalies.Open;

   ID:=frmdm.CDS.FieldByName('id').AsInteger;
   tot_cnt:=1; yy_min:=9999; yy_max:=-9999;
    with Qt1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select * from "'+tbl+'" ');
      SQL.Add(' where "station_id"=:id ');
      SQL.Add(' order by "date" ');
      ParamByName('id').AsInteger:=id;
     Open;
    end;

    Qt1.First;
     DecodeDate(Qt1.FieldByName('date').AsDateTime, yy_old, mn_old, dd_old);
     valn:=Qt1.FieldByName('value').AsFloat;
    Qt1.Next;

  try
   DBGrid1.Enabled:=false;
   DBGrid2.Enabled:=false;
   CDSViewValues.DisableControls;
   CDSViewValues.First;
   CDSViewAnomalies.DisableControls;
   CDSViewAnomalies.First;

  sum:=0; cnt:=0;
  while not Qt1.EOF do begin
   DecodeDate(Qt1.FieldByName('date').AsDateTime, yy, mn, dd);
   val1:=Qt1.FieldByName('value').AsFloat;

   inc(tot_cnt);

    if cnt=0 then begin
       CDSViewValues.Append;
       CDSViewValues.FieldByName('yy').AsInteger:=yy_old;
       CDSViewValues.FieldByName(inttostr(mn_old)).AsFloat:=valn;
       CDSViewValues.Post;

       if yy_old<yy_min then yy_min:=yy_old;
       if yy_old>yy_max then yy_max:=yy_old;

       sum:=sum+valn;
       inc(cnt);
     end;

    if cnt>0 then begin
     //  showmessage(inttostr(cnt)+'   '+floattostr(val1)+'   '+floattostr(valn)+'   '+inttostr(Qt1.RecordCount));
      if (mn<>mn_old) then begin
          CDSViewValues.Edit;
          CDSViewValues.FieldByName(inttostr(mn_old)).AsFloat:=RoundTo(valn, -2);
          CDSViewValues.Post;

           sum:=sum+valn;
           inc(cnt);
           valn:=val1;
           mn_old:=mn;
      end;

      if (yy<>yy_old) then begin
      // showmessage(inttostr(cnt));
      if (cnt=13) then begin
       CDSViewValues.Edit;
       CDSViewValues.FieldByName('13').AsFloat:=RoundTo((sum/12), -2);
       CDSViewValues.Post;
      end;
      CDSViewValues.Next;

      cnt:=0;
      sum:=0;
      yy_old:=yy;
      mn_old:=mn;
      end;
    end;

        if (tot_cnt=Qt1.RecordCount) then begin
          CDSViewValues.Edit;
          CDSViewValues.FieldByName(inttostr(mn)).AsFloat:=val1;
          if cnt=12 then
             CDSViewValues.FieldByName('13').AsFloat:=RoundTo((sum/12), -2);
          CDSViewValues.Post;
         end;

   Qt1.Next;
   end;
  Qt1.Close;
  Qt1.Free;
  Trt.Commit;
  Trt.Free;

  for mn:=1 to 13 do mean_val[mn]:=0;

  for mn:=1 to 13 do begin
   CDSViewValues.First; sum:=0; cnt:=0;
   while not CDSViewValues.EOF do begin
    if not VarIsNull(CDSViewValues.FieldByName(Inttostr(mn)).AsVariant) then begin
      sum:=sum+CDSViewValues.FieldByName(Inttostr(mn)).AsFloat;
      inc(cnt);
    end;
    CDSViewValues.Next;
   end;
   if cnt>0 then mean_val[mn]:=sum/cnt;
  end;

  CDSViewValues.First;
   while not CDSViewValues.EOF do begin
    CDSViewAnomalies.Append;
    CDSViewAnomalies.FieldByName('yy').AsInteger:=CDSViewValues.FieldByName('yy').AsInteger;
    CDSViewAnomalies.Post;
     for mn:=1 to 13 do begin
      if not VarIsNull(CDSViewValues.FieldByName(Inttostr(mn)).AsVariant) then begin
        CDSViewAnomalies.Edit;
        CDSViewAnomalies.FieldByName(Inttostr(mn)).AsFloat:=
          RoundTo((CDSViewValues.FieldByName(Inttostr(mn)).AsFloat-mean_val[mn]), -2);
        CDSViewAnomalies.Post;
      end;
     end;
    CDSViewValues.Next;
   end;

   for k:=yy_min to yy_max do begin
    if VarIsNull(CDSViewValues.Lookup('yy', k, 'yy')) then begin
       CDSViewValues.Append;
       CDSViewValues.FieldByName('yy').AsInteger:=k;
       CDSViewValues.Post;
    end;

   end;

  finally
    CDSViewValues.First;
    CDSViewValues.EnableControls;
    DBGrid1.Enabled:=true;
    DBGrid1.refresh;

    CDSViewAnomalies.First;
    CDSViewAnomalies.EnableControls;
    DBGrid2.Enabled:=true;
    DBGrid2.refresh;
  end;

    btnSave.Enabled := not CDSViewValues.IsEmpty ;
    DbGrid1.Enabled := not CDSViewValues.IsEmpty ;
    DbGrid2.Enabled := not CDSViewValues.IsEmpty ;
 end;


procedure Tfrmviewdata.btnPlotClick(Sender: TObject);
begin
 frmtimeseries := Tfrmtimeseries.Create(Self);
  try
   if not frmtimeseries.ShowModal = mrOk then exit;
  finally
    frmtimeseries.Free;
    frmtimeseries := nil;
  end;
end;

procedure Tfrmviewdata.btnPlotAllMonthClick(Sender: TObject);
begin
  //
end;


procedure Tfrmviewdata.btnPlotColumnClick(Sender: TObject);
Var
 Ini:TIniFile;
 YY, MN:integer;
 val1:Variant;
 grapherpath, fname, title, par, units, xtitle, cmd, p_type:string;
begin
 try
 Ini := TIniFile.Create(IniFileName);
   grapherpath :=Ini.ReadString( 'Grapher', 'Path', '');
 finally
  ini.Free;
 end;

 fname:=tspath+'timeseries.txt';

 AssignFile(f_dat, fname); rewrite(f_dat);
 Writeln(f_dat, 'YY':5, 'Value':8);

 (* Plot real values *)
 if frmViewData.PageControl1.PageIndex=0 then begin
  par:=DBGrid1.SelectedField.FieldName;
  mn:=DBGrid1.SelectedField.FieldNo-1;
  p_type:='values';
  try
   CDSViewValues.First;
   CDSViewValues.DisableControls;
      while not CDSViewValues.EOF do begin
       YY  :=CDSViewValues.FieldByName('YY').AsInteger;
       Val1:=CDSViewValues.FieldByName(inttostr(mn)).AsVariant;
        if not VarIsNull(Val1) then
             writeln(f_dat, yy:5, VarToStr(Val1):8) else
             writeln(f_dat, yy:5, 'NaN':8);
       CDSViewValues.Next;
      end;
  finally
   CDSViewValues.First;
   CDSViewValues.EnableControls;
  end;
 end; //Values

 (* Plot anomalies *)
 if frmViewData.PageControl1.PageIndex=1 then begin
  par:=DBGrid2.SelectedField.FieldName;
  mn:=DBGrid2.SelectedField.FieldNo-1;
  p_type:='anomalies';
  try
   CDSViewAnomalies.DisableControls;
     CDSViewAnomalies.First;
      while not CDSViewAnomalies.EOF do begin
        YY  :=CDSViewAnomalies.FieldByName('YY').AsInteger;
        Val1:=CDSViewAnomalies.FieldByName('13').AsVariant;
        if not VarIsNull(Val1) then writeln(f_dat, yy:5, VarToStr(Val1):8);
       CDSViewAnomalies.Next;
      end;
  finally
   CDSViewAnomalies.First;
   CDSViewAnomalies.EnableControls;
  end;
 end; //Values
 CloseFile(f_dat);

 par:=frmdm.CDS2.FieldByName('par').AsString;
 par:=copy(par, 3, length(par));
 par:=StringReplace(par, '_', ' ', [rfReplaceAll, rfIgnoreCase]);

 if mn<=12 then title:='Monthly mean '+p_type+' of '+par+', '+GetMonthFromIndex(mn);
 if mn=13  then title:='Annual mean ' +p_type+' of '+par;
 units:='';
 xtitle:='';

 PlotTimeSeries(fname, title, par, units, xtitle, 2);

 cmd:='"'+grapherpath+'" -x "'+GlobalPath+'unload\timeseries\timeseries.bas"';
 frmmain.RunScript(3, cmd, nil);
end;


procedure Tfrmviewdata.MenuItem2Click(Sender: TObject);
Var
 Ini:TIniFile;
 mn:integer;
 val_arr:array of real;
 cnt_arr:array of integer;
 grapherpath, fname, title, par, units, xtitle, cmd:string;
begin
 SetLength(Val_arr, CDSViewValues.RecordCount);
 SetLength(cnt_arr, CDSViewValues.RecordCount);

 try
 Ini := TIniFile.Create(IniFileName);
   grapherpath :=Ini.ReadString( 'Grapher', 'Path', '');
 finally
  ini.Free;
 end;

 if FileExists(grapherpath)=false then
    if MessageDlg('Please, set path to Grapher', mtInformation, [mbOk], 0)=mrOk then exit;

 fname:=tspath+frmdm.CDS.FieldByName('name').AsString+'_annual_circle.txt';
 par:=frmdm.CDS2.FieldByName('par').AsString;
 title:='Annual circle of '+par;
 units:='';
 xtitle:='';

 AssignFile(f_dat, fname); rewrite(f_dat);
 Writeln(f_dat, 'MN':5, 'Value':8);

 (* Plot real values *)
 if frmViewData.PageControl1.PageIndex=0 then begin
  try
   CDSViewValues.DisableControls;
    for mn:=1 to 12 do begin
     CDSViewValues.First;
      while not CDSViewValues.EOF do begin
        val_arr[mn]:=Val_arr[mn]+CDSViewValues.FieldByName(inttostr(mn)).AsFloat;
        cnt_arr[mn]:=cnt_arr[mn]+1;
       CDSViewValues.Next;
      end;
     if cnt_arr[mn]>0 then writeln(f_dat, mn:5, FloattostrF((val_arr[mn]/cnt_arr[mn]), fffixed, 8, 2):8);
    end; // 12 month
  finally
   CDSViewValues.First;
   CDSViewValues.EnableControls;
  end;
 end; //Values

 CloseFile(f_dat);

 PlotTimeSeries(fname, title, par, units, xtitle, 2);

 cmd:='"'+grapherpath+'" -x "'+GlobalPath+'unload\timeseries\timeseries.bas"';
 frmmain.RunScript(3, cmd, nil);
end;



procedure Tfrmviewdata.btnSaveClick(Sender: TObject);
Var
 k:integer;
 fout:text;
begin
 frmmain.SD.DefaultExt:='.txt';
 frmmain.SD.InitialDir:=GlobalPath+'unload'+PathDelim;

 if frmmain.SD.Execute then begin
  AssignFile(fout, frmmain.SD.FileName); rewrite(fout);
 (* Export values *)
  if frmViewData.PageControl1.PageIndex=0 then begin
   try
    CDSViewValues.First;
    CDSViewValues.DisableControls;
       while not CDSViewValues.EOF do begin
        write(fout, inttostr(CDSViewValues.FieldByName('YY').AsInteger));
        for k:=1 to 13 do begin
         write(fout, #9, Floattostr(CDSViewValues.FieldByName(inttostr(k)).AsFloat));
        end;
       writeln(fout);
    CDSViewValues.Next;
   end;
   finally
    CDSViewValues.First;
    CDSViewValues.EnableControls;
   end;
  end; //Values

  (* Plot anomalies *)
  if frmViewData.PageControl1.PageIndex=1 then begin
   try
    CDSViewAnomalies.DisableControls;
      CDSViewAnomalies.First;
       while not CDSViewAnomalies.EOF do begin
        write(fout, inttostr(CDSViewAnomalies.FieldByName('YY').AsInteger));
          for k:=1 to 13 do begin
            write(fout, #9, Floattostr(CDSViewAnomalies.FieldByName(inttostr(k)).AsFloat));
          end;
        writeln(fout);
       CDSViewAnomalies.Next;
    end;
   finally
    CDSViewAnomalies.First;
    CDSViewAnomalies.EnableControls;
   end;
  end; //Values
  CloseFile(fout);

 end;
end;


procedure Tfrmviewdata.FormResize(Sender: TObject);
begin
  Toolbar1.Width:=frmviewdata.Width-120;
  Panel1.Width:=Toolbar1.Width-btnSave.Width;
end;

procedure Tfrmviewdata.DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
begin
 if VarIsNull(column.Field.Value)=true then TDBGrid(sender).Canvas.Brush.Color :=clYellow;

 if (gdSelected in AState) then begin
   TDBGrid(Sender).Canvas.Brush.Color := clNavy;
   TDBGrid(Sender).Canvas.Font.Color  := clYellow;
   TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;

end;

procedure Tfrmviewdata.iEditDataClick(Sender: TObject);
begin
frmeditdata := Tfrmeditdata.Create(Self);
  try
   if not frmeditdata.ShowModal = mrOk then exit;
  finally
    frmeditdata.Free;
    frmeditdata := nil;
  end;
end;


procedure Tfrmviewdata.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 CDSViewValues.Free;
 CDSViewAnomalies.Free;

 DSViewValues.Free;
 DSViewAnomalies.Free;

 Open_viewdata:=false;
end;

end.

