unit SbpIBase62;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpIDividingCoder;

type
  IBase62 = interface(IDividingCoder<ICodingAlphabet>)
    ['{A65F3B95-AC2E-4D8F-9B5A-0F672A4A2E64}']
  end;

implementation

end.
