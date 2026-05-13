unit EncodingAlphabetTests;

{$IFDEF FPC}
{$MODE DELPHI}
{$HINTS OFF}
{$WARNINGS OFF}
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
  SbpICodingAlphabet,
  SbpBase16Alphabet,
  SimpleBaseLibTestBase;

type
  TTestEncodingAlphabet = class(TSimpleBaseLibTestCase)
  published
    procedure Test_ToString_ReturnsValue;
  end;

implementation

procedure TTestEncodingAlphabet.Test_ToString_ReturnsValue;
var
  LAlpha: ICodingAlphabet;
begin
  LAlpha := TBase16Alphabet.Create('0123456789abcdef');
  CheckEquals('0123456789abcdef', LAlpha.ToString);
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestEncodingAlphabet);
{$ELSE}
  RegisterTest(TTestEncodingAlphabet.Suite);
{$ENDIF FPC}

end.
