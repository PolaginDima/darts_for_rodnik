unit editUchastnik;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls,LazUtf8;

type

  { TeditAuthorJanrF }

  { TeditUchastnikF }

  TeditUchastnikF = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Edit1: TEdit;
    Label_filtr: TLabel;
    spisok: TListBox;
    Timer1: TTimer;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure spisokClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FoldText:string;
    FEdit:boolean;
    fFlag:boolean;
    FQuit:boolean;
    //FAuthors:Boolean;
    spisokValue:TStringList;
    FSpisoktmp:TStringList;
    function Gettext: string;
    procedure SetCaptionForm(AValue: string);
    procedure SetLabelFiltr(AValue: string);
  public
    constructor Create(TheOwner: TComponent;listValue:TStringList;
      textEdit:string='';edit:boolean=false);
    property text:string read Gettext;
    property CaptionForm:string write SetCaptionForm;
    property LabelFiltr:string write SetLabelFiltr;
  end;

var
 editUchastnikF: TeditUchastnikF;

implementation
uses myprocbd;
{$R *.lfm}

{ TeditUchastnikF }

procedure TeditUchastnikF.FormCreate(Sender: TObject);
begin

end;

procedure TeditUchastnikF.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSpisoktmp);
end;

procedure TeditUchastnikF.spisokClick(Sender: TObject);
begin
  fflag:=true;
  if spisok.SelCount>0 then
     edit1.Text:=spisok.GetSelectedText;
end;

procedure TeditUchastnikF.Timer1Timer(Sender: TObject);
var
  i:integer;
begin
  if fflag then
     begin
       fflag:=false;
       Timer1.Enabled:=false;
       exit;
     end;
  //Чистим список
  spisok.BeginUpdateBounds;
  spisok.Clear;
  if Trim(Edit1.Text)<>'' then
     begin
       //Заполняем вновь с учетом фильтра
       for i:=0 to FSpisoktmp.Count-1 do
       begin
         if UTF8pos(UTF8LowerCase(Edit1.Text),FSpisoktmp.Strings[i])>0 then
              spisok.Items.Add(SpisokValue.Strings[i]);
       end;
     end else
     begin   //Если поле фильтра пустое, то выводим весь список
       spisok.Items.Text:=SpisokValue.Text;
     end;
   //отсортируем список
  spisok.Sorted:=false;
  spisok.Sorted:=true;
  spisok.EndUpdateBounds;
  Timer1.Enabled:=false;
end;

function TeditUchastnikF.Gettext: string;
begin
  result:=edit1.Text;
end;

procedure TeditUchastnikF.SetCaptionForm(AValue: string);
begin
  Caption:=AValue;
end;

procedure TeditUchastnikF.SetLabelFiltr(AValue: string);
begin
  Label_Filtr.Caption:=AValue;
end;

procedure TeditUchastnikF.Edit1Change(Sender: TObject);
begin
  Timer1.Enabled:=false;
  Timer1.Enabled:=true;
end;

procedure TeditUchastnikF.BitBtn1Click(Sender: TObject);
begin
  FQuit:=false;
  if (UTF8Length(edit1.Text)<2)or
  (not FEdit)or(FOldText=edit1.Text) then exit;
  spisokValue.Delete(spisokValue.IndexOf(FOldText));
  spisok.Items.Delete(spisok.Items.IndexOf(FOldText));
  savePeople;
end;

procedure TeditUchastnikF.BitBtn2Click(Sender: TObject);
begin
  FQuit:=true;
end;

procedure TeditUchastnikF.BitBtn3Click(Sender: TObject);
begin
  case QuestionDlg('Удаление','Удалить запись?',mtConfirmation,[mrYes,'Удалить',mrNo,'Не удалять','isdefault'],'') of
            mryes:;
            mrno:exit;
            end;
  spisokValue.Delete(spisokValue.IndexOf(spisok.Items.Strings[spisok.ItemIndex]));
  spisok.DeleteSelected;
  savePeople;
end;

procedure TeditUchastnikF.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
  CanClose:=(utf8length(edit1.Text)>1)or(FQuit);
  FQuit:=true;
end;

constructor TeditUchastnikF.Create(TheOwner: TComponent;
  listValue: TStringList; textEdit: string; edit: boolean);
begin
  inherited Create(TheOwner);
  FQuit:=true;
  spisokValue:=listValue;
  FSpisoktmp:=TStringList.Create;
  fFlag:=false;
  spisok.Clear;
  spisok.Items.Text:=spisokValue.Text;
  //отсортируем список
  spisok.Sorted:=false;
  spisok.Sorted:=true;
  //приведем к нижнему регистру список - для регистронезависимого поиска
  FSpisoktmp.Text:=UTF8LowerCase(spisokValue.Text);
  FEdit:=edit;
  if textEdit<>'' then
     begin
       FOldText:=textEdit;
       Edit1.Text:=Foldtext;
     end;
end;

end.

