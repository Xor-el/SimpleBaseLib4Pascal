unit ExtendedHexTests;

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
  SbpBase32;

type

  TCryptoLibTestCase = class abstract(TTestCase)

  end;

type

  TTestExtendedHex = class(TCryptoLibTestCase)
  private
  var
    FRawData, FEncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_ReturnsExpectedValues;
    procedure Test_Decode_ReturnsExpectedValues;
    procedure Test_Decode_InvalidInput_ThrowsArgumentException;

  end;

implementation

procedure TTestExtendedHex.SetUp;
begin
  inherited;
  FRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob',
    'fooba', 'foobar', '1234567890123456789012345678901234567890'

    );
  FEncodedData := TSimpleBaseLibStringArray.Create('', 'CO======', 'CPNG====',
    'CPNMU===', 'CPNMUOG=', 'CPNMUOJ1', 'CPNMUOJ1E8======',
    '64P36D1L6ORJGE9G64P36D1L6ORJGE9G64P36D1L6ORJGE9G64P36D1L6ORJGE9G'

    );

end;

procedure TTestExtendedHex.TearDown;
begin
  inherited;

end;

procedure TTestExtendedHex.Test_Decode_InvalidInput_ThrowsArgumentException;
begin
  try

    TBase32.ExtendedHex.Decode('!@#!#@!#@#!@');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase32.ExtendedHex.Decode('||||');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

end;

procedure TTestExtendedHex.Test_Decode_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FEncodedData) to System.High(FEncodedData) do
  begin
    bytes := TBase32.ExtendedHex.Decode(FEncodedData[Idx]);
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));

    bytes := TBase32.ExtendedHex.Decode(LowerCase(FEncodedData[Idx]));
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestExtendedHex.Test_Encode_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    result := TBase32.ExtendedHex.Encode(bytes, true);
    CheckEquals(FEncodedData[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestExtendedHex);
{$ELSE}
  RegisterTest(TTestExtendedHex.Suite);
{$ENDIF FPC}

end.
