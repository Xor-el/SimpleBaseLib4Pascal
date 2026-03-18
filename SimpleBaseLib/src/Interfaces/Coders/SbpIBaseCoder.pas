unit SbpIBaseCoder;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes;

type
  IBaseCoder = interface(IInterface)
    ['{F9A2C68D-7D5A-4C6F-9D4F-9E8A1D5F7B32}']
    /// <summary>
    /// Encode a buffer to base-encoded representation.
    /// </summary>
    function Encode(const ABytes: TSimpleBaseLibByteArray): String;

    /// <summary>
    /// Decode base-encoded text into bytes.
    /// </summary>
    function Decode(const AText: String): TSimpleBaseLibByteArray;
  end;

implementation

end.

