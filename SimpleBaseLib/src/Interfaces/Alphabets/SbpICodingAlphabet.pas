unit SbpICodingAlphabet;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes;

type
  ICodingAlphabet = interface(IInterface)
    ['{3C1C1A5D-5B8E-4C61-9A9E-4E1E3A9E3E9A}']
    function GetValue: String;
    function GetLength: Int32;
    function GetReverseLookupTable: TSimpleBaseLibByteArray;

    function ToString: String;
    function GetHashCode: {$IFDEF DELPHI}Int32;{$ELSE}PtrInt;{$ENDIF DELPHI}

    property Value: String read GetValue;
    property Length: Int32 read GetLength;
    property ReverseLookupTable: TSimpleBaseLibByteArray read GetReverseLookupTable;
  end;

implementation

end.

