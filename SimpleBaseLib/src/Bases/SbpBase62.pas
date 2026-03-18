unit SbpBase62;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase62,
  SbpDividingCoder,
  SbpBase62Alphabet;

type
  TBase62 = class(TDividingCoder<ICodingAlphabet>, IBase62)
  strict private
    class var FDefault: IBase62;
    class var FLowerFirst: IBase62;
    class function GetDefault: IBase62; static;
    class function GetLowerFirst: IBase62; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: ICodingAlphabet);
    class property Default: IBase62 read GetDefault;
    class property LowerFirst: IBase62 read GetLowerFirst;
  end;

implementation

{ TBase62 }

class constructor TBase62.Create;
begin
  FDefault := nil;
  FLowerFirst := nil;
end;

constructor TBase62.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create(AAlphabet);
end;

class function TBase62.GetDefault: IBase62;
begin
  if FDefault = nil then
  begin
    FDefault := TBase62.Create(TBase62Alphabet.Default);
  end;
  Result := FDefault;
end;

class function TBase62.GetLowerFirst: IBase62;
begin
  if FLowerFirst = nil then
  begin
    FLowerFirst := TBase62.Create(TBase62Alphabet.Alternative);
  end;
  Result := FLowerFirst;
end;

end.
