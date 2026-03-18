unit Base10Tests;

{$IFDEF FPC}
{$MODE DELPHI}
{$HINTS OFF}
{$WARNINGS OFF}
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
  SbpBase10,
  SimpleBaseLibTestBase;

type
  TTestBase10 = class(TSimpleBaseLibTestCase)
  strict private
    FDecodedHexData: TSimpleBaseLibStringArray;
    FEncodedData: TSimpleBaseLibStringArray;
    FZeroPrefixedDecodedHexData: TSimpleBaseLibStringArray;
    FZeroPrefixedEncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_EncodesCorrectly;
    procedure Test_Encode_ZeroPrefixed_EncodesCorrectly;
    procedure Test_Decode_DecodesCorrectly;
  end;

implementation

procedure TTestBase10.SetUp;
begin
  inherited;

  FDecodedHexData := TSimpleBaseLibStringArray.Create('', '0100', '010000');
  FEncodedData := TSimpleBaseLibStringArray.Create('', '256', '65536');

  FZeroPrefixedDecodedHexData := TSimpleBaseLibStringArray.Create('0001', '0000FF', '000100');
  FZeroPrefixedEncodedData := TSimpleBaseLibStringArray.Create('01', '00255', '0256');
end;

procedure TTestBase10.TearDown;
begin
  inherited;
end;

procedure TTestBase10.Test_Encode_EncodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    CheckEquals(FEncodedData[LI], TBase10.Default.Encode(HexToBytes(FDecodedHexData[LI])),
      Format('Base10 Encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase10.Test_Encode_ZeroPrefixed_EncodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FZeroPrefixedDecodedHexData) to High(FZeroPrefixedDecodedHexData) do
  begin
    CheckEquals(FZeroPrefixedEncodedData[LI],
      TBase10.Default.Encode(HexToBytes(FZeroPrefixedDecodedHexData[LI])),
      Format('Base10 ZeroPrefixed Encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase10.Test_Decode_DecodesCorrectly;
var
  LI: Int32;
begin
  for LI := Low(FDecodedHexData) to High(FDecodedHexData) do
  begin
    CheckEquals(FDecodedHexData[LI], BytesToHex(TBase10.Default.Decode(FEncodedData[LI])),
      Format('Base10 Decode mismatch at index %d', [LI]));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase10);
{$ELSE}
  RegisterTest(TTestBase10.Suite);
{$ENDIF FPC}

end.
