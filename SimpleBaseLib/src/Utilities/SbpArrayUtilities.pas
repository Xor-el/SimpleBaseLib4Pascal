unit SbpArrayUtilities;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes;

type
  TArrayUtilities = class sealed(TObject)

  public

    class function AreEqual(const A, B: TSimpleBaseLibByteArray): Boolean; static;

    /// <summary>
    /// Constant-time comparison of two byte arrays.
    /// Both length and content comparisons are constant-time to avoid
    /// leaking information through timing side channels.
    /// </summary>
    class function FixedTimeEquals(const AAr1, AAr2: TSimpleBaseLibByteArray): Boolean; static;

    class procedure Fill<T>(ABuf: TSimpleBaseLibGenericArray<T>; AFrom, ATo: Int32;
      const AFiller: T); static;
  end;

implementation

{ TArrayUtilities }

class function TArrayUtilities.AreEqual(const A, B: TSimpleBaseLibByteArray): Boolean;
var
  LLen: Int32;
begin
  LLen := System.Length(A);
  if LLen <> System.Length(B) then
    Exit(False);
  if LLen = 0 then
    Exit(True);
  Result := CompareMem(@A[0], @B[0], LLen * System.SizeOf(Byte));
end;

class function TArrayUtilities.FixedTimeEquals(const AAr1, AAr2: TSimpleBaseLibByteArray): Boolean;
var
  LLenA, LLenB, LLen, LI: Int32;
  LDiff: UInt32;
begin
  LLenA := System.Length(AAr1);
  LLenB := System.Length(AAr2);
  // Accumulate length mismatch without branching
  LDiff := UInt32(LLenA xor LLenB);
  // Compare up to the shorter length to stay in bounds
  LLen := LLenA;
  if LLenB < LLen then
    LLen := LLenB;
  for LI := 0 to LLen - 1 do
    LDiff := LDiff or UInt32(AAr1[LI] xor AAr2[LI]);
  Result := LDiff = 0;
end;

class procedure TArrayUtilities.Fill<T>(ABuf: TSimpleBaseLibGenericArray<T>;
  AFrom, ATo: Int32; const AFiller: T);
var
  LI: Int32;
begin
  if ABuf = nil then
    Exit;
  for LI := AFrom to ATo - 1 do
    ABuf[LI] := AFiller;
end;

end.

