unit SbpBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpUtilities,
  SbpEncodingAlphabet,
  SbpSimpleBaseLibTypes,
  SbpIBase32Alphabet;

type
  TBase32Alphabet = class(TEncodingAlphabet, IBase32Alphabet)

  strict private

    class var

      FCrockford, FRfc4648, FExtendedHex: IBase32Alphabet;

    procedure MapLowerCaseCounterParts(const alphabet: String); inline;

    class function GetCrockford: IBase32Alphabet; static; inline;
    class function GetRfc4648: IBase32Alphabet; static; inline;
    class function GetExtendedHex: IBase32Alphabet; static; inline;

    class constructor Base32Alphabet();

  public
    class property Crockford: IBase32Alphabet read GetCrockford;
    class property Rfc4648: IBase32Alphabet read GetRfc4648;
    class property ExtendedHex: IBase32Alphabet read GetExtendedHex;
    constructor Create(const alphabet: String);
    destructor Destroy; override;
  end;

implementation

uses
  SbpCrockfordBase32Alphabet; // included here to avoid circular dependency :)

{ TBase32Alphabet }

procedure TBase32Alphabet.MapLowerCaseCounterParts(const alphabet: String);
var
  LowPoint, HighPoint, I: Int32;
  c: Char;
begin
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(alphabet);
  HighPoint := System.High(alphabet);
{$ELSE}
  LowPoint := 1;
  HighPoint := System.Length(alphabet);
{$ENDIF DELPHIXE3_UP}
  for I := LowPoint to HighPoint do
  begin
    c := alphabet[I];
    if TUtilities.IsUpper(c) then
    begin
      Map(TUtilities.LowCase(c), ReverseLookupTable[Ord(c)] - 1);
    end;
  end;
end;

class constructor TBase32Alphabet.Base32Alphabet;
begin
  FCrockford := TCrockfordBase32Alphabet.Create();
  FRfc4648 := TBase32Alphabet.Create('ABCDEFGHIJKLMNOPQRSTUVWXYZ234567');
  FExtendedHex := TBase32Alphabet.Create('0123456789ABCDEFGHIJKLMNOPQRSTUV');
end;

constructor TBase32Alphabet.Create(const alphabet: String);
begin
  Inherited Create(32, alphabet);
  MapLowerCaseCounterParts(alphabet);
end;

destructor TBase32Alphabet.Destroy;
begin
  inherited Destroy;
end;

class function TBase32Alphabet.GetCrockford: IBase32Alphabet;
begin
  Result := TCrockfordBase32Alphabet.Create();
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
