unit SbpIBase64Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes;

type
  IBase64Alphabet = interface(IInterface)
    ['{F8B6C5B1-57F9-4B91-AD50-437B3D3AD0B4}']

    function GetEncodingTable: TSimpleBaseLibCharArray;
    function GetDecodingTable: TSimpleBaseLibByteArray;
    function GetPaddingEnabled: Boolean;

    property PaddingEnabled: Boolean read GetPaddingEnabled;
    property EncodingTable: TSimpleBaseLibCharArray read GetEncodingTable;
    property DecodingTable: TSimpleBaseLibByteArray read GetDecodingTable;
  end;

implementation

end.
