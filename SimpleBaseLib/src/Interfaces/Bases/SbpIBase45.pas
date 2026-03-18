unit SbpIBase45;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpICodingAlphabet,
  SbpIBaseCoder;

type
  IBase45 = interface(IBaseCoder)
    ['{1A72F424-53C5-4DDA-9EEB-CB6632BC5B15}']

    function GetAlphabet: ICodingAlphabet;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;

    property Alphabet: ICodingAlphabet read GetAlphabet;
  end;

implementation

end.
