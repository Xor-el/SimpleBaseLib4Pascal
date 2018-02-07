unit SbpIBase32Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes;

type
  IBase32Alphabet = interface(IInterface)
    ['{A4CDFD70-541D-4CD3-8C9C-B25277186A66}']

    function GetEncodingTable: TSimpleBaseLibCharArray;
    function GetDecodingTable: TSimpleBaseLibByteArray;

    property EncodingTable: TSimpleBaseLibCharArray read GetEncodingTable;
    property DecodingTable: TSimpleBaseLibByteArray read GetDecodingTable;
  end;

implementation

end.
