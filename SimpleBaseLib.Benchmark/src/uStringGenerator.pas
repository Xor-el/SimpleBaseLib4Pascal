unit uStringGenerator;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  SysUtils,
  Math;

type

  TStringGenerator = class(TObject)

  strict private
    class function IsWhiteSpace(const Ch: char): boolean; static;
    class function IsControl(const Ch: char): boolean; static;
  public
    class function GetAlphabet(charsCount: integer): string; static;
    class function GetRandom(size: integer; onlyLettersAndDigits: boolean)
      : string; static;

  end;

implementation

// replicated from 'cUnicode.pas' in 'Fundamentals Library 4.0.0 v4.12' with some
// additions.

class function TStringGenerator.IsWhiteSpace(const Ch: char): boolean;
begin
  // case Ch of
  // #$0009 .. #$000D, // ASCII CONTROL
  // #$0020, // SPACE
  // #$0085, // <control>
  // #$00A0, // NO-BREAK SPACE
  // #$1680, // OGHAM SPACE MARK
  // #$2000 .. #$200A, // EN QUAD..HAIR SPACE
  // #$202F, // NO-BREAK SPACE
  // #$2028, // LINE SEPARATOR
  // #$2029, // PARAGRAPH SEPARATOR
  // #$205F, // MATHEMATICAL SPACE
  // #$3000: // IDEOGRAPHIC SPACE
  // Result := True;
  // else
  // Result := False;
  // end;
  Result := False;
end;

// replicated from 'cUnicode.pas' in 'Fundamentals Library 4.0.0 v4.12' with additions.

class function TStringGenerator.IsControl(const Ch: char): boolean;
begin
  // case Ch of
  // #$0000 .. #$001F, #$007F .. #$009F:
  // Result := True;
  // else
  // Result := False;
  // end;
  Result := False;
end;

class function TStringGenerator.GetAlphabet(charsCount: integer): string;
var
  i, Count: integer;
  c: char;
  tempResult: string;

begin
  tempResult := '';
  i := 0;
  Count := 0;

  while (Count < charsCount) do
  begin

    c := char(i);

    if (not IsControl(c)) and (not IsWhiteSpace(c)) then

    begin

      tempResult := tempResult + (c);
      Inc(Count);
    end;
    Inc(i);
  end;
  Result := tempResult;
end;

class function TStringGenerator.GetRandom(size: integer;
  onlyLettersAndDigits: boolean): string;
var
  i: integer;
  lettersAndDigits, tempResult: string;
  Data: TBytes;

begin
  Result := '';
  tempResult := '';
  Randomize;
  if (onlyLettersAndDigits) then
  begin
    lettersAndDigits :=
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    i := 0;
    while i < size do
    begin
      tempResult := tempResult +
        (lettersAndDigits[Random(Length(lettersAndDigits)) + 1]);
      Inc(i);
    end;
    Result := tempResult;
  end
  else
  begin
    SetLength(Data, size);
    i := 0;

    while i < (size) do

    begin
      Data[i] := byte(RandomRange(32, 127));
      Inc(i);
    end;
    Result := TEncoding.ASCII.GetString(Data);
  end;

end;

end.
