unit Base32StreamRegressionTests;

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
  SbpIBase32,
  SbpBase32,
  SimpleBaseLibTestBase;

type
  TTestBase32StreamRegression = class(TSimpleBaseLibTestCase)
  published
    procedure Test_StreamEncode_BufferBoundary_Regression;
  end;

implementation

procedure TTestBase32StreamRegression.Test_StreamEncode_BufferBoundary_Regression;
const
  CLengths: array [0 .. 5] of Int32 = (4095, 4096, 4097, 8191, 8192, 8193);
var
  LI, LJ, LK: Int32;
  LSeed: UInt32;
  LBytes, LDecoded: TSimpleBaseLibByteArray;
  LInput: TMemoryStream;
  LBuilder: TStringBuilder;
  LStreamEncoded, LDirectEncoded: String;
  LCoders: array [0 .. 7] of IBase32;
  LCoderNames: array [0 .. 7] of String;
begin
  LCoders[0] := TBase32.Crockford;
  LCoders[1] := TBase32.Rfc4648;
  LCoders[2] := TBase32.ExtendedHex;
  LCoders[3] := TBase32.ExtendedHexLower;
  LCoders[4] := TBase32.ZBase32;
  LCoders[5] := TBase32.Geohash;
  LCoders[6] := TBase32.Bech32;
  LCoders[7] := TBase32.FileCoin;

  LCoderNames[0] := 'Crockford';
  LCoderNames[1] := 'Rfc4648';
  LCoderNames[2] := 'ExtendedHex';
  LCoderNames[3] := 'ExtendedHexLower';
  LCoderNames[4] := 'ZBase32';
  LCoderNames[5] := 'Geohash';
  LCoderNames[6] := 'Bech32';
  LCoderNames[7] := 'FileCoin';

  LSeed := UInt32($9E3779B9);
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
      for LJ := 0 to 1 do
      begin
        LInput := TMemoryStream.Create;
        LBuilder := TStringBuilder.Create;
        try
          if Length(LBytes) > 0 then
          begin
            LInput.WriteBuffer(LBytes[0], Length(LBytes));
          end;
          LInput.Position := 0;
          LCoders[LK].Encode(LInput, LBuilder, LJ = 1);
          LStreamEncoded := LBuilder.ToString;
        finally
          LBuilder.Free;
          LInput.Free;
        end;

        LDirectEncoded := LCoders[LK].Encode(LBytes, LJ = 1);
        CheckEquals(LDirectEncoded, LStreamEncoded,
          Format('Base32 stream/direct mismatch len=%d mode=%s padding=%s',
          [CLengths[LI], LCoderNames[LK], SysUtils.BoolToStr(LJ = 1, True)]));

        LDecoded := LCoders[LK].Decode(LStreamEncoded);
        CheckTrue(AreEqual(LBytes, LDecoded),
          Format('Base32 round-trip mismatch len=%d mode=%s padding=%s',
          [CLengths[LI], LCoderNames[LK], SysUtils.BoolToStr(LJ = 1, True)]));
      end;
    end;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase32StreamRegression);
{$ELSE}
  RegisterTest(TTestBase32StreamRegression.Suite);
{$ENDIF FPC}

end.
