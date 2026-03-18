unit Base16Tests;

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
  SbpIBase16,
  SbpBase16,
  SbpBase16Alphabet,
  SimpleBaseLibTestBase;

type
  TTestBase16 = class(TSimpleBaseLibTestCase)
  strict private
    FEncoders: array[0..2] of IBase16;
    FEncoderNames: array[0..2] of String;
    FTestInputBytes: TSimpleBaseLibMatrixByteArray;
    FExpectedTexts: array[0..2] of TSimpleBaseLibStringArray;
  strict private
    procedure CheckEncodeMatchesExpected(const AEncoder: IBase16;
      const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
    procedure CheckDecodeMatchesExpected(const AEncoder: IBase16;
      const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
    procedure CheckTryEncodeMatchesExpected(const AEncoder: IBase16;
      const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
    procedure CheckTryDecodeMatchesExpected(const AEncoder: IBase16;
      const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode;
    procedure Test_Decode;
    procedure Test_Encode_Stream;
    procedure Test_Decode_Stream;
    procedure Test_TryEncode_RegularInput_Succeeds;
    procedure Test_TryDecode_RegularInput_Succeeds;
    procedure Test_Decode_OtherCase_StillPasses;
    procedure Test_TryEncode_SmallerOutput_Fails;
    procedure Test_TryDecode_InvalidChar_ReturnsFalse;
    procedure Test_TryDecode_SmallOutputBuffer_Fails;
    procedure Test_TryDecode_UnevenInputBuffer_Fails;
    procedure Test_Decode_InvalidChar_Throws;
    procedure Test_Decode_InvalidLength_Throws;
    procedure Test_GetSafeCharCountForEncoding_ReturnsCorrectValue;
    procedure Test_GetSafeByteCountForDecoding_ReturnsCorrectValue;
    procedure Test_GetSafeByteCountForDecoding_InvalidLength_ReturnsZero;
    procedure Test_CustomCtor;
    procedure Test_ToString_ReturnsNameWithAlphabet;
    procedure Test_GetHashCode_ReturnsAlphabetHashCode;
  end;

implementation

{ TTestBase16 }

procedure TTestBase16.SetUp;
begin
  inherited;

  FEncoders[0] := TBase16.LowerCase;
  FEncoders[1] := TBase16.UpperCase;
  FEncoders[2] := TBase16.ModHex;

  FEncoderNames[0] := 'LowerCase';
  FEncoderNames[1] := 'UpperCase';
  FEncoderNames[2] := 'ModHex';

  FTestInputBytes := TSimpleBaseLibMatrixByteArray.Create(
    nil,
    TSimpleBaseLibByteArray.Create($AB),
    TSimpleBaseLibByteArray.Create($00, $01, $02, $03),
    TSimpleBaseLibByteArray.Create($10, $11, $12, $13),
    TSimpleBaseLibByteArray.Create($AB, $CD, $EF, $BA),
    TSimpleBaseLibByteArray.Create($AB, $CD, $EF, $F0),
    TSimpleBaseLibByteArray.Create($AB, $CD, $EF, $BA, $AB, $CD, $EF, $BA)
  );

  FExpectedTexts[0] := TSimpleBaseLibStringArray.Create(
    '', 'ab', '00010203', '10111213', 'abcdefba', 'abcdeff0', 'abcdefbaabcdefba');
  FExpectedTexts[1] := TSimpleBaseLibStringArray.Create(
    '', 'AB', '00010203', '10111213', 'ABCDEFBA', 'ABCDEFF0', 'ABCDEFBAABCDEFBA');
  FExpectedTexts[2] := TSimpleBaseLibStringArray.Create(
    '', 'ln', 'cccbcdce', 'bcbbbdbe', 'lnrtuvnl', 'lnrtuvvc', 'lnrtuvnllnrtuvnl');
end;

procedure TTestBase16.TearDown;
begin
  inherited;
end;

procedure TTestBase16.CheckEncodeMatchesExpected(const AEncoder: IBase16;
  const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
var
  LI: Int32;
  LActual: String;
begin
  for LI := System.Low(FTestInputBytes) to System.High(FTestInputBytes) do
  begin
    LActual := AEncoder.Encode(FTestInputBytes[LI]);
    CheckEquals(AExpectedTexts[LI], LActual,
      Format('%s: Encode mismatch at index %d', [AEncoderName, LI]));
  end;
end;

procedure TTestBase16.CheckDecodeMatchesExpected(const AEncoder: IBase16;
  const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
var
  LI: Int32;
  LActual: TSimpleBaseLibByteArray;
begin
  for LI := System.Low(FTestInputBytes) to System.High(FTestInputBytes) do
  begin
    LActual := AEncoder.Decode(AExpectedTexts[LI]);
    CheckTrue(AreEqual(FTestInputBytes[LI], LActual),
      Format('%s: Decode mismatch at index %d', [AEncoderName, LI]));
  end;
end;

procedure TTestBase16.CheckTryEncodeMatchesExpected(const AEncoder: IBase16;
  const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
var
  LI, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
  LExpectedLen: Int32;
  LActual: String;
begin
  for LI := System.Low(FTestInputBytes) to System.High(FTestInputBytes) do
  begin
    LExpectedLen := System.Length(AExpectedTexts[LI]);
    SetLength(LOutput, LExpectedLen);
    CheckTrue(AEncoder.TryEncode(FTestInputBytes[LI], LOutput, LCharsWritten),
      Format('%s: TryEncode should succeed at index %d', [AEncoderName, LI]));
    CheckEquals(LExpectedLen, LCharsWritten,
      Format('%s: TryEncode chars written mismatch at index %d', [AEncoderName, LI]));
    LActual := CharsToString(LOutput, LCharsWritten);
    CheckEquals(AExpectedTexts[LI], LActual,
      Format('%s: TryEncode text mismatch at index %d', [AEncoderName, LI]));
  end;
end;

procedure TTestBase16.CheckTryDecodeMatchesExpected(const AEncoder: IBase16;
  const AExpectedTexts: TSimpleBaseLibStringArray; const AEncoderName: String);
var
  LI, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
  LExpectedLen: Int32;
  LActual: TSimpleBaseLibByteArray;
begin
  for LI := System.Low(FTestInputBytes) to System.High(FTestInputBytes) do
  begin
    LExpectedLen := System.Length(FTestInputBytes[LI]);
    SetLength(LOutput, LExpectedLen);
    CheckTrue(AEncoder.TryDecode(AExpectedTexts[LI], LOutput, LBytesWritten),
      Format('%s: TryDecode should succeed at index %d', [AEncoderName, LI]));
    CheckEquals(LExpectedLen, LBytesWritten,
      Format('%s: TryDecode bytes written mismatch at index %d', [AEncoderName, LI]));
    LActual := System.Copy(LOutput, 0, LBytesWritten);
    CheckTrue(AreEqual(FTestInputBytes[LI], LActual),
      Format('%s: TryDecode bytes mismatch at index %d', [AEncoderName, LI]));
  end;
end;

procedure TTestBase16.Test_Encode;
var
  LI: Int32;
begin
  for LI := 0 to High(FEncoders) do
  begin
    CheckEncodeMatchesExpected(FEncoders[LI], FExpectedTexts[LI], FEncoderNames[LI]);
  end;
end;

procedure TTestBase16.Test_Decode;
var
  LI: Int32;
begin
  for LI := 0 to High(FEncoders) do
  begin
    CheckDecodeMatchesExpected(FEncoders[LI], FExpectedTexts[LI], FEncoderNames[LI]);
  end;
end;

procedure TTestBase16.Test_Encode_Stream;
var
  LInput: TMemoryStream;
  LOutput: TStringBuilder;
  LExpected: String;
begin
  LInput := TMemoryStream.Create;
  LOutput := TStringBuilder.Create;
  try
    LExpected := FExpectedTexts[1][4];
    if System.Length(FTestInputBytes[4]) > 0 then
    begin
      LInput.Write(FTestInputBytes[4][0], System.Length(FTestInputBytes[4]));
    end;
    LInput.Position := 0;
    TBase16.UpperCase.Encode(LInput, LOutput);
    CheckEquals(LExpected, LOutput.ToString, 'Stream Encode mismatch');
  finally
    LOutput.Free;
    LInput.Free;
  end;
end;

procedure TTestBase16.Test_Decode_Stream;
var
  LInput: TStringBuilder;
  LOutput: TMemoryStream;
  LExpected, LActual: TSimpleBaseLibByteArray;
begin
  LInput := TStringBuilder.Create(FExpectedTexts[1][4]);
  LOutput := TMemoryStream.Create;
  try
    TBase16.UpperCase.Decode(LInput, LOutput);
    SetLength(LActual, LOutput.Size);
    if LOutput.Size > 0 then
    begin
      LOutput.Position := 0;
      LOutput.ReadBuffer(LActual[0], LOutput.Size);
    end;
    LExpected := FTestInputBytes[4];
    CheckTrue(AreEqual(LExpected, LActual), 'Stream Decode mismatch');
  finally
    LOutput.Free;
    LInput.Free;
  end;
end;

procedure TTestBase16.Test_TryEncode_RegularInput_Succeeds;
var
  LI: Int32;
begin
  for LI := 0 to High(FEncoders) do
  begin
    CheckTryEncodeMatchesExpected(FEncoders[LI], FExpectedTexts[LI], FEncoderNames[LI]);
  end;
end;

procedure TTestBase16.Test_TryDecode_RegularInput_Succeeds;
var
  LI: Int32;
begin
  for LI := 0 to High(FEncoders) do
  begin
    CheckTryDecodeMatchesExpected(FEncoders[LI], FExpectedTexts[LI], FEncoderNames[LI]);
  end;
end;

procedure TTestBase16.Test_Decode_OtherCase_StillPasses;
var
  LDecoded: TSimpleBaseLibByteArray;
begin
  LDecoded := TBase16.LowerCase.Decode(UpperCase(FExpectedTexts[0][4]));
  CheckTrue(AreEqual(FTestInputBytes[4], LDecoded), 'LowerCase should decode uppercase input');

  LDecoded := TBase16.UpperCase.Decode(LowerCase(FExpectedTexts[1][4]));
  CheckTrue(AreEqual(FTestInputBytes[4], LDecoded), 'UpperCase should decode lowercase input');
end;

procedure TTestBase16.Test_TryEncode_SmallerOutput_Fails;
var
  LBuffer: TSimpleBaseLibCharArray;
  LCharsWritten: Int32;
begin
  SetLength(LBuffer, 0);
  CheckFalse(TBase16.UpperCase.TryEncode(TSimpleBaseLibByteArray.Create($12, $34, $56, $78),
    LBuffer, LCharsWritten), 'TryEncode must fail for undersized output');
  CheckEquals(0, LCharsWritten, 'TryEncode must report zero chars written on failure');
end;

procedure TTestBase16.Test_TryDecode_InvalidChar_ReturnsFalse;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 10);
  CheckFalse(TBase16.UpperCase.TryDecode('1234ZB', LOutput, LBytesWritten),
    'TryDecode should fail on invalid character');
  CheckEquals(2, LBytesWritten, 'TryDecode should report bytes decoded before failure');
end;

procedure TTestBase16.Test_TryDecode_SmallOutputBuffer_Fails;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 1);
  CheckFalse(TBase16.UpperCase.TryDecode('1234', LOutput, LBytesWritten),
    'TryDecode should fail when output buffer is too small');
  CheckEquals(0, LBytesWritten, 'TryDecode should report zero bytes written on small buffer');
end;

procedure TTestBase16.Test_TryDecode_UnevenInputBuffer_Fails;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOutput, 10);
  CheckFalse(TBase16.UpperCase.TryDecode('123', LOutput, LBytesWritten),
    'TryDecode should fail when input length is odd');
  CheckEquals(0, LBytesWritten, 'TryDecode should report zero bytes written on odd input');
end;

procedure TTestBase16.Test_Decode_InvalidChar_Throws;
begin
  try
    TBase16.LowerCase.Decode('AZ12');
    Fail('Expected EArgumentSimpleBaseLibException for invalid char');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase16.UpperCase.Decode('ZAAA');
    Fail('Expected EArgumentSimpleBaseLibException for invalid char');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase16.ModHex.Decode('!AAA');
    Fail('Expected EArgumentSimpleBaseLibException for invalid char');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase16.UpperCase.Decode('=AAA');
    Fail('Expected EArgumentSimpleBaseLibException for invalid char');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase16.Test_Decode_InvalidLength_Throws;
begin
  try
    TBase16.LowerCase.Decode('123');
    Fail('Expected EArgumentSimpleBaseLibException for odd-length input');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase16.UpperCase.Decode('12345');
    Fail('Expected EArgumentSimpleBaseLibException for odd-length input');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase16.Test_GetSafeCharCountForEncoding_ReturnsCorrectValue;
begin
  CheckEquals(10, TBase16.UpperCase.GetSafeCharCountForEncoding(
    TSimpleBaseLibByteArray.Create($00, $01, $02, $03, $04)));
end;

procedure TTestBase16.Test_GetSafeByteCountForDecoding_ReturnsCorrectValue;
begin
  CheckEquals(5, TBase16.UpperCase.GetSafeByteCountForDecoding('0011223344'));
end;

procedure TTestBase16.Test_GetSafeByteCountForDecoding_InvalidLength_ReturnsZero;
begin
  CheckEquals(0, TBase16.UpperCase.GetSafeByteCountForDecoding('00112233444'));
end;

procedure TTestBase16.Test_CustomCtor;
var
  LEncoder: IBase16;
  LResult: String;
begin
  LEncoder := TBase16.Create(TBase16Alphabet.Create('abcdefghijklmnop'));
  LResult := LEncoder.Encode(TSimpleBaseLibByteArray.Create($00, $01, $10, $80, $FF));
  CheckEquals('aaabbaiapp', LResult, 'Custom alphabet encoding mismatch');
end;

procedure TTestBase16.Test_ToString_ReturnsNameWithAlphabet;
var
  LEncoder: IBase16;
begin
  LEncoder := TBase16.UpperCase;
  CheckEquals('Base16_' + LEncoder.Alphabet.ToString, LEncoder.ToString);
end;

procedure TTestBase16.Test_GetHashCode_ReturnsAlphabetHashCode;
var
  LEncoder: IBase16;
begin
  LEncoder := TBase16.ModHex;
  CheckEquals(LEncoder.Alphabet.GetHashCode, LEncoder.GetHashCode);
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase16);
{$ELSE}
  RegisterTest(TTestBase16.Suite);
{$ENDIF FPC}

end.
