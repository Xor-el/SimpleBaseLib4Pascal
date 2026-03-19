unit SbpBase45;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpSimpleBaseLibConstants,
  SbpICodingAlphabet,
  SbpINonAllocatingBaseCoder,
  SbpIBaseStreamCoder,
  SbpIBase45,
  SbpBase45Alphabet,
  SbpCodingAlphabet,
  SbpBitOperations,
  SbpStreamUtilities;

type
  TBase45 = class(TInterfacedObject, IBase45, INonAllocatingBaseCoder, IBaseStreamCoder)
  strict private
  type
    TDecodeResult = (
      Success,
      InvalidOutputLength,
      InvalidCharacter,
      InvalidInput,
      InvalidInputLength
    );

    TDecodeOutcome = record
      Status: TDecodeResult;
      InvalidChar: Char;
    end;

  const
    EncodeBlockSize = Int32(2);
    DecodeBlockSize = Int32(3);

  var
    FAlphabet: ICodingAlphabet;

    class var FDefault: IBase45;
    class function GetDefault: IBase45; static;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBuffer(ABytes: TSimpleBaseLibByteArray; ALastBlock: Boolean): String;
    function GetAlphabet: ICodingAlphabet;

    class function GetDecodingBufferSize(ALen: Int32): Int32; static; inline;
    class function GetEncodingBufferSize(ALen: Int32): Int32; static; inline;

    function InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
    function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeOutcome;
  public
    class constructor Create;

    constructor Create(const AAlphabet: ICodingAlphabet);

    class property Default: IBase45 read GetDefault;

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

    property Alphabet: ICodingAlphabet read GetAlphabet;
  end;

implementation

{ TBase45 }

class constructor TBase45.Create;
begin
  FDefault := nil;
end;

constructor TBase45.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create;
  FAlphabet := AAlphabet;
end;

class function TBase45.GetDefault: IBase45;
begin
  if FDefault = nil then
  begin
    FDefault := TBase45.Create(TBase45Alphabet.Default);
  end;
  Result := FDefault;
end;

function TBase45.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase45.EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes);
end;

function TBase45.GetAlphabet: ICodingAlphabet;
begin
  Result := FAlphabet;
end;

class function TBase45.GetDecodingBufferSize(ALen: Int32): Int32;
var
  LA, LB: Int32;
begin
  LA := ALen div 3;
  LB := ALen mod 3;
  Result := (LA * 2) + (Ord(LB > 0));
end;

class function TBase45.GetEncodingBufferSize(ALen: Int32): Int32;
var
  LWholeBlocks, LRemainder: Int32;
begin
  LWholeBlocks := ALen div 2;
  LRemainder := ALen mod 2;
  Result := (LWholeBlocks * 3) + (LRemainder * 2);
end;

function TBase45.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := GetDecodingBufferSize(System.Length(AText));
end;

function TBase45.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := GetEncodingBufferSize(System.Length(ABytes));
end;

function TBase45.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
var
  LWholeBlocks, LRemainder, LWholeLen, LOutputLength: Int32;
  LI: Int32;
  LA, LB, LValue, LQuotient, LC, LD, LE: UInt16;
  LAlphabet: String;
begin
  LWholeBlocks := System.Length(AInput) div 2;
  LRemainder := System.Length(AInput) mod 2;
  LWholeLen := LWholeBlocks * 2;
  ACharsWritten := 0;

  LOutputLength := GetEncodingBufferSize(System.Length(AInput));
  if System.Length(AOutput) < LOutputLength then
  begin
    Result := False;
    Exit;
  end;

  LAlphabet := FAlphabet.Value;
  LI := 0;
  while LI < LWholeLen do
  begin
    LA := AInput[LI];
    Inc(LI);
    LB := AInput[LI];
    Inc(LI);
    LValue := UInt16((LA shl 8) or LB);

    LC := LValue mod 45;
    LQuotient := LValue div 45;
    LD := LQuotient mod 45;
    LE := LQuotient div 45;

    AOutput[ACharsWritten] := LAlphabet[LC + 1];
    Inc(ACharsWritten);
    AOutput[ACharsWritten] := LAlphabet[LD + 1];
    Inc(ACharsWritten);
    AOutput[ACharsWritten] := LAlphabet[LE + 1];
    Inc(ACharsWritten);
  end;

  if LRemainder = 1 then
  begin
    LD := AInput[LI] div 45;
    LC := AInput[LI] mod 45;
    AOutput[ACharsWritten] := LAlphabet[LC + 1];
    Inc(ACharsWritten);
    AOutput[ACharsWritten] := LAlphabet[LD + 1];
    Inc(ACharsWritten);
  end;

  Result := True;
end;

function TBase45.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeOutcome;
var
  LWholeBlocks, LRemainder: Int32;
  LExpectedOutputLen: Int32;
  LTable: TSimpleBaseLibByteArray;
  LI, LBlock: Int32;
  LChr: Char;
  LC, LD, LE, LValue: Int32;
begin
  LWholeBlocks := System.Length(AInput) div 3;
  LRemainder := System.Length(AInput) mod 3;
  ABytesWritten := 0;

  if LRemainder = 1 then
  begin
    Result.Status := TDecodeResult.InvalidInputLength;
    Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
    Exit;
  end;

  LExpectedOutputLen := (LWholeBlocks * 2) + Ord(LRemainder > 0);
  if System.Length(AOutput) < LExpectedOutputLen then
  begin
    Result.Status := TDecodeResult.InvalidOutputLength;
    Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
    Exit;
  end;

  LTable := FAlphabet.ReverseLookupTable;
  LI := 1;

  for LBlock := 0 to LWholeBlocks - 1 do
  begin
    LChr := AInput[LI];
    Inc(LI);
    if not TCodingAlphabet.TryLookup(LTable, LChr, LC) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LChr;
      Exit;
    end;

    LChr := AInput[LI];
    Inc(LI);
    if not TCodingAlphabet.TryLookup(LTable, LChr, LD) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LChr;
      Exit;
    end;

    LChr := AInput[LI];
    Inc(LI);
    if not TCodingAlphabet.TryLookup(LTable, LChr, LE) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LChr;
      Exit;
    end;

    LValue := LC + (LD * 45) + (LE * 45 * 45);
    if LValue > $FFFF then
    begin
      Result.Status := TDecodeResult.InvalidInput;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;

    AOutput[ABytesWritten] := Byte(TBitOperations.Asr32(LValue, 8) and $FF);
    Inc(ABytesWritten);
    AOutput[ABytesWritten] := Byte(LValue and $FF);
    Inc(ABytesWritten);
  end;

  if LRemainder = 2 then
  begin
    LChr := AInput[LI];
    Inc(LI);
    if not TCodingAlphabet.TryLookup(LTable, LChr, LC) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LChr;
      Exit;
    end;

    LChr := AInput[LI];
    if not TCodingAlphabet.TryLookup(LTable, LChr, LD) then
    begin
      Result.Status := TDecodeResult.InvalidCharacter;
      Result.InvalidChar := LChr;
      Exit;
    end;

    LValue := LC + (LD * 45);
    if LValue > $FF then
    begin
      Result.Status := TDecodeResult.InvalidInput;
      Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
      Exit;
    end;

    AOutput[ABytesWritten] := Byte(LValue);
    Inc(ABytesWritten);
  end;

  Result.Status := TDecodeResult.Success;
  Result.InvalidChar := TSimpleBaseLibConstants.NullChar;
end;

function TBase45.Decode(const AText: String): TSimpleBaseLibByteArray;
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

  LOutputLen := GetDecodingBufferSize(System.Length(AText));
  System.SetLength(LOutput, LOutputLen);
  LOutcome := InternalDecode(AText, LOutput, LBytesWritten);
  case LOutcome.Status of
    TDecodeResult.Success:
      Result := System.Copy(LOutput, 0, LBytesWritten);
    TDecodeResult.InvalidOutputLength:
      raise EInvalidOperationSimpleBaseLibException.Create(
        'Internal error: insufficient output buffer size');
    TDecodeResult.InvalidCharacter:
      raise EArgumentSimpleBaseLibException.CreateFmt('Invalid character: %s',
        [LOutcome.InvalidChar]);
    TDecodeResult.InvalidInput:
      raise EArgumentSimpleBaseLibException.Create(
        'Input buffer is incorrectly encoded or corrupt');
    TDecodeResult.InvalidInputLength:
      raise EArgumentSimpleBaseLibException.Create(
        'Input buffer is at incorrect size');
  else
    raise EInvalidOperationSimpleBaseLibException.Create('Unexpected decode result');
  end;
end;

function TBase45.Encode(const ABytes: TSimpleBaseLibByteArray): String;
var
  LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  LOutputLen := GetEncodingBufferSize(System.Length(ABytes));
  if LOutputLen = 0 then
  begin
    Result := '';
    Exit;
  end;

  System.SetLength(LOutput, LOutputLen);
  if not InternalEncode(ABytes, LOutput, LCharsWritten) then
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Internal error: insufficient output buffer size');
  end;
  SetString(Result, PChar(@LOutput[0]), LCharsWritten);
end;

function TBase45.TryDecode(const AText: String;
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

function TBase45.TryEncode(const ABytes: TSimpleBaseLibByteArray;
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

procedure TBase45.Decode(const AInput: TStringBuilder; const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

procedure TBase45.Encode(const AInput: TStream; const AOutput: TStringBuilder);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  TStreamUtilities.Encode(AInput, AOutput, EncodeBuffer, LBufferSize);
end;

end.
