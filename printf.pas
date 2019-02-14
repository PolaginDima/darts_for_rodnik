unit printF;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Class, LR_View, LR_DSet, Forms, Controls,
  Graphics, Dialogs, Grids;

type

  { TPrintFrm }

  TPrintFrm = class(TForm)
    frPreview1: TfrPreview;
    procedure FormCreate(Sender: TObject);
    procedure frReport1GetValue(const ParName: String; var ParValue: Variant);
    procedure frUserDataset1CheckEOF(Sender: TObject; var Eof: Boolean);
    procedure frUserDataset1First(Sender: TObject);
    procedure frUserDataset1Next(Sender: TObject);
  private
    FGrid:TStringGrid;
    FNumeric:integer;
  public
    constructor Create(TheOwner: TComponent; Grid:TStringGrid);
  end;

var
  PrintFrm: TPrintFrm;

implementation
uses myProc;
{$R *.lfm}

{ TPrintFrm }

procedure TPrintFrm.frUserDataset1CheckEOF(Sender: TObject; var Eof: Boolean);
begin
  eof:=Fnumeric>(FGrid.RowCount-1);
end;

procedure TPrintFrm.frReport1GetValue(const ParName: String;
  var ParValue: Variant);
begin
  case ParName of
  'FIO':
    begin
      ParValue:=FGrid.Cells[1,Fnumeric];
    end;
  'Score':;
  'Rating':;
  end;
  exit;
  if ParName='FIO' then
  ParValue:=inttostr(Fnumeric);
  if ParName='Score' then
  ParValue:='NAME1='+inttostr(Fnumeric);
  if ParName='PRICE1' then
  ParValue:='PRICE1='+inttostr(Fnumeric);
end;

procedure TPrintFrm.FormCreate(Sender: TObject);
begin
end;

procedure TPrintFrm.frUserDataset1First(Sender: TObject);
begin
  Fnumeric:=1;
end;

procedure TPrintFrm.frUserDataset1Next(Sender: TObject);
begin
  inc(FNumeric);
end;

constructor TPrintFrm.Create(TheOwner: TComponent; Grid: TStringGrid);
begin
  inherited Create(TheOwner);
  FGrid:=Grid;
end;

end.

