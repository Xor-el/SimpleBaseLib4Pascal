unit SbpIBaseStreamCoder;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils;

type
  /// <summary>
  /// Stream-based encoding/decoding interface.
  /// </summary>
  IBaseStreamCoder = interface(IInterface)
    ['{8E6C2B49-6E9E-4D2A-9F4B-7B7B3C2F9A11}']
    /// <summary>
    /// Decode base-encoded text from a text buffer into a byte stream.
    /// </summary>
    procedure Decode(const AInput: TStringBuilder; const AOutput: TStream);

    /// <summary>
    /// Encode bytes from a stream into base-encoded text.
    /// </summary>
    procedure Encode(const AInput: TStream; const AOutput: TStringBuilder);
  end;

implementation

end.

