unit SbpIBase36;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIDividingCoder;

type
  IBase36 = interface(IDividingCoder<ICodingAlphabet>)
    ['{3A1B5F04-6A80-4E84-9F4D-3D7C9E2B8A1C}']
  end;

implementation

end.
