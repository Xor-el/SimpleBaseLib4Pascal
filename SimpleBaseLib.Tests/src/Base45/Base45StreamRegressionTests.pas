unit Base45StreamRegressionTests;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  Classes,
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpSimpleBaseLibTypes,
  SbpBase45,
  SimpleBaseLibTestBase;

type
  TTestBase45StreamRegression = class(TSimpleBaseLibTestCase)
  published
    procedure Test_StreamEncode_BufferBoundary_Regression;
  end;

implementation

procedure TTestBase45StreamRegression.Test_StreamEncode_BufferBoundary_Regression;
const
  CLengths: array [0 .. 5] of Int32 = (4095, 4096, 4097, 8191, 8192, 8193);
var
  LI, LJ: Int32;
  LSeed: UInt32;
  LBytes, LDecoded: TSimpleBaseLibByteArray;
  LInput: TMemoryStream;
  LBuilder: TStringBuilder;
  LStreamEncoded, LDirectEncoded: String;
begin
  LSeed := UInt32($85D5B2F3);
  for LI := Low(CLengths) to High(CLengths) do
  begin
    SetLength(LBytes, CLengths[LI]);
    for LJ := 0 to High(LBytes) do
    begin
      LSeed := UInt32(LSeed * 1664525 + 1013904223);
      LBytes[LJ] := Byte(LSeed shr 24);
    end;

    LInput := TMemoryStream.Create;
    LBuilder := TStringBuilder.Create;
    try
      if Length(LBytes) > 0 then
      begin
        LInput.WriteBuffer(LBytes[0], Length(LBytes));
      end;
      LInput.Position := 0;
      TBase45.Default.Encode(LInput, LBuilder);
      LStreamEncoded := LBuilder.ToString;
    finally
      LBuilder.Free;
      LInput.Free;
    end;

    LDirectEncoded := TBase45.Default.Encode(LBytes);
    CheckEquals(LDirectEncoded, LStreamEncoded,
      Format('Base45 stream/direct mismatch len=%d', [CLengths[LI]]));

    LDecoded := TBase45.Default.Decode(LStreamEncoded);
    CheckTrue(AreEqual(LBytes, LDecoded),
      Format('Base45 round-trip mismatch len=%d', [CLengths[LI]]));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase45StreamRegression);
{$ELSE}
  RegisterTest(TTestBase45StreamRegression.Suite);
{$ENDIF FPC}

end.
