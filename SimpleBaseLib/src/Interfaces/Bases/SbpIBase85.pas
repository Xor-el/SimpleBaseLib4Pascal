unit SbpIBase85;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBaseCoder,
  SbpIBase85Alphabet;

type
  IBase85 = interface(IBaseCoder)
    ['{A06F3298-CF2D-4FC4-96B5-D84D9B25A710}']

    function GetAlphabet: IBase85Alphabet;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;

    property Alphabet: IBase85Alphabet read GetAlphabet;
  end;

implementation

end.
