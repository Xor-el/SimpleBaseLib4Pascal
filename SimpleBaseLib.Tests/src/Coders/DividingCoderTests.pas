unit DividingCoderTests;

{$IFDEF FPC}
{$MODE DELPHI}
{$HINTS OFF}
{$WARNINGS OFF}
{$ENDIF FPC}

interface

uses
  SysUtils,
  Math,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpIDividingCoder,
  SbpBase58,
  SbpBase62,
  SbpBase36,
  SbpArrayUtilities,
  SbpSimpleBaseLibTypes,
  SimpleBaseLibTestBase;

type
  TTestDividingCoder = class(TSimpleBaseLibTestCase)
  strict private
    procedure CheckRoundtrip(const ACoder: IDividingCoder; const AName: String;
      const ABytes: TSimpleBaseLibByteArray);
    procedure CheckEdgeBuffers(const ACoder: IDividingCoder; const AName: String);
  published
    procedure Test_Base58_Roundtrip_EdgeBuffers;
    procedure Test_Base62_Roundtrip_EdgeBuffers;
    procedure Test_Base36_Roundtrip_EdgeBuffers;
    procedure Test_SafeSizes_NeverUnderAllocate;
  end;

implementation

function MakeFilled(ALen: Int32; AValue: Byte): TSimpleBaseLibByteArray;
begin
  System.SetLength(Result, ALen);
  if ALen > 0 then
    TArrayUtilities.Fill<Byte>(Result, 0, ALen, AValue);
end;

function MakeLeadingZeros(AZeroLen, ADataLen: Int32): TSimpleBaseLibByteArray;
var
  LI: Int32;
begin
  System.SetLength(Result, AZeroLen + ADataLen);
  for LI := 0 to AZeroLen - 1 do
    Result[LI] := 0;
  for LI := 0 to ADataLen - 1 do
    Result[AZeroLen + LI] := Byte(LI + 1);
end;

procedure TTestDividingCoder.CheckRoundtrip(const ACoder: IDividingCoder;
  const AName: String; const ABytes: TSimpleBaseLibByteArray);
var
  LEncoded: String;
  LDecoded, LDecodeBuf: TSimpleBaseLibByteArray;
  LEncodeBuf: TSimpleBaseLibCharArray;
  LCharsWritten, LBytesWritten, LSafeChars, LSafeBytes: Int32;
begin
  // allocating API
  LEncoded := ACoder.Encode(ABytes);
  LDecoded := ACoder.Decode(LEncoded);
  CheckTrue(AreEqual(ABytes, LDecoded), AName + ' Encode/Decode roundtrip failed');

  // non-allocating API within reported safe sizes
  LSafeChars := ACoder.GetSafeCharCountForEncoding(ABytes);
  CheckTrue(LSafeChars >= System.Length(LEncoded),
    AName + ' GetSafeCharCountForEncoding under-allocated');
  System.SetLength(LEncodeBuf, LSafeChars);
  CheckTrue(ACoder.TryEncode(ABytes, LEncodeBuf, LCharsWritten),
    AName + ' TryEncode failed');
  CheckEquals(LEncoded, CharsToString(LEncodeBuf, LCharsWritten),
    AName + ' TryEncode output mismatch');

  LSafeBytes := ACoder.GetSafeByteCountForDecoding(LEncoded);
  CheckTrue(LSafeBytes >= System.Length(LDecoded),
    AName + ' GetSafeByteCountForDecoding under-allocated');
  System.SetLength(LDecodeBuf, LSafeBytes);
  CheckTrue(ACoder.TryDecode(LEncoded, LDecodeBuf, LBytesWritten),
    AName + ' TryDecode failed');
  CheckTrue(AreEqual(ABytes, System.Copy(LDecodeBuf, 0, LBytesWritten)),
    AName + ' TryDecode output mismatch');
end;

procedure TTestDividingCoder.CheckEdgeBuffers(const ACoder: IDividingCoder;
  const AName: String);
var
  LLens: TSimpleBaseLibInt32Array;
  LI: Int32;
begin
  LLens := TSimpleBaseLibInt32Array.Create(1, 2, 7, 32, 255, 256, 1024, 4096);
  for LI := 0 to High(LLens) do
  begin
    CheckRoundtrip(ACoder, AName + ' 0xFF', MakeFilled(LLens[LI], $FF));
    CheckRoundtrip(ACoder, AName + ' zeros', MakeFilled(LLens[LI], 0));
    CheckRoundtrip(ACoder, AName + ' leading-zeros',
      MakeLeadingZeros(LLens[LI], LLens[LI]));
  end;
end;

procedure TTestDividingCoder.Test_Base58_Roundtrip_EdgeBuffers;
begin
  CheckEdgeBuffers(TBase58.Bitcoin, 'Base58.Bitcoin');
end;

procedure TTestDividingCoder.Test_Base62_Roundtrip_EdgeBuffers;
begin
  CheckEdgeBuffers(TBase62.Default, 'Base62.Default');
end;

procedure TTestDividingCoder.Test_Base36_Roundtrip_EdgeBuffers;
begin
  CheckEdgeBuffers(TBase36.LowerCase, 'Base36.LowerCase');
end;

procedure TTestDividingCoder.Test_SafeSizes_NeverUnderAllocate;
const
  Lens: array[0..6] of Int32 = (1, 100, 1000, 10000, 20000, 50000, 100000);

  procedure CheckOne(const ACoder: IDividingCoder; const AName: String);
  var
    LI, LN, LLen, LMinBytes, LMinChars: Int32;
    LMaxChar: Char;
    LMaxText: String;
    LBytes: TSimpleBaseLibByteArray;
    LBitsPerChar: Double;
    LAlpha: String;
  begin
    LAlpha := ACoder.Alphabet.Value;
    LMaxChar := LAlpha[System.Length(LAlpha)];
    LBitsPerChar := Log2(ACoder.Alphabet.Length);
    for LI := 0 to High(Lens) do
    begin
      LN := Lens[LI];
      // longest value expressible in LN chars needs Ceil(LN * log2(L) / 8) bytes
      LMaxText := StringOfChar(LMaxChar, LN);
      LMinBytes := Ceil(LN * LBitsPerChar / 8);
      CheckTrue(ACoder.GetSafeByteCountForDecoding(LMaxText) >= LMinBytes,
        AName + ' decode size under-allocated at len ' + IntToStr(LN));

      // longest value in LN bytes needs Ceil(LN * 8 / log2(L)) chars
      LLen := LN;
      LBytes := MakeFilled(LLen, $FF);
      LMinChars := Ceil(LLen * 8 / LBitsPerChar);
      CheckTrue(ACoder.GetSafeCharCountForEncoding(LBytes) >= LMinChars,
        AName + ' encode size under-allocated at len ' + IntToStr(LN));
    end;
  end;

begin
  CheckOne(TBase58.Bitcoin, 'Base58.Bitcoin');
  CheckOne(TBase62.Default, 'Base62.Default');
  CheckOne(TBase36.LowerCase, 'Base36.LowerCase');
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestDividingCoder);
{$ELSE}
  RegisterTest(TTestDividingCoder.Suite);
{$ENDIF FPC}

end.
