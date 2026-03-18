unit SbpIBase32;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBaseCoder,
  SbpIBase32Alphabet;

type
  IBase32 = interface(IBaseCoder)
    ['{8FC8C853-1BB8-4923-84D7-BADE267F80A8}']

    function GetAlphabet: IBase32Alphabet;

    function GetSafeByteCountForDecoding(const AText: String): Int32;
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean; overload;
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; APadding: Boolean; out ACharsWritten: Int32): Boolean; overload;

    function TryDecode(const AText: String;
      const AOutput: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;

    function EncodeInt64(const ANumber: Int64): String;
    function EncodeUInt64(const ANumber: UInt64): String;
    function DecodeUInt64(const AText: String): UInt64;
    function TryDecodeUInt64(const AText: String; out ANumber: UInt64): Boolean;
    function DecodeInt64(const AText: String): Int64;

    function Encode(const ABytes: TSimpleBaseLibByteArray; APadding: Boolean): String; overload;

    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder;
      APadding: Boolean); overload;

    property Alphabet: IBase32Alphabet read GetAlphabet;
  end;

implementation

end.
