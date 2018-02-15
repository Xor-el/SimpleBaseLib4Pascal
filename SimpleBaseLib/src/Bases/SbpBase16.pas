unit SbpBase16;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpBits,
  SbpPointerUtils;

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
    numberOffset = Byte(48);
    upperNumberDiff = Byte(7);
    lowerUpperDiff = Byte(32);

    lowerAlphabet = '0123456789abcdef';
    upperAlphabet = '0123456789ABCDEF';

    class procedure ValidateHex(c: Char); static; inline;
    class function GetHexByte(character: Int32): Int32; static; inline;

    class function Encode(bytes: TSimpleBaseLibByteArray;
      const alphabet: String): String; static;

  public
    /// <summary>
    /// Encode to Base16 representation using uppercase lettering
    /// </summary>
    /// <param name="bytes">Bytes to encode</param>
    /// <returns>Base16 string</returns>
    class function EncodeUpper(bytes: TSimpleBaseLibByteArray): String;
      static; inline;

    /// <summary>
    /// Encode to Base16 representation using lowercase lettering
    /// </summary>
    /// <param name="bytes">Bytes to encode</param>
    /// <returns>Base16 string</returns>
    class function EncodeLower(bytes: TSimpleBaseLibByteArray): String;
      static; inline;

    class function Decode(const text: String): TSimpleBaseLibByteArray; static;

  end;

implementation

{ TBase16 }

class function TBase16.GetHexByte(character: Int32): Int32;
var
  c: Int32;
begin
  c := character - numberOffset;
  if (c < 10) then // is number?
  begin
    result := c;
    Exit;
  end;
  c := c - upperNumberDiff;
  if (c < 16) then // is uppercase?
  begin
    result := c;
    Exit;
  end;
  result := c - lowerUpperDiff;
end;

class procedure TBase16.ValidateHex(c: Char);
begin
  if (not(((c >= '0') and (c <= '9')) or ((c >= 'A') and (c <= 'F')) or
    ((c >= 'a') and (c <= 'f')))) then
  begin
    raise EInvalidOperationSimpleBaseLibException.CreateResFmt
      (@SInvalidHexCharacter, [c]);
  end;
end;

class function TBase16.Decode(const text: String): TSimpleBaseLibByteArray;
var
  textLen, b1, b2: Int32;
  resultPtr, pResult: PByte;
  textPtr, pInput, pEnd: PChar;
  c1, c2: Char;
begin
  result := Nil;
  textLen := System.Length(text);
  if (textLen = 0) then
  begin
    result := Nil;
    Exit;
  end;
  if (textLen mod 2 <> 0) then
  begin
    raise EArgumentSimpleBaseLibException.CreateResFmt
      (@SInvalidTextLength, [text]);
  end;
  System.SetLength(result, textLen div 2);
  resultPtr := PByte(result);
  textPtr := PChar(text);

  pResult := resultPtr;
  pInput := textPtr;
  pEnd := TPointerUtils.Offset(pInput, textLen);
  while (pInput <> pEnd) do
  begin
    c1 := pInput^;
    System.Inc(pInput);
    ValidateHex(c1);
    b1 := GetHexByte(Ord(c1));
    c2 := pInput^;
    System.Inc(pInput);
    ValidateHex(c2);
    b2 := GetHexByte(Ord(c2));
    pResult^ := Byte(b1 shl 4 or b2);
    System.Inc(pResult);
  end;
end;

class function TBase16.Encode(bytes: TSimpleBaseLibByteArray;
  const alphabet: String): String;
var
  bytesLen, b: Int32;
  resultPtr, alphabetPtr, pResult, pAlphabet: PChar;
  bytesPtr, pInput, pEnd: PByte;
begin
  result := '';
  bytesLen := System.Length(bytes);
  if (bytesLen = 0) then
  begin
    result := '';
    Exit;
  end;
  result := StringOfChar(Char(0), bytesLen * 2);
  resultPtr := PChar(result);
  bytesPtr := PByte(bytes);
  alphabetPtr := PChar(alphabet);

  pResult := resultPtr;
  pAlphabet := alphabetPtr;
  pInput := bytesPtr;
  pEnd := TPointerUtils.Offset(pInput, bytesLen);
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

class function TBase16.EncodeLower(bytes: TSimpleBaseLibByteArray): String;
begin
  result := Encode(bytes, lowerAlphabet);
end;

class function TBase16.EncodeUpper(bytes: TSimpleBaseLibByteArray): String;
begin
  result := Encode(bytes, upperAlphabet);
end;

end.
