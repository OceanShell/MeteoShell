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
begin
  qcpath:=GlobalUnloadPath+'qc'+PathDelim;
    if not DirectoryExists(qcpath) then CreateDir(qcpath);

  AssignFile(outf,  qcpath+tbl+'_outliers_sigma_'+inttostr(sigma)+'.txt'); rewrite(outf);
 // AssignFile(outsd, qcpath+tbl+'_sd.txt'); rewrite(outsd);


  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' select "id" from "station" ');
    SQL.Add(' order by "id" ');
   Open;
   Last;
   First;
  end;

  stat_cnt:=frmdm.q1.RecordCount;

  cnt_curr:=0;
  frmdm.q1.First;
  while not frmdm.q1.EOF do begin
   id:=frmdm.q1.FieldByName('id').Value;
   inc(cnt_curr);

   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select * from "'+tbl+'" ');
     SQL.Add(' where "station_id"=:id ');
     SQL.Add(' and "pqf1"=0 ');
     ParamByName('id').Value:=id;
    Open;
   end;

   if not frmdm.q2.IsEmpty then begin
  // showmessage(inttostr(id));
    for mn_i:=1 to 12 do begin

     sum:=0; cnt:=0;
     frmdm.q2.First;
     while not frmdm.q2.EOF do begin
       dat1:=frmdm.q2.FieldByName('date').Value;
       val1:=frmdm.q2.FieldByName('value').Value;

       DecodeDate(dat1, yy, mn, dd);

       if (mn=mn_i) and (val1<>null) then begin
        sum:=sum+val1;
        inc(cnt);
       end;

       frmdm.q2.Next;
     end;

     if cnt>0 then begin
     mean:=sum/cnt;

     dif2:=0;
     frmdm.q2.First;
     while not frmdm.q2.EOF do begin
       dat1:=frmdm.q2.FieldByName('date').Value;
       val1:=frmdm.q2.FieldByName('value').Value;

       DecodeDate(dat1, yy, mn, dd);

       if (mn=mn_i) and (val1<>null) then begin
         Dif2:=Dif2+sqr(Val1-mean);
       end;

       frmdm.q2.Next;
     end;

     sd:=sqrt(Dif2/cnt);
     abs_min:=mean-(sd*sigma);
     abs_max:=mean+(sd*sigma);


     frmdm.q2.First;
     while not frmdm.q2.EOF do begin
       dat1:=frmdm.q2.FieldByName('date').Value;
       val1:=frmdm.q2.FieldByName('value').Value;

       DecodeDate(dat1, yy, mn, dd);

       if (mn=mn_i) and (abs_min<>abs_max) and
          ((val1<abs_min) or (val1>abs_max)) then begin
          if towrite=true then begin
           with frmdm.q3 do begin
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

       frmdm.q2.Next;
     end;
    end; //cnt>0
   end; // 12 month
  end; // not empty

   ProgressTaskbar(cnt_curr, stat_cnt);
   Application.ProcessMessages;
 //  exit;
   frmdm.q1.Next;
 end;
 if towrite=true then frmdm.TR.CommitRetaining;

 //CloseFile(outsd);
 Closefile(outf);
 ProgressTaskbar(0, 0);
end;

end.

