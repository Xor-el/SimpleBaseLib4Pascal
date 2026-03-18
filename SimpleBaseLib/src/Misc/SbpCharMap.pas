unit SbpCharMap;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes;

type
  TCharMap = record
    FromChar: Char;
    ToChar: Char;
    constructor Create(AFromChar, AToChar: Char);
  end;

  TCharMapArray = TSimpleBaseLibGenericArray<TCharMap>;

implementation

constructor TCharMap.Create(AFromChar, AToChar: Char);
begin
  FromChar := AFromChar;
  ToChar := AToChar;
end;

end.
