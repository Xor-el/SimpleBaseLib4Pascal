unit SbpBase64;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpBits,
  SbpPointerUtils,
  SbpBase64Alphabet,
  SbpIBase64Alphabet,
  SbpIBase64;

resourcestring
  SAlphabetNil = 'Alphabet Instance cannot be Nil "%s"';

type
  TBase64 = class sealed(TInterfacedObject, IBase64)

  strict private
  const
    paddingChar = Char('=');

    class var

      FDefault, FDefaultNoPadding, FUrlEncoding, FXmlEncoding, FRegExEncoding,
      FFileEncoding: IBase64;

  var
    Falphabet: IBase64Alphabet;

    class function Process(var pInput: PChar; pEnd: PChar; decode_table: PByte)
      : Byte; static; inline;

    class function GetDefault: IBase64; static; inline;
    class function GetDefaultNoPadding: IBase64; static; inline;
    class function GetFileEncoding: IBase64; static; inline;
    class function GetRegExEncoding: IBase64; static; inline;
    class function GetUrlEncoding: IBase64; static; inline;
    class function GetXmlEncoding: IBase64; static; inline;

    class constructor Base64();

  public

    /// <summary>
    /// Encode a byte array into a Base64 string
    /// </summary>
    /// <param name="bytes">Buffer to be encoded</param>
    /// <returns>Encoded string</returns>
    function Encode(bytes: TSimpleBaseLibByteArray): String;
    /// <summary>
    /// Decode a Base64 encoded string into a byte array.
    /// </summary>
    /// <param name="text">Encoded Base64 string</param>
    /// <returns>Decoded byte array</returns>
    function Decode(const text: String): TSimpleBaseLibByteArray;

    class property Default: IBase64 read GetDefault;
    class property DefaultNoPadding: IBase64 read GetDefaultNoPadding;
    class property UrlEncoding: IBase64 read GetUrlEncoding;
    class property XmlEncoding: IBase64 read GetXmlEncoding;
    class property RegExEncoding: IBase64 read GetRegExEncoding;
    class property FileEncoding: IBase64 read GetFileEncoding;

    constructor Create(const alphabet: IBase64Alphabet);
    destructor Destroy; override;

  end;

implementation

{ TBase64 }

class function TBase64.Process(var pInput: PChar; pEnd: PChar;
  decode_table: PByte): Byte;
var
  c: Char;
begin
  // if pInput >= pEnd then
  // begin
  // Result := Byte(0);
  // System.Inc(pInput);
  // Exit;
  // end;

  c := pInput^;
  System.Inc(pInput);

  Result := decode_table[Ord(c)];
end;

class constructor TBase64.Base64;
begin
  FDefault := TBase64.Create(TBase64Alphabet.Default as IBase64Alphabet);
  FDefaultNoPadding := TBase64.Create
    (TBase64Alphabet.DefaultNoPadding as IBase64Alphabet);
  FUrlEncoding := TBase64.Create
    (TBase64Alphabet.UrlEncoding as IBase64Alphabet);
  FXmlEncoding := TBase64.Create
    (TBase64Alphabet.XmlEncoding as IBase64Alphabet);
  FRegExEncoding := TBase64.Create
    (TBase64Alphabet.RegExEncoding as IBase64Alphabet);
  FFileEncoding := TBase64.Create
    (TBase64Alphabet.FileEncoding as IBase64Alphabet);
end;

constructor TBase64.Create(const alphabet: IBase64Alphabet);
begin
  Inherited Create();
  if (alphabet = Nil) then
  begin
    raise EArgumentNilSimpleBaseLibException.CreateResFmt(@SAlphabetNil,
      ['alphabet']);
  end;
  Falphabet := alphabet;
end;

function TBase64.Decode(const text: String): TSimpleBaseLibByteArray;
var
  Idx, textLen, LowPoint, HighPoint, blocks, bytes, padding, i: Int32;
  temp1, temp2: Byte;
  tempArray: TSimpleBaseLibCharArray;
  _data: TSimpleBaseLibByteArray;
  _p, p2, pEnd: PChar;
  dp, _d, p_decode: PByte;
begin
  Result := Nil;
  textLen := System.Length(text);
  if (textLen = 0) then
  begin
    Result := Nil;
    Exit;
  end;

  System.SetLength(tempArray, textLen);

{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(text);
  HighPoint := System.High(text);
{$ELSE}
  LowPoint := 1;
  HighPoint := System.Length(text);
{$ENDIF DELPHIXE3_UP}
  for Idx := LowPoint to HighPoint do
  begin
    tempArray[Idx - 1] := text[Idx];
  end;

  _p := PChar(tempArray);
  p_decode := PByte(Falphabet.DecodingTable);
  pEnd := TPointerUtils.Offset(_p, System.Length(tempArray));

  p2 := _p;

  blocks := (textLen - 1) div 4 + 1;
  bytes := blocks * 3;

  padding := blocks * 4 - textLen;

  if ((textLen > 2) and (p2[textLen - 2] = paddingChar)) then
  begin
    padding := 2;
  end
  else if ((textLen > 1) and (p2[textLen - 1] = paddingChar)) then
  begin
    padding := 1;
  end;

  System.SetLength(_data, bytes - padding);

  _d := PByte(_data);

  dp := _d;

  i := 1;

  while i < blocks do
  begin

    temp1 := Process(p2, pEnd, p_decode);

    temp2 := Process(p2, pEnd, p_decode);

    dp^ := Byte((temp1 shl 2) or (TBits.Asr32(temp2 and $30, 4)));
    System.Inc(dp);

    temp1 := Process(p2, pEnd, p_decode);

    dp^ := Byte((TBits.Asr32(temp1 and $3C, 2)) or ((temp2 and $0F) shl 4));
    System.Inc(dp);

    temp2 := Process(p2, pEnd, p_decode);

    dp^ := Byte(((temp1 and $03) shl 6) or temp2);
    System.Inc(dp);

    System.Inc(i);
  end;

  temp1 := Process(p2, pEnd, p_decode);

  temp2 := Process(p2, pEnd, p_decode);

  dp^ := Byte((temp1 shl 2) or (TBits.Asr32(temp2 and $30, 4)));
  System.Inc(dp);

  temp1 := Process(p2, pEnd, p_decode);

  if (padding <> 2) then
  begin
    dp^ := Byte((TBits.Asr32(temp1 and $3C, 2) or ((temp2 and $0F) shl 4)));
    System.Inc(dp);
  end;

  temp2 := Process(p2, pEnd, p_decode);
  if (padding = 0) then
  begin
    dp^ := Byte(((temp1 and $03) shl 6) or temp2);
    System.Inc(dp);
  end;

  Result := _data;

end;

destructor TBase64.Destroy;
begin
  inherited Destroy;
end;

function TBase64.Encode(bytes: TSimpleBaseLibByteArray): String;
var
  bytesLen, padding, blocks, l, i: Int32;
  b1, b2, b3: Byte;
  _d, d: PByte;
  _cs, _sp, sp: PChar;
  _s: TSimpleBaseLibCharArray;
  pad2, pad1: Boolean;
begin
  Result := '';
  bytesLen := System.Length(bytes);
  if (bytesLen = 0) then
  begin
    Result := '';
    Exit;
  end;

  _d := PByte(bytes);
  _cs := PChar(Falphabet.EncodingTable);

  d := _d;

  padding := bytesLen mod 3;
  if (padding > 0) then
  begin
    padding := 3 - padding;
  end;
  blocks := (bytesLen - 1) div 3 + 1;

  l := blocks * 4;

  System.SetLength(_s, l);

  _sp := PChar(_s);
  sp := _sp;

  i := 1;

  while i < blocks do
  begin
    b1 := d^;
    System.Inc(d);
    b2 := d^;
    System.Inc(d);
    b3 := d^;
    System.Inc(d);

    sp^ := _cs[TBits.Asr32((b1 and $FC), 2)];
    System.Inc(sp);
    sp^ := _cs[TBits.Asr32((b2 and $F0), 4) or (b1 and $03) shl 4];
    System.Inc(sp);
    sp^ := _cs[TBits.Asr32((b3 and $C0), 6) or (b2 and $0F) shl 2];
    System.Inc(sp);
    sp^ := _cs[b3 and $3F];
    System.Inc(sp);

    System.Inc(i);
  end;

  pad2 := padding = 2;
  pad1 := padding > 0;

  b1 := d^;
  System.Inc(d);
  if pad2 then
  begin
    b2 := Byte(0)
  end
  else
  begin
    b2 := d^;
    System.Inc(d);
  end;

  if pad1 then
  begin
    b3 := Byte(0)
  end
  else
  begin
    b3 := d^;
    System.Inc(d);
  end;

  sp^ := _cs[TBits.Asr32((b1 and $FC), 2)];
  System.Inc(sp);
  sp^ := _cs[TBits.Asr32((b2 and $F0), 4) or (b1 and $03) shl 4];
  System.Inc(sp);
  if pad2 then
  begin
    sp^ := '='
  end
  else
  begin
    sp^ := _cs[TBits.Asr32((b3 and $C0), 6) or (b2 and $0F) shl 2]
  end;

  System.Inc(sp);

  if pad1 then
  begin
    sp^ := '='
  end
  else
  begin
    sp^ := _cs[b3 and $3F]
  end;

  System.Inc(sp);

  if (not Falphabet.PaddingEnabled) then
  begin
    if (pad2) then
    begin
      System.Dec(l);
    end;
    if (pad1) then
    begin
      System.Dec(l);
    end;

  end;

  System.SetString(Result, PChar(@_s[0]), l);

end;

class function TBase64.GetDefault: IBase64;
begin
  Result := FDefault;
end;

class function TBase64.GetDefaultNoPadding: IBase64;
begin
  Result := FDefaultNoPadding;
end;

class function TBase64.GetFileEncoding: IBase64;
begin
  Result := FFileEncoding;
end;

class function TBase64.GetRegExEncoding: IBase64;
begin
  Result := FRegExEncoding;
end;

class function TBase64.GetUrlEncoding: IBase64;
begin
  Result := FUrlEncoding;
end;

class function TBase64.GetXmlEncoding: IBase64;
begin
  Result := FXmlEncoding;
end;

end.
