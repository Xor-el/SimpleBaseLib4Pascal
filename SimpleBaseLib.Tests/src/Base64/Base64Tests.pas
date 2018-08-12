unit Base64Tests;

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
  SbpUtilities,
  SbpBase64;

type

  TCryptoLibTestCase = class abstract(TTestCase)

  end;

type

  TTestBase64 = class(TCryptoLibTestCase)
  private
  var
    FRawData, FEncodedDataBase64Default: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_Default_ReturnsExpectedValues;
    procedure Test_Decode_Default_ReturnsExpectedValues;
    procedure Test_Encode_DefaultNoPadding_ReturnsExpectedValues;
    procedure Test_Decode_DefaultNoPadding_ReturnsExpectedValues;
    procedure Test_Decode__Default_InvalidInput_ThrowsArgumentException;
    procedure Test_Dog_Food_Default;
    procedure Test_Dog_Food_DefaultNoPadding;
    procedure Test_Dog_Food_UrlEncoding;
    procedure Test_Dog_Food_XmlEncoding;
    procedure Test_Dog_Food_RegExEncoding;
    procedure Test_Dog_Food_FileEncoding;

  end;

implementation

procedure TTestBase64.SetUp;
begin
  inherited;
  FRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob',
    'fooba', 'foobar', '1234567890123456789012345678901234567890'

    );
  FEncodedDataBase64Default := TSimpleBaseLibStringArray.Create('', 'Zg==',
    'Zm8=', 'Zm9v', 'Zm9vYg==', 'Zm9vYmE=', 'Zm9vYmFy',
    'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MA=='

    );

end;

procedure TTestBase64.TearDown;
begin
  inherited;

end;

procedure TTestBase64.Test_Decode_DefaultNoPadding_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FEncodedDataBase64Default)
    to System.High(FEncodedDataBase64Default) do
  begin
    bytes := TBase64.DefaultNoPadding.Decode
      (TUtilities.TrimRight(FEncodedDataBase64Default[Idx],
      TSimpleBaseLibCharArray.Create('=')));
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Decode_Default_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FEncodedDataBase64Default)
    to System.High(FEncodedDataBase64Default) do
  begin
    bytes := TBase64.Default.Decode(FEncodedDataBase64Default[Idx]);
    result := TEncoding.ASCII.GetString(bytes);
    CheckEquals(FRawData[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Decode__Default_InvalidInput_ThrowsArgumentException;
begin
  try

    TBase64.Default.Decode('Zm8=Zm8=');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase64.Default.Decode('Z=m=');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase64.Default.Decode('@@@@');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

procedure TTestBase64.Test_Dog_Food_Default;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(TBase64.Default.Decode(TBase64.
      Default.Encode(bytes)), bytes),
      Format('Encoding & Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Dog_Food_DefaultNoPadding;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(TBase64.DefaultNoPadding.Decode
      (TBase64.DefaultNoPadding.Encode(bytes)), bytes),
      Format('Encoding & Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Dog_Food_FileEncoding;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(TBase64.FileEncoding.Decode
      (TBase64.FileEncoding.Encode(bytes)), bytes),
      Format('Encoding & Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Dog_Food_RegExEncoding;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(TBase64.RegExEncoding.Decode
      (TBase64.RegExEncoding.Encode(bytes)), bytes),
      Format('Encoding & Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Dog_Food_UrlEncoding;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(TBase64.UrlEncoding.Decode
      (TBase64.UrlEncoding.Encode(bytes)), bytes),
      Format('Encoding & Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Dog_Food_XmlEncoding;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(TBase64.XmlEncoding.Decode
      (TBase64.XmlEncoding.Encode(bytes)), bytes),
      Format('Encoding & Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Encode_DefaultNoPadding_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    result := TBase64.DefaultNoPadding.Encode(bytes);
    CheckEquals(TUtilities.TrimRight(FEncodedDataBase64Default[Idx],
      TSimpleBaseLibCharArray.Create('=')), result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase64.Test_Encode_Default_ReturnsExpectedValues;
var
  Idx: Int32;
  bytes: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawData) to System.High(FRawData) do
  begin
    bytes := TEncoding.ASCII.GetBytes(FRawData[Idx]);
    result := TBase64.Default.Encode(bytes);
    CheckEquals(FEncodedDataBase64Default[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestBase64);
{$ELSE}
  RegisterTest(TTestBase64.Suite);
{$ENDIF FPC}

end.
