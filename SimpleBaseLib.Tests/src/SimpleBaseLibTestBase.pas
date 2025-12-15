unit SimpleBaseLibTestBase;

interface

uses
{$IFDEF FPC}
  fpcunit,
  testregistry
{$ELSE}
  TestFramework
{$ENDIF FPC};

type

  TSimpleBaseLibTestCase = class abstract(TTestCase)

  end;

implementation

end.

