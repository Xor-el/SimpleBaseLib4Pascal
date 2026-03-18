unit SbpIMoneroBase58;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SbpICodingAlphabet,
  SbpIBaseCoder;

type
  IMoneroBase58 = interface(IBaseCoder)
    ['{2176E5D2-0D96-4CC8-B2E6-4187F53CDA45}']
    function GetAlphabet: ICodingAlphabet;
    function GetZeroChar: Char;
    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;
    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    property Alphabet: ICodingAlphabet read GetAlphabet;
    property ZeroChar: Char read GetZeroChar;
  end;

implementation

end.
