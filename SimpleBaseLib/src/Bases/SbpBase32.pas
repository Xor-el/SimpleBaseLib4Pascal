unit SbpBase32;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBase32,
  SbpIBaseStreamCoder,
  SbpINonAllocatingBaseCoder,
  SbpINumericBaseCoder,
  SbpIBase32Alphabet,
  SbpPaddingPosition,
  SbpBase32Alphabet,
  SbpStreamUtilities,
  SbpPlatformUtilities,
  SbpBinaryPrimitives;

type
  TBase32 = class(TInterfacedObject, IBase32, IBaseStreamCoder, INonAllocatingBaseCoder, INumericBaseCoder)
  strict private
    type
    TDecodeResult = (
      Success,
      InvalidInput,
      OutputOverflow
    );

    const
    EncodeBlockSize = Int32(5);
    DecodeBlockSize = Int32(8);
    BitsPerByte = Int32(8);
    BitsPerChar = Int32(5);

    var
    FAlphabet: IBase32Alphabet;
    FIsBigEndian: Boolean;

    class var FCrockford: IBase32;
    class var FRfc4648: IBase32;
    class var FExtendedHex: IBase32;
    class var FExtendedHexLower: IBase32;
    class var FZBase32: IBase32;
    class var FGeohash: IBase32;
    class var FBech32: IBase32;
    class var FFileCoin: IBase32;

    class var FZeroBuffer: TSimpleBaseLibByteArray;

    class function GetCrockford: IBase32; static;
    class function GetRfc4648: IBase32; static;
    class function GetExtendedHex: IBase32; static;
    class function GetExtendedHexLower: IBase32; static;
    class function GetZBase32: IBase32; static;
    class function GetGeohash: IBase32; static;
    class function GetBech32: IBase32; static;
    class function GetFileCoin: IBase32; static;

    class function GetAllocationByteCountForDecoding(ATextLenWithoutPadding: Int32): Int32; static; inline;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBufferNoPadding(ABytes: TSimpleBaseLibByteArray;
      ALastBlock: Boolean): String;
    function EncodeBufferPadFinal(ABytes: TSimpleBaseLibByteArray;
      ALastBlock: Boolean): String;
    function GetPaddingCharCount(const AText: String): Int32;
    function InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; APadding: Boolean; out ACharsWritten: Int32): Boolean;
    function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeResult;
    function GetAlphabet: IBase32Alphabet;
  public
    class constructor Create;

    constructor Create(const AAlphabet: IBase32Alphabet); overload;
    constructor Create(const AAlphabet: IBase32Alphabet; AIsBigEndian: Boolean); overload;

    class property Crockford: IBase32 read GetCrockford;
    class property Rfc4648: IBase32 read GetRfc4648;
    class property ExtendedHex: IBase32 read GetExtendedHex;
    class property ExtendedHexLower: IBase32 read GetExtendedHexLower;
    class property ZBase32: IBase32 read GetZBase32;
    class property Geohash: IBase32 read GetGeohash;
    class property Bech32: IBase32 read GetBech32;
    class property FileCoin: IBase32 read GetFileCoin;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function Encode(const ABytes: TSimpleBaseLibByteArray): String; overload;
    function Encode(const ABytes: TSimpleBaseLibByteArray; APadding: Boolean): String; overload;
    function Decode(const AText: String): TSimpleBaseLibByteArray; overload;

    function EncodeInt64(const ANumber: Int64): String;
    function EncodeUInt64(const ANumber: UInt64): String;
    function DecodeUInt64(const AText: String): UInt64;
    function TryDecodeUInt64(const AText: String; out ANumber: UInt64): Boolean;
    function DecodeInt64(const AText: String): Int64;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean; overload;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; APadding: Boolean; out ACharsWritten: Int32): Boolean; overload;
    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;

    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder;
      APadding: Boolean); overload;
    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;

    property Alphabet: IBase32Alphabet read GetAlphabet;
  end;

implementation

{ TBase32 }

class constructor TBase32.Create;
begin
  FCrockford := nil;
  FRfc4648 := nil;
  FExtendedHex := nil;
  FExtendedHexLower := nil;
  FZBase32 := nil;
  FGeohash := nil;
  FBech32 := nil;
  FFileCoin := nil;
  SetLength(FZeroBuffer, 1);
  FZeroBuffer[0] := 0;
end;

constructor TBase32.Create(const AAlphabet: IBase32Alphabet);
begin
  Create(AAlphabet, not TPlatformUtilities.IsLittleEndian);
end;

constructor TBase32.Create(const AAlphabet: IBase32Alphabet; AIsBigEndian: Boolean);
begin
  inherited Create;
  if AAlphabet.PaddingPosition <> TPaddingPosition.&End then
  begin
    raise EArgumentSimpleBaseLibException.Create(
      'Only encoding alphabets with paddings at the end are supported by this implementation');
  end;

  FAlphabet := AAlphabet;
  FIsBigEndian := AIsBigEndian;
end;

function TBase32.GetAlphabet: IBase32Alphabet;
begin
  Result := FAlphabet;
end;

class function TBase32.GetCrockford: IBase32;
begin
  if FCrockford = nil then
  begin
    FCrockford := TBase32.Create(TBase32Alphabet.Crockford);
  end;
  Result := FCrockford;
end;

class function TBase32.GetRfc4648: IBase32;
begin
  if FRfc4648 = nil then
  begin
    FRfc4648 := TBase32.Create(TBase32Alphabet.Rfc4648);
  end;
  Result := FRfc4648;
end;

class function TBase32.GetExtendedHex: IBase32;
begin
  if FExtendedHex = nil then
  begin
    FExtendedHex := TBase32.Create(TBase32Alphabet.ExtendedHex);
  end;
  Result := FExtendedHex;
end;

class function TBase32.GetExtendedHexLower: IBase32;
begin
  if FExtendedHexLower = nil then
  begin
    FExtendedHexLower := TBase32.Create(TBase32Alphabet.ExtendedHexLower);
  end;
  Result := FExtendedHexLower;
end;

class function TBase32.GetZBase32: IBase32;
begin
  if FZBase32 = nil then
  begin
    FZBase32 := TBase32.Create(TBase32Alphabet.ZBase32);
  end;
  Result := FZBase32;
end;

class function TBase32.GetGeohash: IBase32;
begin
  if FGeohash = nil then
  begin
    FGeohash := TBase32.Create(TBase32Alphabet.Geohash);
  end;
  Result := FGeohash;
end;

class function TBase32.GetBech32: IBase32;
begin
  if FBech32 = nil then
  begin
    FBech32 := TBase32.Create(TBase32Alphabet.Bech32);
  end;
  Result := FBech32;
end;

class function TBase32.GetFileCoin: IBase32;
begin
  if FFileCoin = nil then
  begin
    FFileCoin := TBase32.Create(TBase32Alphabet.FileCoin);
  end;
  Result := FFileCoin;
end;

function TBase32.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := GetAllocationByteCountForDecoding(System.Length(AText) - GetPaddingCharCount(AText));
end;

function TBase32.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := (((System.Length(ABytes) - 1) div BitsPerChar) + 1) * BitsPerByte;
end;

class function TBase32.GetAllocationByteCountForDecoding(
  ATextLenWithoutPadding: Int32): Int32;
begin
  Result := ATextLenWithoutPadding * BitsPerChar div BitsPerByte;
end;

function TBase32.Encode(const ABytes: TSimpleBaseLibByteArray): String;
begin
  Result := Encode(ABytes, False);
end;

function TBase32.Encode(const ABytes: TSimpleBaseLibByteArray;
  APadding: Boolean): String;
var
  LBytesLen, LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  LBytesLen := System.Length(ABytes);
  if LBytesLen = 0 then
  begin
    Result := '';
    Exit;
  end;

  LOutputLen := GetSafeCharCountForEncoding(ABytes);
  SetLength(LOutput, LOutputLen);
  if not InternalEncode(ABytes, LOutput, APadding, LCharsWritten) then
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Internal error: couldn''t calculate proper output buffer size for input');
  end;
  SetString(Result, PChar(@LOutput[0]), LCharsWritten);
end;

function TBase32.Decode(const AText: String): TSimpleBaseLibByteArray;
var
  LPaddingLen, LTextLen, LOutputLen, LBytesWritten: Int32;
  LOutput: TSimpleBaseLibByteArray;
  LDecodeResult: TDecodeResult;
begin
  LPaddingLen := GetPaddingCharCount(AText);
  LTextLen := System.Length(AText) - LPaddingLen;
  LOutputLen := GetAllocationByteCountForDecoding(LTextLen);
  if LOutputLen = 0 then
  begin
    Result := nil;
    Exit;
  end;

  SetLength(LOutput, LOutputLen);
  LDecodeResult := InternalDecode(System.Copy(AText, 1, LTextLen), LOutput, LBytesWritten);
  case LDecodeResult of
    TDecodeResult.InvalidInput:
      raise EArgumentSimpleBaseLibException.Create('Invalid character in input');
    TDecodeResult.OutputOverflow:
      raise EInvalidOperationSimpleBaseLibException.Create('Output buffer is too small');
    TDecodeResult.Success:
      begin
        if LBytesWritten <> LOutputLen then
        begin
          raise EInvalidOperationSimpleBaseLibException.Create(
            'Actual written bytes are different');
        end;
        Result := LOutput;
      end;
  else
    raise EInvalidOperationSimpleBaseLibException.Create('Unhandled decode result');
  end;
end;

function TBase32.EncodeInt64(const ANumber: Int64): String;
begin
  if ANumber < 0 then
  begin
    raise EArgumentOutOfRangeSimpleBaseLibException.Create('Number is negative');
  end;
  Result := EncodeUInt64(UInt64(ANumber));
end;

function TBase32.EncodeUInt64(const ANumber: UInt64): String;
const
  NumBytes = 8;
var
  LBuffer, LSpan: TSimpleBaseLibByteArray;
  LI: Int32;
begin
  if ANumber = 0 then
  begin
    Result := Encode(FZeroBuffer);
    Exit;
  end;

  SetLength(LBuffer, NumBytes);
  TBinaryPrimitives.WriteUInt64LittleEndian(LBuffer, 0, ANumber);

  if FIsBigEndian then
  begin
    LI := 0;
    while (LI < NumBytes) and (LBuffer[LI] = 0) do
    begin
      Inc(LI);
    end;
    LSpan := System.Copy(LBuffer, LI, NumBytes - LI);
    for LI := 0 to (System.Length(LSpan) div 2) - 1 do
    begin
      LBuffer[0] := LSpan[LI];
      LSpan[LI] := LSpan[System.Length(LSpan) - 1 - LI];
      LSpan[System.Length(LSpan) - 1 - LI] := LBuffer[0];
    end;
    Result := Encode(LSpan);
    Exit;
  end;

  LI := NumBytes - 1;
  while (LI > 0) and (LBuffer[LI] = 0) do
  begin
    Dec(LI);
  end;
  Result := Encode(System.Copy(LBuffer, 0, LI + 1));
end;

function TBase32.DecodeUInt64(const AText: String): UInt64;
var
  LBuffer, LNewSpan: TSimpleBaseLibByteArray;
  LI: Int32;
begin
  LBuffer := Decode(AText);
  if System.Length(LBuffer) > 8 then
  begin
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Decoded text is too long to fit in a buffer');
  end;

  SetLength(LNewSpan, 8);
  for LI := 0 to 7 do
  begin
    LNewSpan[LI] := 0;
  end;
  Move(LBuffer[0], LNewSpan[0], System.Length(LBuffer));

  if FIsBigEndian then
  begin
    for LI := 0 to 3 do
    begin
      LBuffer := nil;
      SetLength(LBuffer, 1);
      LBuffer[0] := LNewSpan[LI];
      LNewSpan[LI] := LNewSpan[7 - LI];
      LNewSpan[7 - LI] := LBuffer[0];
    end;
  end;

  Result := TBinaryPrimitives.ReadUInt64LittleEndian(LNewSpan, 0);
end;

function TBase32.TryDecodeUInt64(const AText: String; out ANumber: UInt64): Boolean;
var
  LOutput: TSimpleBaseLibByteArray;
  LBytesWritten, LI: Int32;
  LTmp: Byte;
begin
  SetLength(LOutput, 8);
  for LI := 0 to 7 do
  begin
    LOutput[LI] := 0;
  end;
  if not TryDecode(AText, LOutput, LBytesWritten) then
  begin
    ANumber := 0;
    Result := False;
    Exit;
  end;

  if FIsBigEndian then
  begin
    for LI := 0 to 3 do
    begin
      LTmp := LOutput[LI];
      LOutput[LI] := LOutput[7 - LI];
      LOutput[7 - LI] := LTmp;
    end;
  end;

  ANumber := TBinaryPrimitives.ReadUInt64LittleEndian(LOutput, 0);
  Result := True;
end;

function TBase32.DecodeInt64(const AText: String): Int64;
var
  LResult: UInt64;
begin
  LResult := DecodeUInt64(AText);
  if LResult > UInt64(High(Int64)) then
  begin
    raise EArgumentOutOfRangeSimpleBaseLibException.Create(
      'Decoded buffer is out of Int64 range');
  end;
  Result := Int64(LResult);
end;

function TBase32.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
begin
  Result := TryEncode(ABytes, AOutput, False, ACharsWritten);
end;

function TBase32.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; APadding: Boolean;
  out ACharsWritten: Int32): Boolean;
begin
  if System.Length(ABytes) = 0 then
  begin
    ACharsWritten := 0;
    Result := True;
    Exit;
  end;
  Result := InternalEncode(ABytes, AOutput, APadding, ACharsWritten);
end;

function TBase32.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LInputLen: Int32;
begin
  LInputLen := System.Length(AText) - GetPaddingCharCount(AText);
  if LInputLen = 0 then
  begin
    ABytesWritten := 0;
    Result := True;
    Exit;
  end;

  if System.Length(AOutput) = 0 then
  begin
    ABytesWritten := 0;
    Result := False;
    Exit;
  end;

  Result := InternalDecode(System.Copy(AText, 1, LInputLen), AOutput, ABytesWritten) =
    TDecodeResult.Success;
end;

function TBase32.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; APadding: Boolean; out ACharsWritten: Int32): Boolean;
var
  LTable: String;
  LBitsLeft, LOutputPad, LO, LValue, LI, LNextBits: Int32;
  LPaddingChar: Char;
begin
  LTable := FAlphabet.Value;
  LBitsLeft := BitsPerByte;
  LO := 0;
  LI := 0;
  LValue := AInput[0];

  while LI < System.Length(AInput) do
  begin
    if LBitsLeft > BitsPerChar then
    begin
      LBitsLeft := LBitsLeft - BitsPerChar;
      LOutputPad := LValue shr LBitsLeft;
      if LO >= System.Length(AOutput) then
      begin
        ACharsWritten := LO;
        Result := False;
        Exit;
      end;
      AOutput[LO] := LTable[LOutputPad + 1];
      Inc(LO);
      LValue := LValue and ((1 shl LBitsLeft) - 1);
    end;

    LNextBits := BitsPerChar - LBitsLeft;
    LBitsLeft := BitsPerByte - LNextBits;
    LOutputPad := LValue shl LNextBits;
    Inc(LI);
    if LI < System.Length(AInput) then
    begin
      LValue := AInput[LI];
      LOutputPad := LOutputPad or (LValue shr LBitsLeft);
      LValue := LValue and ((1 shl LBitsLeft) - 1);
    end;

    if LO >= System.Length(AOutput) then
    begin
      ACharsWritten := LO;
      Result := False;
      Exit;
    end;
    AOutput[LO] := LTable[LOutputPad + 1];
    Inc(LO);
  end;

  if APadding then
  begin
    LPaddingChar := FAlphabet.PaddingChar;
    while LO < System.Length(AOutput) do
    begin
      AOutput[LO] := LPaddingChar;
      Inc(LO);
    end;
  end;

  ACharsWritten := LO;
  Result := True;
end;

function TBase32.GetPaddingCharCount(const AText: String): Int32;
var
  LPaddingChar: Char;
  LTextLen, LI: Int32;
begin
  LPaddingChar := FAlphabet.PaddingChar;
  Result := 0;
  LTextLen := System.Length(AText);

  if FAlphabet.PaddingPosition = TPaddingPosition.Start then
  begin
    for LI := 1 to LTextLen do
    begin
      if AText[LI] <> LPaddingChar then
      begin
        Exit;
      end;
      Inc(Result);
    end;
    Exit;
  end;

  while (LTextLen > 0) and (AText[LTextLen] = LPaddingChar) do
  begin
    Dec(LTextLen);
    Inc(Result);
  end;
end;

function TBase32.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): TDecodeResult;
var
  LTable: TSimpleBaseLibByteArray;
  LOutputPad, LBitsLeft, LO, LI, LB, LShiftBits: Int32;
  LC: Char;
begin
  LTable := FAlphabet.ReverseLookupTable;
  LOutputPad := 0;
  LBitsLeft := BitsPerByte;
  ABytesWritten := 0;
  LO := 0;

  for LI := 1 to System.Length(AInput) do
  begin
    LC := AInput[LI];
    LB := LTable[Ord(LC)] - 1;
    if LB < 0 then
    begin
      ABytesWritten := LO;
      Result := TDecodeResult.InvalidInput;
      Exit;
    end;

    if LBitsLeft > BitsPerChar then
    begin
      LBitsLeft := LBitsLeft - BitsPerChar;
      LOutputPad := LOutputPad or (LB shl LBitsLeft);
      Continue;
    end;

    LShiftBits := BitsPerChar - LBitsLeft;
    LOutputPad := LOutputPad or (LB shr LShiftBits);
    if LO >= System.Length(AOutput) then
    begin
      Result := TDecodeResult.OutputOverflow;
      Exit;
    end;
    AOutput[LO] := Byte(LOutputPad);
    Inc(LO);

    LB := LB and ((1 shl LShiftBits) - 1);
    LBitsLeft := BitsPerByte - LShiftBits;
    LOutputPad := LB shl LBitsLeft;
  end;

  ABytesWritten := LO;
  Result := TDecodeResult.Success;
end;

function TBase32.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase32.EncodeBufferNoPadding(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes, False);
end;

function TBase32.EncodeBufferPadFinal(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes, ALastBlock);
end;

procedure TBase32.Encode(const AInput: TStream; const AOutput: TStringBuilder);
begin
  Encode(AInput, AOutput, False);
end;

procedure TBase32.Encode(const AInput: TStream; const AOutput: TStringBuilder;
  APadding: Boolean);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  if APadding then
  begin
    TStreamUtilities.Encode(AInput, AOutput, EncodeBufferPadFinal, LBufferSize);
  end
  else
  begin
    TStreamUtilities.Encode(AInput, AOutput, EncodeBufferNoPadding, LBufferSize);
  end;
end;

procedure TBase32.Decode(const AInput: TStringBuilder; const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

end.
