unit SbpINumericBaseCoder;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

type
  INumericBaseCoder = interface(IInterface)
    ['{A2CFE15E-9B8F-48DA-99F8-D9FC68B2E5A1}']
    function EncodeInt64(const ANumber: Int64): String;
    function EncodeUInt64(const ANumber: UInt64): String;

    function DecodeUInt64(const AText: String): UInt64;
    function TryDecodeUInt64(const AText: String; out ANumber: UInt64): Boolean;
    function DecodeInt64(const AText: String): Int64;
  end;

implementation

end.
