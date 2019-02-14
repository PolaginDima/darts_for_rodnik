unit msgSavefrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tmsgfrm }

  Tmsgfrm = class(TForm)
    label1: TStaticText;
  private
  public
    constructor Create(TheOwner: TComponent;msg:string);
  end;

var
  msgfrm: Tmsgfrm;

implementation

{$R *.lfm}

{ Tmsgfrm }

constructor Tmsgfrm.Create(TheOwner: TComponent; msg: string);
begin
  inherited Create(TheOwner);
  Label1.Caption:=msg;
end;

end.

