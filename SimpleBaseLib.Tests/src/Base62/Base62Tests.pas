unit Base62Tests;

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
  SbpBase62,
  SimpleBaseLibTestBase;

type
  TTestBase62 = class(TSimpleBaseLibTestCase)
  strict private
    FDecodedData: TSimpleBaseLibStringArray;
    FDefaultEncodedData: TSimpleBaseLibStringArray;
    FLowerFirstEncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Default_Encode_ReturnsCorrectValues;
    procedure Test_Default_Decode_ReturnsCorrectValues;
    procedure Test_Default_TryDecode_ReturnsCorrectValues;
    procedure Test_LowerFirst_Encode_ReturnsCorrectValues;
    procedure Test_LowerFirst_Decode_ReturnsCorrectValues;
    procedure Test_LowerFirst_TryDecode_ReturnsCorrectValues;
  end;

implementation

procedure TTestBase62.SetUp;
begin
  inherited;
  FDecodedData := TSimpleBaseLibStringArray.Create(
    '',
    'SSG WAS HERE!',
    #0#0 + 'SSG WAS HERE!',
    #0#0#0,
    'A quick brown fox jumps over the lazy dog',
    'A',
    'AA',
    'AAA',
    'abc'
  );
  FDefaultEncodedData := TSimpleBaseLibStringArray.Create(
    '',
    '2ETo47rrJdrFdqI4CP',
    '002ETo47rrJdrFdqI4CP',
    '000',
    'MbW36N4wUwiF8w630WywYtgnrGqMKAxpYKQRT90ZlD5pv9LLGP4wHgd',
    '13',
    '4LR',
    'HwWX',
    'QmIN'
  );
  FLowerFirstEncodedData := TSimpleBaseLibStringArray.Create(
    '',
    '2etO47RRjDRfDQi4cp',
    '002etO47RRjDRfDQi4cp',
    '000',
    'mBw36n4WuWIf8W630wYWyTGNRgQmkaXPykqrt90zLd5PV9llgp4WhGD',
    '13',
    '4lr',
    'hWwx',
    'qMin'
  );
end;

procedure TTestBase62.TearDown;
begin
  inherited;
end;

procedure TTestBase62.Test_Default_Encode_ReturnsCorrectValues;
var
  LI: Int32;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedData) to High(FDecodedData) do
  begin
    LBytes := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    CheckEquals(FDefaultEncodedData[LI], TBase62.Default.Encode(LBytes),
      Format('Default: Encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase62.Test_Default_Decode_ReturnsCorrectValues;
var
  LI: Int32;
  LExpected, LActual: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDefaultEncodedData) to High(FDefaultEncodedData) do
  begin
    LExpected := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    LActual := TBase62.Default.Decode(FDefaultEncodedData[LI]);
    CheckTrue(AreEqual(LExpected, LActual),
      Format('Default: Decode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase62.Test_Default_TryDecode_ReturnsCorrectValues;
var
  LI, LBytesWritten: Int32;
  LOut, LExpected: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDefaultEncodedData) to High(FDefaultEncodedData) do
  begin
    SetLength(LOut, 100);
    CheckTrue(TBase62.Default.TryDecode(FDefaultEncodedData[LI], LOut, LBytesWritten),
      Format('Default: TryDecode should succeed at index %d', [LI]));
    LExpected := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    CheckTrue(AreEqual(LExpected, System.Copy(LOut, 0, LBytesWritten)),
      Format('Default: TryDecode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase62.Test_LowerFirst_Encode_ReturnsCorrectValues;
var
  LI: Int32;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedData) to High(FDecodedData) do
  begin
    LBytes := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    CheckEquals(FLowerFirstEncodedData[LI], TBase62.LowerFirst.Encode(LBytes),
      Format('LowerFirst: Encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase62.Test_LowerFirst_Decode_ReturnsCorrectValues;
var
  LI: Int32;
  LExpected, LActual: TSimpleBaseLibByteArray;
begin
  for LI := Low(FLowerFirstEncodedData) to High(FLowerFirstEncodedData) do
  begin
    LExpected := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    LActual := TBase62.LowerFirst.Decode(FLowerFirstEncodedData[LI]);
    CheckTrue(AreEqual(LExpected, LActual),
      Format('LowerFirst: Decode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase62.Test_LowerFirst_TryDecode_ReturnsCorrectValues;
var
  LI, LBytesWritten: Int32;
  LOut, LExpected: TSimpleBaseLibByteArray;
begin
  for LI := Low(FLowerFirstEncodedData) to High(FLowerFirstEncodedData) do
  begin
    SetLength(LOut, 100);
    CheckTrue(TBase62.LowerFirst.TryDecode(FLowerFirstEncodedData[LI], LOut, LBytesWritten),
      Format('LowerFirst: TryDecode should succeed at index %d', [LI]));
    LExpected := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    CheckTrue(AreEqual(LExpected, System.Copy(LOut, 0, LBytesWritten)),
      Format('LowerFirst: TryDecode mismatch at index %d', [LI]));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase62);
{$ELSE}
  RegisterTest(TTestBase62.Suite);
{$ENDIF FPC}

end.
