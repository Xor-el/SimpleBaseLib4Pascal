unit SbpBase16;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  Classes,
  SbpSimpleBaseLibTypes,
  SbpICodingAlphabet,
  SbpIBase16,
  SbpIBaseStreamCoder,
  SbpINonAllocatingBaseCoder,
  SbpStreamUtilities,
  SbpCodingAlphabet,
  SbpBase16Alphabet;

type
  TBase16 = class(TInterfacedObject, IBase16, IBaseStreamCoder, INonAllocatingBaseCoder)
  strict private
  const
    EncodeBlockSize = Int32(1);
    DecodeBlockSize = Int32(2);

  var
    FAlphabet: ICodingAlphabet;

    class var FUpperCase: IBase16;
    class var FLowerCase: IBase16;
    class var FModHex: IBase16;

    class function GetUpperCase: IBase16; static;
    class function GetLowerCase: IBase16; static;
    class function GetModHex: IBase16; static;

    function DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
    function EncodeBuffer(ABytes: TSimpleBaseLibByteArray; ALastBlock: Boolean): String;

    function GetAlphabet: ICodingAlphabet;

    class procedure InternalEncode(const AInput: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; const AAlphabet: String); static;

    function InternalDecode(const AInput: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;

  public
    class constructor Create;

    constructor Create(const AAlphabet: ICodingAlphabet);

    function ToString: String; override;
    function GetHashCode: {$IFDEF DELPHI}Int32;{$ELSE}PtrInt;{$ENDIF DELPHI}override;

    function Encode(const ABytes: TSimpleBaseLibByteArray): String; overload;
    function Decode(const AText: String): TSimpleBaseLibByteArray; overload;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;
    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;

    class property UpperCase: IBase16 read GetUpperCase;
    class property LowerCase: IBase16 read GetLowerCase;
    class property ModHex: IBase16 read GetModHex;

    property Alphabet: ICodingAlphabet read GetAlphabet;
  end;

implementation

{ TBase16 }

class constructor TBase16.Create;
begin
  FUpperCase := nil;
  FLowerCase := nil;
  FModHex := nil;
end;

function TBase16.DecodeBuffer(AText: String): TSimpleBaseLibByteArray;
begin
  Result := Decode(AText);
end;

function TBase16.EncodeBuffer(ABytes: TSimpleBaseLibByteArray;
  ALastBlock: Boolean): String;
begin
  Result := Encode(ABytes);
end;

constructor TBase16.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create;
  FAlphabet := AAlphabet;
end;

function TBase16.GetHashCode: {$IFDEF DELPHI}Int32;{$ELSE}PtrInt;{$ENDIF DELPHI}
begin
  Result := Alphabet.GetHashCode;
end;

function TBase16.ToString: String;
begin
  Result := 'Base16_' + Alphabet.ToString;
end;

function TBase16.GetAlphabet: ICodingAlphabet;
begin
  Result := FAlphabet;
end;

class function TBase16.GetUpperCase: IBase16;
begin
  if FUpperCase = nil then
  begin
    FUpperCase := TBase16.Create(TBase16Alphabet.UpperCase);
  end;
  Result := FUpperCase;
end;

class function TBase16.GetLowerCase: IBase16;
begin
  if FLowerCase = nil then
  begin
    FLowerCase := TBase16.Create(TBase16Alphabet.LowerCase);
  end;
  Result := FLowerCase;
end;

class function TBase16.GetModHex: IBase16;
begin
  if FModHex = nil then
  begin
    FModHex := TBase16.Create(TBase16Alphabet.ModHex);
  end;
  Result := FModHex;
end;

function TBase16.Decode(const AText: String): TSimpleBaseLibByteArray;
var
  LSafeCount, LBytesWritten: Int32;
begin
  if System.Length(AText) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  LSafeCount := GetSafeByteCountForDecoding(AText);
  if LSafeCount = 0 then
  begin
    raise EArgumentSimpleBaseLibException.Create('Invalid text length');
  end;

  System.SetLength(Result, LSafeCount);
  if not InternalDecode(AText, Result, LBytesWritten) then
  begin
    raise EArgumentSimpleBaseLibException.Create('Invalid character in input');
  end;
end;

procedure TBase16.Decode(const AInput: TStringBuilder;
  const AOutput: TStream);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(DecodeBlockSize);
  TStreamUtilities.Decode(AInput, AOutput, DecodeBuffer, LBufferSize);
end;

function TBase16.GetSafeByteCountForDecoding(const AText: String): Int32;
var
  LTextLen: Int32;
begin
  LTextLen := System.Length(AText);
  if (LTextLen and 1) <> 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := LTextLen div 2;
end;

function TBase16.GetSafeCharCountForEncoding(
  const ABytes: TSimpleBaseLibByteArray): Int32;
begin
  Result := System.Length(ABytes) * 2;
end;

function TBase16.TryDecode(const AText: String;
  const AOutput: TSimpleBaseLibByteArray;
  out ABytesWritten: Int32): Boolean;
var
  LTextLen, LOutputLen: Int32;
begin
  ABytesWritten := 0;
  LTextLen := System.Length(AText);
  if LTextLen = 0 then
  begin
    Result := True;
    Exit;
  end;

  if (LTextLen and 1) <> 0 then
  begin
    Result := False;
    Exit;
  end;

  LOutputLen := LTextLen div 2;
  if System.Length(AOutput) < LOutputLen then
  begin
    Result := False;
    Exit;
  end;

  Result := InternalDecode(AText, AOutput, ABytesWritten);
end;

function TBase16.Encode(const ABytes: TSimpleBaseLibByteArray): String;
var
  LLen, LSafeCount: Int32;
  LAlphabet: String;
  LOutput: TSimpleBaseLibCharArray;
begin
  LLen := System.Length(ABytes);
  if LLen = 0 then
  begin
    Result := '';
    Exit;
  end;

  LAlphabet := FAlphabet.Value;
  LSafeCount := GetSafeCharCountForEncoding(ABytes);
  System.SetLength(LOutput, LSafeCount);
  InternalEncode(ABytes, LOutput, LAlphabet);
  SetString(Result, PChar(@LOutput[0]), System.Length(LOutput));
end;

function TBase16.TryEncode(const ABytes: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
var
  LLen, LOutputLen: Int32;
  LAlphabet: String;
begin
  ACharsWritten := 0;
  LLen := System.Length(ABytes);
  if LLen = 0 then
  begin
    Result := True;
    Exit;
  end;

  LOutputLen := LLen * 2;
  if System.Length(AOutput) < LOutputLen then
  begin
    Result := False;
    Exit;
  end;

  LAlphabet := FAlphabet.Value;
  InternalEncode(ABytes, AOutput, LAlphabet);

  ACharsWritten := LOutputLen;
  Result := True;
end;

function TBase16.InternalDecode(const AInput: String;
  const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LTextLen, LI, LO, LByte1, LByte2: Int32;
  LChar1, LChar2: Char;
  LTable: TSimpleBaseLibByteArray;
begin
  LTable := FAlphabet.ReverseLookupTable;
  LTextLen := System.Length(AInput);
  LO := 0;
  LI := 1;
  while LI <= LTextLen do
  begin
    LChar1 := AInput[LI];
    LChar2 := AInput[LI + 1];

    if (not TCodingAlphabet.TryLookup(LTable, LChar1, LByte1)) or
      (not TCodingAlphabet.TryLookup(LTable, LChar2, LByte2)) then
    begin
      ABytesWritten := LO;
      Result := False;
      Exit;
    end;

    AOutput[LO] := Byte((LByte1 * 16) or LByte2);
    Inc(LO);
    Inc(LI, 2);
  end;

  ABytesWritten := LO;
  Result := True;
end;

class procedure TBase16.InternalEncode(const AInput: TSimpleBaseLibByteArray;
  const AOutput: TSimpleBaseLibCharArray; const AAlphabet: String);
var
  LI, LO, LLen: Int32;
  LByte: Byte;
begin
  LLen := System.Length(AInput);
  LO := 0;
  for LI := 0 to LLen - 1 do
  begin
    LByte := AInput[LI];
    AOutput[LO] := AAlphabet[(LByte shr 4) + 1];
    AOutput[LO + 1] := AAlphabet[(LByte and $0F) + 1];
    Inc(LO, 2);
  end;
end;

procedure TBase16.Encode(const AInput: TStream;
  const AOutput: TStringBuilder);
var
  LBufferSize: Int32;
begin
  LBufferSize := TStreamUtilities.GetAlignedBufferSize(EncodeBlockSize);
  TStreamUtilities.Encode(AInput, AOutput, EncodeBuffer, LBufferSize);
end;

end.

