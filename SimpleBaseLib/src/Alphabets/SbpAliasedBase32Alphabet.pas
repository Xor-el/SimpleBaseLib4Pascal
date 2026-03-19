unit SbpAliasedBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpCharMap,
  SbpPaddingPosition,
  SbpCharUtilities,
  SbpCodingAlphabet,
  SbpIAliasedBase32Alphabet,
  SbpBase32Alphabet;

type
  TAliasedBase32Alphabet = class(TBase32Alphabet, IAliasedBase32Alphabet)
  strict private
    procedure SetupMap(const AMap: TCharMapArray);
    procedure MapAlternate(ASource, ADestination: Char);
  public
    constructor Create(const AAlphabet: String; const AMap: TCharMapArray); overload;
    constructor Create(const AAlphabet: String; APaddingChar: Char;
      APaddingPosition: TPaddingPosition; const AMap: TCharMapArray); overload;
  end;

implementation

constructor TAliasedBase32Alphabet.Create(const AAlphabet: String;
  const AMap: TCharMapArray);
begin
  inherited Create(AAlphabet);
  SetupMap(AMap);
end;

constructor TAliasedBase32Alphabet.Create(const AAlphabet: String;
  APaddingChar: Char; APaddingPosition: TPaddingPosition; const AMap: TCharMapArray);
begin
  inherited Create(AAlphabet, APaddingChar, APaddingPosition);
  SetupMap(AMap);
end;

procedure TAliasedBase32Alphabet.SetupMap(const AMap: TCharMapArray);
var
  LMap: TCharMap;
begin
  for LMap in AMap do
  begin
    MapAlternate(LMap.FromChar, LMap.ToChar);
  end;
end;

procedure TAliasedBase32Alphabet.MapAlternate(ASource, ADestination: Char);
var
  LResult: Int32;
begin
  if not TCodingAlphabet.TryLookup(ReverseLookupTable, ADestination, LResult) then
    raise EArgumentSimpleBaseLibException.CreateFmt(
      'Character "%s" is not in the alphabet', [ADestination]);
  Map(ASource, LResult);
  Map(TCharUtilities.ToAsciiLower(ASource), LResult);
end;

end.
