unit SbpBase10Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase10Alphabet,
  SbpCodingAlphabet;

type
  TBase10Alphabet = class(TCodingAlphabet, IBase10Alphabet)
  strict private
    class var FDefaultAlphabet: ICodingAlphabet;
    class function GetDefault: ICodingAlphabet; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String);

    class property Default: ICodingAlphabet read GetDefault;
  end;

implementation

{ TBase10Alphabet }

class constructor TBase10Alphabet.Create;
begin
  FDefaultAlphabet := nil;
end;

constructor TBase10Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(10, AAlphabet);
end;

class function TBase10Alphabet.GetDefault: ICodingAlphabet;
begin
  if FDefaultAlphabet = nil then
  begin
    FDefaultAlphabet := TBase10Alphabet.Create('0123456789');
  end;
  Result := FDefaultAlphabet;
end;

end.
