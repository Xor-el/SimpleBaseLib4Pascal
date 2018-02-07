unit SbpCrockfordBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpBase32Alphabet,
  SbpICrockfordBase32Alphabet;

type
  TCrockfordBase32Alphabet = class sealed(TBase32Alphabet,
    ICrockfordBase32Alphabet)

  strict private
    class procedure map(buffer: TSimpleBaseLibByteArray;
      source, destination: Char); static; inline;

  public
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

{ TCrockfordBase32Alphabet }

class procedure TCrockfordBase32Alphabet.map(buffer: TSimpleBaseLibByteArray;
  source, destination: Char);
var
  result: Byte;
begin
  result := buffer[Ord(destination)];
  buffer[Ord(source)] := result;
  buffer[Ord(LowCase(source))] := result;
end;

constructor TCrockfordBase32Alphabet.Create;
var
  buf: TSimpleBaseLibByteArray;
begin
  Inherited Create('0123456789ABCDEFGHJKMNPQRSTVWXYZ');
  buf := DecodingTable;
  map(buf, 'O', '0');
  map(buf, 'I', '1');
  map(buf, 'L', '1');
end;

destructor TCrockfordBase32Alphabet.Destroy;
begin
  inherited Destroy;
end;

end.
