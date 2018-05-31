unit SbpBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBase32Alphabet;

type
  TBase32Alphabet = class(TInterfacedObject, IBase32Alphabet)

  strict private

  const
    HighestAsciiCharSupported = Char('z');

    class var

      FCrockford, FRfc4648, FExtendedHex: IBase32Alphabet;

  var
    FEncodingTable: TSimpleBaseLibCharArray;
    FDecodingTable: TSimpleBaseLibByteArray;

    function GetEncodingTable: TSimpleBaseLibCharArray; inline;
    function GetDecodingTable: TSimpleBaseLibByteArray; inline;

    procedure CreateDecodingTable(const chars: String); inline;

    class function GetCrockford: IBase32Alphabet; static; inline;
    class function GetRfc4648: IBase32Alphabet; static; inline;
    class function GetExtendedHex: IBase32Alphabet; static; inline;

    class constructor Base32Alphabet();

  strict protected
    class function LowCase(ch: Char): Char; static; inline;

  public
    property EncodingTable: TSimpleBaseLibCharArray read GetEncodingTable;
    property DecodingTable: TSimpleBaseLibByteArray read GetDecodingTable;
    class property Crockford: IBase32Alphabet read GetCrockford;
    class property Rfc4648: IBase32Alphabet read GetRfc4648;
    class property ExtendedHex: IBase32Alphabet read GetExtendedHex;
    constructor Create(const chars: String);
    destructor Destroy; override;
  end;

implementation

uses
  SbpCrockfordBase32Alphabet; // included here to avoid circular dependency :)

{ TBase32Alphabet }

class function TBase32Alphabet.LowCase(ch: Char): Char;
begin
  case ch of
    'A' .. 'Z':
      Result := Char((Int32(Ord(ch)) + Int32(Ord('a'))) - Int32(Ord('A')));
  else
    Result := ch;
  end;
end;

procedure TBase32Alphabet.CreateDecodingTable(const chars: String);
var
  bytes: TSimpleBaseLibByteArray;
  idx, LowPoint, HighPoint: Int32;
  c: Char;
  b: Byte;
begin
  System.SetLength(bytes, Ord(HighestAsciiCharSupported) + 1);
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(chars);
  HighPoint := System.High(chars);
{$ELSE}
  LowPoint := 1;
  HighPoint := System.length(chars);
{$ENDIF DELPHIXE3_UP}
  for idx := LowPoint to HighPoint do
  begin
    c := chars[idx];
    b := Byte(idx);
    bytes[Ord(c)] := b;
    bytes[Ord(LowCase(c))] := b;
  end;

  FDecodingTable := bytes;
end;

class constructor TBase32Alphabet.Base32Alphabet;
begin
  FCrockford := TCrockfordBase32Alphabet.Create();
  FRfc4648 := TBase32Alphabet.Create('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567');
  FExtendedHex := TBase32Alphabet.Create('0123456789ABCDEFGHIJKLMNOPQRSTUV');
end;

constructor TBase32Alphabet.Create(const chars: String);
var
  idx, LowPoint, HighPoint: Int32;
begin
  Inherited Create();

  System.SetLength(FEncodingTable, System.length(chars));
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(chars);
  HighPoint := System.High(chars);
{$ELSE}
  LowPoint := 1;
  HighPoint := System.length(chars);
{$ENDIF DELPHIXE3_UP}
  for idx := LowPoint to HighPoint do
  begin
    FEncodingTable[idx - 1] := chars[idx];
  end;

  CreateDecodingTable(chars);

end;

destructor TBase32Alphabet.Destroy;
begin
  inherited Destroy;
end;

class function TBase32Alphabet.GetCrockford: IBase32Alphabet;
begin
  Result := FCrockford;
end;

function TBase32Alphabet.GetDecodingTable: TSimpleBaseLibByteArray;
begin
  Result := FDecodingTable;
end;

function TBase32Alphabet.GetEncodingTable: TSimpleBaseLibCharArray;
begin
  Result := FEncodingTable;
end;

class function TBase32Alphabet.GetExtendedHex: IBase32Alphabet;
begin
  Result := FExtendedHex;
end;

class function TBase32Alphabet.GetRfc4648: IBase32Alphabet;
begin
  Result := FRfc4648;
end;

end.
