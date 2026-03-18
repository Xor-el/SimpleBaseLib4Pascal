unit Base32AlphabetTests;

{$IFDEF FPC}
{$MODE DELPHI}
{$HINTS OFF}
{$WARNINGS OFF}
{$ENDIF FPC}

interface

uses
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpIBase32Alphabet,
  SbpPaddingPosition,
  SbpBase32Alphabet,
  SbpBase32,
  SimpleBaseLibTestBase;

type
  TTestBase32Alphabet = class(TSimpleBaseLibTestCase)
  published
    procedure Test_CtorWithPaddingChar_Works;
    procedure Test_GetSafeByteCountForDecoding_Works;
  end;

implementation

procedure TTestBase32Alphabet.Test_CtorWithPaddingChar_Works;
var
  LAlpha: IBase32Alphabet;
begin
  LAlpha := TBase32Alphabet.Create(
    '0123456789abcdef0123456789abcdef', '!', TPaddingPosition.Start);
  CheckEquals(Ord('!'), Ord(LAlpha.PaddingChar));
  CheckEquals(Ord(TPaddingPosition.Start), Ord(LAlpha.PaddingPosition));
end;

procedure TTestBase32Alphabet.Test_GetSafeByteCountForDecoding_Works;
begin
  CheckEquals(3, TBase32.Crockford.GetSafeByteCountForDecoding('12345'));
  CheckEquals(0, TBase32.Crockford.GetSafeByteCountForDecoding(''));
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase32Alphabet);
{$ELSE}
  RegisterTest(TTestBase32Alphabet.Suite);
{$ENDIF FPC}

end.
