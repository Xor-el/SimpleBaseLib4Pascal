unit SimpleBaseLibTestBase;

interface

uses
{$IFDEF FPC}
  StrUtils, // FPC needs StrUtils for BinToHex/HexToBin
{$ELSE}
  Classes,
{$ENDIF}
 SysUtils,
 SbpIBaseCoder,
 SbpSimpleBaseLibTypes,
 SbpArrayUtilities,
{$IFDEF FPC}
  fpcunit,
  testregistry
{$ELSE}
  TestFramework
{$ENDIF FPC};

type

  TSimpleBaseLibTestCase = class abstract(TTestCase)
  protected

    function AreEqual(const AA, AB: TBytes): Boolean;
    function CharsToString(const AData: TSimpleBaseLibCharArray;
      ACount: Int32): String;
    function HexToBytes(const AHex: String): TSimpleBaseLibByteArray;
    function BytesToHex(const ABytes: TSimpleBaseLibByteArray): String;
    procedure AssertCodersAreIsolated(const ACoderA, ACoderB: IBaseCoder;
      const AInput: TSimpleBaseLibByteArray; const ANameA, ANameB: String;
      AExpectDifferentEncoded: Boolean = True);
  end;

implementation

{ TSimpleBaseLibTestCase }

function TSimpleBaseLibTestCase.AreEqual(const AA, AB: TBytes): Boolean;
begin
  Result := TArrayUtilities.AreEqual(AA, AB);
end;

function TSimpleBaseLibTestCase.CharsToString(
  const AData: TSimpleBaseLibCharArray; ACount: Int32): String;
begin
  if ACount = 0 then
  begin
    Result := '';
    Exit;
  end;
  SetString(Result, PChar(@AData[0]), ACount);
end;

function TSimpleBaseLibTestCase.HexToBytes(
  const AHex: String): TSimpleBaseLibByteArray;
var
  LLen: Integer;
begin
  LLen := Length(AHex);
  if (LLen mod 2) <> 0 then
    raise EArgumentException.Create('Invalid hex string length (must be even)');
  SetLength(Result, LLen div 2);
  if {$IFDEF FPC}StrUtils.{$ENDIF}HexToBin(PChar(AHex), @Result[0], Length(Result)) <> Length(Result) then
    raise EArgumentException.Create('Invalid hex character in input');
end;

function TSimpleBaseLibTestCase.BytesToHex(
  const ABytes: TSimpleBaseLibByteArray): String;
var
  LCount: Int32;
begin
  LCount := Length(ABytes);
  SetLength(Result, LCount * 2);
  if LCount > 0 then
    {$IFDEF FPC}StrUtils.{$ENDIF}BinToHex(@ABytes[0], PChar(Result), LCount);
end;

procedure TSimpleBaseLibTestCase.AssertCodersAreIsolated(
  const ACoderA, ACoderB: IBaseCoder;
  const AInput: TSimpleBaseLibByteArray; const ANameA, ANameB: String;
  AExpectDifferentEncoded: Boolean);
var
  LAEncodedBefore, LAEncodedAfter, LBEncoded: String;
  LADecoded, LBDecoded: TSimpleBaseLibByteArray;
begin
  LAEncodedBefore := ACoderA.Encode(AInput);
  LADecoded := ACoderA.Decode(LAEncodedBefore);
  CheckTrue(AreEqual(AInput, LADecoded), ANameA + ' roundtrip failed');

  LBEncoded := ACoderB.Encode(AInput);
  LBDecoded := ACoderB.Decode(LBEncoded);
  CheckTrue(AreEqual(AInput, LBDecoded), ANameB + ' roundtrip failed');

  LAEncodedAfter := ACoderA.Encode(AInput);
  CheckEquals(LAEncodedBefore, LAEncodedAfter,
    ANameA + ' output changed after using ' + ANameB);

  if AExpectDifferentEncoded then
  begin
    CheckTrue(LAEncodedBefore <> LBEncoded,
      ANameA + ' and ' + ANameB + ' should encode differently for this vector');
  end;

  CheckFalse(ACoderA = ACoderB,
    ANameA + ' and ' + ANameB + ' should be distinct instances');
end;

end.

