unit SbpIBase58;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpIDividingCoder;

type
  IBase58 = interface(IDividingCoder)
    ['{9D4B1311-4967-4B4A-9C9F-1F8AA873FE95}']
    function GetZeroChar: Char;

    property ZeroChar: Char read GetZeroChar;
  end;

implementation

end.
