unit SbpBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpIBase32Alphabet,
  SbpPaddingPosition,
  SbpCharMap,
  SbpCodingAlphabet;

type
  TBase32Alphabet = class(TCodingAlphabet, IBase32Alphabet)
  strict private
    FPaddingChar: Char;
    FPaddingPosition: TPaddingPosition;

    class var FCrockfordAlphabet: IBase32Alphabet;
    class var FRfc4648Alphabet: IBase32Alphabet;
    class var FExtendedHexAlphabet: IBase32Alphabet;
    class var FExtendedHexLowerAlphabet: IBase32Alphabet;
    class var FZBase32Alphabet: IBase32Alphabet;
    class var FGeohashAlphabet: IBase32Alphabet;
    class var FBech32Alphabet: IBase32Alphabet;
    class var FFileCoinAlphabet: IBase32Alphabet;
    class var FBase32HAlphabet: IBase32Alphabet;

    class function GetCrockford: IBase32Alphabet; static;
    class function GetRfc4648: IBase32Alphabet; static;
    class function GetExtendedHex: IBase32Alphabet; static;
    class function GetExtendedHexLower: IBase32Alphabet; static;
    class function GetZBase32: IBase32Alphabet; static;
    class function GetGeohash: IBase32Alphabet; static;
    class function GetBech32: IBase32Alphabet; static;
    class function GetFileCoin: IBase32Alphabet; static;
    class function GetBase32H: IBase32Alphabet; static;
  strict protected
    function GetPaddingChar: Char;
    function GetPaddingPosition: TPaddingPosition;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String); overload;
    constructor Create(const AAlphabet: String; APaddingChar: Char;
      APaddingPosition: TPaddingPosition); overload;

    class property Crockford: IBase32Alphabet read GetCrockford;
    class property Rfc4648: IBase32Alphabet read GetRfc4648;
    class property ExtendedHex: IBase32Alphabet read GetExtendedHex;
    class property ExtendedHexLower: IBase32Alphabet read GetExtendedHexLower;
    class property ZBase32: IBase32Alphabet read GetZBase32;
    class property Geohash: IBase32Alphabet read GetGeohash;
    class property Bech32: IBase32Alphabet read GetBech32;
    class property FileCoin: IBase32Alphabet read GetFileCoin;
    class property Base32H: IBase32Alphabet read GetBase32H;

    property PaddingChar: Char read GetPaddingChar;
    property PaddingPosition: TPaddingPosition read GetPaddingPosition;
  end;

implementation

uses
  SbpAliasedBase32Alphabet;

{ TBase32Alphabet }

class constructor TBase32Alphabet.Create;
begin
  FCrockfordAlphabet := nil;
  FRfc4648Alphabet := nil;
  FExtendedHexAlphabet := nil;
  FExtendedHexLowerAlphabet := nil;
  FZBase32Alphabet := nil;
  FGeohashAlphabet := nil;
  FBech32Alphabet := nil;
  FFileCoinAlphabet := nil;
  FBase32HAlphabet := nil;
end;

constructor TBase32Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(32, AAlphabet, True);
  FPaddingChar := '=';
  FPaddingPosition := TPaddingPosition.&End;
end;

constructor TBase32Alphabet.Create(const AAlphabet: String; APaddingChar: Char;
  APaddingPosition: TPaddingPosition);
begin
  Create(AAlphabet);
  FPaddingChar := APaddingChar;
  FPaddingPosition := APaddingPosition;
end;

function TBase32Alphabet.GetPaddingChar: Char;
begin
  Result := FPaddingChar;
end;

function TBase32Alphabet.GetPaddingPosition: TPaddingPosition;
begin
  Result := FPaddingPosition;
end;

class function TBase32Alphabet.GetRfc4648: IBase32Alphabet;
begin
  if FRfc4648Alphabet = nil then
  begin
    FRfc4648Alphabet := TBase32Alphabet.Create('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567');
  end;
  Result := FRfc4648Alphabet;
end;

class function TBase32Alphabet.GetExtendedHex: IBase32Alphabet;
begin
  if FExtendedHexAlphabet = nil then
  begin
    FExtendedHexAlphabet := TBase32Alphabet.Create('0123456789ABCDEFGHIJKLMNOPQRSTUV');
  end;
  Result := FExtendedHexAlphabet;
end;

class function TBase32Alphabet.GetExtendedHexLower: IBase32Alphabet;
begin
  if FExtendedHexLowerAlphabet = nil then
  begin
    FExtendedHexLowerAlphabet := TBase32Alphabet.Create('0123456789abcdefghijklmnopqrstuv');
  end;
  Result := FExtendedHexLowerAlphabet;
end;

class function TBase32Alphabet.GetZBase32: IBase32Alphabet;
begin
  if FZBase32Alphabet = nil then
  begin
    FZBase32Alphabet := TBase32Alphabet.Create('ybndrfg8ejkmcpqxot1uwisza345h769');
  end;
  Result := FZBase32Alphabet;
end;

class function TBase32Alphabet.GetGeohash: IBase32Alphabet;
begin
  if FGeohashAlphabet = nil then
  begin
    FGeohashAlphabet := TBase32Alphabet.Create('0123456789bcdefghjkmnpqrstuvwxyz');
  end;
  Result := FGeohashAlphabet;
end;

class function TBase32Alphabet.GetBech32: IBase32Alphabet;
begin
  if FBech32Alphabet = nil then
  begin
    FBech32Alphabet := TBase32Alphabet.Create('qpzry9x8gf2tvdw0s3jn54khce6mua7l');
  end;
  Result := FBech32Alphabet;
end;

class function TBase32Alphabet.GetFileCoin: IBase32Alphabet;
begin
  if FFileCoinAlphabet = nil then
  begin
    FFileCoinAlphabet := TBase32Alphabet.Create('abcdefghijklmnopqrstuvwxyz234567');
  end;
  Result := FFileCoinAlphabet;
end;

class function TBase32Alphabet.GetCrockford: IBase32Alphabet;
const
  CMap: array [0 .. 2] of TCharMap = (
    (FromChar: 'O'; ToChar: '0'),
    (FromChar: 'I'; ToChar: '1'),
    (FromChar: 'L'; ToChar: '1')
  );
var
  LMap: TCharMapArray;
begin
  if FCrockfordAlphabet = nil then
  begin
    SetLength(LMap, 3);
    LMap[0] := CMap[0];
    LMap[1] := CMap[1];
    LMap[2] := CMap[2];
    FCrockfordAlphabet := TAliasedBase32Alphabet.Create(
      '0123456789ABCDEFGHJKMNPQRSTVWXYZ', LMap);
  end;
  Result := FCrockfordAlphabet;
end;

class function TBase32Alphabet.GetBase32H: IBase32Alphabet;
const
  CMap: array [0 .. 3] of TCharMap = (
    (FromChar: 'O'; ToChar: '0'),
    (FromChar: 'I'; ToChar: '1'),
    (FromChar: 'S'; ToChar: '5'),
    (FromChar: 'U'; ToChar: 'V')
  );
var
  LMap: TCharMapArray;
begin
  if FBase32HAlphabet = nil then
  begin
    SetLength(LMap, 4);
    LMap[0] := CMap[0];
    LMap[1] := CMap[1];
    LMap[2] := CMap[2];
    LMap[3] := CMap[3];
    FBase32HAlphabet := TAliasedBase32Alphabet.Create(
      '0123456789ABCDEFGHJKLMNPQRTVWXYZ',
      '0', TPaddingPosition.Start, LMap);
  end;
  Result := FBase32HAlphabet;
end;

end.
