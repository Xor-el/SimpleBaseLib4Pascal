unit SimpleBaseLibTestBase;

interface

uses
{$IFDEF FPC}
  StrUtils, // FPC needs StrUtils for BinToHex/HexToBin
{$ELSE}
  Classes,
{$ENDIF}
 SysUtils,
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

end.

