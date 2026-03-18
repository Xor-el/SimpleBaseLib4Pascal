unit Base85Tests;

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
  SbpBase85,
  SimpleBaseLibTestBase;

type
  TTestBase85 = class(TSimpleBaseLibTestCase)
  strict private
    FAsciiDecodedHexData: TSimpleBaseLibStringArray;
    FAsciiEncodedData: TSimpleBaseLibStringArray;
    FZ85DecodedHexData: TSimpleBaseLibStringArray;
    FZ85EncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Ascii85_Encode_ReturnsExpectedValues;
    procedure Test_Ascii85_TryEncode_ReturnsExpectedValues;
    procedure Test_Ascii85_Decode_ReturnsExpectedValues;
    procedure Test_Ascii85_TryDecode_ReturnsExpectedValues;
    procedure Test_Ascii85_Encode_Stream_ReturnsExpectedValues;
    procedure Test_Ascii85_Decode_Stream_ReturnsExpectedValues;
    procedure Test_Ascii85_Decode_Whitespace_IsIgnored;
    procedure Test_Ascii85_Decode_InvalidShortcut_Throws;
    procedure Test_Ascii85_Decode_InvalidCharacter_Throws;
    procedure Test_Ascii85_TryDecode_InvalidCharacter_ReturnsFalse;
    procedure Test_Ascii85_Encode_NullBuffer_ReturnsEmptyString;
    procedure Test_Ascii85_Encode_UnevenBuffer_DoesNotThrow;
    procedure Test_Ascii85_Decode_UnevenText_DoesNotThrow;

    procedure Test_Z85_Encode_ReturnsExpectedValues;
    procedure Test_Z85_Decode_ReturnsExpectedValues;
    procedure Test_Z85_Encode_NullBuffer_ReturnsEmptyString;

    procedure Test_Alphabet_GetSafeCharCountForEncoding_Buffer_Works;
    procedure Test_Alphabet_GetSafeCharCountForEncoding_Length_Works;
    procedure Test_Alphabet_HasShortcut_Works;
    procedure Test_Instances_AreIsolated;
  end;

implementation

procedure TTestBase85.SetUp;
begin
  inherited;

  FAsciiDecodedHexData := TSimpleBaseLibStringArray.Create(
    '',
    '00000000',
    '20202020',
    '4142434445',
    '864FD26FB559F75B',
    '112233',
    '4D616E20'
  );
  FAsciiEncodedData := TSimpleBaseLibStringArray.Create(
    '',
    'z',
    'y',
    '5sdq,70',
    'L/669[9<6.',
    '&L''"',
    '9jqo^'
  );

  FZ85DecodedHexData := TSimpleBaseLibStringArray.Create(
    '',
    '864FD26FB559F75B',
    '11',
    '1122',
    '112233',
    '11223344',
    '1122334455',
    '00000000',
    '20202020'
  );
  FZ85EncodedData := TSimpleBaseLibStringArray.Create(
    '',
    'HelloWorld',
    '5D',
    '5H4',
    '5H61',
    '5H620',
    '5H620rr',
    '00000',
    'arR^H'
  );
end;

procedure TTestBase85.TearDown;
begin
  inherited;
end;

procedure TTestBase85.Test_Ascii85_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FAsciiDecodedHexData) to High(FAsciiDecodedHexData) do
  begin
    CheckEquals(FAsciiEncodedData[LI], TBase85.Ascii85.Encode(HexToBytes(FAsciiDecodedHexData[LI])),
      Format('Ascii85 encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Ascii85_TryEncode_ReturnsExpectedValues;
var
  LI, LCharsWritten: Int32;
  LInput: TSimpleBaseLibByteArray;
  LOutput: TSimpleBaseLibCharArray;
begin
  for LI := Low(FAsciiDecodedHexData) to High(FAsciiDecodedHexData) do
  begin
    LInput := HexToBytes(FAsciiDecodedHexData[LI]);
    SetLength(LOutput, TBase85.Ascii85.GetSafeCharCountForEncoding(LInput));
    CheckTrue(TBase85.Ascii85.TryEncode(LInput, LOutput, LCharsWritten),
      Format('Ascii85 TryEncode failed at index %d', [LI]));
    CheckEquals(FAsciiEncodedData[LI], CharsToString(LOutput, LCharsWritten),
      Format('Ascii85 TryEncode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Ascii85_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FAsciiEncodedData) to High(FAsciiEncodedData) do
  begin
    CheckEquals(FAsciiDecodedHexData[LI], BytesToHex(TBase85.Ascii85.Decode(FAsciiEncodedData[LI])),
      Format('Ascii85 decode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Ascii85_TryDecode_ReturnsExpectedValues;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FAsciiEncodedData) to High(FAsciiEncodedData) do
  begin
    SetLength(LOutput, TBase85.Ascii85.GetSafeByteCountForDecoding(FAsciiEncodedData[LI]));
    CheckTrue(TBase85.Ascii85.TryDecode(FAsciiEncodedData[LI], LOutput, LBytesWritten),
      Format('Ascii85 TryDecode failed at index %d', [LI]));
    CheckEquals(FAsciiDecodedHexData[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)),
      Format('Ascii85 TryDecode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Ascii85_Encode_Stream_ReturnsExpectedValues;
var
  LI: Int32;
  LInput: TMemoryStream;
  LOutput: TStringBuilder;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FAsciiDecodedHexData) to High(FAsciiDecodedHexData) do
  begin
    LInput := TMemoryStream.Create;
    LOutput := TStringBuilder.Create;
    try
      LBytes := HexToBytes(FAsciiDecodedHexData[LI]);
      if Length(LBytes) > 0 then
      begin
        LInput.WriteBuffer(LBytes[0], Length(LBytes));
      end;
      LInput.Position := 0;
      TBase85.Ascii85.Encode(LInput, LOutput);
      CheckEquals(FAsciiEncodedData[LI], LOutput.ToString,
        Format('Ascii85 stream encode mismatch at index %d', [LI]));
    finally
      LOutput.Free;
      LInput.Free;
    end;
  end;
end;

procedure TTestBase85.Test_Ascii85_Decode_Stream_ReturnsExpectedValues;
var
  LI: Int32;
  LInput: TStringBuilder;
  LOutput: TMemoryStream;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FAsciiEncodedData) to High(FAsciiEncodedData) do
  begin
    LInput := TStringBuilder.Create(FAsciiEncodedData[LI]);
    LOutput := TMemoryStream.Create;
    try
      TBase85.Ascii85.Decode(LInput, LOutput);
      SetLength(LBytes, LOutput.Size);
      if LOutput.Size > 0 then
      begin
        LOutput.Position := 0;
        LOutput.ReadBuffer(LBytes[0], LOutput.Size);
      end;
      CheckEquals(FAsciiDecodedHexData[LI], BytesToHex(LBytes),
        Format('Ascii85 stream decode mismatch at index %d', [LI]));
    finally
      LOutput.Free;
      LInput.Free;
    end;
  end;
end;

procedure TTestBase85.Test_Ascii85_Decode_Whitespace_IsIgnored;
var
  LI, LJ: Int32;
  LSpacedInput: String;
begin
  for LI := Low(FAsciiEncodedData) to High(FAsciiEncodedData) do
  begin
    LSpacedInput := '';
    for LJ := 1 to Length(FAsciiEncodedData[LI]) do
    begin
      LSpacedInput := LSpacedInput + '  ' + FAsciiEncodedData[LI][LJ];
    end;
    LSpacedInput := LSpacedInput + ' ';
    CheckEquals(FAsciiDecodedHexData[LI], BytesToHex(TBase85.Ascii85.Decode(LSpacedInput)),
      Format('Ascii85 whitespace decode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Ascii85_Decode_InvalidShortcut_Throws;
begin
  try
    TBase85.Ascii85.Decode('9zjqo');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase85.Test_Ascii85_Decode_InvalidCharacter_Throws;
begin
  try
    TBase85.Ascii85.Decode('~!@#()(');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase85.Test_Ascii85_TryDecode_InvalidCharacter_ReturnsFalse;
var
  LBuffer: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LBuffer, 50);
  CheckFalse(TBase85.Ascii85.TryDecode('{{{{{{{', LBuffer, LBytesWritten));
end;

procedure TTestBase85.Test_Ascii85_Encode_NullBuffer_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase85.Ascii85.Encode(LBytes));
end;

procedure TTestBase85.Test_Ascii85_Encode_UnevenBuffer_DoesNotThrow;
begin
  try
    TBase85.Ascii85.Encode(TSimpleBaseLibByteArray.Create(0, 0, 0));
  except
    on E: Exception do
    begin
      Fail('Unexpected exception: ' + E.Message);
    end;
  end;
end;

procedure TTestBase85.Test_Ascii85_Decode_UnevenText_DoesNotThrow;
begin
  try
    TBase85.Ascii85.Decode('hebe');
  except
    on E: Exception do
    begin
      Fail('Unexpected exception: ' + E.Message);
    end;
  end;
end;

procedure TTestBase85.Test_Z85_Encode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FZ85DecodedHexData) to High(FZ85DecodedHexData) do
  begin
    CheckEquals(FZ85EncodedData[LI], TBase85.Z85.Encode(HexToBytes(FZ85DecodedHexData[LI])),
      Format('Z85 encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Z85_Decode_ReturnsExpectedValues;
var
  LI: Int32;
begin
  for LI := Low(FZ85EncodedData) to High(FZ85EncodedData) do
  begin
    CheckEquals(FZ85DecodedHexData[LI], BytesToHex(TBase85.Z85.Decode(FZ85EncodedData[LI])),
      Format('Z85 decode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Z85_Encode_NullBuffer_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase85.Z85.Encode(LBytes));
end;

procedure TTestBase85.Test_Alphabet_GetSafeCharCountForEncoding_Buffer_Works;
begin
  CheckEquals(8, TBase85.Ascii85.GetSafeCharCountForEncoding(
    TSimpleBaseLibByteArray.Create(0, 1, 2, 3)));
end;

procedure TTestBase85.Test_Alphabet_GetSafeCharCountForEncoding_Length_Works;
const
  CInputLen: array [0 .. 6] of Int32 = (0, 1, 2, 3, 4, 5, 8);
  CExpected: array [0 .. 6] of Int32 = (0, 5, 6, 7, 8, 10, 13);
var
  LI: Int32;
  LBuffer: TSimpleBaseLibByteArray;
begin
  for LI := Low(CInputLen) to High(CInputLen) do
  begin
    SetLength(LBuffer, CInputLen[LI]);
    CheckEquals(CExpected[LI], TBase85.Ascii85.GetSafeCharCountForEncoding(LBuffer),
      Format('GetSafeCharCount mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase85.Test_Alphabet_HasShortcut_Works;
begin
  CheckTrue(TBase85.Ascii85.Alphabet.HasShortcut);
  CheckFalse(TBase85.Z85.Alphabet.HasShortcut);
end;

procedure TTestBase85.Test_Instances_AreIsolated;
var
  LInput: TSimpleBaseLibByteArray;
begin
  LInput := HexToBytes('864FD26FB559F75B');
  AssertCodersAreIsolated(
    TBase85.Ascii85,
    TBase85.Z85,
    LInput,
    'Base85.Ascii85',
    'Base85.Z85',
    True
  );
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase85);
{$ELSE}
  RegisterTest(TTestBase85.Suite);
{$ENDIF FPC}

end.
