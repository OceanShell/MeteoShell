unit qc_sigma;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, db, sqldb, main, dm, procedures, Dialogs;

procedure SigmaCheck(tbl:string; sigma:integer; towrite:boolean);

implementation

procedure SigmaCheck(tbl:string; sigma:integer; towrite:boolean);
Var
  id, cnt_curr, stat_cnt, mn_i, cnt: integer;
  dat1:TDateTime;
  qcpath: string;
  val1: Variant;
  yy, mn, dd: word;
  mean, sum, dif2, sd, abs_min, abs_max:double;
  outf, outsd: text;

  TRt1, TRt2:TSQLTransaction;
  db1q1, db2q1, db2q2:TSQLQuery;
begin
  qcpath:=GlobalUnloadPath+'qc'+PathDelim;
    if not DirectoryExists(qcpath) then CreateDir(qcpath);

try
  AssignFile(outf,  qcpath+tbl+'_outliers_sigma_'+inttostr(sigma)+'.txt'); rewrite(outf);

  TRt1:=TSQLTransaction.Create(nil);
  TRt1.DataBase:=frmdm.TR.DataBase;
  db1q1:=TSQLQuery.Create(nil);
  db1q1.Database:=frmdm.TR.DataBase;
  db1q1.Transaction:=TRt1;

  TRt2:=TSQLTransaction.Create(nil);
  TRt2.DataBase:=frmdm.TR2.DataBase;
  db2q1:=TSQLQuery.Create(nil);
  db2q1.Database:=frmdm.TR2.DataBase;
  db2q1.Transaction:=TRt2;
  db2q2:=TSQLQuery.Create(nil);
  db2q2.Database:=frmdm.TR2.DataBase;
  db2q2.Transaction:=TRt2;

  with db1q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "id" from "station" ');
    SQL.Add(' order by "id" ');
   Open;
   Last;
   First;
  end;

  stat_cnt:=db1q1.RecordCount;

  cnt_curr:=0;
  db1q1.First;
  while not db1q1.EOF do begin
   id:=db1q1.FieldByName('id').Value;
   inc(cnt_curr);

   with db2q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select * from "'+tbl+'" ');
     SQL.Add(' where "station_id"=:id ');
     SQL.Add(' and "pqf1"=0 ');
     ParamByName('id').Value:=id;
    Open;
   end;

   if not db2q1.IsEmpty then begin
  // showmessage(inttostr(id));
    for mn_i:=1 to 12 do begin

     sum:=0; cnt:=0;
     db2q1.First;
     while not db2q1.EOF do begin
       dat1:=db2q1.FieldByName('date').Value;
       val1:=db2q1.FieldByName('value').Value;

       DecodeDate(dat1, yy, mn, dd);

       if (mn=mn_i) and (val1<>null) then begin
        sum:=sum+val1;
        inc(cnt);
       end;

       db2q1.Next;
     end;

     if cnt>0 then begin
     mean:=sum/cnt;

     dif2:=0;
     db2q1.First;
     while not db2q1.EOF do begin
       dat1:=db2q1.FieldByName('date').Value;
       val1:=db2q1.FieldByName('value').Value;

       DecodeDate(dat1, yy, mn, dd);

       if (mn=mn_i) and (val1<>null) then begin
         Dif2:=Dif2+sqr(Val1-mean);
       end;

       db2q1.Next;
     end;

     sd:=sqrt(Dif2/cnt);
     abs_min:=mean-(sd*sigma);
     abs_max:=mean+(sd*sigma);


     db2q1.First;
     while not db2q1.EOF do begin
       dat1:=db2q1.FieldByName('date').Value;
       val1:=db2q1.FieldByName('value').Value;

       DecodeDate(dat1, yy, mn, dd);

       if (mn=mn_i) and (abs_min<>abs_max) and
          ((val1<abs_min) or (val1>abs_max)) then begin
          if towrite=true then begin
           with db2q2 do begin
            Close;
             SQL.Clear;
             SQL.Add(' update "'+tbl+'" ');
             SQL.Add(' set "pqf2"=1 ');
             SQL.Add(' where ');
             SQL.Add(' "station_id"=:id and ');
             SQL.Add(' "date"=:dat1 and ');
             SQL.Add(' "value"=:val1');
             ParamByName('id').Value:=id;
             ParamByName('dat1').Value:=dat1;
             ParamByName('val1').Value:=val1;
            ExecSQL;
           end;
          end;
         writeln(outf, tbl+'   '+
                       inttostr(id)+'   '+
                       datetostr(dat1)+'   '+
                       floattostr(abs_min)+'   '+
                       floattostr(abs_max)+'   '+
                       floattostr(val1));
       end;

       db2q1.Next;
     end;
    end; //cnt>0
   end; // 12 month
  end; // not empty

   ProgressTaskbar(cnt_curr, stat_cnt);
   Application.ProcessMessages;
 //  exit;
   db1q1.Next;
 end;
 if towrite=true then TRt2.CommitRetaining;

finally
Closefile(outf);
db1q1.Close;
db1q1.Free;
Trt1.Commit;
Trt1.Free;

db2q1.Close;
db2q1.Free;
db2q2.Close;
db2q2.Free;
Trt2.Commit;
Trt2.Free;

ProgressTaskbar(0, 0);
end


end;

end.

