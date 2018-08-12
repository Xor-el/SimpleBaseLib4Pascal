unit CrockfordTests;

interface

uses
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpUtilities,
  SbpSimpleBaseLibTypes,
  SbpBase32;

type

  TCryptoLibTestCase = class abstract(TTestCase)

  end;

type

  TTestCrockford = class(TCryptoLibTestCase)
  private
  var
    FRawData, FEncodedData, FSpecialRaw, FSpecialEncoded
      : TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_ReturnsExpectedValues;
    procedure Test_Decode_ReturnsExpectedValues;
    procedure Test_Decode_InvalidInput_ThrowsArgumentException;
    procedure Test_Decode_CrockfordChars_DecodedCorrectly;

  end;

implementation

procedure TTestCrockford.SetUp;
begin
  inherited;
  FRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob',
    'fooba', 'foobar', '1234567890123456789012345678901234567890'

    );
  FEncodedData := TSimpleBaseLibStringArray.Create('', 'CR', 'CSQG', 'CSQPY',
    'CSQPYRG', 'CSQPYRK1', 'CSQPYRK1E8',
    '64S36D1N6RVKGE9G64S36D1N6RVKGE9G64S36D1N6RVKGE9G64S36D1N6RVKGE9G'

    );

  FSpecialRaw := TSimpleBaseLibStringArray.Create('000', '111', '111');
  FSpecialEncoded := TSimpleBaseLibStringArray.Create('O0o', 'Ll1', 'I1i');

end;

procedure TTestCrockford.TearDown;
begin
  inherited;

end;

procedure TTestCrockford.Test_Decode_CrockfordChars_DecodedCorrectly;
var
  Idx: Int32;
  expectedResult, result: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FSpecialRaw) to System.High(FSpecialRaw) do
  begin
    expectedResult := TBase32.Crockford.Decode(FSpecialRaw[Idx]);
    result := TBase32.Crockford.Decode(FSpecialEncoded[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(expectedResult, result),
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestCrockford.Test_Decode_InvalidInput_ThrowsArgumentException;
begin
  try

    TBase32.Crockford.Decode('[];'',m.');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

procedure TTestCrockford.Test_Decode_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FEncodedData) to System.High(FEncodedData) do
  begin
    bytes := TBase32.Crockford.Decode(FEncodedData[Idx]);
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));

    bytes := TBase32.Crockford.Decode(LowerCase(FEncodedData[Idx]));
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestCrockford.Test_Encode_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    result := TBase32.Crockford.Encode(bytes, false);
    CheckEquals(FEncodedData[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestCrockford);
{$ELSE}
  RegisterTest(TTestCrockford.Suite);
{$ENDIF FPC}

end.
