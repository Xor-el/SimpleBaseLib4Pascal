unit SbpBase62Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase62Alphabet,
  SbpCodingAlphabet;

type
  TBase62Alphabet = class(TCodingAlphabet, IBase62Alphabet)
  strict private
    class var FDefaultAlphabet: ICodingAlphabet;
    class var FAlternativeAlphabet: ICodingAlphabet;
    class function GetDefault: ICodingAlphabet; static;
    class function GetAlternative: ICodingAlphabet; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String);

    class property Default: ICodingAlphabet read GetDefault;
    class property Alternative: ICodingAlphabet read GetAlternative;
  end;

implementation

{ TBase62Alphabet }

class constructor TBase62Alphabet.Create;
begin
  FDefaultAlphabet := nil;
  FAlternativeAlphabet := nil;
end;

constructor TBase62Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(62, AAlphabet);
end;

class function TBase62Alphabet.GetDefault: ICodingAlphabet;
begin
  if FDefaultAlphabet = nil then
  begin
    FDefaultAlphabet := TBase62Alphabet.Create(
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
  end;
  Result := FDefaultAlphabet;
end;

class function TBase62Alphabet.GetAlternative: ICodingAlphabet;
begin
  if FAlternativeAlphabet = nil then
  begin
    FAlternativeAlphabet := TBase62Alphabet.Create(
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
  end;
  Result := FAlternativeAlphabet;
end;

end.
