unit SbpBase64;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpSimpleBaseLibConstants,
  SbpIBase64,
  SbpIBase64Alphabet,
  SbpINonAllocatingBaseCoder,
  SbpIBaseStreamCoder,
  SbpBase64Alphabet,
  SbpCodingAlphabet,
  SbpBitOperations,
  SbpStreamUtilities;

type
  TBase64 = class(TInterfacedObject, IBase64, INonAllocatingBaseCoder,
    IBaseStreamCoder)
  strict private
  type
    TDecodeResult = (
      Success,
      InsufficientOutputBuffer,
      InvalidCharacter,
      InvalidLength,
      InvalidPadding
    );

    TDecodeOutcome = record
      Status: TDecodeResult;
      InvalidChar: Char;
    end;

  const
    EncodeBlockSize = Int32(3);
    DecodeBlockSize = Int32(4);
    PaddingChar = '=';

  var
    FAlphabet: IBase64Alphabet;
    FPadding: Boolean;

    class var FDefault: IBase64;
    class var FDefaultNoPad: IBase64;
    class var FUrl: IBase64;
    class var FUrlPadded: IBase64;

    class function GetDefault: IBase64; static;
    class function GetDefaultNoPad: IBase64; static;
    class function GetUrl: IBase64; static;
    class function GetUrlPadded: IBase64; static;

    function GetAlphabet: IBase64Alphabet;
    function GetPadding: Boolean;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
      ALastBlock: Boolean): String;

    class function InternalEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray;
      const AAlphabetValue: String; APadding: Boolean;
      out ACharsWritten: Int32): Boolean; static;
    class function InternalDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray;
      const AReverseLookup: TSimpleBaseLibByteArray;
      AAllowNoPadding: Boolean;
      out ABytesWritten: Int32): TDecodeOutcome; static;

    class function GetSafeByteCountForDecodingInternal(ATextLength: Int32): Int32; static; inline;
    class function GetSafeCharCountForEncodingInternal(ABytesLength: Int32;
      APadding: Boolean): Int32; static; inline;

    class function AllocatingEncode(const ABytes: TSimpleBaseLibByteArray;
      const AAlphabetValue: String; APadding: Boolean): String; static;
    class function AllocatingDecode(const AText: String;
      const AReverseLookup: TSimpleBaseLibByteArray;
      AAllowNoPadding: Boolean): TSimpleBaseLibByteArray; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: IBase64Alphabet; APadding: Boolean);

    class function DecodeUrl(const AText: String): TSimpleBaseLibByteArray; static;
    class function TryDecodeUrl(const AText: String;
      const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean; static;

    class function EncodeUrl(const ABytes: TSimpleBaseLibByteArray): String; static;
    class function EncodeUrlPadded(const ABytes: TSimpleBaseLibByteArray): String; static;

    class function EncodeWithoutPadding(const ABytes: TSimpleBaseLibByteArray): String; static;
    class function DecodeWithoutPadding(const AText: String): TSimpleBaseLibByteArray; static;
    class function TryDecodeWithoutPadding(const AText: String;
      const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean; static;

    function Decode(const AText: String): TSimpleBaseLibByteArray; overload;
    function Encode(const ABytes: TSimpleBaseLibByteArray): String; overload;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;

    class property Default: IBase64 read GetDefault;
    class property DefaultNoPad: IBase64 read GetDefaultNoPad;
    class property Url: IBase64 read GetUrl;
    class property UrlPadded: IBase64 read GetUrlPadded;

    property Alphabet: IBase64Alphabet read GetAlphabet;
    property Padding: Boolean read GetPadding;
  end;

implementation

{ TBase64 }

class constructor TBase64.Create;
begin
  FDefault := nil;
  FDefaultNoPad := nil;
  FUrl := nil;
  FUrlPadded := nil;
end;

constructor TBase64.Create(const AAlphabet: IBase64Alphabet; APadding: Boolean);
begin
  inherited Create;
  FAlphabet := AAlphabet;
  FPadding := APadding;
end;

class function TBase64.GetDefault: IBase64;
begin
  if FDefault = nil then
  begin
    FDefault := TBase64.Create(TBase64Alphabet.Default, True);
  end;
  Result := FDefault;
end;

class function TBase64.GetDefaultNoPad: IBase64;
begin
  if FDefaultNoPad = nil then
  begin
    FDefaultNoPad := TBase64.Create(TBase64Alphabet.Default, False);
  end;
  Result := FDefaultNoPad;
end;

class function TBase64.GetUrl: IBase64;
begin
  if FUrl = nil then
  begin
    FUrl := TBase64.Create(TBase64Alphabet.Url, False);
  end;
  Result := FUrl;
end;

class function TBase64.GetUrlPadded: IBase64;
begin
  if FUrlPadded = nil then
  begin
    FUrlPadded := TBase64.Create(TBase64Alphabet.Url, True);
  end;
  Result := FUrlPadded;
end;

function TBase64.GetAlphabet: IBase64Alphabet;
begin
  Result := FAlphabet;
end;

function TBase64.GetPadding: Boolean;
begin
  Result := FPadding;
end;

class function TBase64.InternalEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray;
  const AAlphabetValue: String; APadding: Boolean;
  out ACharsWritten: Int32): Boolean;
var
  LLen, LWholeBlocks, LRemainder, LOutLen: Int32;
  LI, LOutIndex: Int32;
  LB0, LB1, LB2: Byte;
begin
  ACharsWritten := 0;
  LLen := System.Length(ABytes);
  if LLen = 0 then
  begin
    Result := True;
    Exit;
  end;

  LWholeBlocks := LLen div 3;
  LRemainder := LLen mod 3;

  LOutLen := LWholeBlocks * 4;
  if LRemainder > 0 then
  begin
    if APadding then
    begin
      Inc(LOutLen, 4);
    end
    else
    begin
      Inc(LOutLen, LRemainder + 1);
    end;
  end;

  if System.Length(AOutput) < LOutLen then
  begin
    Result := False;
    Exit;
  end;

  LI := 0;
  LOutIndex := 0;

  while LI + 2 < LLen do
  begin
    LB0 := ABytes[LI];
    LB1 := ABytes[LI + 1];
    LB2 := ABytes[LI + 2];

    AOutput[LOutIndex] := AAlphabetValue[(LB0 shr 2) + 1];
    AOutput[LOutIndex + 1] := AAlphabetValue[((Int32(LB0 and $03) shl 4) or
      Int32(LB1 shr 4)) + 1];
    AOutput[LOutIndex + 2] := AAlphabetValue[((Int32(LB1 and $0F) shl 2) or
      Int32(LB2 shr 6)) + 1];
    AOutput[LOutIndex + 3] := AAlphabetValue[(LB2 and $3F) + 1];

    Inc(LI, 3);
    Inc(LOutIndex, 4);
  end;

  if LRemainder = 1 then
  begin
    LB0 := ABytes[LI];
    AOutput[LOutIndex] := AAlphabetValue[(LB0 shr 2) + 1];
    AOutput[LOutIndex + 1] := AAlphabetValue[((LB0 and $03) shl 4) + 1];

    if APadding then
    begin
      AOutput[LOutIndex + 2] := PaddingChar;
      AOutput[LOutIndex + 3] := PaddingChar;
    end;
  end;
  if LRemainder = 2 then
  begin
    LB0 := ABytes[LI];
    LB1 := ABytes[LI + 1];
    AOutput[LOutIndex] := AAlphabetValue[(LB0 shr 2) + 1];
    AOutput[LOutIndex + 1] := AAlphabetValue[((Int32(LB0 and $03) shl 4) or
      Int32(LB1 shr 4)) + 1];
    AOutput[LOutIndex + 2] := AAlphabetValue[((LB1 and $0F) shl 2) + 1];

    if APadding then
    begin
      AOutput[LOutIndex + 3] := PaddingChar;
    end;
  end;

  ACharsWritten := LOutLen;
  Result := True;
end;

class function TBase64.InternalDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray;
  const AReverseLookup: TSimpleBaseLibByteArray;
  AAllowNoPadding: Boolean;
  out ABytesWritten: Int32): TDecodeOutcome;
var
  LTextLen, LPadCount, LDataLen, LRemainder: Int32;
  LFullBlocks, LOutLen, LOutPos, LI: Int32;
  LV1, LV2, LV3, LV4: Int32;
begin
  ABytesWritten := 0;
  LTextLen := System.Length(AText);
  if LTextLen = 0 then
  begin
    Result.Status := TDecodeResult.Success;
    Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
    Exit;
  end;

  LPadCount := 0;
  while (LPadCount < LTextLen) and
    (AText[LTextLen - LPadCount] = PaddingChar) do
    Inc(LPadCount);

  if LPadCount > 2 then
  begin
    Result.Status := TDecodeResult.InvalidPadding;
    Result.InvalidChar := PaddingChar;
    Exit;
  end;

  LDataLen := LTextLen - LPadCount;

  if LPadCount > 0 then
  begin
    if (LTextLen mod 4) <> 0 then
    begin
      Result.Status := TDecodeResult.InvalidLength;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;
  end
  else if not AAllowNoPadding then
  begin
    if (LTextLen mod 4) <> 0 then
    begin
      Result.Status := TDecodeResult.InvalidLength;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;
  end;

  LRemainder := LDataLen mod 4;
  if LRemainder = 1 then
  begin
    Result.Status := TDecodeResult.InvalidLength;
    Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
    Exit;
  end;

  for LI := 1 to LDataLen do
  begin
    if AText[LI] = PaddingChar then
    begin
      Result.Status := TDecodeResult.InvalidPadding;
      Result.InvalidChar := PaddingChar;
      Exit;
    end;
  end;

  LFullBlocks := LDataLen div 4;
  LOutLen := LFullBlocks * 3;
  case LRemainder of
    2: Inc(LOutLen, 1);
    3: Inc(LOutLen, 2);
  end;

  if System.Length(AOutput) < LOutLen then
  begin
    Result.Status := TDecodeResult.InsufficientOutputBuffer;
    Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
    Exit;
  end;

  LOutPos := 0;
  LI := 1;

  while LFullBlocks > 0 do
  begin
    if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI], LV1) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := AText[LI];
      Exit;
    end;

    if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI + 1], LV2) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := AText[LI + 1];
      Exit;
    end;

    if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI + 2], LV3) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := AText[LI + 2];
      Exit;
    end;

    if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI + 3], LV4) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := AText[LI + 3];
      Exit;
    end;

    AOutput[LOutPos] := Byte((LV1 shl 2) or TBitOperations.Asr32(LV2, 4));
    AOutput[LOutPos + 1] := Byte(((LV2 and $0F) shl 4) or TBitOperations.Asr32(LV3, 2));
    AOutput[LOutPos + 2] := Byte(((LV3 and $03) shl 6) or LV4);

    Inc(LOutPos, 3);
    Inc(LI, 4);
    Dec(LFullBlocks);
  end;

  if LRemainder >= 2 then
  begin
    if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI], LV1) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := AText[LI];
      Exit;
    end;
    if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI + 1], LV2) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := AText[LI + 1];
      Exit;
    end;

    AOutput[LOutPos] := Byte((LV1 shl 2) or TBitOperations.Asr32(LV2, 4));
    Inc(LOutPos);

    if LRemainder = 3 then
    begin
      if not TCodingAlphabet.TryLookup(AReverseLookup, AText[LI + 2], LV3) then
      begin
        Result.Status := TDecodeResult.InvalidCharacter;
        Result.InvalidChar := AText[LI + 2];
        Exit;
      end;

      AOutput[LOutPos] := Byte(((LV2 and $0F) shl 4) or TBitOperations.Asr32(LV3, 2));
    end;
  end;

  ABytesWritten := LOutLen;
  Result.Status := TDecodeResult.Success;
  Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
end;

class function TBase64.GetSafeByteCountForDecodingInternal(ATextLength: Int32): Int32;
begin
  Result := ((ATextLength + 3) div 4) * 3;
end;

class function TBase64.GetSafeCharCountForEncodingInternal(ABytesLength: Int32;
  APadding: Boolean): Int32;
begin
  if ABytesLength = 0 then
  begin
    Result := 0;
    Exit;
  end;
  if APadding then
    Result := ((ABytesLength + 2) div 3) * 4
  else
    Result := (ABytesLength * 4 + 2) div 3;
end;

class function TBase64.AllocatingEncode(const ABytes: TSimpleBaseLibByteArray;
  const AAlphabetValue: String; APadding: Boolean): String;
var
  LLen, LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  LLen := System.Length(ABytes);
  if LLen = 0 then
  begin
    Result := '';
    Exit;
  end;

  LOutputLen := GetSafeCharCountForEncodingInternal(LLen, True);
  System.SetLength(LOutput, LOutputLen);
  if not InternalEncode(ABytes, LOutput, AAlphabetValue, APadding, LCharsWritten) then
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Internal error: insufficient output buffer size');
  end;
  SetString(Result, PChar(@LOutput[0]), LCharsWritten);
end;

class function TBase64.AllocatingDecode(const AText: String;
  const AReverseLookup: TSimpleBaseLibByteArray;
  AAllowNoPadding: Boolean): TSimpleBaseLibByteArray;
var
  LDecodeBufferLen, LBytesWritten: Int32;
  LDecodeBuffer: TSimpleBaseLibByteArray;
  LOutcome: TDecodeOutcome;
begin
  if System.Length(AText) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  LDecodeBufferLen := GetSafeByteCountForDecodingInternal(System.Length(AText));
  System.SetLength(LDecodeBuffer, LDecodeBufferLen);
  LOutcome := InternalDecode(AText, LDecodeBuffer, AReverseLookup,
    AAllowNoPadding, LBytesWritten);
  case LOutcome.Status of
    TDecodeResult.Success:
      Result := System.Copy(LDecodeBuffer, 0, LBytesWritten);
    TDecodeResult.InvalidCharacter:
      raise EArgumentSimpleBaseLibException.CreateFmt(
        'Invalid Base64 character "%s"', [LOutcome.InvalidChar]);
    TDecodeResult.InvalidLength:
      raise EArgumentSimpleBaseLibException.Create('Invalid Base64 string length');
    TDecodeResult.InvalidPadding:
      raise EArgumentSimpleBaseLibException.Create('Invalid Base64 padding placement');
    TDecodeResult.InsufficientOutputBuffer:
      raise EInvalidOperationSimpleBaseLibException.Create(
        'Internal error: insufficient output buffer size');
  else
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Unexpected decode result');
  end;
end;

class function TBase64.DecodeUrl(const AText: String): TSimpleBaseLibByteArray;
begin
  Result := AllocatingDecode(AText, TBase64Alphabet.Url.ReverseLookupTable, True);
end;

class function TBase64.TryDecodeUrl(const AText: String;
  const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LOutcome: TDecodeOutcome;
begin
  ABytesWritten := 0;
  if System.Length(AText) = 0 then
  begin
    Result := True;
    Exit;
  end;
  if System.Length(ABytes) < GetSafeByteCountForDecodingInternal(System.Length(AText)) then
  begin
    Result := False;
    Exit;
  end;
  LOutcome := InternalDecode(AText, ABytes,
    TBase64Alphabet.Url.ReverseLookupTable, True, ABytesWritten);
  Result := LOutcome.Status = TDecodeResult.Success;
end;

class function TBase64.EncodeUrl(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := AllocatingEncode(ABytes, TBase64Alphabet.Url.Value, False);
end;

class function TBase64.EncodeUrlPadded(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := AllocatingEncode(ABytes, TBase64Alphabet.Url.Value, True);
end;

class function TBase64.EncodeWithoutPadding(
  const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := AllocatingEncode(ABytes, TBase64Alphabet.Default.Value, False);
end;

class function TBase64.DecodeWithoutPadding(
  const AText: String): TSimpleBaseLibByteArray;
begin
  Result := AllocatingDecode(AText, TBase64Alphabet.Default.ReverseLookupTable, True);
end;

class function TBase64.TryDecodeWithoutPadding(const AText: String;
  const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LOutcome: TDecodeOutcome;
begin
  ABytesWritten := 0;
  if System.Length(AText) = 0 then
  begin
    Result := True;
    Exit;
  end;
  if System.Length(ABytes) < GetSafeByteCountForDecodingInternal(System.Length(AText)) then
  begin
    Result := False;
    Exit;
  end;
  LOutcome := InternalDecode(AText, ABytes,
    TBase64Alphabet.Default.ReverseLookupTable, True, ABytesWritten);
  Result := LOutcome.Status = TDecodeResult.Success;
end;

function TBase64.Decode(const AText: String): TSimpleBaseLibByteArray;
begin
  Result := AllocatingDecode(AText, FAlphabet.ReverseLookupTable, not FPadding);
end;

function TBase64.Encode(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := AllocatingEncode(ABytes, FAlphabet.Value, FPadding);
end;

function TBase64.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := GetSafeByteCountForDecodingInternal(System.Length(AText));
end;

function TBase64.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := GetSafeCharCountForEncodingInternal(System.Length(ABytes), FPadding);
end;

function TBase64.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LOutcome: TDecodeOutcome;
begin
  ABytesWritten := 0;
  if System.Length(AText) = 0 then
  begin
    Result := True;
    Exit;
  end;
  if System.Length(AOutput) < GetSafeByteCountForDecodingInternal(System.Length(AText)) then
  begin
    Result := False;
    Exit;
  end;
  LOutcome := InternalDecode(AText, AOutput,
    FAlphabet.ReverseLookupTable, not FPadding, ABytesWritten);
  Result := LOutcome.Status = TDecodeResult.Success;
end;

function TBase64.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
begin
  ACharsWritten := 0;
  if System.Length(ABytes) = 0 then
  begin
    Result := True;
    Exit;
  end;
  if System.Length(AOutput) < GetSafeCharCountForEncoding(ABytes) then
  begin
    Result := False;
    Exit;
  end;
  Result := InternalEncode(ABytes, AOutput, FAlphabet.Value,
    FPadding, ACharsWritten);
end;

function TBase64.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase64.EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes);
end;

procedure TBase64.Decode(const AInput: TStringBuilder; const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

procedure TBase64.Encode(const AInput: TStream; const AOutput: TStringBuilder);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  TStreamUtilities.Encode(AInput, AOutput, EncodeBuffer, LBufferSize);
end;

end.
