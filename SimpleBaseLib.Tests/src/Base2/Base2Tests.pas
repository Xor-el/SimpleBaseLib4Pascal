unit Base2Tests;

{$IFDEF FPC}
{$MODE DELPHI}
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
  SbpBase2,
  SimpleBaseLibTestBase;

type
  TTestBase2 = class(TSimpleBaseLibTestCase)
  strict private
    FDecodedHexData: TSimpleBaseLibStringArray;
    FEncodedData: TSimpleBaseLibStringArray;
    FNonCanonicalInput: TSimpleBaseLibStringArray;
    FEdgeCaseDecodedHexData: TSimpleBaseLibStringArray;
    FEdgeCaseEncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_EncodesCorrectly;
    procedure Test_Decode_DecodesCorrectly;
    procedure Test_Decode_NonCanonicalInput_Throws;
    procedure Test_TryEncode_ValidInput_ReturnsExpectedValues;
    procedure Test_TryEncode_EdgeCases_ReturnsExpectedValues;
    procedure Test_TryEncode_EmptyInput_ReturnsTrue;
    procedure Test_TryEncode_InsufficientOutputBuffer_ReturnsFalse;
    procedure Test_TryDecode_ValidInput_ReturnsExpectedValues;
    procedure Test_TryDecode_EdgeCases_ReturnsExpectedValues;
    procedure Test_TryDecode_EmptyInput_ReturnsTrue;
    procedure Test_TryDecode_NonCanonicalInput_ReturnsFalse;
    procedure Test_TryDecode_InvalidCharacters_ReturnsFalse;
    procedure Test_TryDecode_InsufficientOutputBuffer_ReturnsFalse;
    procedure Test_GetSafeCharCountForEncoding_ValidInput_ReturnsCorrectCount;
    procedure Test_GetSafeCharCountForEncoding_VariousLengths_ReturnsCorrectCount;
    procedure Test_GetSafeByteCountForDecoding_ValidInput_ReturnsCorrectCount;
    procedure Test_GetSafeByteCountForDecoding_VariousLengths_ReturnsCorrectCount;
    procedure Test_Encode_Stream_ReturnsExpectedValues;
    procedure Test_Decode_Stream_ReturnsExpectedValues;
    procedure Test_Encode_NullInput_ReturnsEmptyString;
    procedure Test_Decode_InvalidCharacter_ThrowsArgumentException;
    procedure Test_Decode_InvalidCharacterMixed_ThrowsArgumentException;
    procedure Test_Decode_SpecialCharacters_ThrowsArgumentException;
    procedure Test_Constructor_CreatesValidInstance;
  end;

implementation

procedure TTestBase2.SetUp;
begin
  inherited;
  FDecodedHexData := TSimpleBaseLibStringArray.Create(
    '',
    '00010203',
    'FFFEFDFC',
    '00010203FFFEFD'
  );
  FEncodedData := TSimpleBaseLibStringArray.Create(
    '',
    '00000000000000010000001000000011',
    '11111111111111101111110111111100',
    '00000000000000010000001000000011111111111111111011111101'
  );

  FNonCanonicalInput := TSimpleBaseLibStringArray.Create('1', '10', '101', '1010', '101010', '1010101');

  FEdgeCaseDecodedHexData := TSimpleBaseLibStringArray.Create(
    '00',
    'FF',
    '0102',
    'AA55'
  );
  FEdgeCaseEncodedData := TSimpleBaseLibStringArray.Create(
    '00000000',
    '11111111',
    '0000000100000010',
    '1010101001010101'
  );
end;

procedure TTestBase2.TearDown;
begin
  inherited;
end;

procedure TTestBase2.Test_Encode_EncodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    CheckEquals(FEncodedData[LI], TBase2.Default.Encode(HexToBytes(FDecodedHexData[LI])));
  end;
end;

procedure TTestBase2.Test_Decode_DecodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    CheckEquals(FDecodedHexData[LI], BytesToHex(TBase2.Default.Decode(FEncodedData[LI])));
  end;
end;

procedure TTestBase2.Test_Decode_NonCanonicalInput_Throws;
var
  LI: Int32;
begin
  for LI := Low(FNonCanonicalInput) to High(FNonCanonicalInput) do
  begin
    try
      TBase2.Default.Decode(FNonCanonicalInput[LI]);
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  end;
end;

procedure TTestBase2.Test_TryEncode_ValidInput_ReturnsExpectedValues;
var
  LI, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    LInput := HexToBytes(FDecodedHexData[LI]);
    SetLength(LOutput, TBase2.Default.GetSafeCharCountForEncoding(LInput));
    CheckTrue(TBase2.Default.TryEncode(LInput, LOutput, LCharsWritten));
    CheckEquals(FEncodedData[LI], CharsToString(LOutput, LCharsWritten));
    CheckEquals(Length(FEncodedData[LI]), LCharsWritten);
  end;
end;

procedure TTestBase2.Test_TryEncode_EdgeCases_ReturnsExpectedValues;
var
  LI, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEdgeCaseDecodedHexData) to High(FEdgeCaseDecodedHexData) do
  begin
    LInput := HexToBytes(FEdgeCaseDecodedHexData[LI]);
    SetLength(LOutput, TBase2.Default.GetSafeCharCountForEncoding(LInput));
    CheckTrue(TBase2.Default.TryEncode(LInput, LOutput, LCharsWritten));
    CheckEquals(FEdgeCaseEncodedData[LI], CharsToString(LOutput, LCharsWritten));
    CheckEquals(Length(FEdgeCaseEncodedData[LI]), LCharsWritten);
  end;
end;

procedure TTestBase2.Test_TryEncode_EmptyInput_ReturnsTrue;
var
  LOutput: TSimpleBaseLibCharArray;
  LCharsWritten: Int32;
  LInput: TSimpleBaseLibByteArray;
begin
  LInput := nil;
  SetLength(LOutput, 1);
  CheckTrue(TBase2.Default.TryEncode(LInput, LOutput, LCharsWritten));
  CheckEquals(0, LCharsWritten);
end;

procedure TTestBase2.Test_TryEncode_InsufficientOutputBuffer_ReturnsFalse;
var
  LOutput: TSimpleBaseLibCharArray;
  LCharsWritten: Int32;
begin
  SetLength(LOutput, 7);
  CheckFalse(TBase2.Default.TryEncode(TSimpleBaseLibByteArray.Create($FF), LOutput, LCharsWritten));
  CheckEquals(0, LCharsWritten);
end;

procedure TTestBase2.Test_TryDecode_ValidInput_ReturnsExpectedValues;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    SetLength(LOutput, TBase2.Default.GetSafeByteCountForDecoding(FEncodedData[LI]));
    CheckTrue(TBase2.Default.TryDecode(FEncodedData[LI], LOutput, LBytesWritten));
    CheckEquals(FDecodedHexData[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
    CheckEquals(Length(HexToBytes(FDecodedHexData[LI])), LBytesWritten);
  end;
end;

procedure TTestBase2.Test_TryDecode_EdgeCases_ReturnsExpectedValues;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEdgeCaseEncodedData) to High(FEdgeCaseEncodedData) do
  begin
    SetLength(LOutput, TBase2.Default.GetSafeByteCountForDecoding(FEdgeCaseEncodedData[LI]));
    CheckTrue(TBase2.Default.TryDecode(FEdgeCaseEncodedData[LI], LOutput, LBytesWritten));
    CheckEquals(FEdgeCaseDecodedHexData[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
    CheckEquals(Length(HexToBytes(FEdgeCaseDecodedHexData[LI])), LBytesWritten);
  end;
end;

procedure TTestBase2.Test_TryDecode_EmptyInput_ReturnsTrue;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 1);
  CheckTrue(TBase2.Default.TryDecode('', LOutput, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase2.Test_TryDecode_NonCanonicalInput_ReturnsFalse;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 10);
  for LI := Low(FNonCanonicalInput) to High(FNonCanonicalInput) do
  begin
    CheckFalse(TBase2.Default.TryDecode(FNonCanonicalInput[LI], LOutput, LBytesWritten));
    CheckEquals(0, LBytesWritten);
  end;
end;

procedure TTestBase2.Test_TryDecode_InvalidCharacters_ReturnsFalse;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 10);
  CheckFalse(TBase2.Default.TryDecode('0102abcd', LOutput, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase2.Test_TryDecode_InsufficientOutputBuffer_ReturnsFalse;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 0);
  CheckFalse(TBase2.Default.TryDecode('00000001', LOutput, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase2.Test_GetSafeCharCountForEncoding_ValidInput_ReturnsCorrectCount;
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    LInput := HexToBytes(FDecodedHexData[LI]);
    CheckEquals(Length(FEncodedData[LI]), TBase2.Default.GetSafeCharCountForEncoding(LInput));
  end;
end;

procedure TTestBase2.Test_GetSafeCharCountForEncoding_VariousLengths_ReturnsCorrectCount;
const
  CInputLengths: array [0 .. 4] of Int32 = (0, 1, 2, 3, 10);
  CExpectedCharCounts: array [0 .. 4] of Int32 = (0, 8, 16, 24, 80);
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(CInputLengths) to High(CInputLengths) do
  begin
    SetLength(LInput, CInputLengths[LI]);
    CheckEquals(CExpectedCharCounts[LI], TBase2.Default.GetSafeCharCountForEncoding(LInput));
  end;
end;

procedure TTestBase2.Test_GetSafeByteCountForDecoding_ValidInput_ReturnsCorrectCount;
var
  LI: Int32;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    CheckEquals(Length(HexToBytes(FDecodedHexData[LI])),
      TBase2.Default.GetSafeByteCountForDecoding(FEncodedData[LI]));
  end;
end;

procedure TTestBase2.Test_GetSafeByteCountForDecoding_VariousLengths_ReturnsCorrectCount;
const
  CInputs: array [0 .. 3] of String = ('', '00000000', '0000000000000000', '000000000000000000000000');
  CExpectedByteCounts: array [0 .. 3] of Int32 = (0, 1, 2, 3);
var
  LI: Int32;
begin
  for LI := Low(CInputs) to High(CInputs) do
  begin
    CheckEquals(CExpectedByteCounts[LI], TBase2.Default.GetSafeByteCountForDecoding(CInputs[LI]));
  end;
end;

procedure TTestBase2.Test_Encode_Stream_ReturnsExpectedValues;
var
  LI: Int32;
  LInputStream: TMemoryStream;
  LWriter: TStringBuilder;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    LInput := HexToBytes(FDecodedHexData[LI]);
    LInputStream := TMemoryStream.Create;
    LWriter := TStringBuilder.Create;
    try
      if Length(LInput) > 0 then
      begin
        LInputStream.WriteBuffer(LInput[0], Length(LInput));
      end;
      LInputStream.Position := 0;
      TBase2.Default.Encode(LInputStream, LWriter);
      CheckEquals(FEncodedData[LI], LWriter.ToString);
    finally
      LWriter.Free;
      LInputStream.Free;
    end;
  end;
end;

procedure TTestBase2.Test_Decode_Stream_ReturnsExpectedValues;
var
  LI: Int32;
  LInputReader: TStringBuilder;
  LOutputStream: TMemoryStream;
  LActual: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    LInputReader := TStringBuilder.Create(FEncodedData[LI]);
    LOutputStream := TMemoryStream.Create;
    try
      TBase2.Default.Decode(LInputReader, LOutputStream);
      SetLength(LActual, LOutputStream.Size);
      if LOutputStream.Size > 0 then
      begin
        LOutputStream.Position := 0;
        LOutputStream.ReadBuffer(LActual[0], LOutputStream.Size);
      end;
      CheckEquals(FDecodedHexData[LI], BytesToHex(LActual));
    finally
      LOutputStream.Free;
      LInputReader.Free;
    end;
  end;
end;

procedure TTestBase2.Test_Encode_NullInput_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase2.Default.Encode(LBytes));
end;

procedure TTestBase2.Test_Decode_InvalidCharacter_ThrowsArgumentException;
begin
  try
    TBase2.Default.Decode('0001002');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase2.Test_Decode_InvalidCharacterMixed_ThrowsArgumentException;
begin
  try
    TBase2.Default.Decode('01010abc');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase2.Test_Decode_SpecialCharacters_ThrowsArgumentException;
begin
  try
    TBase2.Default.Decode('01010!@#');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase2.Test_Constructor_CreatesValidInstance;
var
  LInstance: TBase2;
begin
  LInstance := TBase2.Create;
  try
    CheckEquals('01000010', LInstance.Encode(TSimpleBaseLibByteArray.Create($42)));
  finally
    LInstance.Free;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase2);
{$ELSE}
  RegisterTest(TTestBase2.Suite);
{$ENDIF FPC}

end.
