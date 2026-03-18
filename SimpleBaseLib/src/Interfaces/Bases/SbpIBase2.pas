unit SbpIBase2;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBaseCoder;

type
  IBase2 = interface(IBaseCoder)
    ['{B11C7A74-1C7B-4E8E-9CA7-2FD1A0B6B1F2}']

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;
  end;

implementation

end.
