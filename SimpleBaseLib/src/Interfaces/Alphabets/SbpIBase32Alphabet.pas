unit SbpIBase32Alphabet;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet,
  SbpPaddingPosition;

type
  IBase32Alphabet = interface(ICodingAlphabet)
    ['{C5762C59-DFD9-4DAA-BF1E-6D2DADDAEC13}']
    function GetPaddingChar: Char;
    function GetPaddingPosition: TPaddingPosition;

    property PaddingChar: Char read GetPaddingChar;
    property PaddingPosition: TPaddingPosition read GetPaddingPosition;
  end;

implementation

end.
