unit myprocbd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, myProc, forms, Grids;

  procedure SavePeople;
  function AddUchastnik(FIO:string;Grid:TStringGrid;plp:TStringList;man:boolean=true):integer;//если -1, то добавлен новый участник, если больше, то индекс в переданном списке
  procedure SaveGrid(Grid:TStringGrid);
implementation



function AddUchastnik(FIO: string; Grid: TStringGrid; plp: TStringList;
  man: boolean): integer;
var
  i:integer;
begin
  result:=-1;
  //Добавляем нового участника в люди, если его нет
  if plp.IndexOf(FIO)=-1 then plp.Add(FIO);
  for i:=1 to Grid.RowCount-1 do
    if Grid.Cells[1,i] = FIO then
    begin
      result:=i;
      break;
    end;
  SavePeople;
end;

procedure SaveGrid(Grid: TStringGrid);
var
  setupSorevn:TStringList;
begin
  setupSorevn:=TStringList.Create;
  setupSorevn.Delimiter:='=';
  //Сохраним количество строк в сетке
  if fileexists( extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup) then
     setupSorevn.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup);
  if setupSorevn.IndexOfName(Grid.Name+'rowCount')>-1 then
     setupSorevn.ValueFromIndex[setupSorevn.IndexOfName(Grid.Name+'rowCount')]:=inttostr(Grid.RowCount)
     else
       setupSorevn.Add(Grid.Name+'rowCount='+inttostr(Grid.RowCount));
  setupSorevn.SaveToFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup);
  Grid.SaveToFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+Grid.Name+'.dat');
  freeAndNil(setupSorevn);
end;

procedure SavePeople;
var
  spisokplp:TStringList;
begin
  //Сохраним список людей
  spisokplp:=TStringList.Create;
  //Мужчины
  spisokplp.Add('9men9');
  spisokplp.AddStrings(lstPpl_M);
  //женщины
  spisokplp.Add('9women9');
  spisokplp.AddStrings(lstPpl_W);
  spisokplp.SaveToFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FilePeople);
  spisokplp.Free;
end;

end.

