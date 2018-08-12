unit Base58AlphabetTests;

interface

uses
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpSimpleBaseLibTypes,
  SbpBase58Alphabet;

type

  TCryptoLibTestCase = class abstract(TTestCase)

  end;

type

  TTestBase58Alphabet = class(TCryptoLibTestCase)

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Constructor_Invalid_Length_Raise;

  end;

implementation

procedure TTestBase58Alphabet.SetUp;
begin
  inherited;

end;

procedure TTestBase58Alphabet.TearDown;
begin
  inherited;

end;

procedure TTestBase58Alphabet.Test_Constructor_Invalid_Length_Raise;
begin
  try

    TBase58Alphabet.Create('123');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestBase58Alphabet);
{$ELSE}
  RegisterTest(TTestBase58Alphabet.Suite);
{$ENDIF FPC}

end.
