unit SbpIBase64;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBaseCoder,
  SbpIBase64Alphabet;

type
  IBase64 = interface(IBaseCoder)
    ['{E63DAF2A-BB4E-49DB-BD7E-0CD39A4A0A1D}']
    function GetAlphabet: IBase64Alphabet;
    function GetPadding: Boolean;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;

    property Alphabet: IBase64Alphabet read GetAlphabet;
    property Padding: Boolean read GetPadding;
  end;

implementation

end.
