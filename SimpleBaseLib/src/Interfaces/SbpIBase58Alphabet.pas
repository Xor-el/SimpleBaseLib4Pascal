unit SbpIBase58Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

type
  IBase58Alphabet = interface(IInterface)
    ['{9E984482-B694-4DED-A6DC-A033F96738E6}']

    function GetValue: String;
    property Value: String read GetValue;
    function GetSelf(c: Char): Int32; overload;
    property Self[c: Char]: Int32 read GetSelf; default;

  end;

implementation

end.
