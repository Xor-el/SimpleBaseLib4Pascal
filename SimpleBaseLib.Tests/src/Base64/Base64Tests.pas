unit Base64Tests;

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
  SbpIBase64,
  SbpBase64,
  SimpleBaseLibTestBase;

type
  TTestBase64 = class(TSimpleBaseLibTestCase)
  strict private
    FInputHexData: TSimpleBaseLibStringArray;
    FExpectedDefault: TSimpleBaseLibStringArray;
    FExpectedDefaultNoPad: TSimpleBaseLibStringArray;
    FExpectedUrl: TSimpleBaseLibStringArray;
    FExpectedUrlPadded: TSimpleBaseLibStringArray;
    FCoders: array [0 .. 3] of IBase64;
    FCoderNames: array [0 .. 3] of String;
    function GetExpectedByCoderIndex(AIndex: Int32): TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_ReturnsExpectedValues;
    procedure Test_Decode_ReturnsExpectedValues;
    procedure Test_TryEncode_ReturnsExpectedValues;
    procedure Test_TryDecode_ReturnsExpectedValues;
    procedure Test_Encode_Stream_ReturnsExpectedValues;
    procedure Test_Decode_Stream_ReturnsExpectedValues;
    procedure Test_Encode_NullBytes_ReturnsEmptyString;
    procedure Test_GetSafeCount_APIs_ReturnExpectedValues;
    procedure Test_Decode_InvalidInput_Throws;
    procedure Test_TryDecode_InvalidInput_ReturnsFalse;
  end;

implementation

procedure TTestBase64.SetUp;
begin
  inherited;

  FInputHexData := TSimpleBaseLibStringArray.Create(
    '', '66', '666F', '666F6F', '666F6F62', '666F6F6261', '666F6F626172',
    'FBFFEF', 'FFEEDDCCBBAA', '68656C6C6F20776F726C64'
  );

  // RFC 4648 vectors + generated binary vectors.
  FExpectedDefault := TSimpleBaseLibStringArray.Create(
    '', 'Zg==', 'Zm8=', 'Zm9v', 'Zm9vYg==', 'Zm9vYmE=', 'Zm9vYmFy',
    '+//v', '/+7dzLuq', 'aGVsbG8gd29ybGQ='
  );
  FExpectedDefaultNoPad := TSimpleBaseLibStringArray.Create(
    '', 'Zg', 'Zm8', 'Zm9v', 'Zm9vYg', 'Zm9vYmE', 'Zm9vYmFy',
    '+//v', '/+7dzLuq', 'aGVsbG8gd29ybGQ'
  );
  FExpectedUrl := TSimpleBaseLibStringArray.Create(
    '', 'Zg', 'Zm8', 'Zm9v', 'Zm9vYg', 'Zm9vYmE', 'Zm9vYmFy',
    '-__v', '_-7dzLuq', 'aGVsbG8gd29ybGQ'
  );
  FExpectedUrlPadded := TSimpleBaseLibStringArray.Create(
    '', 'Zg==', 'Zm8=', 'Zm9v', 'Zm9vYg==', 'Zm9vYmE=', 'Zm9vYmFy',
    '-__v', '_-7dzLuq', 'aGVsbG8gd29ybGQ='
  );

  FCoders[0] := TBase64.Default;
  FCoders[1] := TBase64.DefaultNoPad;
  FCoders[2] := TBase64.Url;
  FCoders[3] := TBase64.UrlPadded;

  FCoderNames[0] := 'Default';
  FCoderNames[1] := 'DefaultNoPad';
  FCoderNames[2] := 'Url';
  FCoderNames[3] := 'UrlPadded';
end;

procedure TTestBase64.TearDown;
begin
  inherited;
end;

function TTestBase64.GetExpectedByCoderIndex(
  AIndex: Int32): TSimpleBaseLibStringArray;
begin
  case AIndex of
    0:
      Result := FExpectedDefault;
    1:
      Result := FExpectedDefaultNoPad;
    2:
      Result := FExpectedUrl;
  else
    Result := FExpectedUrlPadded;
  end;
end;

procedure TTestBase64.Test_Encode_ReturnsExpectedValues;
var
  LI, LJ: Int32;
  LExpected: TSimpleBaseLibStringArray;
begin
  for LI := Low(FCoders) to High(FCoders) do
  begin
    LExpected := GetExpectedByCoderIndex(LI);
    for LJ := Low(FInputHexData) to High(FInputHexData) do
    begin
      CheckEquals(LExpected[LJ], FCoders[LI].Encode(HexToBytes(FInputHexData[LJ])),
        Format('%s Encode mismatch at index %d', [FCoderNames[LI], LJ]));
    end;
  end;
end;

procedure TTestBase64.Test_Decode_ReturnsExpectedValues;
var
  LI, LJ: Int32;
  LExpected: TSimpleBaseLibStringArray;
begin
  for LI := Low(FCoders) to High(FCoders) do
  begin
    LExpected := GetExpectedByCoderIndex(LI);
    for LJ := Low(LExpected) to High(LExpected) do
    begin
      CheckEquals(FInputHexData[LJ], BytesToHex(FCoders[LI].Decode(LExpected[LJ])),
        Format('%s Decode mismatch at index %d', [FCoderNames[LI], LJ]));
    end;
  end;
end;

procedure TTestBase64.Test_TryEncode_ReturnsExpectedValues;
var
  LI, LJ, LCharsWritten: Int32;
  LExpected: TSimpleBaseLibStringArray;
  LOut: TSimpleBaseLibCharArray;
  LIn: TSimpleBaseLibByteArray;
begin
  for LI := Low(FCoders) to High(FCoders) do
  begin
    LExpected := GetExpectedByCoderIndex(LI);
    for LJ := Low(FInputHexData) to High(FInputHexData) do
    begin
      LIn := HexToBytes(FInputHexData[LJ]);
      SetLength(LOut, FCoders[LI].GetSafeCharCountForEncoding(LIn));
      CheckTrue(FCoders[LI].TryEncode(LIn, LOut, LCharsWritten),
        Format('%s TryEncode should succeed at index %d', [FCoderNames[LI], LJ]));
      CheckEquals(LExpected[LJ], CharsToString(LOut, LCharsWritten),
        Format('%s TryEncode mismatch at index %d', [FCoderNames[LI], LJ]));
    end;
  end;
end;

procedure TTestBase64.Test_TryDecode_ReturnsExpectedValues;
var
  LI, LJ, LBytesWritten: Int32;
  LExpected: TSimpleBaseLibStringArray;
  LOut: TSimpleBaseLibByteArray;
begin
  for LI := Low(FCoders) to High(FCoders) do
  begin
    LExpected := GetExpectedByCoderIndex(LI);
    for LJ := Low(LExpected) to High(LExpected) do
    begin
      SetLength(LOut, FCoders[LI].GetSafeByteCountForDecoding(LExpected[LJ]));
      CheckTrue(FCoders[LI].TryDecode(LExpected[LJ], LOut, LBytesWritten),
        Format('%s TryDecode should succeed at index %d', [FCoderNames[LI], LJ]));
      CheckEquals(FInputHexData[LJ], BytesToHex(System.Copy(LOut, 0, LBytesWritten)),
        Format('%s TryDecode mismatch at index %d', [FCoderNames[LI], LJ]));
    end;
  end;
end;

procedure TTestBase64.Test_Encode_Stream_ReturnsExpectedValues;
var
  LI, LJ: Int32;
  LExpected: TSimpleBaseLibStringArray;
  LInput: TMemoryStream;
  LOutput: TStringBuilder;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FCoders) to High(FCoders) do
  begin
    LExpected := GetExpectedByCoderIndex(LI);
    for LJ := Low(FInputHexData) to High(FInputHexData) do
    begin
      LInput := TMemoryStream.Create;
      LOutput := TStringBuilder.Create;
      try
        LBytes := HexToBytes(FInputHexData[LJ]);
        if Length(LBytes) > 0 then
        begin
          LInput.WriteBuffer(LBytes[0], Length(LBytes));
        end;
        LInput.Position := 0;
        FCoders[LI].Encode(LInput, LOutput);
        CheckEquals(LExpected[LJ], LOutput.ToString,
          Format('%s Stream encode mismatch at index %d', [FCoderNames[LI], LJ]));
      finally
        LOutput.Free;
        LInput.Free;
      end;
    end;
  end;
end;

procedure TTestBase64.Test_Decode_Stream_ReturnsExpectedValues;
var
  LI, LJ: Int32;
  LExpected: TSimpleBaseLibStringArray;
  LInput: TStringBuilder;
  LOutput: TMemoryStream;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FCoders) to High(FCoders) do
  begin
    LExpected := GetExpectedByCoderIndex(LI);
    for LJ := Low(LExpected) to High(LExpected) do
    begin
      LInput := TStringBuilder.Create(LExpected[LJ]);
      LOutput := TMemoryStream.Create;
      try
        FCoders[LI].Decode(LInput, LOutput);
        SetLength(LBytes, LOutput.Size);
        if LOutput.Size > 0 then
        begin
          LOutput.Position := 0;
          LOutput.ReadBuffer(LBytes[0], LOutput.Size);
        end;
        CheckEquals(FInputHexData[LJ], BytesToHex(LBytes),
          Format('%s Stream decode mismatch at index %d', [FCoderNames[LI], LJ]));
      finally
        LOutput.Free;
        LInput.Free;
      end;
    end;
  end;
end;

procedure TTestBase64.Test_Encode_NullBytes_ReturnsEmptyString;
var
  LI: Int32;
  LBytes: TSimpleBaseLibByteArray;
begin
  LBytes := nil;
  for LI := Low(FCoders) to High(FCoders) do
  begin
    CheckEquals('', FCoders[LI].Encode(LBytes), Format('%s Nil encode', [FCoderNames[LI]]));
  end;
end;

procedure TTestBase64.Test_GetSafeCount_APIs_ReturnExpectedValues;
begin
  CheckEquals(4, TBase64.Default.GetSafeCharCountForEncoding(TSimpleBaseLibByteArray.Create($01)));
  CheckEquals(2, TBase64.DefaultNoPad.GetSafeCharCountForEncoding(TSimpleBaseLibByteArray.Create($01)));
  CheckEquals(4, TBase64.UrlPadded.GetSafeCharCountForEncoding(TSimpleBaseLibByteArray.Create($01)));
  CheckEquals(2, TBase64.Url.GetSafeCharCountForEncoding(TSimpleBaseLibByteArray.Create($01)));

  CheckEquals(3, TBase64.Default.GetSafeByteCountForDecoding('Zm8='));
  CheckEquals(3, TBase64.DefaultNoPad.GetSafeByteCountForDecoding('Zm8'));
  CheckEquals(3, TBase64.Url.GetSafeByteCountForDecoding('Zm8'));
end;

procedure TTestBase64.Test_Decode_InvalidInput_Throws;
begin
  try
    TBase64.Default.Decode('Zg');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase64.Url.Decode('++++');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;

  try
    TBase64.DefaultNoPad.Decode('Z');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestBase64.Test_TryDecode_InvalidInput_ReturnsFalse;
var
  LOut: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LOut, 16);
  CheckFalse(TBase64.Default.TryDecode('Zg', LOut, LBytesWritten));
  CheckFalse(TBase64.Url.TryDecode('++++', LOut, LBytesWritten));
  CheckFalse(TBase64.DefaultNoPad.TryDecode('Z', LOut, LBytesWritten));
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase64);
{$ELSE}
  RegisterTest(TTestBase64.Suite);
{$ENDIF FPC}

end.
