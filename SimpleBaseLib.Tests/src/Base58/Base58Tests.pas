unit Base58Tests;

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
  SbpSimpleBaseLibTypes,
  SbpICodingAlphabet,
  SbpBase58Alphabet,
  SbpBase58,
  SimpleBaseLibTestBase;

type
  TTestBase58 = class(TSimpleBaseLibTestCase)
  strict private
    FBitcoinHexData: TSimpleBaseLibStringArray;
    FBitcoinEncodedData: TSimpleBaseLibStringArray;
    FRippleHexData: TSimpleBaseLibStringArray;
    FRippleEncodedData: TSimpleBaseLibStringArray;
    FFlickrHexData: TSimpleBaseLibStringArray;
    FFlickrEncodedData: TSimpleBaseLibStringArray;
    FMoneroHexData: TSimpleBaseLibStringArray;
    FMoneroEncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Bitcoin_Encode_NullBuffer_ReturnsEmptyString;
    procedure Test_Bitcoin_Encode_EmptyBuffer_ReturnsEmptyString;
    procedure Test_Bitcoin_Decode_EmptyString_ReturnsEmptyBuffer;
    procedure Test_Bitcoin_TryDecode_EmptyString_ReturnsEmptyBuffer;
    procedure Test_Bitcoin_Encode_ReturnsExpectedResults;
    procedure Test_Bitcoin_TryEncode_ReturnsExpectedResults;
    procedure Test_Bitcoin_Decode_ReturnsExpectedResults;
    procedure Test_Bitcoin_TryDecode_ReturnsExpectedResults;
    procedure Test_Bitcoin_Decode_InvalidCharacter_Throws;
    procedure Test_Bitcoin_TryDecode_InvalidCharacter_ReturnsFalse;

    procedure Test_Ripple_Encode_NullBuffer_ReturnsEmptyString;
    procedure Test_Ripple_Encode_EmptyBuffer_ReturnsEmptyString;
    procedure Test_Ripple_Decode_EmptyString_ReturnsEmptyBuffer;
    procedure Test_Ripple_Encode_ReturnsExpectedResults;
    procedure Test_Ripple_TryEncode_ReturnsExpectedResults;
    procedure Test_Ripple_Decode_ReturnsExpectedResults;
    procedure Test_Ripple_Decode_InvalidCharacter_Throws;

    procedure Test_Flickr_Encode_NullBuffer_ReturnsEmptyString;
    procedure Test_Flickr_Encode_EmptyBuffer_ReturnsEmptyString;
    procedure Test_Flickr_Decode_EmptyString_ReturnsEmptyBuffer;
    procedure Test_Flickr_Encode_ReturnsExpectedResults;
    procedure Test_Flickr_TryEncode_ReturnsExpectedResults;
    procedure Test_Flickr_Decode_ReturnsExpectedResults;
    procedure Test_Flickr_Decode_InvalidCharacter_Throws;

    procedure Test_Monero_Encode_NullBuffer_ReturnsEmptyString;
    procedure Test_Monero_Encode_EmptyBuffer_ReturnsEmptyString;
    procedure Test_Monero_Decode_EmptyString_ReturnsEmptyBuffer;
    procedure Test_Monero_Encode_ReturnsExpectedResults;
    procedure Test_Monero_TryEncode_ReturnsExpectedResults;
    procedure Test_Monero_Decode_ReturnsExpectedResults;
    procedure Test_Monero_TryDecode_ReturnsExpectedResults;
    procedure Test_Monero_TryDecode_EmptyString_ReturnsTrueZeroBytes;
    procedure Test_Monero_Decode_InvalidCharacter_Throws;
    procedure Test_Monero_TryDecode_InvalidCharacter_ReturnsFalse;

    procedure Test_Alphabet_Ctor_InvalidLength_Throws;
    procedure Test_Alphabet_GetSafeCharCountForEncoding_Works;
  end;

implementation

procedure TTestBase58.SetUp;
begin
  inherited;

  FBitcoinHexData := TSimpleBaseLibStringArray.Create(
    '0001',
    '0000010203',
    '009C1CA2CBA6422D3988C735BB82B5C880B0441856B9B0910F',
    '000860C220EBBAF591D40F51994C4E2D9C9D88168C33E761F6',
    '00313E1F905554E7AE2580CD36F86D0C8088382C9E1951C44D010203',
    '0000000000',
    '1111111111',
    'FFEEDDCCBBAA',
    '00',
    '21',
    '000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0F',
    '0000000000000000000000000000000000000000000000000000'
  );
  FBitcoinEncodedData := TSimpleBaseLibStringArray.Create(
    '12',
    '11Ldp',
    '1FESiat4YpNeoYhW3Lp7sW1T6WydcW7vcE',
    '1mJKRNca45GU2JQuHZqZjHFNktaqAs7gh',
    '17f1hgANcLE5bQhAGRgnBaLTTs23rK4VGVKuFQ',
    '11111',
    '2vgLdhi',
    '3CSwN61PP',
    '1',
    'a',
    '1thX6LZfHDZZKUs92febWaf4WJZnsKRiVwJusXxB7L',
    '11111111111111111111111111'
  );

  FRippleHexData := TSimpleBaseLibStringArray.Create(
    '0000010203',
    '009C1CA2CBA6422D3988C735BB82B5C880B0441856B9B0910F',
    '000860C220EBBAF591D40F51994C4E2D9C9D88168C33E761F6',
    '00313E1F905554E7AE2580CD36F86D0C8088382C9E1951C44D010203',
    '0000000000',
    '1111111111',
    'FFEEDDCCBBAA',
    '00',
    '21'
  );
  FRippleEncodedData := TSimpleBaseLibStringArray.Create(
    'rrLdF',
    'rENS52thYF4eoY6WsLFf1WrTaWydcWfvcN',
    'rmJKR4c2hnG7pJQuHZqZjHE4kt2qw1fg6',
    'rfCr6gw4cLNnbQ6wGRg8B2LTT1psiKhVGVKuEQ',
    'rrrrr',
    'pvgLd65',
    'sUSA4arPP',
    'r',
    '2'
  );

  FFlickrHexData := TSimpleBaseLibStringArray.Create(
    '0000010203',
    '009C1CA2CBA6422D3988C735BB82B5C880B0441856B9B0910F',
    '000860C220EBBAF591D40F51994C4E2D9C9D88168C33E761F6',
    '00313E1F905554E7AE2580CD36F86D0C8088382C9E1951C44D010203',
    '0000000000',
    '1111111111',
    'FFEEDDCCBBAA',
    '00',
    '21'
  );
  FFlickrEncodedData := TSimpleBaseLibStringArray.Create(
    '11kCP',
    '1ferHzT4xPnDNxGv3kP7Sv1s6vYCBv7VBe',
    '1LijqnBz45gt2ipUhyQyJhfnKTzQaS7FG',
    '17E1GFanBke5ApGagqFMbzkssS23Rj4ugujUfp',
    '11111',
    '2VFkCGH',
    '3crWn61oo',
    '1',
    'z'
  );

  FMoneroHexData := TSimpleBaseLibStringArray.Create(
    '00', '39', 'FF', '0000', '0039', '0100', 'FFFF', '000000', '000039',
    '010000', 'FFFFFF', '00000039', 'FFFFFFFF', '0000000039', 'FFFFFFFFFF',
    '000000000039', 'FFFFFFFFFFFF', '00000000000039', 'FFFFFFFFFFFFFF',
    '0000000000000039', 'FFFFFFFFFFFFFFFF', '0000000000000000',
    '0000000000000001', '0000000000000008', '0000000000000009',
    '000000000000003A', '00FFFFFFFFFFFFFF', '06156013762879F7',
    '05E022BA374B2A00', '00', '0000', '000000', '00000000', '0000000000',
    '000000000000', '00000000000000', '0000000000000000', '000000000000000000',
    '00000000000000000000', '0000000000000000000000', '000000000000000000000000',
    '00000000000000000000000000', '0000000000000000000000000000',
    '000000000000000000000000000000', '00000000000000000000000000000000',
    '06156013762879F7FFFFFFFFFF'
  );
  FMoneroEncodedData := TSimpleBaseLibStringArray.Create(
    '11', '1z', '5Q', '111', '11z', '15R', 'LUv', '11111', '1111z',
    '11LUw', '2UzHL', '11111z', '7YXq9G', '111111z', 'VtB5VXc',
    '11111111z', '3CUsUpv9t', '111111111z', 'Ahg1opVcGW',
    '1111111111z', 'jpXCZedGfVQ', '11111111111', '11111111112',
    '11111111119', '1111111111A', '11111111121', '1Ahg1opVcGW',
    '22222222222', '1z111111111', '11', '111', '11111', '111111',
    '1111111', '111111111', '1111111111', '11111111111', '1111111111111',
    '11111111111111', '1111111111111111', '11111111111111111',
    '111111111111111111', '11111111111111111111', '111111111111111111111',
    '1111111111111111111111', '22222222222VtB5VXc'
  );
end;

procedure TTestBase58.TearDown;
begin
  inherited;
end;

procedure TTestBase58.Test_Bitcoin_Encode_NullBuffer_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase58.Bitcoin.Encode(LBytes));
end;

procedure TTestBase58.Test_Bitcoin_Encode_EmptyBuffer_ReturnsEmptyString;
begin
  CheckEquals('', TBase58.Bitcoin.Encode(TSimpleBaseLibByteArray.Create()));
end;

procedure TTestBase58.Test_Bitcoin_Decode_EmptyString_ReturnsEmptyBuffer;
var
  LResult: TSimpleBaseLibByteArray;
begin
  LResult := TBase58.Bitcoin.Decode('');
  CheckEquals(0, Length(LResult));
end;

procedure TTestBase58.Test_Bitcoin_TryDecode_EmptyString_ReturnsEmptyBuffer;
var
  LBytesWritten: Int32;
  LBuffer: TSimpleBaseLibByteArray;
begin
  SetLength(LBuffer, 1);
  CheckTrue(TBase58.Bitcoin.TryDecode('', LBuffer, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase58.Test_Bitcoin_Encode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FBitcoinHexData) to High(FBitcoinHexData) do
  begin
    CheckEquals(FBitcoinEncodedData[LI], TBase58.Bitcoin.Encode(HexToBytes(FBitcoinHexData[LI])));
  end;
end;

procedure TTestBase58.Test_Bitcoin_TryEncode_ReturnsExpectedResults;
var
  LI, LCharsWritten: Int32;
  LIn: TSimpleBaseLibByteArray;
  LOut: TSimpleBaseLibCharArray;
begin
  for LI := Low(FBitcoinHexData) to High(FBitcoinHexData) do
  begin
    LIn := HexToBytes(FBitcoinHexData[LI]);
    SetLength(LOut, TBase58.Bitcoin.GetSafeCharCountForEncoding(LIn));
    CheckTrue(TBase58.Bitcoin.TryEncode(LIn, LOut, LCharsWritten));
    CheckEquals(FBitcoinEncodedData[LI], CharsToString(LOut, LCharsWritten));
  end;
end;

procedure TTestBase58.Test_Bitcoin_Decode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FBitcoinEncodedData) to High(FBitcoinEncodedData) do
  begin
    CheckEquals(FBitcoinHexData[LI], BytesToHex(TBase58.Bitcoin.Decode(FBitcoinEncodedData[LI])));
  end;
end;

procedure TTestBase58.Test_Bitcoin_TryDecode_ReturnsExpectedResults;
var
  LI, LBytesWritten: Int32;
  LOut: TSimpleBaseLibByteArray;
begin
  for LI := Low(FBitcoinEncodedData) to High(FBitcoinEncodedData) do
  begin
    SetLength(LOut, TBase58.Bitcoin.GetSafeByteCountForDecoding(FBitcoinEncodedData[LI]));
    CheckTrue(TBase58.Bitcoin.TryDecode(FBitcoinEncodedData[LI], LOut, LBytesWritten));
    CheckEquals(FBitcoinHexData[LI], BytesToHex(System.Copy(LOut, 0, LBytesWritten)));
  end;
end;

procedure TTestBase58.Test_Bitcoin_Decode_InvalidCharacter_Throws;
begin
  try
    TBase58.Bitcoin.Decode('?');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase58.Test_Bitcoin_TryDecode_InvalidCharacter_ReturnsFalse;
var
  LOut: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOut, 10);
  CheckFalse(TBase58.Bitcoin.TryDecode('?', LOut, LBytesWritten));
end;

procedure TTestBase58.Test_Ripple_Encode_NullBuffer_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase58.Ripple.Encode(LBytes));
end;

procedure TTestBase58.Test_Ripple_Encode_EmptyBuffer_ReturnsEmptyString;
begin
  CheckEquals('', TBase58.Ripple.Encode(TSimpleBaseLibByteArray.Create()));
end;

procedure TTestBase58.Test_Ripple_Decode_EmptyString_ReturnsEmptyBuffer;
var
  LResult: TSimpleBaseLibByteArray;
begin
  LResult := TBase58.Ripple.Decode('');
  CheckEquals(0, Length(LResult));
end;

procedure TTestBase58.Test_Ripple_Encode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FRippleHexData) to High(FRippleHexData) do
  begin
    CheckEquals(FRippleEncodedData[LI], TBase58.Ripple.Encode(HexToBytes(FRippleHexData[LI])));
  end;
end;

procedure TTestBase58.Test_Ripple_TryEncode_ReturnsExpectedResults;
var
  LI, LCharsWritten: Int32;
  LIn: TSimpleBaseLibByteArray;
  LOut: TSimpleBaseLibCharArray;
begin
  for LI := Low(FRippleHexData) to High(FRippleHexData) do
  begin
    LIn := HexToBytes(FRippleHexData[LI]);
    SetLength(LOut, TBase58.Ripple.GetSafeCharCountForEncoding(LIn));
    CheckTrue(TBase58.Ripple.TryEncode(LIn, LOut, LCharsWritten));
    CheckEquals(FRippleEncodedData[LI], CharsToString(LOut, LCharsWritten));
  end;
end;

procedure TTestBase58.Test_Ripple_Decode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FRippleEncodedData) to High(FRippleEncodedData) do
  begin
    CheckEquals(FRippleHexData[LI], BytesToHex(TBase58.Ripple.Decode(FRippleEncodedData[LI])));
  end;
end;

procedure TTestBase58.Test_Ripple_Decode_InvalidCharacter_Throws;
begin
  try
    TBase58.Ripple.Decode('?');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase58.Test_Flickr_Encode_NullBuffer_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase58.Flickr.Encode(LBytes));
end;

procedure TTestBase58.Test_Flickr_Encode_EmptyBuffer_ReturnsEmptyString;
begin
  CheckEquals('', TBase58.Flickr.Encode(TSimpleBaseLibByteArray.Create()));
end;

procedure TTestBase58.Test_Flickr_Decode_EmptyString_ReturnsEmptyBuffer;
var
  LResult: TSimpleBaseLibByteArray;
begin
  LResult := TBase58.Flickr.Decode('');
  CheckEquals(0, Length(LResult));
end;

procedure TTestBase58.Test_Flickr_Encode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FFlickrHexData) to High(FFlickrHexData) do
  begin
    CheckEquals(FFlickrEncodedData[LI], TBase58.Flickr.Encode(HexToBytes(FFlickrHexData[LI])));
  end;
end;

procedure TTestBase58.Test_Flickr_TryEncode_ReturnsExpectedResults;
var
  LI, LCharsWritten: Int32;
  LIn: TSimpleBaseLibByteArray;
  LOut: TSimpleBaseLibCharArray;
begin
  for LI := Low(FFlickrHexData) to High(FFlickrHexData) do
  begin
    LIn := HexToBytes(FFlickrHexData[LI]);
    SetLength(LOut, TBase58.Flickr.GetSafeCharCountForEncoding(LIn));
    CheckTrue(TBase58.Flickr.TryEncode(LIn, LOut, LCharsWritten));
    CheckEquals(FFlickrEncodedData[LI], CharsToString(LOut, LCharsWritten));
  end;
end;

procedure TTestBase58.Test_Flickr_Decode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FFlickrEncodedData) to High(FFlickrEncodedData) do
  begin
    CheckEquals(FFlickrHexData[LI], BytesToHex(TBase58.Flickr.Decode(FFlickrEncodedData[LI])));
  end;
end;

procedure TTestBase58.Test_Flickr_Decode_InvalidCharacter_Throws;
begin
  try
    TBase58.Flickr.Decode('?');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase58.Test_Monero_Encode_NullBuffer_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase58.Monero.Encode(LBytes));
end;

procedure TTestBase58.Test_Monero_Encode_EmptyBuffer_ReturnsEmptyString;
begin
  CheckEquals('', TBase58.Monero.Encode(TSimpleBaseLibByteArray.Create()));
end;

procedure TTestBase58.Test_Monero_Decode_EmptyString_ReturnsEmptyBuffer;
var
  LResult: TSimpleBaseLibByteArray;
begin
  LResult := TBase58.Monero.Decode('');
  CheckEquals(0, Length(LResult));
end;

procedure TTestBase58.Test_Monero_Encode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FMoneroHexData) to High(FMoneroHexData) do
  begin
    CheckEquals(FMoneroEncodedData[LI], TBase58.Monero.Encode(HexToBytes(FMoneroHexData[LI])));
  end;
end;

procedure TTestBase58.Test_Monero_TryEncode_ReturnsExpectedResults;
var
  LI, LCharsWritten: Int32;
  LInput: TSimpleBaseLibByteArray;
  LOut: TSimpleBaseLibCharArray;
begin
  for LI := Low(FMoneroHexData) to High(FMoneroHexData) do
  begin
    LInput := HexToBytes(FMoneroHexData[LI]);
    SetLength(LOut, TBase58.Monero.GetSafeCharCountForEncoding(LInput));
    CheckTrue(TBase58.Monero.TryEncode(LInput, LOut, LCharsWritten));
    CheckEquals(FMoneroEncodedData[LI], CharsToString(LOut, LCharsWritten));
  end;
end;

procedure TTestBase58.Test_Monero_Decode_ReturnsExpectedResults;
var
  LI: Int32;
begin
  for LI := Low(FMoneroEncodedData) to High(FMoneroEncodedData) do
  begin
    CheckEquals(FMoneroHexData[LI], BytesToHex(TBase58.Monero.Decode(FMoneroEncodedData[LI])));
  end;
end;

procedure TTestBase58.Test_Monero_TryDecode_ReturnsExpectedResults;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FMoneroEncodedData) to High(FMoneroEncodedData) do
  begin
    SetLength(LOutput, TBase58.Monero.GetSafeByteCountForDecoding(FMoneroEncodedData[LI]));
    CheckTrue(TBase58.Monero.TryDecode(FMoneroEncodedData[LI], LOutput, LBytesWritten));
    CheckEquals(FMoneroHexData[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
  end;
end;

procedure TTestBase58.Test_Monero_TryDecode_EmptyString_ReturnsTrueZeroBytes;
var
  LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 1);
  CheckTrue(TBase58.Monero.TryDecode('', LOutput, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase58.Test_Monero_Decode_InvalidCharacter_Throws;
begin
  try
    TBase58.Monero.Decode('?');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase58.Test_Monero_TryDecode_InvalidCharacter_ReturnsFalse;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 10);
  CheckFalse(TBase58.Monero.TryDecode('?', LOutput, LBytesWritten));
end;

procedure TTestBase58.Test_Alphabet_Ctor_InvalidLength_Throws;
var
  LAlphabet: ICodingAlphabet;
begin
  LAlphabet := nil;
  try
    LAlphabet := TBase58Alphabet.Create('123');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
  CheckTrue(LAlphabet = nil);
end;

procedure TTestBase58.Test_Alphabet_GetSafeCharCountForEncoding_Works;
var
  LInput: TSimpleBaseLibByteArray;
begin
  LInput := TSimpleBaseLibByteArray.Create(0, 0, 0, 0, 1, 2, 3, 4);
  CheckEquals(10, TBase58.Bitcoin.GetSafeCharCountForEncoding(LInput));
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase58);
{$ELSE}
  RegisterTest(TTestBase58.Suite);
{$ENDIF FPC}

end.
