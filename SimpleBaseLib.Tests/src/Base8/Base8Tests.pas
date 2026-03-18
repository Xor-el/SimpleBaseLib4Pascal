unit Base8Tests;

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
  SbpBase8,
  SimpleBaseLibTestBase;

type
  TTestBase8 = class(TSimpleBaseLibTestCase)
  strict private
    FDecodedHexData: TSimpleBaseLibStringArray;
    FEncodedData: TSimpleBaseLibStringArray;
    FEdgeDecodedHexData: TSimpleBaseLibStringArray;
    FEdgeEncodedData: TSimpleBaseLibStringArray;
    FNonCanonicalDecodedHexData: TSimpleBaseLibStringArray;
    FNonCanonicalEncodedData: TSimpleBaseLibStringArray;
    FInvalidCharacterInputs: TSimpleBaseLibStringArray;
    FInvalidLengthInputs: TSimpleBaseLibStringArray;
    FValidPartialLengthInputs: TSimpleBaseLibStringArray;
    FCompleteBlockInputs: TSimpleBaseLibStringArray;
    FCompleteBlockDecodedHex: TSimpleBaseLibStringArray;
    FB6B7EdgeInputs: TSimpleBaseLibStringArray;
    FB6B7EdgeDecodedHex: TSimpleBaseLibStringArray;
    FInvalidB6Inputs: TSimpleBaseLibStringArray;
    FInvalidB7Inputs: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_EncodesCorrectly;
    procedure Test_Encode_NonCanonicalData_EncodesCorrectly;
    procedure Test_Decode_DecodesCorrectly;
    procedure Test_Encode_EdgeCases_EncodesCorrectly;
    procedure Test_Decode_EdgeCases_DecodesCorrectly;
    procedure Test_TryEncode_ValidInput_ReturnsExpectedValues;
    procedure Test_TryEncode_EdgeCases_ReturnsExpectedValues;
    procedure Test_TryEncode_EmptyInput_ReturnsTrue;
    procedure Test_TryEncode_InsufficientOutputBuffer_ReturnsFalse;
    procedure Test_TryDecode_ValidInput_ReturnsExpectedValues;
    procedure Test_TryDecode_EdgeCases_ReturnsExpectedValues;
    procedure Test_TryDecode_EmptyInput_ReturnsTrue;
    procedure Test_TryDecode_InvalidCharacters_ReturnsFalse;
    procedure Test_TryDecode_InvalidInputLength_ReturnsFalse;
    procedure Test_TryDecode_ValidPartialLength_ReturnsTrue;
    procedure Test_TryDecode_InsufficientOutputBuffer_ReturnsFalse;
    procedure Test_GetSafeCharCountForEncoding_ValidInput_ReturnsCorrectCount;
    procedure Test_GetSafeCharCountForEncoding_VariousLengths_ReturnsCorrectCount;
    procedure Test_GetSafeByteCountForDecoding_VariousLengths_ReturnsCorrectCount;
    procedure Test_Decode_InvalidCharacters_ThrowsArgumentException;
    procedure Test_Decode_InvalidInputLength_ThrowsArgumentException;
    procedure Test_Encode_Stream_ReturnsExpectedValues;
    procedure Test_Decode_Stream_ReturnsExpectedValues;
    procedure Test_Encode_NullInput_ReturnsEmptyString;
    procedure Test_Constructor_CreatesValidInstance;
    procedure Test_RoundTrip_AllByteValues_WorksCorrectly;

    procedure Test_Decode_CompleteEightCharacterBlocks_DecodesCorrectly;
    procedure Test_TryDecode_CompleteEightCharacterBlocks_ReturnsSuccess;
    procedure Test_Decode_InvalidB6Character_ThrowsArgumentException;
    procedure Test_TryDecode_InvalidB6Character_ReturnsFalse;
    procedure Test_Decode_InvalidB7Character_ThrowsArgumentException;
    procedure Test_TryDecode_InvalidB7Character_ReturnsFalse;
    procedure Test_Decode_B6B7EdgeCases_DecodesCorrectly;
    procedure Test_TryDecode_B6B7EdgeCases_ReturnsSuccess;
    procedure Test_Decode_B6B7BoundaryValues_ValidatesCorrectly;
    procedure Test_TryDecode_B6B7BoundaryValues_ReturnsCorrectStatus;
    procedure Test_Decode_MultipleCompleteBlocks_ProcessesAllB6B7Correctly;
    procedure Test_Decode_MultipleCompleteBlocksWithInvalidB6_ThrowsException;
    procedure Test_Decode_MultipleCompleteBlocksWithInvalidB7_ThrowsException;
    procedure Test_TryDecode_MultipleCompleteBlocksWithInvalidCharacters_ReturnsFalse;
    procedure Test_Decode_B6B7AllValidCombinations_ProduceExpectedBytes;
  end;

implementation

procedure TTestBase8.SetUp;
begin
  inherited;
  FDecodedHexData := TSimpleBaseLibStringArray.Create(
    '',
    'FFFFFF',
    '000000',
    'FFFFFF',
    '796573206D616E692021'
  );
  FEncodedData := TSimpleBaseLibStringArray.Create(
    '',
    '77777777',
    '00000000',
    '77777777',
    '362625631006654133464440102'
  );

  FNonCanonicalDecodedHexData := TSimpleBaseLibStringArray.Create('FF', 'FFFF');
  FNonCanonicalEncodedData := TSimpleBaseLibStringArray.Create('776', '777774');

  FEdgeDecodedHexData := TSimpleBaseLibStringArray.Create(
    '00', '01', '07', '08', 'FF', '0001', '0102', 'AA55'
  );
  FEdgeEncodedData := TSimpleBaseLibStringArray.Create(
    '000', '002', '016', '020', '776', '000004', '002010', '524524'
  );

  FInvalidCharacterInputs := TSimpleBaseLibStringArray.Create(
    '8', '9', '01289', 'abc', '0128!@#', '012a567'
  );
  FInvalidLengthInputs := TSimpleBaseLibStringArray.Create('1', '12', '1234', '12345', '1234567');
  FValidPartialLengthInputs := TSimpleBaseLibStringArray.Create('123', '123456', '12345670');

  FCompleteBlockInputs := TSimpleBaseLibStringArray.Create(
    '00000000', '77777777', '12345670', '01234567', '76543210',
    '70000007', '07777770', '01010101', '10101010'
  );
  FCompleteBlockDecodedHex := TSimpleBaseLibStringArray.Create(
    '000000', 'FFFFFF', '29CBB8', '053977', 'FAC688',
    'E00007', '1FFFF8', '041041', '208208'
  );

  FB6B7EdgeInputs := TSimpleBaseLibStringArray.Create(
    '00000000', '00000007', '00000070', '00000077',
    '12345600', '12345607', '12345670', '12345677',
    '00000010', '00000020', '00000030', '00000040', '00000050', '00000060',
    '00000001', '00000002', '00000003', '00000004', '00000005', '00000006'
  );
  FB6B7EdgeDecodedHex := TSimpleBaseLibStringArray.Create(
    '000000', '000007', '000038', '00003F',
    '29CB80', '29CB87', '29CBB8', '29CBBF',
    '000008', '000010', '000018', '000020', '000028', '000030',
    '000001', '000002', '000003', '000004', '000005', '000006'
  );

  FInvalidB6Inputs := TSimpleBaseLibStringArray.Create('01234580', '01234590');
  FInvalidB7Inputs := TSimpleBaseLibStringArray.Create('01234508', '01234509');
end;

procedure TTestBase8.TearDown;
begin
  inherited;
end;

procedure TTestBase8.Test_Encode_EncodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    CheckEquals(FEncodedData[LI], TBase8.Default.Encode(HexToBytes(FDecodedHexData[LI])));
  end;
end;

procedure TTestBase8.Test_Encode_NonCanonicalData_EncodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FNonCanonicalDecodedHexData) to High(FNonCanonicalDecodedHexData) do
  begin
    CheckEquals(FNonCanonicalEncodedData[LI],
      TBase8.Default.Encode(HexToBytes(FNonCanonicalDecodedHexData[LI])));
  end;
end;

procedure TTestBase8.Test_Decode_DecodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    CheckEquals(FDecodedHexData[LI], BytesToHex(TBase8.Default.Decode(FEncodedData[LI])));
  end;
end;

procedure TTestBase8.Test_Encode_EdgeCases_EncodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FEdgeDecodedHexData) to High(FEdgeDecodedHexData) do
  begin
    CheckEquals(FEdgeEncodedData[LI], TBase8.Default.Encode(HexToBytes(FEdgeDecodedHexData[LI])));
  end;
end;

procedure TTestBase8.Test_Decode_EdgeCases_DecodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FEdgeEncodedData) to High(FEdgeEncodedData) do
  begin
    CheckEquals(FEdgeDecodedHexData[LI], BytesToHex(TBase8.Default.Decode(FEdgeEncodedData[LI])));
  end;
end;

procedure TTestBase8.Test_TryEncode_ValidInput_ReturnsExpectedValues;
var
  LI, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    LInput := HexToBytes(FDecodedHexData[LI]);
    SetLength(LOutput, TBase8.Default.GetSafeCharCountForEncoding(LInput));
    CheckTrue(TBase8.Default.TryEncode(LInput, LOutput, LCharsWritten));
    CheckEquals(FEncodedData[LI], CharsToString(LOutput, LCharsWritten));
    CheckEquals(Length(FEncodedData[LI]), LCharsWritten);
  end;
end;

procedure TTestBase8.Test_TryEncode_EdgeCases_ReturnsExpectedValues;
var
  LI, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEdgeDecodedHexData) to High(FEdgeDecodedHexData) do
  begin
    LInput := HexToBytes(FEdgeDecodedHexData[LI]);
    SetLength(LOutput, TBase8.Default.GetSafeCharCountForEncoding(LInput));
    CheckTrue(TBase8.Default.TryEncode(LInput, LOutput, LCharsWritten));
    CheckEquals(FEdgeEncodedData[LI], CharsToString(LOutput, LCharsWritten));
  end;
end;

procedure TTestBase8.Test_TryEncode_EmptyInput_ReturnsTrue;
var
  LOutput: TSimpleBaseLibCharArray;
  LCharsWritten: Int32;
  LInput: TSimpleBaseLibByteArray;
begin
  LInput := nil;
  SetLength(LOutput, 1);
  CheckTrue(TBase8.Default.TryEncode(LInput, LOutput, LCharsWritten));
  CheckEquals(0, LCharsWritten);
end;

procedure TTestBase8.Test_TryEncode_InsufficientOutputBuffer_ReturnsFalse;
var
  LOutput: TSimpleBaseLibCharArray;
  LCharsWritten: Int32;
begin
  SetLength(LOutput, 2);
  CheckFalse(TBase8.Default.TryEncode(TSimpleBaseLibByteArray.Create($FF), LOutput, LCharsWritten));
  CheckEquals(0, LCharsWritten);
end;

procedure TTestBase8.Test_TryDecode_ValidInput_ReturnsExpectedValues;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    SetLength(LOutput, TBase8.Default.GetSafeByteCountForDecoding(FEncodedData[LI]));
    CheckTrue(TBase8.Default.TryDecode(FEncodedData[LI], LOutput, LBytesWritten));
    CheckEquals(FDecodedHexData[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
  end;
end;

procedure TTestBase8.Test_TryDecode_EdgeCases_ReturnsExpectedValues;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEdgeEncodedData) to High(FEdgeEncodedData) do
  begin
    SetLength(LOutput, TBase8.Default.GetSafeByteCountForDecoding(FEdgeEncodedData[LI]));
    CheckTrue(TBase8.Default.TryDecode(FEdgeEncodedData[LI], LOutput, LBytesWritten));
    CheckEquals(FEdgeDecodedHexData[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
  end;
end;

procedure TTestBase8.Test_TryDecode_EmptyInput_ReturnsTrue;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 1);
  CheckTrue(TBase8.Default.TryDecode('', LOutput, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase8.Test_TryDecode_InvalidCharacters_ReturnsFalse;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 10);
  for LI := Low(FInvalidCharacterInputs) to High(FInvalidCharacterInputs) do
  begin
    CheckFalse(TBase8.Default.TryDecode(FInvalidCharacterInputs[LI], LOutput, LBytesWritten));
    CheckEquals(0, LBytesWritten);
  end;
end;

procedure TTestBase8.Test_TryDecode_InvalidInputLength_ReturnsFalse;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 10);
  for LI := Low(FInvalidLengthInputs) to High(FInvalidLengthInputs) do
  begin
    CheckFalse(TBase8.Default.TryDecode(FInvalidLengthInputs[LI], LOutput, LBytesWritten));
    CheckEquals(0, LBytesWritten);
  end;
end;

procedure TTestBase8.Test_TryDecode_ValidPartialLength_ReturnsTrue;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 10);
  for LI := Low(FValidPartialLengthInputs) to High(FValidPartialLengthInputs) do
  begin
    CheckTrue(TBase8.Default.TryDecode(FValidPartialLengthInputs[LI], LOutput, LBytesWritten));
  end;
end;

procedure TTestBase8.Test_TryDecode_InsufficientOutputBuffer_ReturnsFalse;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 0);
  CheckFalse(TBase8.Default.TryDecode('12345670', LOutput, LBytesWritten));
  CheckEquals(0, LBytesWritten);
end;

procedure TTestBase8.Test_GetSafeCharCountForEncoding_ValidInput_ReturnsCorrectCount;
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    LInput := HexToBytes(FDecodedHexData[LI]);
    CheckTrue(TBase8.Default.GetSafeCharCountForEncoding(LInput) >= Length(FEncodedData[LI]));
  end;
end;

procedure TTestBase8.Test_GetSafeCharCountForEncoding_VariousLengths_ReturnsCorrectCount;
const
  CInputLength: array [0 .. 7] of Int32 = (0, 1, 2, 3, 4, 5, 6, 7);
  CExpected: array [0 .. 7] of Int32 = (0, 8, 8, 8, 16, 16, 16, 24);
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
begin
  for LI := Low(CInputLength) to High(CInputLength) do
  begin
    SetLength(LInput, CInputLength[LI]);
    CheckEquals(CExpected[LI], TBase8.Default.GetSafeCharCountForEncoding(LInput));
  end;
end;

procedure TTestBase8.Test_GetSafeByteCountForDecoding_VariousLengths_ReturnsCorrectCount;
const
  CInputs: array [0 .. 6] of String =
    ('', '000', '000000', '00000000', '000001234', '000001234567', '000012345670');
  CExpected: array [0 .. 6] of Int32 = (0, 3, 3, 3, 6, 6, 6);
var
  LI: Int32;
begin
  for LI := Low(CInputs) to High(CInputs) do
  begin
    CheckEquals(CExpected[LI], TBase8.Default.GetSafeByteCountForDecoding(CInputs[LI]));
  end;
end;

procedure TTestBase8.Test_Decode_InvalidCharacters_ThrowsArgumentException;
var
  LI: Int32;
begin
  for LI := Low(FInvalidCharacterInputs) to High(FInvalidCharacterInputs) do
  begin
    try
      TBase8.Default.Decode(FInvalidCharacterInputs[LI]);
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  end;
end;

procedure TTestBase8.Test_Decode_InvalidInputLength_ThrowsArgumentException;
var
  LI: Int32;
begin
  for LI := Low(FInvalidLengthInputs) to High(FInvalidLengthInputs) do
  begin
    try
      TBase8.Default.Decode(FInvalidLengthInputs[LI]);
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  end;
end;

procedure TTestBase8.Test_Encode_Stream_ReturnsExpectedValues;
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
      TBase8.Default.Encode(LInputStream, LWriter);
      CheckEquals(FEncodedData[LI], LWriter.ToString);
    finally
      LWriter.Free;
      LInputStream.Free;
    end;
  end;
end;

procedure TTestBase8.Test_Decode_Stream_ReturnsExpectedValues;
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
      TBase8.Default.Decode(LInputReader, LOutputStream);
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

procedure TTestBase8.Test_Encode_NullInput_ReturnsEmptyString;
var
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  CheckEquals('', TBase8.Default.Encode(LBytes));
end;

procedure TTestBase8.Test_Constructor_CreatesValidInstance;
var
  LInstance: TBase8;
begin
  LInstance := TBase8.Create;
  try
    CheckEquals('204', LInstance.Encode(TSimpleBaseLibByteArray.Create($42)));
  finally
    LInstance.Free;
  end;
end;

procedure TTestBase8.Test_RoundTrip_AllByteValues_WorksCorrectly;
var
  LInput, LDecoded: TSimpleBaseLibByteArray;
  LI: Int32;
  LEncoded: String;
begin
  SetLength(LInput, 256);
  for LI := 0 to 255 do
  begin
    LInput[LI] := Byte(LI);
  end;
  LEncoded := TBase8.Default.Encode(LInput);
  LDecoded := TBase8.Default.Decode(LEncoded);
  CheckTrue(AreEqual(LInput, LDecoded));
end;

procedure TTestBase8.Test_Decode_CompleteEightCharacterBlocks_DecodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FCompleteBlockInputs) to High(FCompleteBlockInputs) do
  begin
    CheckEquals(FCompleteBlockDecodedHex[LI],
      BytesToHex(TBase8.Default.Decode(FCompleteBlockInputs[LI])));
  end;
end;

procedure TTestBase8.Test_TryDecode_CompleteEightCharacterBlocks_ReturnsSuccess;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FCompleteBlockInputs) to High(FCompleteBlockInputs) do
  begin
    SetLength(LOutput, TBase8.Default.GetSafeByteCountForDecoding(FCompleteBlockInputs[LI]));
    CheckTrue(TBase8.Default.TryDecode(FCompleteBlockInputs[LI], LOutput, LBytesWritten));
    CheckEquals(FCompleteBlockDecodedHex[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
  end;
end;

procedure TTestBase8.Test_Decode_InvalidB6Character_ThrowsArgumentException;
var
  LI: Int32;
begin
  for LI := Low(FInvalidB6Inputs) to High(FInvalidB6Inputs) do
  begin
    try
      TBase8.Default.Decode(FInvalidB6Inputs[LI]);
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  end;
end;

procedure TTestBase8.Test_TryDecode_InvalidB6Character_ReturnsFalse;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 10);
  for LI := Low(FInvalidB6Inputs) to High(FInvalidB6Inputs) do
  begin
    CheckFalse(TBase8.Default.TryDecode(FInvalidB6Inputs[LI], LOutput, LBytesWritten));
  end;
end;

procedure TTestBase8.Test_Decode_InvalidB7Character_ThrowsArgumentException;
var
  LI: Int32;
begin
  for LI := Low(FInvalidB7Inputs) to High(FInvalidB7Inputs) do
  begin
    try
      TBase8.Default.Decode(FInvalidB7Inputs[LI]);
      Fail('Expected EArgumentSimpleBaseLibException');
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  end;
end;

procedure TTestBase8.Test_TryDecode_InvalidB7Character_ReturnsFalse;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  SetLength(LOutput, 10);
  for LI := Low(FInvalidB7Inputs) to High(FInvalidB7Inputs) do
  begin
    CheckFalse(TBase8.Default.TryDecode(FInvalidB7Inputs[LI], LOutput, LBytesWritten));
  end;
end;

procedure TTestBase8.Test_Decode_B6B7EdgeCases_DecodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FB6B7EdgeInputs) to High(FB6B7EdgeInputs) do
  begin
    CheckEquals(FB6B7EdgeDecodedHex[LI], BytesToHex(TBase8.Default.Decode(FB6B7EdgeInputs[LI])));
  end;
end;

procedure TTestBase8.Test_TryDecode_B6B7EdgeCases_ReturnsSuccess;
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
begin
  for LI := Low(FB6B7EdgeInputs) to High(FB6B7EdgeInputs) do
  begin
    SetLength(LOutput, TBase8.Default.GetSafeByteCountForDecoding(FB6B7EdgeInputs[LI]));
    CheckTrue(TBase8.Default.TryDecode(FB6B7EdgeInputs[LI], LOutput, LBytesWritten));
    CheckEquals(FB6B7EdgeDecodedHex[LI], BytesToHex(System.Copy(LOutput, 0, LBytesWritten)));
  end;
end;

procedure TTestBase8.Test_Decode_B6B7BoundaryValues_ValidatesCorrectly;
begin
  TBase8.Default.Decode('00000077');
  try
    TBase8.Default.Decode('00000088');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
  try
    TBase8.Default.Decode('00000808');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
  try
    TBase8.Default.Decode('00000080');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase8.Test_TryDecode_B6B7BoundaryValues_ReturnsCorrectStatus;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 10);
  CheckTrue(TBase8.Default.TryDecode('00000077', LOutput, LBytesWritten));
  CheckFalse(TBase8.Default.TryDecode('00000088', LOutput, LBytesWritten));
  CheckFalse(TBase8.Default.TryDecode('00000808', LOutput, LBytesWritten));
  CheckFalse(TBase8.Default.TryDecode('00000080', LOutput, LBytesWritten));
end;

procedure TTestBase8.Test_Decode_MultipleCompleteBlocks_ProcessesAllB6B7Correctly;
begin
  CheckEquals('000000FFFFFF', BytesToHex(TBase8.Default.Decode('0000000077777777')));
end;

procedure TTestBase8.Test_Decode_MultipleCompleteBlocksWithInvalidB6_ThrowsException;
begin
  try
    TBase8.Default.Decode('0123458000000000');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
  try
    TBase8.Default.Decode('0000000001234580');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase8.Test_Decode_MultipleCompleteBlocksWithInvalidB7_ThrowsException;
begin
  try
    TBase8.Default.Decode('0123450800000000');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
  try
    TBase8.Default.Decode('0000000001234508');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase8.Test_TryDecode_MultipleCompleteBlocksWithInvalidCharacters_ReturnsFalse;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 20);
  CheckFalse(TBase8.Default.TryDecode('0123458000000000', LOutput, LBytesWritten));
  CheckFalse(TBase8.Default.TryDecode('0000000001234509', LOutput, LBytesWritten));
end;

procedure TTestBase8.Test_Decode_B6B7AllValidCombinations_ProduceExpectedBytes;
var
  LB6, LB7: Int32;
  LInput: String;
  LResult: TSimpleBaseLibByteArray;
  LExpectedFinalByte: Byte;
begin
  for LB6 := 0 to 7 do
  begin
    for LB7 := 0 to 7 do
    begin
      LInput := Format('000000%d%d', [LB6, LB7]);
      LResult := TBase8.Default.Decode(LInput);
      LExpectedFinalByte := Byte((LB6 shl 3) or LB7);
      CheckEquals(Integer(LExpectedFinalByte), Integer(LResult[Length(LResult) - 1]));
    end;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase8);
{$ELSE}
  RegisterTest(TTestBase8.Suite);
{$ENDIF FPC}

end.
