unit SbpBase8;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBase8,
  SbpINonAllocatingBaseCoder,
  SbpIBaseStreamCoder,
  SbpStreamUtilities;

type
  TBase8 = class(TInterfacedObject, IBase8, INonAllocatingBaseCoder, IBaseStreamCoder)
  strict private
  type
    TDecodeResult = (
      Success,
      InvalidCharacter,
      InvalidInputLength
    );

  const
    EncodedPadSize = Int32(8);
    DecodedPadSize = Int32(3);
    EncodeBlockSize = DecodedPadSize;
    DecodeBlockSize = EncodedPadSize;
    ZeroChar = '0';

    class var FDefault: IBase8;
    class function GetDefault: IBase8; static;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBuffer(ABytes: TSimpleBaseLibByteArray; ALastBlock: Boolean): String;

    class function GetSafeByteCountForDecodingInternal(ATextLength: Int32): Int32; static; inline;
    class function GetSafeCharCountForEncodingInternal(ABytesLength: Int32): Int32; static; inline;

    class function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): TDecodeResult; static;
    class function InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray): Int32; static;
  public
    class constructor Create;
    class property Default: IBase8 read GetDefault;

    function Decode(const AText: String): TSimpleBaseLibByteArray; overload;
    function Encode(const ABytes: TSimpleBaseLibByteArray): String; overload;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;
  end;

implementation

{ TBase8 }

class constructor TBase8.Create;
begin
  FDefault := nil;
end;

function TBase8.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase8.EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes);
end;

class function TBase8.GetDefault: IBase8;
begin
  if FDefault = nil then
  begin
    FDefault := TBase8.Create;
  end;
  Result := FDefault;
end;

function TBase8.Decode(const AText: String): TSimpleBaseLibByteArray;
var
  LOutputLen, LBytesWritten: Int32;
  LDecodeResult: TDecodeResult;
begin
  if System.Length(AText) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  LOutputLen := GetSafeByteCountForDecodingInternal(System.Length(AText));
  System.SetLength(Result, LOutputLen);
  LDecodeResult := InternalDecode(AText, Result, LBytesWritten);
  case LDecodeResult of
    TDecodeResult.Success:
      begin
        Result := System.Copy(Result, 0, LBytesWritten);
      end;
    TDecodeResult.InvalidCharacter:
      raise EArgumentSimpleBaseLibException.Create('Invalid Base8 character encountered');
    TDecodeResult.InvalidInputLength:
      raise EArgumentSimpleBaseLibException.Create('Invalid encoded text length');
  else
    raise EInvalidOperationSimpleBaseLibException.Create(
      'Unknown error during decoding -- this is a bug');
  end;
end;

procedure TBase8.Decode(const AInput: TStringBuilder; const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

function TBase8.Encode(const ABytes: TSimpleBaseLibByteArray): String;
var
  LOutputLen, LCharsWritten: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  LOutputLen := GetSafeCharCountForEncodingInternal(System.Length(ABytes));
  if LOutputLen = 0 then
  begin
    Result := '';
    Exit;
  end;
  System.SetLength(LOutput, LOutputLen);
  LCharsWritten := InternalEncode(ABytes, LOutput);
  SetString(Result, PChar(@LOutput[0]), LCharsWritten);
end;

procedure TBase8.Encode(const AInput: TStream; const AOutput: TStringBuilder);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  TStreamUtilities.Encode(AInput, AOutput, EncodeBuffer, LBufferSize);
end;

function TBase8.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := GetSafeByteCountForDecodingInternal(System.Length(AText));
end;

class function TBase8.GetSafeByteCountForDecodingInternal(ATextLength: Int32): Int32;
begin
  Result := ((ATextLength + EncodedPadSize - 1) div EncodedPadSize) * DecodedPadSize;
end;

function TBase8.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := GetSafeCharCountForEncodingInternal(System.Length(ABytes));
end;

class function TBase8.GetSafeCharCountForEncodingInternal(ABytesLength: Int32): Int32;
begin
  Result := ((ABytesLength + DecodedPadSize - 1) div DecodedPadSize) * EncodedPadSize;
end;

function TBase8.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
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

  Result := InternalDecode(AText, AOutput, ABytesWritten) = TDecodeResult.Success;
end;

function TBase8.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
begin
  ACharsWritten := 0;
  if System.Length(ABytes) = 0 then
  begin
    Result := True;
    Exit;
  end;

  if System.Length(AOutput) < GetSafeCharCountForEncodingInternal(System.Length(ABytes)) then
  begin
    Result := False;
    Exit;
  end;

  ACharsWritten := InternalEncode(ABytes, AOutput);
  Result := True;
end;

class function TBase8.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray;
  out ABytesWritten: Int32): TDecodeResult;
var
  LInputLen: Int32;
  LI: Int32;
  LB0, LB1, LB2, LB3, LB4, LB5, LB6, LB7, LB: Byte;
begin
  ABytesWritten := 0;
  LInputLen := System.Length(AInput);

  if ((LInputLen mod EncodedPadSize) <> 0) and
    ((LInputLen mod EncodedPadSize) <> DecodedPadSize) and
    ((LInputLen mod EncodedPadSize) <> (DecodedPadSize * 2)) then
  begin
    Result := TDecodeResult.InvalidInputLength;
    Exit;
  end;

  LI := 1;
  while LI <= LInputLen do
  begin
    LB0 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    LB1 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    LB2 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    if (LB0 > 7) or (LB1 > 7) or (LB2 > 7) then
    begin
      Result := TDecodeResult.InvalidCharacter;
      Exit;
    end;

    AOutput[ABytesWritten] := Byte((LB0 shl 5) or (LB1 shl 2) or (LB2 shr 1));
    Inc(ABytesWritten);

    if LI > LInputLen then
    begin
      LB := Byte((LB2 and 1) shl 7);
      if LB > 0 then
      begin
        AOutput[ABytesWritten] := LB;
        Inc(ABytesWritten);
      end;
      Result := TDecodeResult.Success;
      Exit;
    end;

    LB3 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    LB4 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    LB5 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    if (LB3 > 7) or (LB4 > 7) or (LB5 > 7) then
    begin
      Result := TDecodeResult.InvalidCharacter;
      Exit;
    end;

    AOutput[ABytesWritten] := Byte((Int32(LB2 and 1) shl 7) or
      (Int32(LB3) shl 4) or (Int32(LB4) shl 1) or Int32(LB5 shr 2));
    Inc(ABytesWritten);

    if LI > LInputLen then
    begin
      LB := Byte((LB5 and 3) shl 6);
      if LB > 0 then
      begin
        AOutput[ABytesWritten] := LB;
        Inc(ABytesWritten);
      end;
      Break;
    end;

    LB6 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    LB7 := Byte(Ord(AInput[LI]) - Ord(ZeroChar)); Inc(LI);
    if (LB6 > 7) or (LB7 > 7) then
    begin
      Result := TDecodeResult.InvalidCharacter;
      Exit;
    end;

    AOutput[ABytesWritten] := Byte((Int32(LB5 and 3) shl 6) or
      (Int32(LB6) shl 3) or Int32(LB7 shr 0));
    Inc(ABytesWritten);
  end;

  Result := TDecodeResult.Success;
end;

class function TBase8.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray): Int32;
var
  LI, LO: Int32;
  LEnd: Boolean;
  LB0, LB1, LB2: Byte;
begin
  LO := 0;
  LI := 0;
  while LI < System.Length(AInput) do
  begin
    LB0 := AInput[LI];
    Inc(LI);

    AOutput[LO] := Char((LB0 shr 5) + Ord(ZeroChar)); Inc(LO);
    AOutput[LO] := Char(((LB0 shr 2) and $07) + Ord(ZeroChar)); Inc(LO);

    LEnd := LI >= System.Length(AInput);
    if not LEnd then
    begin
      LB1 := AInput[LI];
      Inc(LI);
    end
    else
    begin
      LB1 := 0;
    end;

    AOutput[LO] := Char((((LB0 shl 1) and $07) + ((LB1 shr 7) and 1)) + Ord(ZeroChar)); Inc(LO);
    if LEnd then
    begin
      Break;
    end;

    AOutput[LO] := Char(((LB1 shr 4) and $07) + Ord(ZeroChar)); Inc(LO);
    AOutput[LO] := Char(((LB1 shr 1) and $07) + Ord(ZeroChar)); Inc(LO);

    LEnd := LI >= System.Length(AInput);
    if not LEnd then
    begin
      LB2 := AInput[LI];
      Inc(LI);
    end
    else
    begin
      LB2 := 0;
    end;

    AOutput[LO] := Char((((LB1 shl 2) and $07) + ((LB2 shr 6) and 3)) + Ord(ZeroChar)); Inc(LO);
    if LEnd then
    begin
      Break;
    end;

    AOutput[LO] := Char(((LB2 shr 3) and $07) + Ord(ZeroChar)); Inc(LO);
    AOutput[LO] := Char(((LB2 shl 0) and $07) + Ord(ZeroChar)); Inc(LO);
  end;

  Result := LO;
end;

end.
