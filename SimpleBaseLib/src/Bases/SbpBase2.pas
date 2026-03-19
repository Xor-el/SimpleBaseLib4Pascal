unit SbpBase2;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBase2,
  SbpINonAllocatingBaseCoder,
  SbpIBaseStreamCoder,
  SbpStreamUtilities;

type
  TBase2 = class(TInterfacedObject, IBase2, INonAllocatingBaseCoder, IBaseStreamCoder)
  strict private
    const
    EncodeBlockSize = Int32(1);
    DecodeBlockSize = Int32(8);

    class var FDefault: IBase2;
    class function GetDefault: IBase2; static;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBuffer(ABytes: TSimpleBaseLibByteArray; ALastBlock: Boolean): String;

    class function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean; static;
    class procedure InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray); static;
  public
    class constructor Create;
    class property Default: IBase2 read GetDefault;

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

{ TBase2 }

class constructor TBase2.Create;
begin
  FDefault := nil;
end;

function TBase2.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase2.EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes);
end;

class function TBase2.GetDefault: IBase2;
begin
  if FDefault = nil then
  begin
    FDefault := TBase2.Create;
  end;
  Result := FDefault;
end;

function TBase2.Decode(const AText: String): TSimpleBaseLibByteArray;
var
  LOutputLen: Int32;
begin
  if System.Length(AText) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  if (System.Length(AText) mod 8) <> 0 then
  begin
    raise EArgumentSimpleBaseLibException.Create('Input length must be a multiple of 8');
  end;

  LOutputLen := System.Length(AText) div 8;
  System.SetLength(Result, LOutputLen);

  if not InternalDecode(AText, Result, LOutputLen) then
  begin
    raise EArgumentSimpleBaseLibException.Create('Invalid Base2 character encountered');
  end;
end;

procedure TBase2.Decode(const AInput: TStringBuilder; const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

function TBase2.Encode(const ABytes: TSimpleBaseLibByteArray): String;
var
  LOutputLen: Int32;
  LOutput: TSimpleBaseLibCharArray;
begin
  LOutputLen := System.Length(ABytes) * 8;
  if LOutputLen = 0 then
  begin
    Result := '';
    Exit;
  end;

  System.SetLength(LOutput, LOutputLen);
  InternalEncode(ABytes, LOutput);
  SetString(Result, PChar(@LOutput[0]), LOutputLen);
end;

procedure TBase2.Encode(const AInput: TStream; const AOutput: TStringBuilder);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  TStreamUtilities.Encode(AInput, AOutput, EncodeBuffer, LBufferSize);
end;

function TBase2.GetSafeByteCountForDecoding(const AText: String): Int32;
begin
  Result := System.Length(AText) div 8;
end;

function TBase2.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := System.Length(ABytes) * 8;
end;

function TBase2.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LInputLen, LNumBlocks, LRemainder: Int32;
begin
  ABytesWritten := 0;
  LInputLen := System.Length(AText);
  if LInputLen = 0 then
  begin
    Result := True;
    Exit;
  end;

  LNumBlocks := LInputLen div 8;
  LRemainder := LInputLen mod 8;
  if (LRemainder <> 0) or (System.Length(AOutput) < LNumBlocks) then
  begin
    Result := False;
    Exit;
  end;

  Result := InternalDecode(AText, AOutput, ABytesWritten);
end;

function TBase2.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
var
  LTargetLen: Int32;
begin
  ACharsWritten := 0;
  if System.Length(ABytes) = 0 then
  begin
    Result := True;
    Exit;
  end;

  LTargetLen := System.Length(ABytes) * 8;
  if System.Length(AOutput) < LTargetLen then
  begin
    Result := False;
    Exit;
  end;

  InternalEncode(ABytes, AOutput);
  ACharsWritten := LTargetLen;
  Result := True;
end;

class function TBase2.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LI, LC, LShift: Int32;
  LPad: Byte;
begin
  ABytesWritten := 0;
  LPad := 0;
  for LI := 1 to System.Length(AInput) do
  begin
    LC := Ord(AInput[LI]) - Ord('0');
    if (LC and 1) <> LC then
    begin
      Result := False;
      Exit;
    end;

    LShift := 7 - ((LI - 1) mod 8);
    LPad := LPad or Byte(LC shl LShift);
    if LShift = 0 then
    begin
      AOutput[ABytesWritten] := LPad;
      Inc(ABytesWritten);
      LPad := 0;
    end;
  end;

  Result := True;
end;

class procedure TBase2.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray);
var
  LI, LO: Int32;
  LByte: Byte;
begin
  LO := 0;
  for LI := 0 to System.Length(AInput) - 1 do
  begin
    LByte := AInput[LI];
    if (LByte and $80) <> 0 then AOutput[LO + 0] := '1' else AOutput[LO + 0] := '0';
    if (LByte and $40) <> 0 then AOutput[LO + 1] := '1' else AOutput[LO + 1] := '0';
    if (LByte and $20) <> 0 then AOutput[LO + 2] := '1' else AOutput[LO + 2] := '0';
    if (LByte and $10) <> 0 then AOutput[LO + 3] := '1' else AOutput[LO + 3] := '0';
    if (LByte and $08) <> 0 then AOutput[LO + 4] := '1' else AOutput[LO + 4] := '0';
    if (LByte and $04) <> 0 then AOutput[LO + 5] := '1' else AOutput[LO + 5] := '0';
    if (LByte and $02) <> 0 then AOutput[LO + 6] := '1' else AOutput[LO + 6] := '0';
    if (LByte and $01) <> 0 then AOutput[LO + 7] := '1' else AOutput[LO + 7] := '0';
    Inc(LO, 8);
  end;
end;

end.
