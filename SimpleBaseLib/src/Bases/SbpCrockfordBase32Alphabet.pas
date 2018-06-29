unit SbpCrockfordBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpUtilities,
  SbpBase32Alphabet,
  SbpICrockfordBase32Alphabet;

type
  TCrockfordBase32Alphabet = class sealed(TBase32Alphabet,
    ICrockfordBase32Alphabet)

  strict private
    procedure MapAlternate(source, destination: Char); inline;

  public
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

{ TCrockfordBase32Alphabet }

procedure TCrockfordBase32Alphabet.MapAlternate(source, destination: Char);
var
  result: Byte;
begin
  result := ReverseLookupTable[Ord(destination)] - 1;
  Map(source, result);
  Map(TUtilities.LowCase(source), result);
end;

constructor TCrockfordBase32Alphabet.Create;
begin
  Inherited Create('0123456789ABCDEFGHJKMNPQRSTVWXYZ');
  MapAlternate('O', '0');
  MapAlternate('I', '1');
  MapAlternate('L', '1');
end;

destructor TCrockfordBase32Alphabet.Destroy;
begin
  inherited Destroy;
end;

end.
