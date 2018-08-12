unit Rfc4648Tests;

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

  TTestRfc4648 = class(TCryptoLibTestCase)
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

procedure TTestRfc4648.SetUp;
begin
  inherited;
  FRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob',
    'fooba', 'foobar', 'foobar1', 'foobar12', 'foobar123',
    '1234567890123456789012345678901234567890'

    );
  FEncodedData := TSimpleBaseLibStringArray.Create('', 'MY======', 'MZXQ====',
    'MZXW6===', 'MZXW6YQ=', 'MZXW6YTB', 'MZXW6YTBOI======', 'MZXW6YTBOIYQ====',
    'MZXW6YTBOIYTE===', 'MZXW6YTBOIYTEMY=',
    'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'

    );

end;

procedure TTestRfc4648.TearDown;
begin
  inherited;

end;

procedure TTestRfc4648.Test_Decode_InvalidInput_ThrowsArgumentException;
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

procedure TTestRfc4648.Test_Decode_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FEncodedData) to System.High(FEncodedData) do
  begin
    bytes := TBase32.Rfc4648.Decode(FEncodedData[Idx]);
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));

    bytes := TBase32.Rfc4648.Decode(LowerCase(FEncodedData[Idx]));
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestRfc4648.Test_Encode_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    result := TBase32.Rfc4648.Encode(bytes, true);
    CheckEquals(FEncodedData[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestRfc4648);
{$ELSE}
  RegisterTest(TTestRfc4648.Suite);
{$ENDIF FPC}

end.
