unit sources_merge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  ExtCtrls, BufDataset, DB, Variants, DateUtils;

type
   Arr_MD=record
     src:string;
     src_id: integer;
     tbl: string;
end;

type

  { Tfrmsourcesmerge }

  Tfrmsourcesmerge = class(TForm)
    btnMerge: TButton;
    GroupBox1: TGroupBox;
    lbSource: TListBox;
    rgTimestep: TRadioGroup;
    rgParameter: TRadioGroup;

    procedure FormShow(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure lbSourceDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbSourceDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbSourceMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rgParameterClick(Sender: TObject);
    procedure rgTimestepClick(Sender: TObject);

  private

  public

  end;

var
  frmsourcesmerge: Tfrmsourcesmerge;
  DraggingItemNumber : integer;
  Arr_MD1: array of Arr_MD;

implementation

{$R *.lfm}

{ Tfrmsourcesmerge }

uses main, dm, procedures;


procedure Tfrmsourcesmerge.FormShow(Sender: TObject);
begin
  rgParameter.OnClick(self);
end;

procedure Tfrmsourcesmerge.rgParameterClick(Sender: TObject);
Var
  k:integer;
  src: string;
begin
  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' select ');
     SQL.Add(' "source"."id" as src_id, "source"."name" as src, ');
     SQL.Add(' "table"."name" as tbl ');
     SQL.Add(' from ');
     SQL.Add(' "table", "source", "parameter", "timestep" ');
     SQL.Add(' where ');
     SQL.Add(' "parameter"."name"=:par and ');
     SQL.Add(' "timestep"."name"=:tim and ');
     SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
     SQL.Add(' "table"."source_id"="source"."id" ');
     SQL.Add(' "table"."timestep_id"="timestep"."id" ');
     SQL.Add(' order by "source"."name"');
     ParamByName('par').AsString:=rgParameter.Items.Strings[rgParameter.ItemIndex];
     ParamByName('tim').AsString:=rgTimestep.Items.Strings[rgTimestep.ItemIndex];
     Open;
  end;

  lbSource.Clear;
  SetLength(Arr_MD1, 50);
  k:=-1;
  while not frmdm.q1.Eof do begin
    src:=frmdm.q1.FieldByName('src').AsString;
     if src<>'merged' then begin
       inc(k);
       lbSource.Items.Add(src);

       Arr_MD1[k].src:=src;
       Arr_MD1[k].src_id:=frmdm.q1.FieldByName('src_id').AsInteger;
       Arr_MD1[k].tbl:=frmdm.q1.FieldByName('tbl').AsString;
     end;
   frmdm.q1.Next;
  end;
  SetLength(Arr_MD1, k+1);
  frmdm.q1.Close;
end;

procedure Tfrmsourcesmerge.rgTimestepClick(Sender: TObject);
begin

end;


procedure Tfrmsourcesmerge.btnMergeClick(Sender: TObject);
Var
  id, pp, ss, stat_cnt, cnt, par_cnt, k, cnt_par: integer;
  parameter_id, mn, mn_between, src_id: integer;
  dat0, dat1:TDateTime;
  val1: Variant;
  tbl_to, sName, tbl, src_id_str, TableTo: string;
  CDSCompare:TBufDataSet;
  DSCompare:TDataSource;
begin

  btnMerge.Enabled:=false;

  case rgParameter.ItemIndex of
    0: begin
        TableTo:='p_precipitation';
        parameter_id:=2;
       end;
    1: begin
        TableTo:='p_surface_air_temperature';
        parameter_id:=1;
       end;
  end;

  with frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' delete from "'+TableTo+'" ');
   ExecSQL;
  end;

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "id" from "station" order by "id" ');
   Open;
   Last;
   First;
  end;

  stat_cnt:=frmdm.q1.RecordCount;

  frmdm.q1.First;
  cnt:=0;
  While not frmdm.q1.Eof do begin
   inc(cnt);
    id:=frmdm.q1.FieldByName('id').Value;

    cnt_par:=0;
     with frmdm.q2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' select count("station_id") ');
        SQL.Add(' from "station_info", "table", "parameter" ');
        SQL.Add(' where ');
        SQL.Add(' "station_info"."station_id"=:id and ');
        SQL.Add(' "parameter"."name"=:par and ');
        SQL.Add(' "station_info"."table_id"="table"."id" and ');
        SQL.Add(' "table"."parameter_id"="parameter"."id" and ');
        SQL.Add(' "table"."id"<90 ');
        ParamByName('id').Value:=id;
        ParamByName('par').Value:=rgParameter.Items.Strings[rgParameter.ItemIndex];;
     //   showmessage(sql.text);
       Open;
        cnt_par:=frmdm.q2.Fields[0].Value;
       Close;
      end;

   if cnt_par>1 then begin


    CDSCompare:=TBufDataSet.Create(self);
    CDSCompare.FieldDefs.Add('date', ftdate, 0, false);
     for k:=0 to lbSource.Count-1 do begin
      sName:=lbSource.Items.Strings[k];
      CDSCompare.FieldDefs.Add(sName, ftfloat, 0, false);
     end;
    CDSCompare.CreateDataSet;
    CDSCompare.IndexFieldNames:='date';

 //     DSCompare:=TDataSource.Create(self);
//  DSCompare.DataSet:=CDSCompare;

  //DBGrid1.DataSource:=DSCompare;


    for k:=0 to lbSource.Count-1 do begin
     sName:=lbSource.Items.Strings[k];
      for pp:=0 to high(Arr_MD1) do
        if Arr_MD1[pp].src=sName then
          tbl:=Arr_MD1[pp].tbl;

    //  showmessage(sname+'   '+tbl);

      with frmdm.q2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' select "date", "value" ');
        SQL.Add(' from "'+tbl+'" ');
        SQL.Add(' where ');
        SQL.Add(' "station_id"=:id ');
        SQL.Add(' and "pqf2"=0 ');
        SQL.Add(' order by "date" ');
        ParamByName('id').Value:=id;
       Open;
      end;

      While not frmdm.q2.EOF do begin
        dat1:=frmdm.q2.FieldByName('date').AsDateTime;
        val1:=frmdm.q2.FieldByName('value').Value;

       with CDSCompare do begin
        if VarIsNull(Lookup('date', dat1, 'date')) then Append else begin
         Locate('date',dat1,[]);
         Edit;
       end;
        FieldByName('date').AsDateTime:=dat1;
        FieldByName(sName).AsFloat:=val1;
       Post;
     end;
    frmdm.q2.Next;
   end;
   end;

    CDSCompare.First;
    dat0:=CDSCompare.FieldByName('date').AsDateTime;

      while not CDSCompare.EOF do begin
       dat1:=CDSCompare.FieldByName('date').AsDateTime;

       mn_between:=MonthsBetween(dat1, dat0{, true});
       if mn_between>1 then begin
       //   showmessage(datetostr(dat1)+'   '+datetostr(dat0)+'   '+inttostr(mn_between));

       for mn:=1 to mn_between-1 do begin
        dat1:=IncMonth(dat0, mn);
         with CDSCompare do begin
           Append;
            FieldByName('date').AsDateTime:=dat1;
           Post;
         end;
        end;
       end;
      // showmessage(inttostr());

       dat0:=dat1;
       CDSCompare.Next;
      end;


      CDSCompare.First;
      while not CDSCompare.EOF do begin
       dat1:=CDSCompare.FieldByName('date').AsDateTime;

       for k:=0 to lbSource.Count-1 do begin
         sName:=lbSource.Items.Strings[k];
         Val1:=CDSCompare.FieldByName(sName).Value;
        // showmessage(sname+'   '+vartostr(val1));

         if not VarIsNull(Val1) then begin
          for pp:=0 to high(Arr_MD1) do begin
            if Arr_MD1[pp].src=sName then
             src_id:=Arr_MD1[pp].src_id;
          end;

         //showmessage(inttostr(src_id));


          with frmdm.q4 do begin
             Close;
               SQL.Clear;
               SQL.Add(' insert into "'+TableTo+'" ');
               SQL.Add(' ("station_id", "date", "value", "source_id", "pqf2") ');
               SQL.Add(' values ');
               SQL.Add(' (:absnum, :date_, :value_, :src, :pqf2)');
               ParamByName('absnum').AsInteger:=id;
               ParamByName('date_').AsDate:=dat1;
               ParamByName('value_').AsFloat:=val1;
               ParamByName('src').AsInteger:=src_id;
               ParamByName('pqf2').AsInteger:=0;
             ExecSQL;
           end;
          break;
         end;
      end;
     CDSCompare.Next;
    end;

    ProgressTaskbar(cnt, stat_cnt);
    Application.ProcessMessages;

   CDSCompare.Free;
   frmdm.TR.CommitRetaining;
   end; //more than 1 source


   frmdm.q1.Next;
  end;
   ProgressTaskbar(0, 0);
   btnMerge.Enabled:=true;
   showmessage('Timeseries have been merged');
end;

procedure Tfrmsourcesmerge.lbSourceDragDrop(Sender, Source: TObject; X,
  Y: Integer);
  var ItemUnderMouse:integer;
begin
  ItemUnderMouse := lbSource.ItemAtPos(Point(X,Y), true);
  if (ItemUnderMouse>-1) and (ItemUnderMouse<lbSource.Count) and (DraggingItemNumber>-1) then
    lbSource.Items.Move(DraggingItemNumber,ItemUnderMouse);
end;

procedure Tfrmsourcesmerge.lbSourceDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
  var ItemUnderMouse:integer;
begin
  if Sender=Source then
    begin
      ItemUnderMouse := lbSource.ItemAtPos(Point(X,Y), true);
      Accept:=(ItemUnderMouse>-1) and (ItemUnderMouse<lbSource.Count);
    end
  else
    Accept:=false;
end;

procedure Tfrmsourcesmerge.lbSourceMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    DraggingItemNumber := lbSource.ItemAtPos(Point(X,Y), true);
  if (DraggingItemNumber>-1) and (DraggingItemNumber<lbSource.Count) then
    lbSource.BeginDrag(true)
  else
    begin
      lbSource.BeginDrag(False);
      DraggingItemNumber:=-1;
    end;
end;

end.

