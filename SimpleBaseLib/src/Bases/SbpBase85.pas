unit SbpBase85;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpSimpleBaseLibConstants,
  SbpIBase85,
  SbpIBase85Alphabet,
  SbpINonAllocatingBaseCoder,
  SbpIBaseStreamCoder,
  SbpBase85Alphabet,
  SbpCodingAlphabet,
  SbpBitOperations,
  SbpStreamUtilities;

type
  TBase85 = class(TInterfacedObject, IBase85, IBaseStreamCoder, INonAllocatingBaseCoder)
  strict private
    type
    TDecodeResult = (
      Success,
      InsufficientOutputBuffer,
      InvalidCharacter,
      InvalidShortcut
    );

    TDecodeOutcome = record
      Status: TDecodeResult;
      InvalidChar: Char;
    end;

    const
    BaseLength = Int32(85);
    EncodeBlockSize = Int32(4);
    DecodeBlockSize = Int32(5);
    FourSpaceChars = Int64($20202020);

    var
    FAlphabet: IBase85Alphabet;
    class var FZ85: IBase85;
    class var FAscii85: IBase85;
    class function GetZ85: IBase85; static;
    class function GetAscii85: IBase85; static;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBuffer(ABytes: TSimpleBaseLibByteArray; ALastBlock: Boolean): String;
    function GetAlphabet: IBase85Alphabet;

    class function IsWhiteSpace(AChar: Char): Boolean; static; inline;
    class function GetSafeCharCountForEncodingInternal(ABytesLength: Int32): Int32; static;
    class function GetSafeByteCountForDecodingInternal(ATextLength: Int32;
      AUsingShortcuts: Boolean): Int32; static;

    class function WriteEncodedValue(ABlock: UInt32;
      const AOutput: TSimpleBaseLibCharArray; AOutputOffset: Int32;
      const ATable: String; ABlockLength: Int32;
      AHasZeroShortcut: Boolean; AZeroShortcut: Char;
      AHasSpaceShortcut: Boolean; ASpaceShortcut: Char;
      out ACharsWritten: Int32): Boolean; static;

    class function WriteDecodedValue(const AOutput: TSimpleBaseLibByteArray;
      AOutputOffset: Int32; AValue: Int64; ANumBytesToWrite: Int32;
      out ABytesWritten: Int32): TDecodeResult; static;

    class function WriteShortcut(const AOutput: TSimpleBaseLibByteArray;
      AOutputOffset: Int32; var ABlockIndex: Int32; AValue: Int64;
      out ABytesWritten: Int32): TDecodeResult; static;

    function InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
    function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeOutcome;
  public
    class constructor Create;

    constructor Create(const AAlphabet: IBase85Alphabet);

    class property Z85: IBase85 read GetZ85;
    class property Ascii85: IBase85 read GetAscii85;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function Encode(const ABytes: TSimpleBaseLibByteArray): String; overload;
    function Decode(const AText: String): TSimpleBaseLibByteArray; overload;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;

    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;
    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;

    property Alphabet: IBase85Alphabet read GetAlphabet;
  end;

implementation

{ TBase85 }

class constructor TBase85.Create;
begin
  FZ85 := nil;
  FAscii85 := nil;
end;

constructor TBase85.Create(const AAlphabet: IBase85Alphabet);
begin
  inherited Create;
  FAlphabet := AAlphabet;
end;

class function TBase85.GetZ85: IBase85;
begin
  if FZ85 = nil then
  begin
    FZ85 := TBase85.Create(TBase85Alphabet.Z85);
  end;
  Result := FZ85;
end;

class function TBase85.GetAscii85: IBase85;
begin
  if FAscii85 = nil then
  begin
    FAscii85 := TBase85.Create(TBase85Alphabet.Ascii85);
  end;
  Result := FAscii85;
end;

function TBase85.GetAlphabet: IBase85Alphabet;
begin
  Result := FAlphabet;
end;

function TBase85.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := GetSafeByteCountForDecodingInternal(System.Length(AText), FAlphabet.HasShortcut);
end;

function TBase85.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := GetSafeCharCountForEncodingInternal(System.Length(ABytes));
end;

class function TBase85.GetSafeCharCountForEncodingInternal(ABytesLength: Int32): Int32;
begin
  if ABytesLength = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := (ABytesLength + EncodeBlockSize - 1) * DecodeBlockSize div EncodeBlockSize;
end;

class function TBase85.GetSafeByteCountForDecodingInternal(ATextLength: Int32;
  AUsingShortcuts: Boolean): Int32;
begin
  if ATextLength = 0 then
  begin
    Result := 0;
    Exit;
  end;
  if AUsingShortcuts then
  begin
    Result := ATextLength * EncodeBlockSize;
    Exit;
  end;
  Result := (((ATextLength - 1) div DecodeBlockSize) + 1) * EncodeBlockSize;
end;

function TBase85.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase85.EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes);
end;

procedure TBase85.Encode(const AInput: TStream; const AOutput: TStringBuilder);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  TStreamUtilities.Encode(AInput, AOutput, EncodeBuffer, LBufferSize);
end;

procedure TBase85.Decode(const AInput: TStringBuilder; const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

function TBase85.Encode(const ABytes: TSimpleBaseLibByteArray): String;
var
  LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  if System.Length(ABytes) = 0 then
  begin
    Result := '';
    Exit;
  end;

  LOutputLen := GetSafeCharCountForEncoding(ABytes);
  System.SetLength(LOutput, LOutputLen);
  if not InternalEncode(ABytes, LOutput, LCharsWritten) then
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Internal error: insufficient output buffer size');
  end;
  SetString(Result, PChar(@LOutput[0]), LCharsWritten);
end;

function TBase85.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
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
  Result := InternalEncode(ABytes, AOutput, ACharsWritten);
end;

function TBase85.Decode(const AText: String): TSimpleBaseLibByteArray;
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

  LDecodeBufferLen := GetSafeByteCountForDecodingInternal(System.Length(AText), FAlphabet.HasShortcut);
  System.SetLength(LDecodeBuffer, LDecodeBufferLen);
  LOutcome := InternalDecode(AText, LDecodeBuffer, LBytesWritten);
  case LOutcome.Status of
    TDecodeResult.Success:
      Result := System.Copy(LDecodeBuffer, 0, LBytesWritten);
    TDecodeResult.InvalidCharacter:
      raise EArgumentSimpleBaseLibException.CreateFmt('Invalid character: %s', [LOutcome.InvalidChar]);
    TDecodeResult.InvalidShortcut:
      raise EArgumentSimpleBaseLibException.CreateFmt(
        'Invalid location for a shortcut character: %s', [LOutcome.InvalidChar]);
    TDecodeResult.InsufficientOutputBuffer:
      raise EInvalidOperationSimpleBaseLibException.Create(
        'Internal error: insufficient output buffer size');
  else
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Unexpected decode result');
  end;
end;

function TBase85.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LOutcome: TDecodeOutcome;
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
  LOutcome := InternalDecode(AText, AOutput, ABytesWritten);
  Result := LOutcome.Status = TDecodeResult.Success;
end;

class function TBase85.IsWhiteSpace(AChar: Char): Boolean;
begin
  Result := (AChar = TSimpleBaseLibConstants.WhiteSpaceChar) or
    (AChar = TSimpleBaseLibConstants.WhiteSpaceNELChar) or
    (AChar = TSimpleBaseLibConstants.WhiteSpaceNBSPChar) or
    ((AChar >= TSimpleBaseLibConstants.WhiteSpaceControlMinChar) and
    (AChar <= TSimpleBaseLibConstants.WhiteSpaceControlMaxChar));
end;

class function TBase85.WriteEncodedValue(ABlock: UInt32;
  const AOutput: TSimpleBaseLibCharArray; AOutputOffset: Int32; const ATable: String;
  ABlockLength: Int32; AHasZeroShortcut: Boolean; AZeroShortcut: Char;
  AHasSpaceShortcut: Boolean; ASpaceShortcut: Char; out ACharsWritten: Int32): Boolean;
var
  LI: Int32;
  LRemainder: UInt32;
begin
  if (System.Length(AOutput) - AOutputOffset) = 0 then
  begin
    ACharsWritten := 0;
    Result := False;
    Exit;
  end;

  if (ABlock = 0) and AHasZeroShortcut then
  begin
    AOutput[AOutputOffset] := AZeroShortcut;
    ACharsWritten := 1;
    Result := True;
    Exit;
  end;

  if (ABlock = UInt32(FourSpaceChars)) and AHasSpaceShortcut then
  begin
    AOutput[AOutputOffset] := ASpaceShortcut;
    ACharsWritten := 1;
    Result := True;
    Exit;
  end;

  if ABlockLength > (System.Length(AOutput) - AOutputOffset) then
  begin
    ACharsWritten := 0;
    Result := False;
    Exit;
  end;

  for LI := DecodeBlockSize - 1 downto 0 do
  begin
    LRemainder := ABlock mod UInt32(BaseLength);
    ABlock := ABlock div UInt32(BaseLength);
    if LI < ABlockLength then
    begin
      AOutput[AOutputOffset + LI] := ATable[Int32(LRemainder) + 1];
    end;
  end;

  ACharsWritten := ABlockLength;
  Result := True;
end;

class function TBase85.WriteDecodedValue(const AOutput: TSimpleBaseLibByteArray;
  AOutputOffset: Int32; AValue: Int64; ANumBytesToWrite: Int32;
  out ABytesWritten: Int32): TDecodeResult;
var
  LO, LI: Int32;
begin
  if ANumBytesToWrite > (System.Length(AOutput) - AOutputOffset) then
  begin
    ABytesWritten := 0;
    Result := TDecodeResult.InsufficientOutputBuffer;
    Exit;
  end;

  LO := 0;
  for LI := EncodeBlockSize - 1 downto 0 do
  begin
    if ANumBytesToWrite < 1 then
    begin
      Break;
    end;
    AOutput[AOutputOffset + LO] := Byte(TBitOperations.Asr64(AValue, LI * 8) and $FF);
    Inc(LO);
    Dec(ANumBytesToWrite);
  end;

  ABytesWritten := LO;
  Result := TDecodeResult.Success;
end;

class function TBase85.WriteShortcut(const AOutput: TSimpleBaseLibByteArray;
  AOutputOffset: Int32; var ABlockIndex: Int32; AValue: Int64;
  out ABytesWritten: Int32): TDecodeResult;
begin
  if ABlockIndex <> 0 then
  begin
    ABytesWritten := 0;
    Result := TDecodeResult.InvalidShortcut;
    Exit;
  end;

  Result := WriteDecodedValue(AOutput, AOutputOffset, AValue, EncodeBlockSize, ABytesWritten);
end;

function TBase85.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
var
  LUsesZeroShortcut, LUsesSpaceShortcut: Boolean;
  LZeroShortcut, LSpaceShortcut: Char;
  LTable: String;
  LFullLen, LI, LNumWritten, LRemainingBytes, LN: Int32;
  LBlock, LLastBlock: UInt32;
begin
  LUsesZeroShortcut := FAlphabet.HasAllZeroShortcut;
  LUsesSpaceShortcut := FAlphabet.HasAllSpaceShortcut;
  LZeroShortcut := FAlphabet.AllZeroShortcut;
  LSpaceShortcut := FAlphabet.AllSpaceShortcut;
  LTable := FAlphabet.Value;
  LFullLen := System.Length(AInput) div EncodeBlockSize * EncodeBlockSize;

  LI := 0;
  ACharsWritten := 0;
  while LI < LFullLen do
  begin
    LBlock := (UInt32(AInput[LI]) shl 24) or
      (UInt32(AInput[LI + 1]) shl 16) or
      (UInt32(AInput[LI + 2]) shl 8) or
      UInt32(AInput[LI + 3]);
    Inc(LI, 4);

    if not WriteEncodedValue(LBlock, AOutput, ACharsWritten, LTable, DecodeBlockSize,
      LUsesZeroShortcut, LZeroShortcut, LUsesSpaceShortcut, LSpaceShortcut, LNumWritten) then
    begin
      ACharsWritten := ACharsWritten + LNumWritten;
      Result := False;
      Exit;
    end;
    ACharsWritten := ACharsWritten + LNumWritten;
  end;

  LRemainingBytes := System.Length(AInput) - LFullLen;
  if LRemainingBytes = 0 then
  begin
    Result := True;
    Exit;
  end;

  LLastBlock := 0;
  for LN := 0 to LRemainingBytes - 1 do
  begin
    LLastBlock := LLastBlock or (UInt32(AInput[LI + LN]) shl ((3 - LN) * 8));
  end;

  if not WriteEncodedValue(LLastBlock, AOutput, ACharsWritten, LTable, LRemainingBytes + 1,
    LUsesZeroShortcut, LZeroShortcut, LUsesSpaceShortcut, LSpaceShortcut, LNumWritten) then
  begin
    Result := False;
    Exit;
  end;

  ACharsWritten := ACharsWritten + LNumWritten;
  Result := True;
end;

function TBase85.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeOutcome;
var
  LAllZeroChar, LAllSpaceChar: Char;
  LHasAllZeroChar, LHasAllSpaceChar: Boolean;
  LTable: TSimpleBaseLibByteArray;
  LBlockIndex, LI, LBytesWrittenNow, LX: Int32;
  LValue: Int64;
  LC: Char;
  LDecodeResult: TDecodeResult;
  LN: Int32;
begin
  LAllZeroChar := FAlphabet.AllZeroShortcut;
  LAllSpaceChar := FAlphabet.AllSpaceShortcut;
  LHasAllZeroChar := FAlphabet.HasAllZeroShortcut;
  LHasAllSpaceChar := FAlphabet.HasAllSpaceShortcut;
  LTable := FAlphabet.ReverseLookupTable;

  LBlockIndex := 0;
  LValue := 0;
  LI := 1;
  ABytesWritten := 0;
  while LI <= System.Length(AInput) do
  begin
    LC := AInput[LI];
    Inc(LI);
    if IsWhiteSpace(LC) then
    begin
      Continue;
    end;

    if LHasAllZeroChar and (LC = LAllZeroChar) then
    begin
      LDecodeResult := WriteShortcut(AOutput, ABytesWritten, LBlockIndex, 0, LBytesWrittenNow);
      if LDecodeResult <> TDecodeResult.Success then
      begin
        Result.Status := LDecodeResult;
        Result.InvalidChar := LC;
        Exit;
      end;
      ABytesWritten := ABytesWritten + LBytesWrittenNow;
      Continue;
    end
    else if LHasAllSpaceChar and (LC = LAllSpaceChar) then
    begin
      LDecodeResult := WriteShortcut(AOutput, ABytesWritten, LBlockIndex, FourSpaceChars, LBytesWrittenNow);
      if LDecodeResult <> TDecodeResult.Success then
      begin
        Result.Status := LDecodeResult;
        Result.InvalidChar := LC;
        Exit;
      end;
      ABytesWritten := ABytesWritten + LBytesWrittenNow;
      Continue;
    end;

    if not TCodingAlphabet.TryLookup(LTable, LC, LX) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LC;
      Exit;
    end;

    LValue := (LValue * BaseLength) + LX;
    LBlockIndex := LBlockIndex + 1;
    if LBlockIndex = DecodeBlockSize then
    begin
      LDecodeResult := WriteDecodedValue(AOutput, ABytesWritten, LValue, EncodeBlockSize, LBytesWrittenNow);
      if LDecodeResult <> TDecodeResult.Success then
      begin
        Result.Status := LDecodeResult;
        Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
        Exit;
      end;

      ABytesWritten := ABytesWritten + LBytesWrittenNow;
      LBlockIndex := 0;
      LValue := 0;
    end;
  end;

  if LBlockIndex > 0 then
  begin
    for LN := 0 to DecodeBlockSize - LBlockIndex - 1 do
    begin
      LValue := (LValue * BaseLength) + (BaseLength - 1);
    end;

    LDecodeResult := WriteDecodedValue(AOutput, ABytesWritten, LValue, LBlockIndex - 1, LBytesWrittenNow);
    if LDecodeResult <> TDecodeResult.Success then
    begin
      Result.Status := LDecodeResult;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;
    ABytesWritten := ABytesWritten + LBytesWrittenNow;
  end;

  Result.Status := TDecodeResult.Success;
  Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
end;

end.
