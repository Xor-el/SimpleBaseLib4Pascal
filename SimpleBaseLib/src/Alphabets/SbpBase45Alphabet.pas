unit SbpBase45Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase45Alphabet,
  SbpCodingAlphabet;

type
  TBase45Alphabet = class(TCodingAlphabet, IBase45Alphabet)
  strict private
    class var FDefaultAlphabet: ICodingAlphabet;
    class function GetDefault: ICodingAlphabet; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String);

    class property Default: ICodingAlphabet read GetDefault;
  end;

implementation

{ TBase45Alphabet }

class constructor TBase45Alphabet.Create;
begin
  FDefaultAlphabet := nil;
end;

constructor TBase45Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(45, AAlphabet);
end;

class function TBase45Alphabet.GetDefault: ICodingAlphabet;
begin
  if FDefaultAlphabet = nil then
  begin
    FDefaultAlphabet := TBase45Alphabet.Create(
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:');
  end;
  Result := FDefaultAlphabet;
end;

end.
