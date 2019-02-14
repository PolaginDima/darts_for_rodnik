program darts;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, myProc, myprocbd, lrcairoexport, msgSavefrm;

{$R *.res}

begin
  Application.Title:='darts';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(Tmainfrm, mainfrm);
  Application.CreateForm(Tmsgfrm, msgfrm);
  Application.Run;
end.

