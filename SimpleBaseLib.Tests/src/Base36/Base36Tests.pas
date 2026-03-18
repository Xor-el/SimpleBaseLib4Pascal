unit Base36Tests;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpBase36,
  SimpleBaseLibTestBase;

type
  TTestBase36 = class(TSimpleBaseLibTestCase)
  strict private
    FDecoded: array[0..3] of String;
    FUpperEncoded: array[0..3] of String;
    FLowerEncoded: array[0..3] of String;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_UpperCase_Encode_EncodesCorrectly;
    procedure Test_LowerCase_Encode_EncodesCorrectly;
  end;

implementation

procedure TTestBase36.SetUp;
begin
  inherited;

  FDecoded[0] := '';
  FDecoded[1] := 'a';
  FDecoded[2] := 'test';
  FDecoded[3] := 'hello world';

  FUpperEncoded[0] := '';
  FUpperEncoded[1] := '2P';
  FUpperEncoded[2] := 'WANEK4';
  FUpperEncoded[3] := 'FUVRSIVVNFRBJWAJO';

  FLowerEncoded[0] := '';
  FLowerEncoded[1] := '2p';
  FLowerEncoded[2] := 'wanek4';
  FLowerEncoded[3] := 'fuvrsivvnfrbjwajo';
end;

procedure TTestBase36.TearDown;
begin
  inherited;
end;

procedure TTestBase36.Test_UpperCase_Encode_EncodesCorrectly;
var
  LI: Int32;
  LResult: String;
begin
  for LI := Low(FDecoded) to High(FDecoded) do
  begin
    LResult := TBase36.UpperCase.Encode(TEncoding.UTF8.GetBytes(FDecoded[LI]));
    CheckEquals(FUpperEncoded[LI], LResult,
      Format('UpperCase encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase36.Test_LowerCase_Encode_EncodesCorrectly;
var
  LI: Int32;
  LResult: String;
begin
  for LI := Low(FDecoded) to High(FDecoded) do
  begin
    LResult := TBase36.LowerCase.Encode(TEncoding.UTF8.GetBytes(FDecoded[LI]));
    CheckEquals(FLowerEncoded[LI], LResult,
      Format('LowerCase encode mismatch at index %d', [LI]));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase36);
{$ELSE}
  RegisterTest(TTestBase36.Suite);
{$ENDIF FPC}

end.
