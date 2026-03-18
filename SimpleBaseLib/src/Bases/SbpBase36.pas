unit SbpBase36;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIBase36,
  SbpDividingCoder,
  SbpBase36Alphabet;

type
  TBase36 = class(TDividingCoder, IBase36)
  strict private
    class var FUpperCase: IBase36;
    class var FLowerCase: IBase36;
    class function GetUpperCase: IBase36; static;
    class function GetLowerCase: IBase36; static;
  public
    class constructor Create;

    constructor Create(const AAlphabet: ICodingAlphabet);
    class property UpperCase: IBase36 read GetUpperCase;
    class property LowerCase: IBase36 read GetLowerCase;
  end;

implementation

{ TBase36 }

class constructor TBase36.Create;
begin
  FUpperCase := nil;
  FLowerCase := nil;
end;

constructor TBase36.Create(const AAlphabet: ICodingAlphabet);
begin
  inherited Create(AAlphabet);
end;

class function TBase36.GetUpperCase: IBase36;
begin
  if FUpperCase = nil then
  begin
    FUpperCase := TBase36.Create(TBase36Alphabet.Upper);
  end;
  Result := FUpperCase;
end;

class function TBase36.GetLowerCase: IBase36;
begin
  if FLowerCase = nil then
  begin
    FLowerCase := TBase36.Create(TBase36Alphabet.Lower);
  end;
  Result := FLowerCase;
end;

end.
