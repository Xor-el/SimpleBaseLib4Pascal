unit BitsTests;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpSimpleBaseLibTypes,
  SbpBits,
  SimpleBaseLibTestBase;

type
  TTestBits = class(TSimpleBaseLibTestCase)
  strict private
    FInputHexData: TSimpleBaseLibStringArray;
    FExpectedCounts: TSimpleBaseLibInt32Array;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_CountPrefixingZeroes_CountsCorrectly;
  end;

implementation

procedure TTestBits.SetUp;
begin
  inherited;
  FInputHexData := TSimpleBaseLibStringArray.Create(
    '000001',
    '000100',
    '010000',
    '',
    '000000',
    '00000001',
    'FFFFFF',
    '00000000'
  );
  FExpectedCounts := TSimpleBaseLibInt32Array.Create(2, 1, 0, 0, 3, 3, 0, 4);
end;

procedure TTestBits.TearDown;
begin
  inherited;
end;

procedure TTestBits.Test_CountPrefixingZeroes_CountsCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FInputHexData) to High(FInputHexData) do
  begin
    CheckEquals(FExpectedCounts[LI], TBits.CountPrefixingZeroes(HexToBytes(FInputHexData[LI])));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBits);
{$ELSE}
  RegisterTest(TTestBits.Suite);
{$ENDIF FPC}

end.
