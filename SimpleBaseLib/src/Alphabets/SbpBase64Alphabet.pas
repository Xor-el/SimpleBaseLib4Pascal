unit SbpBase64Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpIBase64Alphabet,
  SbpCodingAlphabet;

type
  TBase64Alphabet = class(TCodingAlphabet, IBase64Alphabet)
  strict private
    class var FDefault: IBase64Alphabet;
    class var FUrl: IBase64Alphabet;

    class function GetDefault: IBase64Alphabet; static;
    class function GetUrl: IBase64Alphabet; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String);

    class property Default: IBase64Alphabet read GetDefault;
    class property Url: IBase64Alphabet read GetUrl;
  end;

implementation

{ TBase64Alphabet }

class constructor TBase64Alphabet.Create;
begin
  FDefault := nil;
  FUrl := nil;
end;

constructor TBase64Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(64, AAlphabet, False);
end;

class function TBase64Alphabet.GetDefault: IBase64Alphabet;
begin
  if FDefault = nil then
  begin
    FDefault := TBase64Alphabet.Create(
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/');
  end;
  Result := FDefault;
end;

class function TBase64Alphabet.GetUrl: IBase64Alphabet;
begin
  if FUrl = nil then
  begin
    FUrl := TBase64Alphabet.Create(
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_');
  end;
  Result := FUrl;
end;

end.
