unit CodingAlphabetTests;

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
  SbpCodingAlphabet,
  SbpSimpleBaseLibTypes,
  SimpleBaseLibTestBase;

type
  TDummyAlphabet = class(TCodingAlphabet)
  public
    constructor Create(const AAlphabet: String);
  end;

  TTestCodingAlphabet = class(TSimpleBaseLibTestCase)
  published
    procedure Test_Ctor_WithBothCasesOfLettersAndCaseInsensitive_ShouldThrow;
    procedure Test_Ctor_LengthAndAlphabetLengthMismatch_ShouldThrow;
    procedure Test_Ctor_ProperArguments_ShouldNotThrow;
  end;

implementation

constructor TDummyAlphabet.Create(const AAlphabet: String);
begin
  inherited Create(10, AAlphabet, True);
end;

procedure TTestCodingAlphabet.Test_Ctor_WithBothCasesOfLettersAndCaseInsensitive_ShouldThrow;
var
  LAlphabet: TDummyAlphabet;
begin
  LAlphabet := nil;
  try
    try
      LAlphabet := TDummyAlphabet.Create('01234567Aa');
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  finally
    LAlphabet.Free;
  end;
end;

procedure TTestCodingAlphabet.Test_Ctor_LengthAndAlphabetLengthMismatch_ShouldThrow;
var
  LAlphabet: TDummyAlphabet;
begin
  LAlphabet := nil;
  try
    try
      LAlphabet := TDummyAlphabet.Create('01234567a');
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  finally
    LAlphabet.Free;
  end;
end;

procedure TTestCodingAlphabet.Test_Ctor_ProperArguments_ShouldNotThrow;
var
  LAlphabet: TDummyAlphabet;
begin
  LAlphabet := nil;
  try
    try
      LAlphabet := TDummyAlphabet.Create('01234567ab');
    except
      on E: Exception do
      begin
        Fail('Unexpected exception: ' + E.Message);
      end;
    end;
  finally
    LAlphabet.Free;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestCodingAlphabet);
{$ELSE}
  RegisterTest(TTestCodingAlphabet.Suite);
{$ENDIF FPC}

end.
