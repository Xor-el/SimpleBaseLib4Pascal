unit SbpBase36Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase36Alphabet,
  SbpCodingAlphabet;

type
  TBase36Alphabet = class(TCodingAlphabet, IBase36Alphabet)
  strict private
    class var FUpperAlphabet: ICodingAlphabet;
    class var FLowerAlphabet: ICodingAlphabet;
    class function GetUpper: ICodingAlphabet; static;
    class function GetLower: ICodingAlphabet; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String);

    class property Upper: ICodingAlphabet read GetUpper;
    class property Lower: ICodingAlphabet read GetLower;
  end;

implementation

{ TBase36Alphabet }

class constructor TBase36Alphabet.Create;
begin
  FUpperAlphabet := nil;
  FLowerAlphabet := nil;
end;

constructor TBase36Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(36, AAlphabet, True);
end;

class function TBase36Alphabet.GetUpper: ICodingAlphabet;
begin
  if FUpperAlphabet = nil then
  begin
    FUpperAlphabet := TBase36Alphabet.Create('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  end;
  Result := FUpperAlphabet;
end;

class function TBase36Alphabet.GetLower: ICodingAlphabet;
begin
  if FLowerAlphabet = nil then
  begin
    FLowerAlphabet := TBase36Alphabet.Create('0123456789abcdefghijklmnopqrstuvwxyz');
  end;
  Result := FLowerAlphabet;
end;

end.
