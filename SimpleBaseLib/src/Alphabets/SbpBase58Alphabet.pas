unit SbpBase58Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase58Alphabet,
  SbpCodingAlphabet;

type
  TBase58Alphabet = class(TCodingAlphabet, IBase58Alphabet)
  strict private
    class var FBitcoinAlphabet: ICodingAlphabet;
    class var FRippleAlphabet: ICodingAlphabet;
    class var FFlickrAlphabet: ICodingAlphabet;
    class function GetBitcoin: ICodingAlphabet; static;
    class function GetRipple: ICodingAlphabet; static;
    class function GetFlickr: ICodingAlphabet; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String);

    class property Bitcoin: ICodingAlphabet read GetBitcoin;
    class property Ripple: ICodingAlphabet read GetRipple;
    class property Flickr: ICodingAlphabet read GetFlickr;
  end;

implementation

{ TBase58Alphabet }

class constructor TBase58Alphabet.Create;
begin
  FBitcoinAlphabet := nil;
  FRippleAlphabet := nil;
  FFlickrAlphabet := nil;
end;

constructor TBase58Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(58, AAlphabet);
end;

class function TBase58Alphabet.GetBitcoin: ICodingAlphabet;
begin
  if FBitcoinAlphabet = nil then
  begin
    FBitcoinAlphabet := TBase58Alphabet.Create(
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');
  end;
  Result := FBitcoinAlphabet;
end;

class function TBase58Alphabet.GetRipple: ICodingAlphabet;
begin
  if FRippleAlphabet = nil then
  begin
    FRippleAlphabet := TBase58Alphabet.Create(
      'rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz');
  end;
  Result := FRippleAlphabet;
end;

class function TBase58Alphabet.GetFlickr: ICodingAlphabet;
begin
  if FFlickrAlphabet = nil then
  begin
    FFlickrAlphabet := TBase58Alphabet.Create(
      '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ');
  end;
  Result := FFlickrAlphabet;
end;

end.
