unit BaseZ85Tests;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  SbpUtilities,
  SbpSimpleBaseLibTypes,
  SbpBase85;

type

  TCryptoLibTestCase = class abstract(TTestCase)

  end;

type

  TTestBaseZ85 = class(TCryptoLibTestCase)
  private
  var
    FBytes: TSimpleBaseLibMatrixByteArray;
    FStrings: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_TestVectors_ShouldEncodeCorrectly;
    procedure Test_Encode_Empty_Buffer_Returns_Empty_String;
    procedure Test_Decode_Empty_String_Returns_Empty_Buffer;
    procedure Test_Decode_TestVectors_ShouldDecodeCorrectly;

  end;

implementation

procedure TTestBaseZ85.SetUp;
begin
  inherited;
  FBytes := TSimpleBaseLibMatrixByteArray.Create
    (TSimpleBaseLibByteArray.Create($86, $4F, $D2, $6F, $B5, $59, $F7, $5B),
    TSimpleBaseLibByteArray.Create($11), TSimpleBaseLibByteArray.Create($11,
    $22), TSimpleBaseLibByteArray.Create($11, $22, $33),
    TSimpleBaseLibByteArray.Create($11, $22, $33, $44),
    TSimpleBaseLibByteArray.Create($11, $22, $33, $44, $55),
    TSimpleBaseLibByteArray.Create($00, $00, $00, $00),
    TSimpleBaseLibByteArray.Create($20, $20, $20, $20));

  FStrings := TSimpleBaseLibStringArray.Create('HelloWorld', '5D', '5H4',
    '5H61', '5H620', '5H620rr', '00000', 'arR^H');
end;

procedure TTestBaseZ85.TearDown;
begin
  inherited;

end;

procedure TTestBaseZ85.Test_Decode_Empty_String_Returns_Empty_Buffer;
begin
  CheckEquals(0, System.Length(TBase85.Z85.Decode('')));
end;

procedure TTestBaseZ85.Test_Decode_TestVectors_ShouldDecodeCorrectly;
var
  Idx: Int32;
  result, bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FStrings) to System.High(FStrings) do
  begin
    bytes := FBytes[Idx];
    result := TBase85.Z85.Decode(FStrings[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(result, bytes),
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBaseZ85.Test_Encode_Empty_Buffer_Returns_Empty_String;
begin
  CheckEquals('', TBase85.Z85.Encode(Nil));
end;

procedure TTestBaseZ85.Test_Encode_TestVectors_ShouldEncodeCorrectly;
var
  Idx: Int32;
  result: string;
begin
  for Idx := System.Low(FBytes) to System.High(FBytes) do
  begin
    result := TBase85.Z85.Encode(FBytes[Idx]);
    CheckEquals(FStrings[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestBaseZ85);
{$ELSE}
  RegisterTest(TTestBaseZ85.Suite);
{$ENDIF FPC}

end.
