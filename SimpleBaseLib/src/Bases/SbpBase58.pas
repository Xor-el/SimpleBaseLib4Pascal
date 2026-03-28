unit SbpBase58;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase58,
  SbpIMoneroBase58,
  SbpDividingCoder,
  SbpBase58Alphabet,
  SbpMoneroBase58;

type
  TBase58 = class(TDividingCoder, IBase58)
  strict private
  const
    ReductionFactor = Int32(733);
  var
    FZeroChar: Char;
    class var FBitcoin: IBase58;
    class var FRipple: IBase58;
    class var FFlickr: IBase58;
    class var FMonero: IMoneroBase58;
    class function GetBitcoin: IBase58; static;
    class function GetRipple: IBase58; static;
    class function GetFlickr: IBase58; static;
    class function GetMonero: IMoneroBase58; static;
  strict protected
    function GetZeroChar: Char;
  public
    class constructor Create;

    constructor Create(const AAlphabet: ICodingAlphabet);

    class property Bitcoin: IBase58 read GetBitcoin;
    class property Ripple: IBase58 read GetRipple;
    class property Flickr: IBase58 read GetFlickr;
    class property Monero: IMoneroBase58 read GetMonero;

    property ZeroChar: Char read GetZeroChar;
  end;

implementation

{ TBase58 }

class constructor TBase58.Create;
begin
  FBitcoin := nil;
  FRipple := nil;
  FFlickr := nil;
  FMonero := nil;
end;

constructor TBase58.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create(AAlphabet);
  FZeroChar := AAlphabet.Value[1];
end;

function TBase58.GetZeroChar: Char;
begin
  Result := FZeroChar;
end;

class function TBase58.GetBitcoin: IBase58;
begin
  if FBitcoin = nil then
  begin
    FBitcoin := TBase58.Create(TBase58Alphabet.Bitcoin);
  end;
  Result := FBitcoin;
end;

class function TBase58.GetRipple: IBase58;
begin
  if FRipple = nil then
  begin
    FRipple := TBase58.Create(TBase58Alphabet.Ripple);
  end;
  Result := FRipple;
end;

class function TBase58.GetFlickr: IBase58;
begin
  if FFlickr = nil then
  begin
    FFlickr := TBase58.Create(TBase58Alphabet.Flickr);
  end;
  Result := FFlickr;
end;

class function TBase58.GetMonero: IMoneroBase58;
begin
  if FMonero = nil then
  begin
    FMonero := TMoneroBase58.Default;
  end;
  Result := FMonero;
end;

end.
