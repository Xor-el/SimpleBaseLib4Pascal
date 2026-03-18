unit SbpIBase8;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBaseCoder;

type
  IBase8 = interface(IBaseCoder)
    ['{A2E3D0CE-63B3-4A7B-8C22-7DFE12E58C11}']

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
