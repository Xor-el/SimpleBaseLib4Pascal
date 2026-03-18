unit Base16StreamRegressionTests;

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
  SbpIBase16,
  SbpBase16,
  SimpleBaseLibTestBase;

type
  TTestBase16StreamRegression = class(TSimpleBaseLibTestCase)
  published
    procedure Test_StreamEncode_BufferBoundary_Regression;
  end;

implementation

procedure TTestBase16StreamRegression.Test_StreamEncode_BufferBoundary_Regression;
const
  CLengths: array [0 .. 5] of Int32 = (4095, 4096, 4097, 8191, 8192, 8193);
var
  LI, LJ, LK: Int32;
  LSeed: UInt32;
  LBytes, LDecoded: TSimpleBaseLibByteArray;
  LInput: TMemoryStream;
  LBuilder: TStringBuilder;
  LStreamEncoded, LDirectEncoded: String;
  LCoders: array [0 .. 2] of IBase16;
  LCoderNames: array [0 .. 2] of String;
begin
  LCoders[0] := TBase16.LowerCase;
  LCoders[1] := TBase16.UpperCase;
  LCoders[2] := TBase16.ModHex;
  LCoderNames[0] := 'LowerCase';
  LCoderNames[1] := 'UpperCase';
  LCoderNames[2] := 'ModHex';

  LSeed := UInt32($165667B1);
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
        Format('Base16 stream/direct mismatch len=%d mode=%s',
        [CLengths[LI], LCoderNames[LK]]));

      LDecoded := LCoders[LK].Decode(LStreamEncoded);
      CheckTrue(AreEqual(LBytes, LDecoded),
        Format('Base16 round-trip mismatch len=%d mode=%s',
        [CLengths[LI], LCoderNames[LK]]));
    end;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase16StreamRegression);
{$ELSE}
  RegisterTest(TTestBase16StreamRegression.Suite);
{$ENDIF FPC}

end.
