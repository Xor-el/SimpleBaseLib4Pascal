unit SbpINonAllocatingBaseCoder;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes;

type
  /// <summary>
  /// Non-allocating encoding/decoding interface.
  /// </summary>
  INonAllocatingBaseCoder = interface(IInterface)
    ['{D2F4C5A3-1B9E-4F3A-8D24-9F2C3B1E7A55}']
    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;
  end;

implementation

end.

