unit SbpUtilities;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes;

type
  TUtilities = class sealed(TObject)

  strict private

    class function HaveChar(c: Char; const list: TSimpleBaseLibCharArray)
      : Boolean; static; inline;

  public

    class function TrimRight(const S: String;
      const trimchars: TSimpleBaseLibCharArray): String; static; inline;

  end;

implementation

class function TUtilities.HaveChar(c: Char;
  const list: TSimpleBaseLibCharArray): Boolean;
var
  I: Int32;
begin
  I := 0;
  Result := false;
  While (not Result) and (I < System.Length(list)) do
  begin
    Result := (list[I] = c);
    System.Inc(I);
  end;
end;

class function TUtilities.TrimRight(const S: String;
  const trimchars: TSimpleBaseLibCharArray): String;
var
  I, Len, LowPoint: Int32;
begin
  Len := System.Length(S);
  I := Len;
  While (I >= 1) and HaveChar(S[I], trimchars) do
  begin
    System.Dec(I);
  end;
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(String);
{$ELSE}
  LowPoint := 1;
{$ENDIF DELPHIXE3_UP}
  if I < LowPoint then
  begin
    Result := ''
  end
  else if I = Len then
  begin
    Result := S
  end
  else
  begin
    Result := System.Copy(S, LowPoint, I);
  end;
end;

end.
