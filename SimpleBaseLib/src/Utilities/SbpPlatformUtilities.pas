unit SbpPlatformUtilities;

{$I ..\Include\SimpleBaseLib.inc}

interface

type
  TPlatformUtilities = class sealed(TObject)
  public
    class function IsLittleEndian: Boolean; static; inline;
  end;

implementation

class function TPlatformUtilities.IsLittleEndian: Boolean;
var
  LValue: UInt16;
begin
  LValue := 1;
  Result := PByte(@LValue)^ = 1;
end;

end.
