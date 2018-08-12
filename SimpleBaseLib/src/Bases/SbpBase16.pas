unit SbpBase16;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpBits;

resourcestring
  SInvalidHexCharacter = 'Invalid hex character: %s';
  SInvalidTextLength = 'Text cannot be odd length %s';

type
  /// <summary>
  /// Hexadecimal encoding/decoding
  /// </summary>
  TBase16 = class sealed(TObject)
  strict private
  const

    lowerAlphabet: String = '0123456789abcdef';
    upperAlphabet: String = '0123456789ABCDEF';

    class function GetHexByte(c: Int32): Int32; static; inline;

    class function Encode(const bytes: TSimpleBaseLibByteArray;
      const alphabet: String): String; static;

  public
    /// <summary>
    /// Encode to Base16 representation using uppercase lettering
    /// </summary>
    /// <param name="bytes">Bytes to encode</param>
    /// <returns>Base16 string</returns>
    class function EncodeUpper(const bytes: TSimpleBaseLibByteArray): String;
      static; inline;

    /// <summary>
    /// Encode to Base16 representation using lowercase lettering
    /// </summary>
    /// <param name="bytes">Bytes to encode</param>
    /// <returns>Base16 string</returns>
    class function EncodeLower(const bytes: TSimpleBaseLibByteArray): String;
      static; inline;

    class function Decode(const text: String): TSimpleBaseLibByteArray; static;

  end;

implementation

{ TBase16 }

class function TBase16.GetHexByte(c: Int32): Int32;
var
  n: Int32;
begin
  Result := -1;
  n := c - Ord('0');
  if (n < 0) then
  begin
    raise EArgumentSimpleBaseLibException.CreateResFmt(@SInvalidHexCharacter,
      [Char(c)]);
  end;
  if (n < 10) then
  begin
    Result := n;
    Exit;
  end;
  n := (c or Ord(' ')) - Ord('a') + 10;
  if (n < 0) then
  begin
    raise EArgumentSimpleBaseLibException.CreateResFmt(@SInvalidHexCharacter,
      [Char(c)]);
  end;
  if (n <= Ord('z') - Ord('a')) then
  begin
    Result := n;
    Exit;
  end;
  raise EArgumentSimpleBaseLibException.CreateResFmt(@SInvalidHexCharacter,
    [Char(c)]);
end;

class function TBase16.Decode(const text: String): TSimpleBaseLibByteArray;
var
  textLen, b1, b2: Int32;
  resultPtr, pResult: PByte;
  textPtr, pInput, pEnd: PChar;
  c1, c2: Char;
begin
  Result := Nil;
  textLen := System.Length(text);
  if (textLen = 0) then
  begin
    Exit;
  end;
  if (textLen and 1 <> 0) then
  begin
    raise EArgumentSimpleBaseLibException.CreateResFmt
      (@SInvalidTextLength, [text]);
  end;
  System.SetLength(Result, textLen shr 1);
  resultPtr := PByte(Result);
  textPtr := PChar(text);

  pResult := resultPtr;
  pInput := textPtr;
  pEnd := pInput + textLen;
  while (pInput <> pEnd) do
  begin
    c1 := pInput^;
    System.Inc(pInput);
    b1 := GetHexByte(Ord(c1));
    c2 := pInput^;
    System.Inc(pInput);
    b2 := GetHexByte(Ord(c2));
    pResult^ := Byte(b1 shl 4 or b2);
    System.Inc(pResult);
  end;
end;

class function TBase16.Encode(const bytes: TSimpleBaseLibByteArray;
  const alphabet: String): String;
var
  bytesLen, b: Int32;
  resultPtr, alphabetPtr, pResult, pAlphabet: PChar;
  bytesPtr, pInput, pEnd: PByte;
begin
  Result := '';
  bytesLen := System.Length(bytes);
  if (bytesLen = 0) then
  begin
    Exit;
  end;
  Result := StringOfChar(Char(0), bytesLen * 2);
  resultPtr := PChar(Result);
  bytesPtr := PByte(bytes);
  alphabetPtr := PChar(alphabet);

  pResult := resultPtr;
  pAlphabet := alphabetPtr;
  pInput := bytesPtr;
  pEnd := pInput + bytesLen;
  while (pInput <> pEnd) do
  begin
    b := pInput^;
    pResult^ := pAlphabet[TBits.Asr32(b, 4)];
    System.Inc(pResult);
    pResult^ := pAlphabet[b and $0F];
    System.Inc(pResult);
    System.Inc(pInput);
  end;

end;

class function TBase16.EncodeLower(const bytes
  : TSimpleBaseLibByteArray): String;
begin
  Result := Encode(bytes, lowerAlphabet);
end;

class function TBase16.EncodeUpper(const bytes
  : TSimpleBaseLibByteArray): String;
begin
  Result := Encode(bytes, upperAlphabet);
end;

end.
