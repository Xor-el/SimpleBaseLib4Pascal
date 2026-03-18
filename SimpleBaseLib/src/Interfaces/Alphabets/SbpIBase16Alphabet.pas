unit SbpIBase16Alphabet;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet;

type
  /// <summary>
  /// Marker interface for Base16-specific alphabets.
  /// </summary>
  IBase16Alphabet = interface(ICodingAlphabet)
    ['{B5A3C4C2-43E8-4F6D-9C4B-9E89C2D3A1F7}']
  end;

implementation

end.

