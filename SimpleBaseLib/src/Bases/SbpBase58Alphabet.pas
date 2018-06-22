unit SbpBase58Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpIBase58Alphabet;

resourcestring
  SEmptyAlphabet = 'Base58 alphabets cannot be empty "%s"';
  SInvalidAlphabetLength =
    'Base58 alphabets need to be 58-characters long "%s"';
  SInvalidCharacter = 'invalid character "%s"';

type
  TBase58Alphabet = class sealed(TInterfacedObject, IBase58Alphabet)

  strict private

  const
    Length = Int32(58);

    class var

      FBitCoin, FRipple, FFlickr: IBase58Alphabet;

  var
    FreverseLookupTable: TDictionary<Char, Int32>;
    FValue: String;

    function GetValue: String; inline;
    function GetSelf(c: Char): Int32; inline;

    class function GetBitCoin: IBase58Alphabet; static; inline;
    class function GetFlickr: IBase58Alphabet; static; inline;
    class function GetRipple: IBase58Alphabet; static; inline;

    class constructor Base58Alphabet();
  public
    property Value: String read GetValue;
    property Self[c: Char]: Int32 read GetSelf; default;
    class property BitCoin: IBase58Alphabet read GetBitCoin;
    class property Ripple: IBase58Alphabet read GetRipple;
    class property Flickr: IBase58Alphabet read GetFlickr;
    constructor Create(const text: String);
    destructor Destroy; override;
  end;

implementation

{ TBase58Alphabet }

class constructor TBase58Alphabet.Base58Alphabet;
begin
  FBitCoin := TBase58Alphabet.Create
    ('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');
  FRipple := TBase58Alphabet.Create
    ('rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz');
  FFlickr := TBase58Alphabet.Create
    ('123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ');
end;

constructor TBase58Alphabet.Create(const text: String);
var
  idx, LowPoint, HighPoint: Int32;
begin
  Inherited Create();

  if (System.Length(text) = 0) then
  begin
    raise EArgumentNilSimpleBaseLibException.CreateResFmt(@SEmptyAlphabet,
      ['text']);
  end;

  if (System.Length(text) <> Length) then
  begin
    raise EArgumentSimpleBaseLibException.CreateResFmt(@SInvalidAlphabetLength,
      ['text']);
  end;
  FValue := text;
  FreverseLookupTable := TDictionary<Char, Integer>.Create();
{$IFDEF FPC}
{$IFDEF FPC_LESS_THAN_3.0.2}
  FreverseLookupTable.Sorted := True;
{$ENDIF FPC_LESS_THAN_3.0.2}
{$ENDIF FPC}
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(text);
  HighPoint := System.High(text);
{$ELSE}
  LowPoint := 1;
  HighPoint := System.Length(text);
{$ENDIF DELPHIXE3_UP}
  for idx := LowPoint to HighPoint do
  begin
    FreverseLookupTable.Add(text[idx], idx - 1);
  end;

end;

destructor TBase58Alphabet.Destroy;
begin
  FreverseLookupTable.Free;
  inherited Destroy;
end;

class function TBase58Alphabet.GetBitCoin: IBase58Alphabet;
begin
  result := FBitCoin;
end;

class function TBase58Alphabet.GetFlickr: IBase58Alphabet;
begin
  result := FFlickr;
end;

class function TBase58Alphabet.GetRipple: IBase58Alphabet;
begin
  result := FRipple;
end;

function TBase58Alphabet.GetSelf(c: Char): Int32;
var
  DataGotten: Boolean;
begin
{$IFDEF FPC}
{$IFDEF FPC_LESS_THAN_3.0.2}
  DataGotten := FreverseLookupTable.Find(c, result);
{$ELSE}
  DataGotten := FreverseLookupTable.TryGetData(c, result);
{$ENDIF FPC_LESS_THAN_3.0.2}
{$ELSE}
  DataGotten := FreverseLookupTable.TryGetValue(c, result);
{$ENDIF FPC}
  if (not DataGotten) then
  begin
    raise EInvalidOperationSimpleBaseLibException.CreateResFmt
      (@SInvalidCharacter, [c]);
  end;
end;

function TBase58Alphabet.GetValue: String;
begin
  result := FValue;
end;

end.
