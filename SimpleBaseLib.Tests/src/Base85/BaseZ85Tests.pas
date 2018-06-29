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
    TSimpleBaseLibByteArray.Create($11, $22, $33, $44));
  FStrings := TSimpleBaseLibStringArray.Create('HelloWorld', '5H620');
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
    CheckTrue(CompareMem(PByte(result), PByte(bytes), System.Length(bytes)),
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
