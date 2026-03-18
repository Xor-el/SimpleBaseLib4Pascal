unit SbpBase10;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase10,
  SbpDividingCoder,
  SbpBase10Alphabet;

type
  TBase10 = class(TDividingCoder<ICodingAlphabet>, IBase10)
  strict private
    class var FDefault: IBase10;
    class function GetDefault: IBase10; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: ICodingAlphabet);
    class property Default: IBase10 read GetDefault;
  end;

implementation

{ TBase10 }

class constructor TBase10.Create;
begin
  FDefault := nil;
end;

constructor TBase10.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create(AAlphabet);
end;

class function TBase10.GetDefault: IBase10;
begin
  if FDefault = nil then
  begin
    FDefault := TBase10.Create(TBase10Alphabet.Default);
  end;
  Result := FDefault;
end;

end.
