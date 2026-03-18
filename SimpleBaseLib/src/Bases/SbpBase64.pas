unit SbpBase64;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBase64,
  SbpIBase64Alphabet,
  SbpINonAllocatingBaseCoder,
  SbpIBaseStreamCoder,
  SbpBase64Alphabet,
  SbpStreamUtilities;

type
  TBase64 = class(TInterfacedObject, IBase64, INonAllocatingBaseCoder,
    IBaseStreamCoder)
  strict private
  type
    TBase64Kind = (StandardPadded, StandardNoPad, UrlNoPad, UrlPadded);

  const
    EncodeBlockSize = Int32(3);
    DecodeBlockSize = Int32(4);
    PaddingChar = '=';

  var
    FAlphabet: IBase64Alphabet;
    FPadding: Boolean;
    FKind: TBase64Kind;

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

    class function EncodeInternal(const ABytes: TSimpleBaseLibByteArray;
      const AAlphabetValue: String; APadding: Boolean): String; static;
    class function DecodeInternal(const AText: String;
      const AReverseLookup: TSimpleBaseLibByteArray;
      AAllowNoPadding: Boolean): TSimpleBaseLibByteArray; static;
    class function DecodeValue(AChar: Char;
      const AReverseLookup: TSimpleBaseLibByteArray): Byte; static;
    class function NormalizeTextForDecoding(const AText: String;
      AAllowNoPadding: Boolean): String; static;

    function DecodeBasedOnKind(const AText: String): TSimpleBaseLibByteArray;
    function EncodeBasedOnKind(const ABytes: TSimpleBaseLibByteArray): String;
  public
    class constructor Create;

    constructor Create(const AAlphabet: IBase64Alphabet; APadding: Boolean;
      AKind: TBase64Kind);

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

constructor TBase64.Create(const AAlphabet: IBase64Alphabet; APadding: Boolean;
  AKind: TBase64Kind);
begin
  inherited Create;
  FAlphabet := AAlphabet;
  FPadding := APadding;
  FKind := AKind;
end;

class function TBase64.GetDefault: IBase64;
begin
  if FDefault = nil then
  begin
    FDefault := TBase64.Create(TBase64Alphabet.Default, True, TBase64Kind.StandardPadded);
  end;
  Result := FDefault;
end;

class function TBase64.GetDefaultNoPad: IBase64;
begin
  if FDefaultNoPad = nil then
  begin
    FDefaultNoPad := TBase64.Create(TBase64Alphabet.Default, False, TBase64Kind.StandardNoPad);
  end;
  Result := FDefaultNoPad;
end;

class function TBase64.GetUrl: IBase64;
begin
  if FUrl = nil then
  begin
    FUrl := TBase64.Create(TBase64Alphabet.Url, False, TBase64Kind.UrlNoPad);
  end;
  Result := FUrl;
end;

class function TBase64.GetUrlPadded: IBase64;
begin
  if FUrlPadded = nil then
  begin
    FUrlPadded := TBase64.Create(TBase64Alphabet.Url, True, TBase64Kind.UrlPadded);
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

class function TBase64.EncodeInternal(const ABytes: TSimpleBaseLibByteArray;
  const AAlphabetValue: String; APadding: Boolean): String;
var
  LLen, LWholeBlocks, LRemainder, LOutLen: Int32;
  LI, LOutIndex: Int32;
  LB0, LB1, LB2: Byte;
begin
  LLen := System.Length(ABytes);
  if LLen = 0 then
  begin
    Result := '';
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

  SetLength(Result, LOutLen);
  LI := 0;
  LOutIndex := 1;

  while LI + 2 < LLen do
  begin
    LB0 := ABytes[LI];
    LB1 := ABytes[LI + 1];
    LB2 := ABytes[LI + 2];

    Result[LOutIndex] := AAlphabetValue[(LB0 shr 2) + 1];
    Result[LOutIndex + 1] := AAlphabetValue[(((LB0 and $03) shl 4) or
      (LB1 shr 4)) + 1];
    Result[LOutIndex + 2] := AAlphabetValue[(((LB1 and $0F) shl 2) or
      (LB2 shr 6)) + 1];
    Result[LOutIndex + 3] := AAlphabetValue[(LB2 and $3F) + 1];

    Inc(LI, 3);
    Inc(LOutIndex, 4);
  end;

  if LRemainder = 1 then
  begin
    LB0 := ABytes[LI];
    Result[LOutIndex] := AAlphabetValue[(LB0 shr 2) + 1];
    Result[LOutIndex + 1] := AAlphabetValue[((LB0 and $03) shl 4) + 1];

    if APadding then
    begin
      Result[LOutIndex + 2] := PaddingChar;
      Result[LOutIndex + 3] := PaddingChar;
    end;
  end;
  if LRemainder = 2 then
  begin
    LB0 := ABytes[LI];
    LB1 := ABytes[LI + 1];
    Result[LOutIndex] := AAlphabetValue[(LB0 shr 2) + 1];
    Result[LOutIndex + 1] := AAlphabetValue[(((LB0 and $03) shl 4) or
      (LB1 shr 4)) + 1];
    Result[LOutIndex + 2] := AAlphabetValue[((LB1 and $0F) shl 2) + 1];

    if APadding then
    begin
      Result[LOutIndex + 3] := PaddingChar;
    end;
  end;
end;

class function TBase64.DecodeUrl(const AText: String): TSimpleBaseLibByteArray;
begin
  Result := DecodeInternal(AText, TBase64Alphabet.Url.ReverseLookupTable, True);
end;

class function TBase64.TryDecodeUrl(const AText: String;
  const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LDecoded: TSimpleBaseLibByteArray;
begin
  ABytesWritten := 0;
  try
    LDecoded := DecodeUrl(AText);
    if System.Length(ABytes) < System.Length(LDecoded) then
    begin
      Result := False;
      Exit;
    end;
    if System.Length(LDecoded) > 0 then
    begin
      Move(LDecoded[0], ABytes[0], System.Length(LDecoded));
    end;
    ABytesWritten := System.Length(LDecoded);
    Result := True;
  except
    Result := False;
  end;
end;

function TBase64.DecodeBasedOnKind(const AText: String): TSimpleBaseLibByteArray;
begin
  case FKind of
    TBase64Kind.StandardPadded:
      Result := DecodeInternal(AText, FAlphabet.ReverseLookupTable, False);
    TBase64Kind.StandardNoPad:
      Result := DecodeInternal(AText, FAlphabet.ReverseLookupTable, True);
    TBase64Kind.UrlNoPad:
      Result := DecodeInternal(AText, FAlphabet.ReverseLookupTable, True);
    TBase64Kind.UrlPadded:
      Result := DecodeInternal(AText, FAlphabet.ReverseLookupTable, False);
  else
    raise EInvalidOperationSimpleBaseLibException.Create('Unsupported Base64 mode');
  end;
end;

function TBase64.EncodeBasedOnKind(const ABytes: TSimpleBaseLibByteArray): String;
begin
  case FKind of
    TBase64Kind.StandardPadded:
      Result := EncodeInternal(ABytes, FAlphabet.Value, True);
    TBase64Kind.StandardNoPad:
      Result := EncodeInternal(ABytes, FAlphabet.Value, False);
    TBase64Kind.UrlNoPad:
      Result := EncodeInternal(ABytes, FAlphabet.Value, False);
    TBase64Kind.UrlPadded:
      Result := EncodeInternal(ABytes, FAlphabet.Value, True);
  else
    raise EInvalidOperationSimpleBaseLibException.Create('Unsupported Base64 mode');
  end;
end;

class function TBase64.DecodeValue(AChar: Char;
  const AReverseLookup: TSimpleBaseLibByteArray): Byte;
var
  LOrd: Int32;
begin
  LOrd := Ord(AChar);
  if (LOrd < 0) or (LOrd >= System.Length(AReverseLookup)) then
  begin
    raise EArgumentSimpleBaseLibException.CreateFmt(
      'Invalid Base64 character "%s"', [AChar]);
  end;

  Result := AReverseLookup[LOrd];
  if Result = 0 then
  begin
    raise EArgumentSimpleBaseLibException.CreateFmt(
      'Invalid Base64 character "%s"', [AChar]);
  end;
  Dec(Result);
end;

class function TBase64.NormalizeTextForDecoding(const AText: String;
  AAllowNoPadding: Boolean): String;
var
  LLen, LMod: Int32;
begin
  LLen := System.Length(AText);
  if LLen = 0 then
  begin
    Result := '';
    Exit;
  end;

  LMod := LLen mod 4;
  if not AAllowNoPadding then
  begin
    if LMod <> 0 then
    begin
      raise EArgumentSimpleBaseLibException.Create('Invalid Base64 string length');
    end;
    Result := AText;
    Exit;
  end;

  case LMod of
    0:
      Result := AText;
    2:
      begin
        Result := AText + StringOfChar(PaddingChar, 2);
      end;
    3:
      begin
        Result := AText + PaddingChar;
      end;
  else
    raise EArgumentSimpleBaseLibException.Create('Invalid Base64 string length');
  end;
end;

class function TBase64.EncodeUrl(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := EncodeInternal(ABytes, TBase64Alphabet.Url.Value, False);
end;

class function TBase64.EncodeUrlPadded(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := EncodeInternal(ABytes, TBase64Alphabet.Url.Value, True);
end;

class function TBase64.EncodeWithoutPadding(
  const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := EncodeInternal(ABytes, TBase64Alphabet.Default.Value, False);
end;

class function TBase64.DecodeWithoutPadding(
  const AText: String): TSimpleBaseLibByteArray;
begin
  Result := DecodeInternal(AText, TBase64Alphabet.Default.ReverseLookupTable, True);
end;

class function TBase64.TryDecodeWithoutPadding(const AText: String;
  const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LDecoded: TSimpleBaseLibByteArray;
begin
  ABytesWritten := 0;
  try
    LDecoded := DecodeWithoutPadding(AText);
    if System.Length(ABytes) < System.Length(LDecoded) then
    begin
      Result := False;
      Exit;
    end;
    if System.Length(LDecoded) > 0 then
    begin
      Move(LDecoded[0], ABytes[0], System.Length(LDecoded));
    end;
    ABytesWritten := System.Length(LDecoded);
    Result := True;
  except
    Result := False;
  end;
end;

class function TBase64.DecodeInternal(const AText: String;
  const AReverseLookup: TSimpleBaseLibByteArray;
  AAllowNoPadding: Boolean): TSimpleBaseLibByteArray;
var
  LNormalized: String;
  LLen, LPadCount, LI, LBlockCount, LOutPos, LOutLen: Int32;
  LC1, LC2, LC3, LC4: Char;
  LV1, LV2, LV3, LV4: Byte;
begin
  LNormalized := NormalizeTextForDecoding(AText, AAllowNoPadding);
  LLen := System.Length(LNormalized);
  if LLen = 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  if LLen mod 4 <> 0 then
  begin
    raise EArgumentSimpleBaseLibException.Create('Invalid Base64 string length');
  end;

  LPadCount := 0;
  if LNormalized[LLen] = PaddingChar then
  begin
    LPadCount := 1;
    if (LLen > 1) and (LNormalized[LLen - 1] = PaddingChar) then
    begin
      LPadCount := 2;
    end;
  end;

  for LI := 1 to LLen - LPadCount do
  begin
    if LNormalized[LI] = PaddingChar then
    begin
      raise EArgumentSimpleBaseLibException.Create('Invalid Base64 padding placement');
    end;
  end;

  LBlockCount := LLen div 4;
  LOutLen := (LBlockCount * 3) - LPadCount;
  SetLength(Result, LOutLen);
  LOutPos := 0;

  for LI := 0 to LBlockCount - 1 do
  begin
    LC1 := LNormalized[(LI * 4) + 1];
    LC2 := LNormalized[(LI * 4) + 2];
    LC3 := LNormalized[(LI * 4) + 3];
    LC4 := LNormalized[(LI * 4) + 4];

    LV1 := DecodeValue(LC1, AReverseLookup);
    LV2 := DecodeValue(LC2, AReverseLookup);

    if LC3 = PaddingChar then
    begin
      if (LC4 <> PaddingChar) or (LI <> LBlockCount - 1) then
      begin
        raise EArgumentSimpleBaseLibException.Create('Invalid Base64 padding placement');
      end;
      Result[LOutPos] := Byte((LV1 shl 2) or (LV2 shr 4));
      Break;
    end;

    LV3 := DecodeValue(LC3, AReverseLookup);
    Result[LOutPos] := Byte((LV1 shl 2) or (LV2 shr 4));
    Inc(LOutPos);
    Result[LOutPos] := Byte(((LV2 and $0F) shl 4) or (LV3 shr 2));

    if LC4 = PaddingChar then
    begin
      if LI <> LBlockCount - 1 then
      begin
        raise EArgumentSimpleBaseLibException.Create('Invalid Base64 padding placement');
      end;
      Break;
    end;

    LV4 := DecodeValue(LC4, AReverseLookup);
    Inc(LOutPos);
    Result[LOutPos] := Byte(((LV3 and $03) shl 6) or LV4);
    Inc(LOutPos);
  end;
end;

function TBase64.Decode(const AText: String): TSimpleBaseLibByteArray;
begin
  Result := DecodeBasedOnKind(AText);
end;

function TBase64.Encode(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := EncodeBasedOnKind(ABytes);
end;

function TBase64.GetSafeByteCountForDecoding(const AText: String): Int32;
var
  LLen: Int32;
begin
  LLen := System.Length(AText);

  if FPadding then
  begin
    Result := ((LLen + 3) div 4) * 3;
  end
  else
  begin
    case (LLen mod 4) of
      0:
        Result := (LLen div 4) * 3;
      2:
        Result := ((LLen + 2) div 4) * 3;
      3:
        Result := ((LLen + 1) div 4) * 3;
    else
      Result := ((LLen + 3) div 4) * 3;
    end;
  end;
end;

function TBase64.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
var
  LLen, LRem: Int32;
begin
  LLen := System.Length(ABytes);
  if LLen = 0 then
  begin
    Result := 0;
    Exit;
  end;

  if FPadding then
  begin
    Result := ((LLen + 2) div 3) * 4;
    Exit;
  end;

  Result := (LLen div 3) * 4;
  LRem := LLen mod 3;
  case LRem of
    1:
      Inc(Result, 2);
    2:
      Inc(Result, 3);
  end;
end;

function TBase64.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LDecoded: TSimpleBaseLibByteArray;
begin
  ABytesWritten := 0;
  try
    LDecoded := Decode(AText);
    if System.Length(AOutput) < System.Length(LDecoded) then
    begin
      Result := False;
      Exit;
    end;
    if System.Length(LDecoded) > 0 then
    begin
      Move(LDecoded[0], AOutput[0], System.Length(LDecoded));
    end;
    ABytesWritten := System.Length(LDecoded);
    Result := True;
  except
    Result := False;
  end;
end;

function TBase64.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
var
  LEncoded: String;
  LI: Int32;
begin
  ACharsWritten := 0;
  LEncoded := Encode(ABytes);
  if System.Length(AOutput) < System.Length(LEncoded) then
  begin
    Result := False;
    Exit;
  end;

  for LI := 1 to System.Length(LEncoded) do
  begin
    AOutput[LI - 1] := LEncoded[LI];
  end;
  ACharsWritten := System.Length(LEncoded);
  Result := True;
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
