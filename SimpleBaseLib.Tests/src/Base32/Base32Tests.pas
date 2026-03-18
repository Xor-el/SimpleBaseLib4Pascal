unit Base32Tests;

{$IFDEF FPC}
{$MODE DELPHI}
{$HINTS OFF}
{$WARNINGS OFF}
{$ENDIF FPC}

interface

uses
  Classes,
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpSimpleBaseLibTypes,
  SbpIBase32,
  SbpBase32,
  SbpBase32Alphabet,
  SbpBitOperations,
  SimpleBaseLibTestBase;

type
  TTestBase32 = class(TSimpleBaseLibTestCase)
  strict private
    FRfcRawData: TSimpleBaseLibStringArray;
    FRfcPaddedData: TSimpleBaseLibStringArray;
    FCrockfordRawData: TSimpleBaseLibStringArray;
    FCrockfordEncodedData: TSimpleBaseLibStringArray;
    FExtendedHexRawData: TSimpleBaseLibStringArray;
    FExtendedHexEncodedData: TSimpleBaseLibStringArray;
    FZBase32RawData: TSimpleBaseLibStringArray;
    FZBase32EncodedData: TSimpleBaseLibStringArray;
    FBech32RawData: TSimpleBaseLibStringArray;
    FBech32EncodedData: TSimpleBaseLibStringArray;
    FFileCoinRawData: TSimpleBaseLibStringArray;
    FFileCoinEncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Rfc4648_Encode_ReturnsExpectedValues;
    procedure Test_Rfc4648_Decode_ReturnsExpectedValues;
    procedure Test_Rfc4648_Encode_BinaryInput_ReturnsExpectedValues;
    procedure Test_Rfc4648_Encode_NilBytes_ReturnsEmptyString;
    procedure Test_Rfc4648_Decode_InvalidInput_Throws;
    procedure Test_Rfc4648_EncodeUInt64_ReturnsExpectedValues;
    procedure Test_Rfc4648_DecodeUInt64_ReturnsExpectedValues;
    procedure Test_Rfc4648_TryDecodeUInt64_ReturnsExpectedValues;
    procedure Test_Rfc4648_TryDecodeUInt64_InvalidInput_ReturnsFalse;
    procedure Test_Rfc4648_Encode_BigEndianUInt64_ReturnsExpectedValues;
    procedure Test_Rfc4648_DecodeUInt64_BigEndian_ReturnsExpectedValues;
    procedure Test_Rfc4648_EncodeInt64_Negative_Throws;
    procedure Test_Rfc4648_DecodeInt64_ReturnsExpectedValues;
    procedure Test_Rfc4648_DecodeInt64_OutOfRange_Throws;

    procedure Test_Crockford_Encode_ReturnsExpectedValues;
    procedure Test_Crockford_Decode_ReturnsExpectedValues;
    procedure Test_Crockford_TryEncode_ReturnsExpectedValues;
    procedure Test_Crockford_TryDecode_ReturnsExpectedValues;
    procedure Test_Crockford_TryDecode_ZeroBuffer_ReturnsFalse;
    procedure Test_Crockford_Decode_InvalidInput_Throws;
    procedure Test_Crockford_Decode_CrockfordChars_DecodedCorrectly;
    procedure Test_Crockford_Encode_ZeroPrefixData_ReturnsExpectedValues;
    procedure Test_Crockford_Decode_ZeroPrefixData_ReturnsExpectedValues;

    procedure Test_ExtendedHex_Encode_ReturnsExpectedValues;
    procedure Test_ExtendedHex_Decode_ReturnsExpectedValues;
    procedure Test_ExtendedHex_Encode_Stream_ReturnsExpectedValues;
    procedure Test_ExtendedHex_Decode_Stream_ReturnsExpectedValues;
    procedure Test_ExtendedHex_Encode_NilBytes_ReturnsEmptyString;
    procedure Test_ExtendedHex_Decode_InvalidInput_Throws;

    procedure Test_ZBase32_Encode_ReturnsExpectedValues;
    procedure Test_ZBase32_Decode_ReturnsExpectedValues;
    procedure Test_ZBase32_Encode_NilBytes_ReturnsEmptyString;
    procedure Test_ZBase32_Decode_InvalidInput_Throws;

    procedure Test_Bech32_Encode_ReturnsExpectedValues;
    procedure Test_Bech32_Decode_ReturnsExpectedValues;
    procedure Test_Bech32_Encode_NilBytes_ReturnsEmptyString;
    procedure Test_Bech32_Decode_InvalidInput_Throws;

    procedure Test_FileCoin_Encode_ReturnsExpectedValues;
    procedure Test_FileCoin_Encode_Bytes_ReturnsExpectedValues;
    procedure Test_FileCoin_Decode_ReturnsExpectedValues;
    procedure Test_FileCoin_Encode_NilBytes_ReturnsEmptyString;
    procedure Test_FileCoin_Decode_InvalidInput_Throws;

    procedure Test_Geohash_Decode_SmokeTest;
    procedure Test_Geohash_Encode_SmokeTest;
  end;

implementation

procedure TTestBase32.SetUp;
begin
  inherited;

  FRfcRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob', 'fooba',
    'foobar', 'foobar1', 'foobar12', 'foobar123',
    '1234567890123456789012345678901234567890');
  FRfcPaddedData := TSimpleBaseLibStringArray.Create('', 'MY======', 'MZXQ====', 'MZXW6===',
    'MZXW6YQ=', 'MZXW6YTB', 'MZXW6YTBOI======', 'MZXW6YTBOIYQ====',
    'MZXW6YTBOIYTE===', 'MZXW6YTBOIYTEMY=',
    'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ');

  FCrockfordRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob',
    'fooba', 'foobar', 'hello world', '123456789012345678901234567890123456789');
  FCrockfordEncodedData := TSimpleBaseLibStringArray.Create('', 'CR', 'CSQG', 'CSQPY',
    'CSQPYRG', 'CSQPYRK1', 'CSQPYRK1E8', 'D1JPRV3F41VPYWKCCG',
    '64S36D1N6RVKGE9G64S36D1N6RVKGE9G64S36D1N6RVKGE9G64S36D1N6RVKGE8');

  FExtendedHexRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob',
    'fooba', 'foobar', '1234567890123456789012345678901234567890');
  FExtendedHexEncodedData := TSimpleBaseLibStringArray.Create('', 'CO======', 'CPNG====',
    'CPNMU===', 'CPNMUOG=', 'CPNMUOJ1', 'CPNMUOJ1E8======',
    '64P36D1L6ORJGE9G64P36D1L6ORJGE9G64P36D1L6ORJGE9G64P36D1L6ORJGE9G');

  FZBase32RawData := TSimpleBaseLibStringArray.Create('', 'dCode z-base-32',
    'Never did sun more beautifully steep');
  FZBase32EncodedData := TSimpleBaseLibStringArray.Create('', 'ctbs63dfrb7n4aubqp114c31',
    'j31zc3m1rb1g13byqp4shedpp73gkednciozk7djc34sa5d3rb3ze3mfqy');

  FBech32RawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob', 'fooba',
    'foobar', 'foobar1', 'foobar12', 'foobar123', 'foobar1234',
    '1234567890123456789012345678901234567890');
  FBech32EncodedData := TSimpleBaseLibStringArray.Create('', 'vc======', 'vehs====', 'vehk7===',
    'vehk7cs=', 'vehk7cnp', 'vehk7cnpwg======', 'vehk7cnpwgcs====',
    'vehk7cnpwgcny===', 'vehk7cnpwgcnyvc=', 'vehk7cnpwgcnyve5',
    'xyerxdp4xcmnswfsxyerxdp4xcmnswfsxyerxdp4xcmnswfsxyerxdp4xcmnswfs');

  FFileCoinRawData := TSimpleBaseLibStringArray.Create('', 'f', 'fo', 'foo', 'foob', 'fooba',
    'foobar', 'foobar1', 'foobar12', 'foobar123',
    '1234567890123456789012345678901234567890');
  FFileCoinEncodedData := TSimpleBaseLibStringArray.Create('', 'my======', 'mzxq====', 'mzxw6===',
    'mzxw6yq=', 'mzxw6ytb', 'mzxw6ytboi======', 'mzxw6ytboiyq====',
    'mzxw6ytboiyte===', 'mzxw6ytboiytemy=',
    'gezdgnbvgy3tqojqgezdgnbvgy3tqojqgezdgnbvgy3tqojqgezdgnbvgy3tqojq');
end;

procedure TTestBase32.TearDown;
begin
  inherited;
end;

procedure TTestBase32.Test_Rfc4648_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FRfcRawData) to High(FRfcRawData) do
  begin
    CheckEquals(FRfcPaddedData[LI],
      TBase32.Rfc4648.Encode(TEncoding.ASCII.GetBytes(FRfcRawData[LI]), True));
  end;
end;

procedure TTestBase32.Test_Rfc4648_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FRfcPaddedData) to High(FRfcPaddedData) do
  begin
    CheckEquals(FRfcRawData[LI], TEncoding.ASCII.GetString(TBase32.Rfc4648.Decode(FRfcPaddedData[LI])));
    CheckEquals(FRfcRawData[LI],
      TEncoding.ASCII.GetString(TBase32.Rfc4648.Decode(LowerCase(FRfcPaddedData[LI]))));
  end;
end;

procedure TTestBase32.Test_Rfc4648_Encode_BinaryInput_ReturnsExpectedValues;
begin
  CheckEquals('AA', TBase32.Rfc4648.Encode(TSimpleBaseLibByteArray.Create($00), False));
  CheckEquals('AA======', TBase32.Rfc4648.Encode(TSimpleBaseLibByteArray.Create($00), True));
  CheckEquals('AE', TBase32.Rfc4648.Encode(TSimpleBaseLibByteArray.Create($01), False));
  CheckEquals('CY', TBase32.Rfc4648.Encode(TSimpleBaseLibByteArray.Create($16), False));
  CheckEquals('EA======', TBase32.Rfc4648.Encode(TSimpleBaseLibByteArray.Create($20), True));
end;

procedure TTestBase32.Test_Rfc4648_Encode_NilBytes_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase32.Rfc4648.Encode(LBytes, True));
end;

procedure TTestBase32.Test_Rfc4648_Decode_InvalidInput_Throws;
begin
  try
    TBase32.Rfc4648.Decode('[];'',m.');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_Rfc4648_EncodeUInt64_ReturnsExpectedValues;
begin
  CheckEquals('AA', TBase32.Rfc4648.EncodeUInt64(0));
  CheckEquals('CE', TBase32.Rfc4648.EncodeUInt64($11));
  CheckEquals('EIIQ', TBase32.Rfc4648.EncodeUInt64($1122));
  CheckEquals('GMRBC', TBase32.Rfc4648.EncodeUInt64($112233));
  CheckEquals('IQZSEEI', TBase32.Rfc4648.EncodeUInt64($11223344));
  CheckEquals('RB3WMVKEGMRBC', TBase32.Rfc4648.EncodeUInt64($1122334455667788));
end;

procedure TTestBase32.Test_Rfc4648_DecodeUInt64_ReturnsExpectedValues;
begin
  CheckEquals(UInt64(0), TBase32.Rfc4648.DecodeUInt64('AA'));
  CheckEquals(UInt64($11), TBase32.Rfc4648.DecodeUInt64('CE'));
  CheckEquals(UInt64($1122), TBase32.Rfc4648.DecodeUInt64('EIIQ'));
  CheckEquals(UInt64($1122334455667788), TBase32.Rfc4648.DecodeUInt64('RB3WMVKEGMRBC'));
end;

procedure TTestBase32.Test_Rfc4648_TryDecodeUInt64_ReturnsExpectedValues;
var
  LValue: UInt64;
begin
  CheckTrue(TBase32.Rfc4648.TryDecodeUInt64('AA', LValue));
  CheckEquals(UInt64(0), LValue);
  CheckTrue(TBase32.Rfc4648.TryDecodeUInt64('RB3WMVKEGMRBC', LValue));
  CheckEquals(UInt64($1122334455667788), LValue);
end;

procedure TTestBase32.Test_Rfc4648_TryDecodeUInt64_InvalidInput_ReturnsFalse;
var
  LValue: UInt64;
begin
  CheckFalse(TBase32.Rfc4648.TryDecodeUInt64(
    'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', LValue));
  CheckFalse(TBase32.Rfc4648.TryDecodeUInt64('!@#!@#invalid alphabet!@#!@#', LValue));
end;

procedure TTestBase32.Test_Rfc4648_Encode_BigEndianUInt64_ReturnsExpectedValues;
var
  LBigEndian: IBase32;
  LValue: UInt64;
begin
  LBigEndian := TBase32.Create(TBase32Alphabet.Rfc4648, True);
  LValue := TBitOperations.ReverseBytesUInt64($1122334455667788);
  CheckEquals('RB3WMVKEGMRBC', LBigEndian.EncodeUInt64(LValue));
end;

procedure TTestBase32.Test_Rfc4648_DecodeUInt64_BigEndian_ReturnsExpectedValues;
var
  LBigEndian: IBase32;
  LExpected: UInt64;
begin
  LBigEndian := TBase32.Create(TBase32Alphabet.Rfc4648, True);
  LExpected := TBitOperations.ReverseBytesUInt64($1122334455667788);
  CheckEquals(LExpected, LBigEndian.DecodeUInt64('RB3WMVKEGMRBC'));
end;

procedure TTestBase32.Test_Rfc4648_EncodeInt64_Negative_Throws;
begin
  try
    TBase32.Rfc4648.EncodeInt64(-1);
    Fail('Expected EArgumentOutOfRangeSimpleBaseLibException');
  except
    on EArgumentOutOfRangeSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_Rfc4648_DecodeInt64_ReturnsExpectedValues;
begin
  CheckEquals(Int64(0), TBase32.Rfc4648.DecodeInt64('AA'));
  CheckEquals(Int64(1), TBase32.Rfc4648.DecodeInt64('AE'));
  CheckEquals(Int64($1122334455667788), TBase32.Rfc4648.DecodeInt64('RB3WMVKEGMRBC'));
end;

procedure TTestBase32.Test_Rfc4648_DecodeInt64_OutOfRange_Throws;
var
  LEncodedOverMax: String;
begin
  LEncodedOverMax := TBase32.Rfc4648.EncodeUInt64(UInt64(High(Int64)) + 1);
  try
    TBase32.Rfc4648.DecodeInt64(LEncodedOverMax);
    Fail('Expected EArgumentOutOfRangeSimpleBaseLibException');
  except
    on EArgumentOutOfRangeSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_Crockford_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FCrockfordRawData) to High(FCrockfordRawData) do
  begin
    CheckEquals(FCrockfordEncodedData[LI],
      TBase32.Crockford.Encode(TEncoding.ASCII.GetBytes(FCrockfordRawData[LI]), False));
  end;
end;

procedure TTestBase32.Test_Crockford_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FCrockfordEncodedData) to High(FCrockfordEncodedData) do
  begin
    CheckEquals(FCrockfordRawData[LI],
      TEncoding.ASCII.GetString(TBase32.Crockford.Decode(FCrockfordEncodedData[LI])));
    CheckEquals(FCrockfordRawData[LI],
      TEncoding.ASCII.GetString(TBase32.Crockford.Decode(LowerCase(FCrockfordEncodedData[LI]))));
  end;
end;

procedure TTestBase32.Test_Crockford_TryEncode_ReturnsExpectedValues;
var
  LI, LCharsWritten: Int32;
  LOut: TSimpleBaseLibCharArray;
begin
  for LI := Low(FCrockfordRawData) to High(FCrockfordRawData) do
  begin
    SetLength(LOut, TBase32.Crockford.GetSafeCharCountForEncoding(
      TEncoding.ASCII.GetBytes(FCrockfordRawData[LI])));
    CheckTrue(TBase32.Crockford.TryEncode(TEncoding.ASCII.GetBytes(FCrockfordRawData[LI]),
      LOut, False, LCharsWritten));
    CheckEquals(FCrockfordEncodedData[LI], CharsToString(LOut, LCharsWritten));
  end;
end;

procedure TTestBase32.Test_Crockford_TryDecode_ReturnsExpectedValues;
var
  LI, LBytesWritten: Int32;
  LOut: TSimpleBaseLibByteArray;
begin
  for LI := Low(FCrockfordEncodedData) to High(FCrockfordEncodedData) do
  begin
    SetLength(LOut, TBase32.Crockford.GetSafeByteCountForDecoding(FCrockfordEncodedData[LI]));
    CheckTrue(TBase32.Crockford.TryDecode(FCrockfordEncodedData[LI], LOut, LBytesWritten));
    CheckEquals(FCrockfordRawData[LI],
      TEncoding.ASCII.GetString(System.Copy(LOut, 0, LBytesWritten)));
  end;
end;

procedure TTestBase32.Test_Crockford_TryDecode_ZeroBuffer_ReturnsFalse;
var
  LBytesWritten: Int32;
  LOut: TSimpleBaseLibByteArray;
begin
  SetLength(LOut, 0);
  CheckFalse(TBase32.Crockford.TryDecode('test', LOut, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase32.Test_Crockford_Decode_InvalidInput_Throws;
begin
  try
    TBase32.Crockford.Decode('[];'',m.');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_Crockford_Decode_CrockfordChars_DecodedCorrectly;
var
  LExpected, LActual: TSimpleBaseLibByteArray;
begin
  LExpected := TBase32.Crockford.Decode('000');
  LActual := TBase32.Crockford.Decode('O0o');
  CheckTrue(AreEqual(LExpected, LActual));

  LExpected := TBase32.Crockford.Decode('111');
  LActual := TBase32.Crockford.Decode('Ll1');
  CheckTrue(AreEqual(LExpected, LActual));

  LExpected := TBase32.Crockford.Decode('111');
  LActual := TBase32.Crockford.Decode('I1i');
  CheckTrue(AreEqual(LExpected, LActual));
end;

procedure TTestBase32.Test_Crockford_Encode_ZeroPrefixData_ReturnsExpectedValues;
begin
  CheckEquals('00', TBase32.Crockford.Encode(TSimpleBaseLibByteArray.Create($00), False));
  CheckEquals('0000', TBase32.Crockford.Encode(TSimpleBaseLibByteArray.Create($00, $00), False));
  CheckEquals('000G', TBase32.Crockford.Encode(TSimpleBaseLibByteArray.Create($00, $01), False));
  CheckEquals('0000000', TBase32.Crockford.Encode(
    TSimpleBaseLibByteArray.Create($00, $00, $00, $00), False));
end;

procedure TTestBase32.Test_Crockford_Decode_ZeroPrefixData_ReturnsExpectedValues;
begin
  CheckTrue(AreEqual(TSimpleBaseLibByteArray.Create($00), TBase32.Crockford.Decode('00')));
  CheckTrue(AreEqual(TSimpleBaseLibByteArray.Create($00, $00), TBase32.Crockford.Decode('0000')));
  CheckTrue(AreEqual(TSimpleBaseLibByteArray.Create($00, $01), TBase32.Crockford.Decode('000G')));
  CheckTrue(AreEqual(TSimpleBaseLibByteArray.Create($00, $00, $00, $00),
    TBase32.Crockford.Decode('0000000')));
end;

procedure TTestBase32.Test_ExtendedHex_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FExtendedHexRawData) to High(FExtendedHexRawData) do
  begin
    CheckEquals(FExtendedHexEncodedData[LI],
      TBase32.ExtendedHex.Encode(TEncoding.ASCII.GetBytes(FExtendedHexRawData[LI]), True));
  end;
end;

procedure TTestBase32.Test_ExtendedHex_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FExtendedHexEncodedData) to High(FExtendedHexEncodedData) do
  begin
    CheckEquals(FExtendedHexRawData[LI],
      TEncoding.ASCII.GetString(TBase32.ExtendedHex.Decode(FExtendedHexEncodedData[LI])));
    CheckEquals(FExtendedHexRawData[LI],
      TEncoding.ASCII.GetString(TBase32.ExtendedHex.Decode(LowerCase(FExtendedHexEncodedData[LI]))));
  end;
end;

procedure TTestBase32.Test_ExtendedHex_Encode_Stream_ReturnsExpectedValues;
var
  LI: Int32;
  LInput: TMemoryStream;
  LOutput: TStringBuilder;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FExtendedHexRawData) to High(FExtendedHexRawData) do
  begin
    LInput := TMemoryStream.Create;
    LOutput := TStringBuilder.Create;
    try
      LBytes := TEncoding.ASCII.GetBytes(FExtendedHexRawData[LI]);
      if Length(LBytes) > 0 then
      begin
        LInput.WriteBuffer(LBytes[0], Length(LBytes));
      end;
      LInput.Position := 0;
      TBase32.ExtendedHex.Encode(LInput, LOutput, True);
      CheckEquals(FExtendedHexEncodedData[LI], LOutput.ToString);
    finally
      LOutput.Free;
      LInput.Free;
    end;
  end;
end;

procedure TTestBase32.Test_ExtendedHex_Decode_Stream_ReturnsExpectedValues;
var
  LI: Int32;
  LInput: TStringBuilder;
  LOutput: TMemoryStream;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FExtendedHexEncodedData) to High(FExtendedHexEncodedData) do
  begin
    LInput := TStringBuilder.Create(FExtendedHexEncodedData[LI]);
    LOutput := TMemoryStream.Create;
    try
      TBase32.ExtendedHex.Decode(LInput, LOutput);
      SetLength(LBytes, LOutput.Size);
      if LOutput.Size > 0 then
      begin
        LOutput.Position := 0;
        LOutput.ReadBuffer(LBytes[0], LOutput.Size);
      end;
      CheckEquals(FExtendedHexRawData[LI], TEncoding.ASCII.GetString(LBytes));
    finally
      LOutput.Free;
      LInput.Free;
    end;
  end;
end;

procedure TTestBase32.Test_ExtendedHex_Encode_NilBytes_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase32.ExtendedHex.Encode(LBytes, False));
end;

procedure TTestBase32.Test_ExtendedHex_Decode_InvalidInput_Throws;
begin
  try
    TBase32.ExtendedHex.Decode('!@#!#@!#@#!@');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase32.ExtendedHex.Decode('||||');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_ZBase32_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FZBase32RawData) to High(FZBase32RawData) do
  begin
    CheckEquals(FZBase32EncodedData[LI],
      TBase32.ZBase32.Encode(TEncoding.ASCII.GetBytes(FZBase32RawData[LI]), False));
  end;
end;

procedure TTestBase32.Test_ZBase32_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FZBase32EncodedData) to High(FZBase32EncodedData) do
  begin
    CheckEquals(FZBase32RawData[LI], TEncoding.ASCII.GetString(TBase32.ZBase32.Decode(FZBase32EncodedData[LI])));
    CheckEquals(FZBase32RawData[LI],
      TEncoding.ASCII.GetString(TBase32.ZBase32.Decode(LowerCase(FZBase32EncodedData[LI]))));
  end;
end;

procedure TTestBase32.Test_ZBase32_Encode_NilBytes_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase32.ZBase32.Encode(LBytes, False));
end;

procedure TTestBase32.Test_ZBase32_Decode_InvalidInput_Throws;
begin
  try
    TBase32.ZBase32.Decode('[];'',m.');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_Bech32_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FBech32RawData) to High(FBech32RawData) do
  begin
    CheckEquals(FBech32EncodedData[LI],
      TBase32.Bech32.Encode(TEncoding.ASCII.GetBytes(FBech32RawData[LI]), True));
  end;
end;

procedure TTestBase32.Test_Bech32_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FBech32EncodedData) to High(FBech32EncodedData) do
  begin
    CheckEquals(FBech32RawData[LI], TEncoding.ASCII.GetString(TBase32.Bech32.Decode(FBech32EncodedData[LI])));
    CheckEquals(FBech32RawData[LI],
      TEncoding.ASCII.GetString(TBase32.Bech32.Decode(LowerCase(FBech32EncodedData[LI]))));
  end;
end;

procedure TTestBase32.Test_Bech32_Encode_NilBytes_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase32.Bech32.Encode(LBytes, True));
end;

procedure TTestBase32.Test_Bech32_Decode_InvalidInput_Throws;
begin
  try
    TBase32.Bech32.Decode('[];'',m.');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_FileCoin_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FFileCoinRawData) to High(FFileCoinRawData) do
  begin
    CheckEquals(FFileCoinEncodedData[LI],
      TBase32.FileCoin.Encode(TEncoding.ASCII.GetBytes(FFileCoinRawData[LI]), True));
  end;
end;

procedure TTestBase32.Test_FileCoin_Encode_Bytes_ReturnsExpectedValues;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := TSimpleBaseLibByteArray.Create(245, 202, 80, 149, 94, 201, 222, 50,
    17, 198, 138, 104, 32, 183, 131, 33, 139, 208, 203, 211, 197, 191, 92, 194);
  CheckEquals('6xffbfk6zhpdeeogrjucbn4degf5bs6tyw7vzqq', TBase32.FileCoin.Encode(LBytes, False));
end;

procedure TTestBase32.Test_FileCoin_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FFileCoinEncodedData) to High(FFileCoinEncodedData) do
  begin
    CheckEquals(FFileCoinRawData[LI],
      TEncoding.ASCII.GetString(TBase32.FileCoin.Decode(FFileCoinEncodedData[LI])));
    CheckEquals(FFileCoinRawData[LI],
      TEncoding.ASCII.GetString(TBase32.FileCoin.Decode(LowerCase(FFileCoinEncodedData[LI]))));
  end;
end;

procedure TTestBase32.Test_FileCoin_Encode_NilBytes_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase32.FileCoin.Encode(LBytes, True));
end;

procedure TTestBase32.Test_FileCoin_Decode_InvalidInput_Throws;
begin
  try
    TBase32.FileCoin.Decode('[];'',m.');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase32.Test_Geohash_Decode_SmokeTest;
var
  LExpected, LActual: TSimpleBaseLibByteArray;
begin
  LExpected := TSimpleBaseLibByteArray.Create($6F, $F0, $41);
  LActual := TBase32.Geohash.Decode('ezs42');
  CheckTrue(AreEqual(LExpected, LActual));
end;

procedure TTestBase32.Test_Geohash_Encode_SmokeTest;
begin
  CheckEquals('ezs42', TBase32.Geohash.Encode(TSimpleBaseLibByteArray.Create($6F, $F0, $41)));
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase32);
{$ELSE}
  RegisterTest(TTestBase32.Suite);
{$ENDIF FPC}

end.
