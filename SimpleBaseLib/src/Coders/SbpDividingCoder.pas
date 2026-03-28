unit SbpDividingCoder;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  Math,
  SbpSimpleBaseLibTypes,
  SbpSimpleBaseLibConstants,
  SbpArrayUtilities,
  SbpICodingAlphabet,
  SbpCodingAlphabet,
  SbpIBaseCoder,
  SbpIDividingCoder,
  SbpINonAllocatingBaseCoder,
  SbpBitOperations,
  SbpBits;

type
  /// <summary>
  /// Dividing Encoding/Decoding implementation to be used by other dividing encoders.
  /// Dividing encoding schemes can't encode prefixing zeroes due to mathematical insignificance
  /// of them. So they're always encoded as hardcoded zero characters at the beginning.
  /// </summary>
  TDividingCoder = class abstract(TInterfacedObject,
    IBaseCoder, INonAllocatingBaseCoder, IDividingCoder)
  strict private
  type
    TDecodeResult = (
      Success,
      InvalidCharacter,
      InsufficientOutputBuffer
    );

    TDecodeOutcome = record
      Status: TDecodeResult;
      InvalidChar: Char;
    end;

    TRangeWritten = record
      Start: Int32;
      Finish: Int32;
    end;

  var
    FAlphabet: ICodingAlphabet;
    FReductionFactor: Int32;
    FZeroChar: Char;

    function GetSafeByteCountForDecodingInternal(ATextLen: Int32; AZeroPrefixLen: Int32): Int32; inline;
    function GetSafeCharCountForEncodingInternal(ABytesLen: Int32; AZeroPrefixLen: Int32): Int32; inline;

    class function CountPrefixChars(const AText: String; AZeroChar: Char): Int32; static;

    class procedure TranslatedCopy(const ASource: TSimpleBaseLibCharArray;
      ASourceOffset: Int32; const ADestination: TSimpleBaseLibCharArray;
      ADestOffset: Int32; ACount: Int32;
      const AAlphabet: String);

    function InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; AZeroPrefixLen: Int32;
      out ACharsWritten: Int32): Boolean;

    function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; AZeroPrefixLen: Int32;
      out ARangeWritten: TRangeWritten): TDecodeOutcome;

  strict protected
    function GetAlphabet: ICodingAlphabet;

  public
    constructor Create(const AAlphabet: ICodingAlphabet);

    function GetSafeByteCountForDecoding(const AText: String): Int32; virtual;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32; virtual;

    function Encode(const ABytes: TSimpleBaseLibByteArray): String;
    function Decode(const AText: String): TSimpleBaseLibByteArray;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray;
      out ACharsWritten: Int32): Boolean;
    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;

    property Alphabet: ICodingAlphabet read GetAlphabet;
  end;

implementation

{ TDividingCoder }

constructor TDividingCoder.Create(const AAlphabet: ICodingAlphabet);
var
  LAlphabetValue: String;
begin
  inherited Create;
  FAlphabet := AAlphabet;
  LAlphabetValue := FAlphabet.Value;
  FReductionFactor := Trunc(1000 * Log2(System.Length(LAlphabetValue)) / 8);
  FZeroChar := LAlphabetValue[1];
end;

function TDividingCoder.GetAlphabet: ICodingAlphabet;
begin
  Result := FAlphabet;
end;

class function TDividingCoder.CountPrefixChars(
  const AText: String; AZeroChar: Char): Int32;
var
  LI: Int32;
begin
  for LI := 1 to System.Length(AText) do
  begin
    if AText[LI] <> AZeroChar then
    begin
      Result := LI - 1;
      Exit;
    end;
  end;
  Result := System.Length(AText);
end;

function TDividingCoder.GetSafeByteCountForDecodingInternal(
  ATextLen: Int32; AZeroPrefixLen: Int32): Int32;
begin
  Result := AZeroPrefixLen + ((ATextLen - AZeroPrefixLen) * FReductionFactor div 1000) + 1;
end;

function TDividingCoder.GetSafeCharCountForEncodingInternal(
  ABytesLen: Int32; AZeroPrefixLen: Int32): Int32;
begin
  Result := AZeroPrefixLen + ((ABytesLen - AZeroPrefixLen) * 1000 div FReductionFactor) + 1;
end;

function TDividingCoder.GetSafeByteCountForDecoding(
  const AText: String): Int32;
begin
  Result := GetSafeByteCountForDecodingInternal(System.Length(AText),
    CountPrefixChars(AText, FZeroChar));
end;

function TDividingCoder.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := GetSafeCharCountForEncodingInternal(System.Length(ABytes),
    TBits.CountPrefixingZeroes(ABytes));
end;

class procedure TDividingCoder.TranslatedCopy(
  const ASource: TSimpleBaseLibCharArray; ASourceOffset: Int32;
  const ADestination: TSimpleBaseLibCharArray; ADestOffset: Int32;
  ACount: Int32; const AAlphabet: String);
var
  LN: Int32;
begin
  if ACount <= 0 then
  begin
    Exit;
  end;

  for LN := 0 to ACount - 1 do
  begin
    ADestination[ADestOffset + LN] := AAlphabet[Ord(ASource[ASourceOffset + LN]) + 1];
  end;
end;

function TDividingCoder.InternalEncode(
  const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; AZeroPrefixLen: Int32;
  out ACharsWritten: Int32): Boolean;
var
  LAlphabet: String;
  LNumDigits, LIndex, LDivisor, LCarry, LI, LJ, LRemainder: Int32;
  LOutputLen: Int32;
begin
  if System.Length(AInput) = 0 then
  begin
    ACharsWritten := 0;
    Result := True;
    Exit;
  end;

  LAlphabet := FAlphabet.Value;
  LOutputLen := System.Length(AOutput);

  if AZeroPrefixLen > 0 then
  begin
    TArrayUtilities.Fill<Char>(AOutput, 0, AZeroPrefixLen, FZeroChar);
  end;

  LNumDigits := 0;
  LIndex := AZeroPrefixLen;
  LDivisor := System.Length(LAlphabet);

  while LIndex < System.Length(AInput) do
  begin
    LCarry := AInput[LIndex];
    Inc(LIndex);
    LI := 0;
    LJ := LOutputLen - 1;
    while ((LCarry <> 0) or (LI < LNumDigits)) and (LJ >= 0) do
    begin
      LCarry := LCarry + (Int32(Ord(AOutput[LJ])) shl 8);
      LRemainder := LCarry mod LDivisor;
      LCarry := LCarry div LDivisor;
      AOutput[LJ] := Char(LRemainder);
      Dec(LJ);
      Inc(LI);
    end;
    LNumDigits := LI;
  end;

  TranslatedCopy(AOutput, LOutputLen - LNumDigits,
    AOutput, AZeroPrefixLen, LNumDigits, LAlphabet);

  ACharsWritten := AZeroPrefixLen + LNumDigits;
  Result := True;
end;

function TDividingCoder.InternalDecode(
  const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; AZeroPrefixLen: Int32;
  out ARangeWritten: TRangeWritten): TDecodeOutcome;
var
  LTable: TSimpleBaseLibByteArray;
  LMin, LDivisor, LI, LCarry, LO: Int32;
  LCh: Char;
  LOutputLen: Int32;
begin
  LTable := FAlphabet.ReverseLookupTable;
  LOutputLen := System.Length(AOutput);
  LMin := LOutputLen;
  LDivisor := System.Length(FAlphabet.Value);

  for LI := AZeroPrefixLen + 1 to System.Length(AInput) do
  begin
    LCh := AInput[LI];
    if not TCodingAlphabet.TryLookup(LTable, LCh, LCarry) then
    begin
      ARangeWritten.Start := 0;
      ARangeWritten.Finish := 0;
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LCh;
      Exit;
    end;

    for LO := LOutputLen - 1 downto 0 do
    begin
      LCarry := LCarry + (LDivisor * AOutput[LO]);
      AOutput[LO] := Byte(LCarry);
      if (LMin > LO) and (LCarry <> 0) then
      begin
        LMin := LO;
      end;
      LCarry := TBitOperations.Asr32(LCarry, 8);
    end;
  end;

  if AZeroPrefixLen > 0 then
  begin
    if LMin < AZeroPrefixLen then
    begin
      ARangeWritten.Start := 0;
      ARangeWritten.Finish := 0;
      Result.Status := TDecodeResult.InsufficientOutputBuffer;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;
    TArrayUtilities.Fill<Byte>(AOutput, LMin - AZeroPrefixLen, LMin, Byte(0));
    LMin := LMin - AZeroPrefixLen;
  end;

  ARangeWritten.Start := LMin;
  ARangeWritten.Finish := LOutputLen;
  Result.Status := TDecodeResult.Success;
  Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
end;

function TDividingCoder.Encode(
  const ABytes: TSimpleBaseLibByteArray): String;
var
  LZeroPrefixLen, LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  if System.Length(ABytes) = 0 then
  begin
    Result := '';
    Exit;
  end;

  LZeroPrefixLen := TBits.CountPrefixingZeroes(ABytes);
  LOutputLen := GetSafeCharCountForEncodingInternal(System.Length(ABytes), LZeroPrefixLen);
  System.SetLength(LOutput, LOutputLen);

  if InternalEncode(ABytes, LOutput, LZeroPrefixLen, LCharsWritten) then
  begin
    SetString(Result, PChar(@LOutput[0]), LCharsWritten);
  end
  else
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Internal error: insufficient output buffer size');
  end;
end;

function TDividingCoder.Decode(
  const AText: String): TSimpleBaseLibByteArray;
var
  LZeroPrefixLen, LOutputLen: Int32;
  LOutput: TSimpleBaseLibByteArray;
  LRangeWritten: TRangeWritten;
  LOutcome: TDecodeOutcome;
  LRangeLen: Int32;
begin
  if System.Length(AText) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  LZeroPrefixLen := CountPrefixChars(AText, FZeroChar);
  LOutputLen := GetSafeByteCountForDecodingInternal(System.Length(AText), LZeroPrefixLen);
  System.SetLength(LOutput, LOutputLen);

  LOutcome := InternalDecode(AText, LOutput, LZeroPrefixLen, LRangeWritten);

  case LOutcome.Status of
    TDecodeResult.InvalidCharacter:
      raise EArgumentSimpleBaseLibException.CreateFmt('Invalid character: %s',
        [LOutcome.InvalidChar]);
    TDecodeResult.InsufficientOutputBuffer:
      raise EInvalidOperationSimpleBaseLibException.Create(
        'Internal error: insufficient output buffer size');
    TDecodeResult.Success:
      begin
        LRangeLen := LRangeWritten.Finish - LRangeWritten.Start;
        Result := System.Copy(LOutput, LRangeWritten.Start, LRangeLen);
      end;
  else
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Unexpected decode result');
  end;
end;

function TDividingCoder.TryEncode(
  const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray;
  out ACharsWritten: Int32): Boolean;
var
  LOutput: TSimpleBaseLibCharArray;
begin
  if System.Length(ABytes) = 0 then
  begin
    ACharsWritten := 0;
    Result := True;
    Exit;
  end;
  if System.Length(AOutput) < GetSafeCharCountForEncoding(ABytes) then
  begin
    ACharsWritten := 0;
    Result := False;
    Exit;
  end;
  LOutput := AOutput;
  if System.Length(LOutput) > 0 then
  begin
    TArrayUtilities.Fill<Char>(LOutput, 0, System.Length(LOutput), TSimpleBaseLibConstants.NullChar);
  end;
  Result := InternalEncode(ABytes, LOutput,
    TBits.CountPrefixingZeroes(ABytes), ACharsWritten);
end;

function TDividingCoder.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray;
  out ABytesWritten: Int32): Boolean;
var
  LZeroPrefixLen: Int32;
  LRangeWritten: TRangeWritten;
  LOutcome: TDecodeOutcome;
  LOutput: TSimpleBaseLibByteArray;
  LRangeLen, LI: Int32;
begin
  if System.Length(AText) = 0 then
  begin
    ABytesWritten := 0;
    Result := True;
    Exit;
  end;

  if System.Length(AOutput) < GetSafeByteCountForDecoding(AText) then
  begin
    ABytesWritten := 0;
    Result := False;
    Exit;
  end;
  LZeroPrefixLen := CountPrefixChars(AText, FZeroChar);
  LOutput := AOutput;
  if System.Length(LOutput) > 0 then
  begin
    TArrayUtilities.Fill<Byte>(LOutput, 0, System.Length(LOutput), Byte(0));
  end;
  LOutcome := InternalDecode(AText, LOutput, LZeroPrefixLen, LRangeWritten);

  LRangeLen := LRangeWritten.Finish - LRangeWritten.Start;

  // copy rangeWritten portion to the beginning of output
  for LI := 0 to LRangeLen - 1 do
  begin
    LOutput[LI] := LOutput[LRangeWritten.Start + LI];
  end;

  ABytesWritten := LRangeLen;
  Result := LOutcome.Status = TDecodeResult.Success;
end;

end.
