unit SbpCharUtilities;

{$I ..\Include\SimpleBaseLib.inc}

interface

type

  /// <summary>
  /// Utility class for ASCII character operations.
  /// </summary>
  TCharUtilities = class sealed(TObject)
  public
    class function IsAsciiUpper(AChar: Char): Boolean; static; inline;
    class function IsAsciiLower(AChar: Char): Boolean; static; inline;
    class function ToAsciiUpper(AChar: Char): Char; static; inline;
    class function ToAsciiLower(AChar: Char): Char; static; inline;
    class function IsLetter(AChar: Char): Boolean; static; inline;
  end;

implementation

{ TCharUtilities }

class function TCharUtilities.IsAsciiUpper(AChar: Char): Boolean;
begin
  Result := (AChar >= 'A') and (AChar <= 'Z');
end;

class function TCharUtilities.IsAsciiLower(AChar: Char): Boolean;
begin
  Result := (AChar >= 'a') and (AChar <= 'z');
end;

class function TCharUtilities.ToAsciiUpper(AChar: Char): Char;
begin
  if IsAsciiLower(AChar) then
    Result := Char(Ord(AChar) - Ord('a') + Ord('A'))
  else
    Result := AChar;
end;

class function TCharUtilities.ToAsciiLower(AChar: Char): Char;
begin
  if IsAsciiUpper(AChar) then
    Result := Char(Ord(AChar) - Ord('A') + Ord('a'))
  else
    Result := AChar;
end;

class function TCharUtilities.IsLetter(AChar: Char): Boolean;
begin
  Result := IsAsciiUpper(AChar) or IsAsciiLower(AChar);
end;

end.
