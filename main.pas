unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Class, LR_DSet, Forms, Controls, Graphics,
  Dialogs, Grids, ComCtrls, ActnList, StdCtrls, Types, LCLType, ExtCtrls,
  Lr_e_htm, lr_e_cairo{, LazUtf8};

type

  { Tmainfrm }

  Tmainfrm = class(TForm)
    Aadding: TAction;
    AUploadpdf: TAction;
    AUploadhtml: TAction;
    ASaving: TAction;
    ANewSorevn: TAction;
    AUnSort: TAction;
    ASorting: TAction;
    APrinting: TAction;
    ActionList1: TActionList;
    ADeleting: TAction;
    AEditing: TAction;
    AExit: TAction;
    AFind: TAction;
    AFindNext: TAction;
    aMoving: TAction;
    AUpdating: TAction;
    AUpload: TAction;
    frReport1: TfrReport;
    frUserDataset1: TfrUserDataset;
    ImageList1: TImageList;
    lrCairoExport1: TlrCairoExport;
    PageControl1: TPageControl;
    SGridUM: TStringGrid;
    SGridUW: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton2: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure AaddingExecute(Sender: TObject);
    procedure ADeletingExecute(Sender: TObject);
    procedure AEditingExecute(Sender: TObject);
    procedure AFindExecute(Sender: TObject);
    procedure ANewSorevnExecute(Sender: TObject);
    procedure APrintingExecute(Sender: TObject);
    procedure ASavingExecute(Sender: TObject);
    procedure ASortingExecute(Sender: TObject);
    procedure AUnSortExecute(Sender: TObject);
    procedure AUploadExecute(Sender: TObject);
    procedure AUploadhtmlExecute(Sender: TObject);
    procedure AUploadpdfExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure frReport1GetValue(const ParName: String; var ParValue: Variant);
    procedure frUserDataset1CheckEOF(Sender: TObject; var Eof: Boolean);
    procedure frUserDataset1First(Sender: TObject);
    procedure frUserDataset1Next(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure SGridUMDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure SGridUMKeyPress(Sender: TObject; var Key: char);
    procedure SGridUMValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
    procedure Timer1Timer(Sender: TObject);
    procedure ToolButton15Click(Sender: TObject);
    procedure ToolButton19Click(Sender: TObject);
  private
    FNumeric:integer;
    PrintGrid:TStringGrid;
    procedure CompareCells(Sender: TObject; ACol, ARow, BCol,BRow: Integer;
               var Result: integer);
    procedure CompareCells2(Sender: TObject; ACol, ARow, BCol,BRow: Integer;
               var Result: integer);
  public

  end;

var
  mainfrm: Tmainfrm;

implementation
uses myProc, editUchastnik, myprocbd, msgSavefrm;

{$R *.lfm}

{ Tmainfrm }

procedure Tmainfrm.FormCreate(Sender: TObject);
begin
  //Проинициализируем переменные запустим необходимые процедуры
  PrintGrid:=TStringGrid.Create(self);
  InitMyVar(SGridUM, SGridUW);
  if fintervalSaving>0 then
     Timer1.Interval:=fintervalSaving;
  if fintervalSaving>0 then
     Timer1.Enabled:=true;
end;

procedure Tmainfrm.AaddingExecute(Sender: TObject);
          procedure AddRow(Grid:TStringGrid;lst:TStringList);
          var
            i{, index}:integer;
          begin
            //Добавление участника
            editUchastnikF:=TeditUchastnikF.Create(self, lst);
            editUchastnikF.Caption:='добавление человека';
            editUchastnikF.LabelFiltr:='';
            if editUchastnikF.ShowModal=mrOk then
            begin
                 //Добавим участника в список людей и в список участников соревнований
                 //или встанем на уже имеющегося участника
              if myprocbd.AddUchastnik(editUchastnikF.text,Grid, lst, true)>-1 then
              begin
              for i:=1 to Grid.RowCount-1 do
                  if (Grid.Cells[1,i]=editUchastnikF.text) then
                  begin
                       Grid.Row:=i;
                       Grid.Col:=2;
                       break;
                  end;
              end else
              begin
                            //Добавим участника в сетку;
                            AddUchastnikToGrid(editUchastnikF.text, Grid);
                            //Встанем на последнюю запись
                            Grid.Row:=Grid.RowCount-1;
                            //Сохраним сетки
                           // ASavingExecute(ASaving);
              end;
            end;
            freeandnil(editUchastnikF);
          end;
begin
  if pagecontrol1.TabIndex=0 then
  //Мужчины
  AddRow(SGridUM, lstPpl_M) else
  //Женщины
    AddRow(SGridUW, lstPpl_W);
  //SaveGrid;
end;

procedure Tmainfrm.ADeletingExecute(Sender: TObject);

          procedure DeleteRow(Grid:TStringGrid);
          begin
            //Если сетка пустая, то и удалять не чего
            if Grid.RowCount<=1 then exit;
            //Удалим текущую запись
            case QuestionDlg('Удаление','Удалить запись?',mtConfirmation,[mrYes,'Удалить',mrNo,'Не удалять','isdefault'],'') of
            mryes:;
            mrno:exit;
            end;
            Grid.DeleteRow(Grid.Row);
          end;
begin
  if pagecontrol1.TabIndex=0 then
  //Мужчины
  DeleteRow(SGridUM) else
  //Женщины
    DeleteRow(SGridUW);
end;

procedure Tmainfrm.AEditingExecute(Sender: TObject);
  procedure EditRow(Grid:TStringGrid; plp:TstringList);
  var
     index, curIndex:integer;
  begin
       //Редактирование участника
    curIndex:=Grid.Row;
    editUchastnikF:=TeditUchastnikF.Create(self, plp, Grid.Cells[1,Grid.Row],true);
    editUchastnikF.Caption:='редактирование человека';
    editUchastnikF.LabelFiltr:='';
    if editUchastnikF.ShowModal=mrOk then
    begin
      //ИЗменим участника в список людей и в список участников соревнований
      //или встанем на уже имеющегося участника
      index:=myprocbd.AddUchastnik(editUchastnikF.text,Grid, plp, true);
      if index>-1 then
      begin
           Grid.Row:=index;
      end else
      begin
           //Изменим участника в сетке;
           Grid.Cells[1,curIndex]:=editUchastnikF.text;
      end;
    end;
    freeandnil(editUchastnikF);
  end;
Begin
  if pagecontrol1.TabIndex=0 then
  begin//Мужчины
    if SGridUM.RowCount<=1 then exit;
    EditRow(SGridUM, lstPpl_M);
  end else
  begin//Женщины
       if SGridUW.RowCount<=1 then exit;
       EditRow(SGridUW, lstPpl_W);
  end;
end;

procedure Tmainfrm.AFindExecute(Sender: TObject);
begin
  if ((pagecontrol1.TabIndex=0)and(SGridUM.RowCount<=1))or((pagecontrol1.TabIndex=1)and(SGridUW.RowCount<=1)) then exit;
end;

procedure Tmainfrm.ANewSorevnExecute(Sender: TObject);
begin
  case QuestionDlg('Предупреждение','Все текущие данные будут уничтожены.'+lineending+
  'Вы уверены?',mtConfirmation,[mrYes,'Продолжить',mrNo,'Отказаться','isdefault'],'') of
            mryes:;
            mrno:exit;
            end;
  SGridUM.Clean;
  SGridUW.Clean;
  FinalizeMyVar;
  deletefile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup+'.bak');
  deletefile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+SGridUM.Name+'.dat.bak');
  deletefile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+SGridUW.Name+'.dat.bak');
  renamefile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+SGridUM.Name+'.dat',
  extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+SGridUM.Name+'.dat.bak');
  renamefile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+SGridUW.Name+'.dat',
  extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileUchastnik+SGridUW.Name+'.dat.bak');
  renamefile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup,
  extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileSetup+'.bak');
  InitMyVar(SGridUM, SGridUW);
end;

procedure Tmainfrm.APrintingExecute(Sender: TObject);
  procedure  Printing(Grid:TStringGrid);
  var
     i:integer;
  begin
    //Рассчитаем рейтинг
    //SortGrid:=TStringGrid.Create(self);
    PrintGrid.Assign(Grid);
    for i:=1 to PrintGrid.RowCount-1 do PrintGrid.Cells[0,i]:=inttostr(i);
    PrintGrid.OnCompareCells:=@self.CompareCells;
    PrintGrid.SortOrder:=soAscending;
    PrintGrid.SortColRow(true,Grid.ColCount-1);
    {for i:=0 to SortGrid.RowCount-1 do
        for j:=0 to Grid.RowCount-1 do
            if SortGrid.Cells[1,i]=Grid.Cells[1,j] then Grid.Cells[Grid.ColCount-1,j]:=inttostr(i);}
    //конец рассчета рейтинга
    //PrintFrm:=TprintFrm.Create(self, SortGrid);
    //PrintFrm.ShowModal;
    //printFrm.Free;
    frReport1.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileResult);
    frReport1.ShowReport;
    //FreeAndNil(SortGrid);
  end;
begin
if pagecontrol1.TabIndex=0 then
begin//Мужчины
  if SGridUM.RowCount<=1 then exit;
  Printing(SGridUM)
end else
begin//Женщины
     if SGridUW.RowCount<=1 then exit;
     Printing(SGridUW);
end;
end;

procedure Tmainfrm.ASavingExecute(Sender: TObject);
begin
  msgfrm:=Tmsgfrm.Create(self,'ожидайте, данные сохраняются...');
  msgfrm.Show;
  application.ProcessMessages;
  SaveGrid(SGridUM);
  SaveGrid(SGridUW);
  msgfrm.Free;
end;

procedure Tmainfrm.ASortingExecute(Sender: TObject);
begin
     //Отсортируем сетку по местам
     if pagecontrol1.TabIndex=0 then
     begin
          if SGridUM.RowCount<=1 then exit;
          SGridUM.OnCompareCells:=@self.CompareCells;
          SGridUM.SortOrder:=soDescending;
          SGridUM.SortColRow(true,SGridUM.ColCount-2);
     end else
     begin
          if SGridUW.RowCount<=1 then exit;
          SGridUW.OnCompareCells:=@self.CompareCells;
          SGridUW.SortOrder:=soDescending;
          SGridUW.SortColRow(true,SGridUW.ColCount-2);
     end;
end;

procedure Tmainfrm.AUnSortExecute(Sender: TObject);
begin
  //Отсортируем сетку по порядку регистрации
     if pagecontrol1.TabIndex=0 then
     begin
          if SGridUM.RowCount<=1 then exit;
          SGridUM.OnCompareCells:=@self.CompareCells2;
          SGridUM.SortOrder:=soAscending;
          SGridUM.SortColRow(true,0);
     end else
     begin
          if SGridUW.RowCount<=1 then exit;
          SGridUW.OnCompareCells:=@self.CompareCells2;
          SGridUW.SortOrder:=soAscending;
          SGridUW.SortColRow(true,0);
     end;
end;

procedure Tmainfrm.AUploadExecute(Sender: TObject);
var
   sd:TSaveDialog;
begin
  sd:=TSaveDialog.Create(self);
  sd.Title:='Сохранение';
  //Установка начального каталога
  //sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем сохранять файлы типа .csv
  sd.Filter:='csv|*.csv';//'изображение(jpg)|*.jpg|изображение(bmp)|*.bmp';
  // Установка расширения по умолчанию
  sd.DefaultExt := 'csv';
  sd.FileName:='Result.csv';
  // Выбор текстовых файлов как стартовый тип фильтра
  sd.FilterIndex := 1;
  if not  sd.Execute then exit;
  if pagecontrol1.TabIndex=0 then
     SGridUM.SaveToCSVFile(ExtractFileDir(sd.FileName)+directoryseparator+'M_'+ExtractFileName(sd.FileName),';')
     else
         SGridUW.SaveToCSVFile(ExtractFileDir(sd.FileName)+directoryseparator+'W_'+ExtractFileName(sd.FileName),';');
  FreeAndNil(sd);
end;

procedure Tmainfrm.AUploadhtmlExecute(Sender: TObject);
var
   Grid:TStringGrid;
   i:integer;
   sd:TSaveDialog;
begin
  sd:=TSaveDialog.Create(self);
  sd.Title:='Сохранение';
  //Установка начального каталога
  //sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем сохранять файлы типа .csv
  sd.Filter:='html|*.html';//'изображение(jpg)|*.jpg|изображение(bmp)|*.bmp';
  // Установка расширения по умолчанию
  sd.DefaultExt := 'html';
  sd.FileName:='Result.html';
  // Выбор текстовых файлов как стартовый тип фильтра
  sd.FilterIndex := 1;
  if not  sd.Execute then exit;


  if PageControl1.TabIndex=0 then
     Grid:=SGridUM
     else
       Grid:=SGridUW;
  PrintGrid.Assign(Grid);
  for i:=1 to PrintGrid.RowCount-1 do PrintGrid.Cells[0,i]:=inttostr(i);
  PrintGrid.OnCompareCells:=@self.CompareCells;
  PrintGrid.SortOrder:=soAscending;
  PrintGrid.SortColRow(true,Grid.ColCount-1);
  frReport1.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileResult);
  //frReport1.PrepareReport;
  //frreport1.ShowPreparedReport;
  if frReport1.PrepareReport then begin
    frReport1.ExportTo(TfrHTMExportFilter, sd.FileName);
  end;
end;

procedure Tmainfrm.AUploadpdfExecute(Sender: TObject);
var
   Grid:TStringGrid;
   i:integer;
   sd:TSaveDialog;
begin
  sd:=TSaveDialog.Create(self);
  sd.Title:='Сохранение';
  //Установка начального каталога
  //sd.InitialDir:=getcurrentdir;
  //GetEnvironmentVariable;
  // Разрешаем сохранять файлы типа .csv
  sd.Filter:='pdf|*.pdf';//'изображение(jpg)|*.jpg|изображение(bmp)|*.bmp';
  // Установка расширения по умолчанию
  sd.DefaultExt := 'pdf';
  sd.FileName:='Result.pdf';
  // Выбор текстовых файлов как стартовый тип фильтра
  sd.FilterIndex := 1;
  if not  sd.Execute then exit;


  if PageControl1.TabIndex=0 then
     Grid:=SGridUM
     else
       Grid:=SGridUW;
  PrintGrid.Assign(Grid);
  for i:=1 to PrintGrid.RowCount-1 do PrintGrid.Cells[0,i]:=inttostr(i);
  PrintGrid.OnCompareCells:=@self.CompareCells;
  PrintGrid.SortOrder:=soAscending;
  PrintGrid.SortColRow(true,Grid.ColCount-1);
  frReport1.LoadFromFile(extractfilepath(ExcludeTrailingPathDelimiter(application.ExeName))+FileResult);
  //frReport1.PrepareReport;
  //frreport1.ShowPreparedReport;
  if frReport1.PrepareReport then begin
    frReport1.ExportTo(TlrCairoPDFExportFilter, sd.FileName);
  end;
end;

procedure Tmainfrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  msgfrm:=Tmsgfrm.Create(self,'ожидайте, данные сохраняются...');
  msgfrm.Show;
  //сохраним соревнование
   ASavingExecute(ASaving);
  {SaveGrid(SGridUM);
  SaveGrid(SGridUW);}
  //SaveGrid;
  //msgfrm.Free;
end;

procedure Tmainfrm.FormDestroy(Sender: TObject);
begin
  //Освободим ресурсы
  FinalizeMyVar;
  FreeAndNil(PrintGrid);
end;

procedure Tmainfrm.FormShow(Sender: TObject);
begin
  SGridUM.SetFocus;
end;

procedure Tmainfrm.frReport1GetValue(const ParName: String;
  var ParValue: Variant);
begin
  case ParName of
  'FIO':
    begin
         ParValue:=PrintGrid.Cells[1,FNumeric];
    end;
  'Score':
    begin
         ParValue:=PrintGrid.Cells[PrintGrid.ColCount-2,FNumeric];
    end;
  'Rating':
    begin
         ParValue:=PrintGrid.Cells[PrintGrid.ColCount-1,FNumeric];
    end;
  'Number':
    begin
         ParValue:=PrintGrid.Cells[0,FNumeric];
    end;
  end;
end;

procedure Tmainfrm.frUserDataset1CheckEOF(Sender: TObject; var Eof: Boolean);
begin
  eof:=Fnumeric>PrintGrid.RowCount-1;
end;

procedure Tmainfrm.frUserDataset1First(Sender: TObject);
begin
  FNumeric:=1;
end;

procedure Tmainfrm.frUserDataset1Next(Sender: TObject);
begin
  inc(FNumeric);
end;

procedure Tmainfrm.PageControl1Change(Sender: TObject);
begin
  if pagecontrol1.TabIndex=0 then
     begin
          TabSheet1.ImageIndex:=20;
          TabSheet2.ImageIndex:=-1;
          SGridUM.SetFocus
     end else
         begin
              TabSheet1.ImageIndex:=-1;
          TabSheet2.ImageIndex:=20;
              SGridUW.SetFocus;
         end;
end;

procedure Tmainfrm.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin

end;

procedure Tmainfrm.SGridUMDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if aCol=SGridUM.ColCount-1 then
  begin
       if TStringGrid(Sender).Cells[aCol,Arow]='1' then
       begin
            TStringGrid(Sender).Canvas.Pen.Width:=6;
            TStringGrid(Sender).Canvas.Pen.Color:=clLime;
            TStringGrid(Sender).Canvas.Brush.Style:=bsClear;
            //TStringGrid(Sender).Canvas.Brush.Color:=cllime;
            TStringGrid(Sender).Canvas.Rectangle(aRect);
       end;
       if (TStringGrid(Sender).Cells[aCol,Arow]='2'){or
       (TStringGrid(Sender).Cells[aCol,Arow]='3')}then
       begin
            TStringGrid(Sender).Canvas.Pen.Width:=4;
            TStringGrid(Sender).Canvas.Pen.Color:=clYellow;//clGreen;
            TStringGrid(Sender).Canvas.Brush.Style:=bsClear;
            //SGridUM.Canvas.Brush.Color:=cllime;
            TStringGrid(Sender).Canvas.Rectangle(aRect);
       end;
       if {(TStringGrid(Sender).Cells[aCol,Arow]='2')or}
       (TStringGrid(Sender).Cells[aCol,Arow]='3')then
       begin
            TStringGrid(Sender).Canvas.Pen.Width:=4;
            TStringGrid(Sender).Canvas.Pen.Color:=clYellow;
            TStringGrid(Sender).Canvas.Brush.Style:=bsClear;
            //SGridUM.Canvas.Brush.Color:=cllime;
            TStringGrid(Sender).Canvas.Rectangle(aRect);
       end;
  end;
  if (acol>1)and(acol<(countFire+3)){and(aRow>0)} then
  begin
       if (((acol-2) mod 3)=0) then
       begin
            TStringGrid(Sender).Canvas.Pen.Width:=4;
            TStringGrid(Sender).Canvas.Pen.Color:=clBlack;
            //TStringGrid(Sender).Canvas.Brush.Style:=bsClear;
            //SGridUM.Canvas.Brush.Color:=cllime;
            TStringGrid(Sender).Canvas.Line(aRect.Left,aRect.Top,aRect.Left,aRect.Bottom);
       end;
       {if (((acol-4) mod 3)=0) then
       begin

       end; }
  end;
  {if (gdFocused in aState ) then
  begin
    SGridUM.Canvas.Pen.Width:=3;
    SGridUM.Canvas.Pen.Color:=clWhite;
    SGridUM.Canvas.Brush.Style:=bsClear;
    SGridUM.Canvas.Rectangle(aRect);
  end; }
  {gdSelected:;
  gdFocused:;
  gdFixed:;
  gdHot:;
  gdPushed:;
  gdRowHighlight:;
  end;}
end;

procedure Tmainfrm.SGridUMKeyPress(Sender: TObject; var Key: char);
const shablon='0123456789';
begin
if(Key=#8)or(Key=#13)or(Key=#27)or(pos(Key,shablon)>0) then exit;
  Key:=#0;
end;

procedure Tmainfrm.SGridUMValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
var
   Score:integer;
   procedure EditingDone(Grid:TStringGrid);
          var
             i, j, sumScore:integer;
             SortGrid:TStringGrid;
          begin
            //Подсчитаем очки
            sumScore:=0;
            for i:=0 to Grid.Columns.Count-3 do
                if (i+2)=aCol then
                   sumScore:=sumScore+strtoint(NewValue)
                   else
                    sumScore:=sumScore+strtoint(Grid.Cells[i+2,Grid.Row]);
            Grid.Cells[Grid.Columns.Count,Grid.Row]:=inttostr(sumScore);
            //Рассчитаем рейтинг
            SortGrid:=TStringGrid.Create(self);
            SortGrid.Assign(Grid);
            SortGrid.OnCompareCells:=@self.CompareCells;
            SortGrid.SortOrder:=soDescending;
            SortGrid.SortColRow(true,Grid.ColCount-2);
            for i:=1 to SortGrid.RowCount-1 do SortGrid.Cells[0,i]:=inttostr(i);
            for i:=0 to SortGrid.RowCount-1 do
                for j:=0 to Grid.RowCount-1 do
                    if SortGrid.Cells[1,i]=Grid.Cells[1,j] then Grid.Cells[Grid.ColCount-1,j]:=inttostr(i);
            FreeAndNil(SortGrid);
            //Сохраним сетку
            //SaveGrid(Grid);
            {SaveGrid(SGridUM);
            SaveGrid(SGridUW);}
          end;
begin
  if not TryStrToInt(NewValue, Score) then
  begin
          if Length(NewValue)<=0 then
             NewValue:='0'
             else
                 if not TryStrToInt(oldValue, Score) then
                    NewValue:='0'
                    else
                      NewValue:=OldValue;
  end else
  if strtoint(NewValue)>60 then
     NewValue:='60';
  if NewValue<>OldValue then
     if pagecontrol1.TabIndex=0 then
     //Мужчины
     EditingDone(SGridUM) else
       //Женщины
       EditingDone(SGridUW);
  //savegrid;
end;

procedure Tmainfrm.Timer1Timer(Sender: TObject);
begin
  msgfrm:=Tmsgfrm.Create(self,'ожидайте, данные сохраняются...');
  msgfrm.Show;
  ASavingExecute(ASaving);
  msgfrm.Free;
end;

procedure Tmainfrm.ToolButton15Click(Sender: TObject);
begin

end;

procedure Tmainfrm.ToolButton19Click(Sender: TObject);
begin

end;

procedure Tmainfrm.CompareCells(Sender: TObject; ACol, ARow, BCol,
  BRow: Integer; var Result: integer);
begin
     if StrToInt((Sender as TStringGrid).Cells[aCol,ARow])=StrToInt((Sender as TStringGrid).Cells[BCol,BRow]) then
     begin
     if StrToInt((Sender as TStringGrid).Cells[0,ARow])=StrToInt((Sender as TStringGrid).Cells[0,BRow]) then result:=0
     else
         if StrToInt((Sender as TStringGrid).Cells[0,ARow])>StrToInt((Sender as TStringGrid).Cells[0,BRow]) then result:=1 else result:=-1;
     end else
   if StrToInt((Sender as TStringGrid).Cells[aCol,ARow])>StrToInt((Sender as TStringGrid).Cells[BCol,BRow]) then
  result:=-1 else result:=1;
     if TCustomStringGrid(Sender).SortOrder=soAscending then result:=-result;
end;

procedure Tmainfrm.CompareCells2(Sender: TObject; ACol, ARow, BCol,
  BRow: Integer; var Result: integer);
begin
  if StrToInt((Sender as TStringGrid).Cells[aCol,ARow])=StrToInt((Sender as TStringGrid).Cells[BCol,BRow]) then
     begin
          result:=0;
     end else
   if StrToInt((Sender as TStringGrid).Cells[aCol,ARow])>StrToInt((Sender as TStringGrid).Cells[BCol,BRow]) then
  result:=-1 else result:=1;
     if TCustomStringGrid(Sender).SortOrder=soAscending then result:=-result;
end;
end.

