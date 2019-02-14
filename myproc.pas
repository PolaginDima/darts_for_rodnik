unit myProc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, forms, Grids, iniFiles;
const
  FilePeople = 'People.dat';
  FileSetup = 'SetupS.dat';
  FileUchastnik = 'Uchastnik';
  FileResult = 'Result.lrf';
  countFire = 30;
  WidthColScore = 28;
  WidthSumScore = 55;
  widthRating = 55;
  WidthFIO = 150;
  flagwomen = '9women9';
var
  //_M - значит мужчины
  lstPpl_M:TStringList;
  lstUch_M:TStringList;
  lstRes_M:TStringList;
  lstPpl_W:TStringList;
  lstUch_W:TStringList;
  lstRes_W:TStringList;
  fintervalSaving:integer;
  procedure InitMyVar(Grid_M,Grid_W: TStringGrid);
  procedure FinalizeMyVar;
  procedure AddUchastnikToGrid(FIO:string; Grid: TStringGrid);
  procedure LoadConfig;
  procedure SaveConfig;
  function GetDataPath: string;

implementation
function LoadU:Boolean;
var
  spisokplp:TStringList;
  i,j:integer;
begin
  result:=false;
  //Проверим наличие файла со списком людей
  if not fileexists(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FilePeople) then exit;
  spisokplp:=TStringList.Create;
  spisokplp.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FilePeople);
  //Загружаем мужиков
  for i:=1 to spisokplp.Count-1 do
  begin
    if spisokplp.Strings[i]=flagwomen then break;
    lstPpl_M.Add(spisokplp.Strings[i]);
  end;
  //Загружаем женщин
  for j:=i+1 to spisokplp.Count-1 do
  begin
    lstPpl_W.Add(spisokplp.Strings[j]);
  end;
  spisokplp.Free;
  result:=true;
end;

function LoadS(Grid_M, Grid_W: TStringGrid):boolean;
var
  setupSorevn:TStringList;
begin
  result:=false;
  //Проверим файлов настройки сетки
  if (not fileexists(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup))or
  //Проверим наличие файлов соревнования мужчин
  (not fileexists(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+Grid_M.Name+'.dat')) or
  //Проверим наличие файлов соревнования женщин
   (not fileexists(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+Grid_W.Name+'.dat')) then exit;
  setupSorevn:=TStringList.Create;
  setupSorevn.Delimiter:='=';
  //мужчины
  //Загрузим количество столбцов и строк в сетке
  setupSorevn.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup);
  //Установим кол-во строк в сетке
  Grid_M.RowCount:=strtoint(setupSorevn.ValueFromIndex[setupSorevn.IndexOfName(Grid_M.Name+'rowCount')]);
  Grid_M.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+Grid_M.Name+'.dat');
  //женщины
  setupSorevn.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup);
  //Установим кол-во строк в сетке
  Grid_W.RowCount:=strtoint(setupSorevn.ValueFromIndex[setupSorevn.IndexOfName(Grid_W.Name+'rowCount')]);
  Grid_W.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+Grid_W.Name+'.dat');
  freeAndNil(setupSorevn);
end;

procedure setupGrid(Grid:TStringGrid; lst:TStringList);
var
  i:integer;
begin
  //зададим параметры сетки
    //Кол-во строк по количеству записей
    Grid.RowCount:=lst.Count+1;
    //Количество столбцов=кол-во бросков(3*10) + 1(№)+1(ФИО)+1(сумма очков)+1(место)
    for i:=1 to countFire+2 do  Grid.Columns.Add;
    for i:=1 to countFire+2 do  Grid.Columns.Items[i-1].ReadOnly:=false;
    //Grid.ColCount:=countFire+4;
    //Зададим ширину столбцов
    Grid.ColWidths[0]:=WidthColScore;//Нумерация участников
    //Grid.Columns.Items[0].ReadOnly:=true;
    Grid.ColWidths[1]:=WidthFIO;//ФИО участников
    Grid.Cells[1,0]:='ФИО';;
    {Grid.Columns.Items[0].ReadOnly:=true;
    Grid.Columns.Items[0].Title.Caption:='ФИО';}
    Grid.ColWidths[Grid.Columns.Count]:=WidthSumScore;//место
    Grid.Columns.Items[Grid.Columns.Count-1].ReadOnly:=true;
    Grid.ColWidths[Grid.Columns.Count-1]:=widthRating;//очки
    Grid.Columns.Items[Grid.Columns.Count-2].ReadOnly:=true;
    for i:=0 to Grid.Columns.Count-3 do
    begin
      Grid.ColWidths[i+2]:=WidthColScore;
      Grid.Columns.Items[i].Title.Caption:=''+inttostr(i+1);
    end;
    Grid.Columns.Items[Grid.Columns.Count-2].Title.Caption:='очки';
    Grid.Columns.Items[Grid.Columns.Count-1].Title.Caption:='место';
end;

procedure InitMyVar(Grid_M, Grid_W: TStringGrid);
begin
  lstPpl_M:=TStringList.Create;
  lstUch_M:=TStringList.Create;
  lstRes_M:=TStringList.Create;
  lstPpl_W:=TStringList.Create;
  lstUch_W:=TStringList.Create;
  lstRes_W:=TStringList.Create;
  LoadConfig;
  setupGrid(Grid_M, lstUch_M);
  setupGrid(Grid_W, lstUch_W);
  //Загрузим список участников
  LoadU;
  //Загрузим если есть соревнование
  LoadS(Grid_M, Grid_W);
end;

procedure FinalizeMyVar;
begin
  SaveConfig;
  FreeAndNil(lstPpl_M);
  FreeAndNil(lstUch_M);
  FreeAndNil(lstRes_M);
end;

procedure AddUchastnikToGrid(FIO: string; Grid: TStringGrid);
var
  i:integer;
begin
  Grid.RowCount:=Grid.Rowcount+1;
  Grid.Cells[0,Grid.Rowcount-1]:=inttostr(Grid.RowCount-1);
  Grid.Cells[1,Grid.Rowcount-1]:=FIO;
  for i:=1 to countFire+2 do Grid.Cells[i+1,Grid.Rowcount-1]:='0';
end;

procedure LoadConfig;
var
  ini: TIniFile;
  s: string;
  tmpi:integer;
begin
  ini := TIniFile.Create(GetDataPath+'config.ini');
  s := ini.ReadString('General', 'intervalSaving', '');
  if s<>'' then
    begin
    if trystrtoint(s,tmpi) then
      fintervalSaving := tmpi
      else
        fintervalSaving:=120000;
    end
  else
    fintervalSaving := 120000;
  ini.Free;
end;

procedure SaveConfig;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(GetDataPath+'config.ini');
  ini.WriteString('General', 'intervalSaving', inttostr(fintervalSaving));
  ini.free;
end;

function GetDataPath: string;
begin
  result := ExtractFilePath(ParamStr(0));
  {$ifdef Darwin}
  result := IncludeTrailingPathDelimiter(ExpandFileName(result + '../../..'));
  {$endif}
end;

end.

