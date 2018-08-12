unit Ascii85Tests;

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

  TTestAscii85 = class(TCryptoLibTestCase)
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
    procedure Test_Encode_UnevenBuffer_DoesNotThrowArgumentException;
    procedure Test_Decode_Empty_String_Returns_Empty_Buffer;
    procedure Test_Decode_TestVectors_ShouldDecodeCorrectly;
    procedure Test_Decode_UnevenText_DoesNotThrowArgumentException;

  end;

implementation

procedure TTestAscii85.SetUp;
begin
  inherited;
  FBytes := TSimpleBaseLibMatrixByteArray.Create
    (TSimpleBaseLibByteArray.Create($86, $4F, $D2, $6F, $B5, $59, $F7, $5B),
    TSimpleBaseLibByteArray.Create($11, $22, $33),
    TSimpleBaseLibByteArray.Create(77, 97, 110, 32),
    TSimpleBaseLibByteArray.Create(0, 0, 0, 0),
    TSimpleBaseLibByteArray.Create($20, $20, $20, $20));
  FStrings := TSimpleBaseLibStringArray.Create('L/669[9<6.', '&L''"', '9jqo^',
    'z', 'y');
end;

procedure TTestAscii85.TearDown;
begin
  inherited;

end;

procedure TTestAscii85.Test_Decode_Empty_String_Returns_Empty_Buffer;
begin
  CheckEquals(0, System.Length(TBase85.Ascii85.Decode('')));
end;

procedure TTestAscii85.Test_Decode_TestVectors_ShouldDecodeCorrectly;
var
  Idx: Int32;
  result, bytes: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FStrings) to System.High(FStrings) do
  begin
    bytes := FBytes[Idx];
    result := TBase85.Ascii85.Decode(FStrings[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(result, bytes),
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestAscii85.Test_Decode_UnevenText_DoesNotThrowArgumentException;
begin
  try

    TBase85.Ascii85.Decode('hebe');
    // pass

  except
    Fail('UnevenText Decode Should Not Throw Exception');

  end;
end;

procedure TTestAscii85.Test_Encode_Empty_Buffer_Returns_Empty_String;
begin
  CheckEquals('', TBase85.Ascii85.Encode(Nil));
end;

procedure TTestAscii85.Test_Encode_TestVectors_ShouldEncodeCorrectly;
var
  Idx: Int32;
  result: string;
begin
  for Idx := System.Low(FBytes) to System.High(FBytes) do
  begin
    result := TBase85.Ascii85.Encode(FBytes[Idx]);
    CheckEquals(FStrings[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestAscii85.Test_Encode_UnevenBuffer_DoesNotThrowArgumentException;
begin
  try

    TBase85.Ascii85.Encode(TSimpleBaseLibByteArray.Create(0, 0, 0));
    // pass

  except
    Fail('UnevenBuffer Encode Should Not Throw Exception');

  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestAscii85);
{$ELSE}
  RegisterTest(TTestAscii85.Suite);
{$ENDIF FPC}

end.
