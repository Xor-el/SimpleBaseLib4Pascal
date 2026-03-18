unit SbpIDividingCoder;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpICodingAlphabet;

type
  IDividingCoder = interface(IInterface)

    function GetAlphabet: ICodingAlphabet;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function Encode(const ABytes: TSimpleBaseLibByteArray): String;
    function Decode(const AText: String): TSimpleBaseLibByteArray;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;

    property Alphabet: ICodingAlphabet read GetAlphabet;
  end;

implementation

end.
