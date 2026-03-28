unit SbpMoneroBase58;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpSimpleBaseLibConstants,
  SbpICodingAlphabet,
  SbpCodingAlphabet,
  SbpINonAllocatingBaseCoder,
  SbpIMoneroBase58,
  SbpBase58Alphabet,
  SbpBinaryPrimitives,
  SbpBits;

type
  TMoneroBase58 = class(TInterfacedObject, IMoneroBase58, INonAllocatingBaseCoder)
  strict private
  type
    TDecodeResult = (
      Success,
      InsufficientOutputBuffer,
      InvalidCharacter
    );

    TDecodeOutcome = record
      Status: TDecodeResult;
      InvalidChar: Char;
    end;
  const
    BlockSize = Int32(8);
    MaxEncodedBlockSize = Int32(11);
    EncodedBlockSizes: array [0 .. 8] of Int32 = (0, 2, 3, 5, 6, 7, 9, 10, 11);
  var
    FAlphabet: ICodingAlphabet;
    FZeroChar: Char;
    class var FDefault: IMoneroBase58;
    class function GetDefault: IMoneroBase58; static;

    function GetAlphabet: ICodingAlphabet;
    function GetZeroChar: Char;

    class function GetSafeCharCountForEncodingInternal(ALength: Int32): Int32; static; inline;
    class function GetSafeByteCountForDecodingInternal(ALength: Int32): Int32; static; inline;
    class function GetDecodedBlockSizeFromEncodedLength(AEncodedLen: Int32): Int32; static;

    class procedure EncodeBlock(const AInput: TSimpleBaseLibByteArray; AInputOffset, AInputLen: Int32;
      const AOutput: TSimpleBaseLibCharArray; AOutputOffset: Int32;
      const AAlphabet: String; AZeroChar: Char); static;

    class function DecodeBlock(const AInput: String; AInputOffset, AInputLen: Int32;
      const AOutput: TSimpleBaseLibByteArray; AOutputOffset: Int32;
      const AReverseLookupTable: TSimpleBaseLibByteArray): TDecodeOutcome; static;

    function InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
    function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeOutcome;
  public
    class constructor Create;

    constructor Create; overload;
    constructor Create(const AAlphabet: ICodingAlphabet); overload;

    class property Default: IMoneroBase58 read GetDefault;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function Encode(const ABytes: TSimpleBaseLibByteArray): String;
    function Decode(const AText: String): TSimpleBaseLibByteArray;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;

    property Alphabet: ICodingAlphabet read GetAlphabet;
    property ZeroChar: Char read GetZeroChar;
  end;

implementation

uses
  SbpArrayUtilities;

{ TMoneroBase58 }

class constructor TMoneroBase58.Create;
begin
  FDefault := nil;
end;

constructor TMoneroBase58.Create;
begin
  Create(TBase58Alphabet.Bitcoin);
end;

constructor TMoneroBase58.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create;
  FAlphabet := AAlphabet;
  FZeroChar := AAlphabet.Value[1];
end;

class function TMoneroBase58.GetDefault: IMoneroBase58;
begin
  if FDefault = nil then
  begin
    FDefault := TMoneroBase58.Create;
  end;
  Result := FDefault;
end;

function TMoneroBase58.GetAlphabet: ICodingAlphabet;
begin
  Result := FAlphabet;
end;

function TMoneroBase58.GetZeroChar: Char;
begin
  Result := FZeroChar;
end;

class function TMoneroBase58.GetSafeCharCountForEncodingInternal(ALength: Int32): Int32;
begin
  if ALength = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := ((ALength div BlockSize) + 1) * MaxEncodedBlockSize;
end;

class function TMoneroBase58.GetSafeByteCountForDecodingInternal(ALength: Int32): Int32;
begin
  if ALength = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := (ALength * BlockSize div MaxEncodedBlockSize) + 1;
end;

function TMoneroBase58.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := GetSafeCharCountForEncodingInternal(System.Length(ABytes));
end;

function TMoneroBase58.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := GetSafeByteCountForDecodingInternal(System.Length(AText));
end;

class function TMoneroBase58.GetDecodedBlockSizeFromEncodedLength(
  AEncodedLen: Int32): Int32;
var
  LI: Int32;
begin
  for LI := 0 to System.Length(EncodedBlockSizes) - 1 do
  begin
    if EncodedBlockSizes[LI] = AEncodedLen then
    begin
      Result := LI;
      Exit;
    end;
  end;
  Result := -1;
end;

class procedure TMoneroBase58.EncodeBlock(const AInput: TSimpleBaseLibByteArray;
  AInputOffset, AInputLen: Int32; const AOutput: TSimpleBaseLibCharArray;
  AOutputOffset: Int32; const AAlphabet: String; AZeroChar: Char);
var
  LPad, LRemainder: UInt64;
  LLastPos, LI: Int32;
begin
  LPad := TBits.PartialBigEndianBytesToUInt64(AInput, AInputOffset, AInputLen);
  LLastPos := EncodedBlockSizes[AInputLen];

  for LI := LLastPos - 1 downto 0 do
  begin
    LRemainder := LPad mod 58;
    LPad := LPad div 58;
    AOutput[AOutputOffset + LI] := AAlphabet[Int32(LRemainder) + 1];
  end;

  TArrayUtilities.Fill<Char>(AOutput, AOutputOffset + LLastPos,
    AOutputOffset + MaxEncodedBlockSize, AZeroChar);
end;

class function TMoneroBase58.DecodeBlock(const AInput: String; AInputOffset,
  AInputLen: Int32; const AOutput: TSimpleBaseLibByteArray; AOutputOffset: Int32;
  const AReverseLookupTable: TSimpleBaseLibByteArray): TDecodeOutcome;
var
  LPad: UInt64;
  LI: Int32;
  LC: Char;
  LValue: Int32;
begin
  LPad := 0;
  for LI := 0 to AInputLen - 1 do
  begin
    LC := AInput[AInputOffset + LI];
    if not TCodingAlphabet.TryLookup(AReverseLookupTable, LC, LValue) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LC;
      Exit;
    end;
    LPad := (LPad * 58) + UInt64(UInt32(LValue));
  end;

  TBinaryPrimitives.WriteUInt64BigEndian(AOutput, AOutputOffset, LPad);
  Result.Status := TDecodeResult.Success;
  Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
end;

function TMoneroBase58.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
var
  LAlphabet: String;
  LOffset, LOutputOffset, LRemainingLength, LLastBlockSize: Int32;
  LTempPad: TSimpleBaseLibCharArray;
begin
  if System.Length(AInput) = 0 then
  begin
    ACharsWritten := 0;
    Result := True;
    Exit;
  end;

  LAlphabet := FAlphabet.Value;
  LOffset := 0;
  LOutputOffset := 0;
  LRemainingLength := System.Length(AInput) mod BlockSize;

  while LOffset < (System.Length(AInput) - LRemainingLength) do
  begin
    if (LOutputOffset + MaxEncodedBlockSize) > System.Length(AOutput) then
    begin
      ACharsWritten := 0;
      Result := False;
      Exit;
    end;
    EncodeBlock(AInput, LOffset, BlockSize, AOutput, LOutputOffset, LAlphabet, FZeroChar);
    Inc(LOffset, BlockSize);
    Inc(LOutputOffset, MaxEncodedBlockSize);
  end;

  if LRemainingLength > 0 then
  begin
    System.SetLength(LTempPad, MaxEncodedBlockSize);
    EncodeBlock(AInput, LOffset, LRemainingLength, LTempPad, 0, LAlphabet, FZeroChar);
    LLastBlockSize := EncodedBlockSizes[LRemainingLength];
    if (LOutputOffset + LLastBlockSize) > System.Length(AOutput) then
    begin
      ACharsWritten := 0;
      Result := False;
      Exit;
    end;
    Move(LTempPad[0], AOutput[LOutputOffset], LLastBlockSize * System.SizeOf(Char));
    Inc(LOutputOffset, LLastBlockSize);
  end;

  ACharsWritten := LOutputOffset;
  Result := True;
end;

function TMoneroBase58.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeOutcome;
var
  LTable: TSimpleBaseLibByteArray;
  LNumBlocks, LWholeEndOffset, LInputOffset, LRemainingLength: Int32;
  LTemp: TSimpleBaseLibByteArray;
  LTempSize, LI: Int32;
begin
  LTable := FAlphabet.ReverseLookupTable;

  LNumBlocks := System.Length(AInput) div MaxEncodedBlockSize;
  LWholeEndOffset := LNumBlocks * MaxEncodedBlockSize;
  ABytesWritten := 0;
  LInputOffset := 1;

  while LInputOffset <= LWholeEndOffset do
  begin
    if (ABytesWritten + BlockSize) > System.Length(AOutput) then
    begin
      Result.Status := TDecodeResult.InsufficientOutputBuffer;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;

    Result := DecodeBlock(AInput, LInputOffset, MaxEncodedBlockSize,
      AOutput, ABytesWritten, LTable);
    if Result.Status <> TDecodeResult.Success then
    begin
      Exit;
    end;

    Inc(LInputOffset, MaxEncodedBlockSize);
    Inc(ABytesWritten, BlockSize);
  end;

  LRemainingLength := System.Length(AInput) - LWholeEndOffset;
  if LRemainingLength > 0 then
  begin
    System.SetLength(LTemp, BlockSize);
    Result := DecodeBlock(AInput, LInputOffset, LRemainingLength, LTemp, 0, LTable);
    if Result.Status <> TDecodeResult.Success then
    begin
      Exit;
    end;

    LTempSize := GetDecodedBlockSizeFromEncodedLength(LRemainingLength);
    if LTempSize < 0 then
    begin
      Result.Status := TDecodeResult.InsufficientOutputBuffer;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;

    if (ABytesWritten + LTempSize) > System.Length(AOutput) then
    begin
      Result.Status := TDecodeResult.InsufficientOutputBuffer;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;

    for LI := 0 to LTempSize - 1 do
    begin
      AOutput[ABytesWritten + LI] := LTemp[BlockSize - LTempSize + LI];
    end;
    Inc(ABytesWritten, LTempSize);
  end;

  Result.Status := TDecodeResult.Success;
  Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
end;

function TMoneroBase58.Encode(const ABytes: TSimpleBaseLibByteArray): String;
var
  LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  if System.Length(ABytes) = 0 then
  begin
    Result := '';
    Exit;
  end;

  LOutputLen := GetSafeCharCountForEncodingInternal(System.Length(ABytes));
  System.SetLength(LOutput, LOutputLen);
  if not InternalEncode(ABytes, LOutput, LCharsWritten) then
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Internal error: insufficient output buffer size');
  end;
  SetString(Result, PChar(@LOutput[0]), LCharsWritten);
end;

function TMoneroBase58.Decode(const AText: String): TSimpleBaseLibByteArray;
var
  LOutputLen, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
  LOutcome: TDecodeOutcome;
begin
  if System.Length(AText) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  LOutputLen := GetSafeByteCountForDecodingInternal(System.Length(AText));
  System.SetLength(LOutput, LOutputLen);

  LOutcome := InternalDecode(AText, LOutput, LBytesWritten);
  case LOutcome.Status of
    TDecodeResult.Success:
      Result := System.Copy(LOutput, 0, LBytesWritten);
    TDecodeResult.InvalidCharacter:
      raise EArgumentSimpleBaseLibException.CreateFmt('Invalid character: %s',
        [LOutcome.InvalidChar]);
    TDecodeResult.InsufficientOutputBuffer:
      raise EInvalidOperationSimpleBaseLibException.Create(
        'Internal error: insufficient output buffer size');
  else
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Unexpected decode result');
  end;
end;

function TMoneroBase58.TryEncode(const ABytes: TSimpleBaseLibByteArray;
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

function TMoneroBase58.TryDecode(const AText: String;
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

end.
