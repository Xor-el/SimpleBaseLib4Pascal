unit SbpBits;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes;

type

  /// <summary>
  /// Helper functions for bit operations.
  /// </summary>
  TBits = class sealed(TObject)
  public
  const
    /// <summary>
    /// Max decimal digits possible in an unsigned long (64-bit) number.
    /// </summary>
    MaxUInt64Digits = Int32(20);

    /// <summary>
    /// Converts a variable length byte array to a 64-bit unsigned integer.
    /// </summary>
    class function PartialBigEndianBytesToUInt64(const ABytes: TSimpleBaseLibByteArray;
      AOffset, ACount: Int32): UInt64; static;

    /// <summary>
    /// Count the number of consecutive zero bytes at the beginning of the given buffer.
    /// </summary>
    class function CountPrefixingZeroes(const ABytes: TSimpleBaseLibByteArray): Int32; static;
  end;

implementation

{ TBits }

class function TBits.PartialBigEndianBytesToUInt64(const ABytes: TSimpleBaseLibByteArray;
  AOffset, ACount: Int32): UInt64;
var
  LI: Int32;
begin
  if ACount > System.SizeOf(UInt64) then
  begin
    raise EArgumentOutOfRangeSimpleBaseLibException.Create('ACount too large to convert to UInt64');
  end;

  Result := 0;
  for LI := 0 to ACount - 1 do
  begin
    Result := (Result shl 8) or ABytes[AOffset + LI];
  end;
end;

class function TBits.CountPrefixingZeroes(const ABytes: TSimpleBaseLibByteArray): Int32;
var
  LI: Int32;
begin
  for LI := 0 to System.Length(ABytes) - 1 do
  begin
    if ABytes[LI] <> 0 then
    begin
      Result := LI;
      Exit;
    end;
  end;
  Result := System.Length(ABytes);
end;

end.
