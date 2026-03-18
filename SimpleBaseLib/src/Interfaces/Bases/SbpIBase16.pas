unit SbpIBase16;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  Classes,
  SbpSimpleBaseLibTypes,
  SbpIBaseCoder,
  SbpICodingAlphabet;

type
  IBase16 = interface(IBaseCoder)
    ['{6F6E5C3D-9B7A-4F28-8A7E-2E4C2B1D9F01}']

    function ToString: String;
    function GetHashCode: {$IFDEF DELPHI}Int32;{$ELSE}PtrInt;{$ENDIF DELPHI}
    /// <summary>
    /// Gets the alphabet used by this Base16 encoder.
    /// </summary>
    function GetAlphabet: ICodingAlphabet;

    /// <summary>
    /// Returns a safe upper bound for the number of decoded bytes.
    /// Returns 0 if the text length is invalid for decoding.
    /// </summary>
    function GetSafeByteCountForDecoding(const AText: String): Int32;

    /// <summary>
    /// Returns a safe upper bound for the number of encoded characters.
    /// </summary>
    function GetSafeCharCountForEncoding(const ABytes: TSimpleBaseLibByteArray): Int32;

    /// <summary>
    /// Tries to decode Base16 text into a preallocated byte buffer.
    /// Does not raise on failure; instead returns False and sets ABytesWritten to 0.
    /// </summary>
    function TryDecode(const AText: String; const AOutput: TSimpleBaseLibByteArray;
      out ABytesWritten: Int32): Boolean;

    /// <summary>
    /// Tries to encode bytes into a preallocated char buffer.
    /// Does not raise on failure; instead returns False and sets ACharsWritten to 0.
    /// </summary>
    function TryEncode(const ABytes: TSimpleBaseLibByteArray;
      const AOutput: TSimpleBaseLibCharArray; out ACharsWritten: Int32): Boolean;

    /// <summary>
    /// Decode Base16 text from a string builder into a stream of bytes.
    /// </summary>
    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream); overload;

    /// <summary>
    /// Encode bytes from a stream into Base16 text written to a string builder.
    /// </summary>
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder); overload;

    /// <summary>
    /// Alphabet used by this encoder.
    /// </summary>
    property Alphabet: ICodingAlphabet read GetAlphabet;
  end;

implementation

end.

