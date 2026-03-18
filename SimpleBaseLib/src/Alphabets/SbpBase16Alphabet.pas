unit SbpBase16Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpICodingAlphabet,
  SbpIBase16Alphabet,
  SbpCharUtilities,
  SbpCodingAlphabet;

type
  TBase16Alphabet = class(TCodingAlphabet, IBase16Alphabet)
  strict private
    FCaseSensitive: Boolean;

    procedure MapCounterparts;
  public
    class var FUpperCaseAlphabet: ICodingAlphabet;
    class var FLowerCaseAlphabet: ICodingAlphabet;
    class var FModHexAlphabet: ICodingAlphabet;

    class constructor Create;

    constructor Create(const AAlphabet: String); overload;
    constructor Create(const AAlphabet: String; const ACaseSensitive: Boolean); overload;

  strict private
    class function GetUpperCase: ICodingAlphabet; static;
    class function GetLowerCase: ICodingAlphabet; static;
    class function GetModHex: ICodingAlphabet; static;
  public
    class property UpperCase: ICodingAlphabet read GetUpperCase;
    class property LowerCase: ICodingAlphabet read GetLowerCase;
    class property ModHex: ICodingAlphabet read GetModHex;

    property CaseSensitive: Boolean read FCaseSensitive;
  end;

implementation

{ TBase16Alphabet }

class constructor TBase16Alphabet.Create;
begin
  FUpperCaseAlphabet := nil;
  FLowerCaseAlphabet := nil;
  FModHexAlphabet := nil;
end;

constructor TBase16Alphabet.Create(const AAlphabet: String);
begin
  Create(AAlphabet, False);
end;

constructor TBase16Alphabet.Create(const AAlphabet: String;
  const ACaseSensitive: Boolean);
begin
  inherited Create(16, AAlphabet, False);
  FCaseSensitive := ACaseSensitive;

  if not FCaseSensitive then
  begin
    MapCounterparts;
  end;
end;

procedure TBase16Alphabet.MapCounterparts;
var
  LI, LAlphaLen: Int32;
  LChar: Char;
begin
  LAlphaLen := System.Length(Value);
  for LI := 0 to LAlphaLen - 1 do
  begin
    LChar := Value[LI + 1];
    if TCharUtilities.IsLetter(LChar) then
    begin
      if TCharUtilities.IsAsciiUpper(LChar) then
      begin
        Map(TCharUtilities.ToAsciiLower(LChar), LI);
      end
      else
      begin
        Map(TCharUtilities.ToAsciiUpper(LChar), LI);
      end;
    end;
  end;
end;

class function TBase16Alphabet.GetUpperCase: ICodingAlphabet;
begin
  if FUpperCaseAlphabet = nil then
  begin
    FUpperCaseAlphabet := TBase16Alphabet.Create('0123456789ABCDEF', False);
  end;
  Result := FUpperCaseAlphabet;
end;

class function TBase16Alphabet.GetLowerCase: ICodingAlphabet;
begin
  if FLowerCaseAlphabet = nil then
  begin
    FLowerCaseAlphabet := TBase16Alphabet.Create('0123456789abcdef', False);
  end;
  Result := FLowerCaseAlphabet;
end;

class function TBase16Alphabet.GetModHex: ICodingAlphabet;
begin
  if FModHexAlphabet = nil then
  begin
    FModHexAlphabet := TBase16Alphabet.Create('cbdefghijklnrtuv', False);
  end;
  Result := FModHexAlphabet;
end;

end.

