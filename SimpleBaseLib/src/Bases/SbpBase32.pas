unit SbpBase32;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpUtilities,
  SbpBits,
  SbpPointerUtils,
  SbpBase32Alphabet,
  SbpIBase32Alphabet,
  SbpIBase32;

resourcestring
  SAlphabetNil = 'Alphabet Instance cannot be Nil "%s"';
  SInvalidCharacter = 'Invalid character value in input: $%x "c"';

type
  TBase32 = class sealed(TInterfacedObject, IBase32)

  strict private
  const
    bitsPerByte = Int32(8);
    bitsPerChar = Int32(5);
    paddingChar = Char('=');

    class var

      FCrockford, FRfc4648, FExtendedHex: IBase32;

    class procedure InvalidInput(c: Char); static; inline;
    class function GetCrockford: IBase32; static; inline;
    class function GetRfc4648: IBase32; static; inline;
    class function GetExtendedHex: IBase32; static; inline;

  var
    Falphabet: IBase32Alphabet;

    class constructor Base32();

  public

    /// <summary>
    /// Encode a byte array into a Base32 string
    /// </summary>
    /// <param name="bytes">Buffer to be encoded</param>
    /// <param name="padding">Append padding characters in the output</param>
    /// <returns>Encoded string</returns>
    function Encode(bytes: TSimpleBaseLibByteArray; padding: Boolean): String;
    /// <summary>
    /// Decode a Base32 encoded string into a byte array.
    /// </summary>
    /// <param name="text">Encoded Base32 string</param>
    /// <returns>Decoded byte array</returns>
    function Decode(const text: String): TSimpleBaseLibByteArray;
    /// <summary>
    /// Douglas Crockford's Base32 flavor with substitution characters.
    /// </summary>
    class property Crockford: IBase32 read GetCrockford;
    /// <summary>
    /// RFC 4648 variant of Base32 converter
    /// </summary>
    class property Rfc4648: IBase32 read GetRfc4648;
    /// <summary>
    /// Extended Hex variant of Base32 converter
    /// </summary>
    /// <remarks>Also from RFC 4648</remarks>
    class property ExtendedHex: IBase32 read GetExtendedHex;

    constructor Create(const alphabet: IBase32Alphabet);
    destructor Destroy; override;

  end;

implementation

{ TBase32 }

class procedure TBase32.InvalidInput(c: Char);
begin
  raise EArgumentSimpleBaseLibException.CreateResFmt(@SInvalidCharacter,
    [Ord(c)]);
end;

class constructor TBase32.Base32;
begin
  FCrockford := TBase32.Create(TBase32Alphabet.Crockford as IBase32Alphabet);
  FRfc4648 := TBase32.Create(TBase32Alphabet.Rfc4648 as IBase32Alphabet);
  FExtendedHex := TBase32.Create
    (TBase32Alphabet.ExtendedHex as IBase32Alphabet);
end;

constructor TBase32.Create(const alphabet: IBase32Alphabet);
begin
  Inherited Create();
  if (alphabet = Nil) then
  begin
    raise EArgumentNilSimpleBaseLibException.CreateResFmt(@SAlphabetNil,
      ['alphabet']);
  end;
  Falphabet := alphabet;
end;

function TBase32.Decode(const text: String): TSimpleBaseLibByteArray;
var
  textLen, decodingTableLen, bitsLeft, outputLen, outputPad, b,
    shiftBits: Int32;
  decodingTable: TSimpleBaseLibByteArray;
  resultPtr, decodingPtr, pResult, pDecodingTable: PByte;
  inputPtr, pInput, pEnd: PChar;
  c: Char;
  trimmed: String;
begin
  Result := Nil;
  trimmed := TUtilities.TrimRight(text,
    TSimpleBaseLibCharArray.Create(paddingChar));
  textLen := System.Length(trimmed);
  if (textLen = 0) then
  begin
    Result := Nil;
    Exit;
  end;
  decodingTable := Falphabet.decodingTable;
  decodingTableLen := System.Length(decodingTable);
  bitsLeft := bitsPerByte;
  outputLen := textLen * bitsPerChar div bitsPerByte;
  System.SetLength(Result, outputLen);
  outputPad := 0;

  resultPtr := PByte(Result);
  inputPtr := PChar(trimmed);
  decodingPtr := PByte(decodingTable);

  pResult := resultPtr;
  pDecodingTable := decodingPtr;
  pInput := inputPtr;
  pEnd := TPointerUtils.Offset(inputPtr, textLen);
  while (pInput <> pEnd) do
  begin
    c := pInput^;
    System.Inc(pInput);
    if (Ord(c) >= decodingTableLen) then
    begin
      InvalidInput(c);
    end;
    b := pDecodingTable[Ord(c)] - 1;
    if (b < 0) then
    begin
      InvalidInput(c);
    end;
    if (bitsLeft > bitsPerChar) then
    begin
      bitsLeft := bitsLeft - bitsPerChar;
      outputPad := outputPad or (b shl bitsLeft);
      continue;
    end;
    shiftBits := bitsPerChar - bitsLeft;
    outputPad := outputPad or (TBits.Asr32(b, shiftBits));
    pResult^ := Byte(outputPad);
    System.Inc(pResult);
    b := b and ((1 shl shiftBits) - 1);
    bitsLeft := bitsPerByte - shiftBits;
    outputPad := b shl bitsLeft;
  end;
end;

destructor TBase32.Destroy;
begin
  inherited Destroy;
end;

function TBase32.Encode(bytes: TSimpleBaseLibByteArray;
  padding: Boolean): String;
var
  bytesLen, outputLen, bitsLeft, currentByte, outputPad, nextBits: Int32;
  outputBuffer: TSimpleBaseLibCharArray;
  inputPtr, pInput, pEnd: PByte;
  encodingTablePtr, outputPtr, pEncodingTable, pOutput, pOutputEnd: PChar;
begin
  Result := '';
  bytesLen := System.Length(bytes);
  if (bytesLen = 0) then
  begin
    Result := '';
    Exit;
  end;

  // we are ok with slightly larger buffer since the output string will always
  // have the exact length of the output produced.
  outputLen := (((bytesLen - 1) div bitsPerChar) + 1) * bitsPerByte;
  System.SetLength(outputBuffer, outputLen);

  inputPtr := PByte(bytes);
  encodingTablePtr := PChar(Falphabet.EncodingTable);
  outputPtr := PChar(outputBuffer);

  pEncodingTable := encodingTablePtr;
  pOutput := outputPtr;
  pOutputEnd := outputPtr + outputLen;
  pInput := inputPtr;

  bitsLeft := bitsPerByte;
  currentByte := Int32(Byte(pInput^));
  pEnd := TPointerUtils.Offset(pInput, bytesLen);
  while (pInput <> pEnd) do
  begin

    if (bitsLeft > bitsPerChar) then
    begin
      bitsLeft := bitsLeft - bitsPerChar;
      outputPad := TBits.Asr32(currentByte, bitsLeft);
      pOutput^ := pEncodingTable[outputPad];
      System.Inc(pOutput);
      currentByte := currentByte and ((1 shl bitsLeft) - 1);
    end;
    nextBits := bitsPerChar - bitsLeft;
    bitsLeft := bitsPerByte - nextBits;
    outputPad := currentByte shl nextBits;
    System.Inc(pInput);
    if (pInput <> pEnd) then
    begin
      currentByte := Int32(Byte(pInput^));
      outputPad := outputPad or TBits.Asr32(currentByte, bitsLeft);
      currentByte := currentByte and ((1 shl bitsLeft) - 1);
    end;
    pOutput^ := pEncodingTable[outputPad];
    System.Inc(pOutput);
  end;
  if (padding) then
  begin
    while (pOutput <> pOutputEnd) do
    begin
      pOutput^ := paddingChar;
      System.Inc(pOutput);
    end;
  end;
  System.SetString(Result, outputPtr, Int32(pOutput - outputPtr));
end;

class function TBase32.GetCrockford: IBase32;
begin
  Result := FCrockford;
end;

class function TBase32.GetExtendedHex: IBase32;
begin
  Result := FExtendedHex;
end;

class function TBase32.GetRfc4648: IBase32;
begin
  Result := FRfc4648;
end;

end.
