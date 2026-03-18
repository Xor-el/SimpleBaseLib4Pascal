unit Base85StreamRegressionTests;

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
  SbpIBase85,
  SbpBase85,
  SimpleBaseLibTestBase;

type
  TTestBase85StreamRegression = class(TSimpleBaseLibTestCase)
  published
    procedure Test_StreamEncode_BufferBoundary_Regression;
  end;

implementation

procedure TTestBase85StreamRegression.Test_StreamEncode_BufferBoundary_Regression;
const
  CLengths: array [0 .. 5] of Int32 = (4095, 4096, 4097, 8191, 8192, 8193);
var
  LI, LJ, LK: Int32;
  LSeed: UInt32;
  LBytes, LDecoded: TSimpleBaseLibByteArray;
  LInput: TMemoryStream;
  LBuilder: TStringBuilder;
  LStreamEncoded, LDirectEncoded: String;
  LCoders: array [0 .. 1] of IBase85;
  LCoderNames: array [0 .. 1] of String;
begin
  LCoders[0] := TBase85.Z85;
  LCoders[1] := TBase85.Ascii85;
  LCoderNames[0] := 'Z85';
  LCoderNames[1] := 'Ascii85';

  LSeed := UInt32($C3A5C85C);
  for LI := Low(CLengths) to High(CLengths) do
  begin
    SetLength(LBytes, CLengths[LI]);
    for LJ := 0 to High(LBytes) do
    begin
      LSeed := UInt32(LSeed * 1664525 + 1013904223);
      LBytes[LJ] := Byte(LSeed shr 24);
    end;

    for LK := Low(LCoders) to High(LCoders) do
    begin
      LInput := TMemoryStream.Create;
      LBuilder := TStringBuilder.Create;
      try
        if Length(LBytes) > 0 then
        begin
          LInput.WriteBuffer(LBytes[0], Length(LBytes));
        end;
        LInput.Position := 0;
        LCoders[LK].Encode(LInput, LBuilder);
        LStreamEncoded := LBuilder.ToString;
      finally
        LBuilder.Free;
        LInput.Free;
      end;

      LDirectEncoded := LCoders[LK].Encode(LBytes);
      CheckEquals(LDirectEncoded, LStreamEncoded,
        Format('Base85 stream/direct mismatch len=%d mode=%s',
        [CLengths[LI], LCoderNames[LK]]));

      LDecoded := LCoders[LK].Decode(LStreamEncoded);
      CheckTrue(AreEqual(LBytes, LDecoded),
        Format('Base85 round-trip mismatch len=%d mode=%s',
        [CLengths[LI], LCoderNames[LK]]));
    end;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase85StreamRegression);
{$ELSE}
  RegisterTest(TTestBase85StreamRegression.Suite);
{$ENDIF FPC}

end.
