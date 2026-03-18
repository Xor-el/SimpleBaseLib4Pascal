unit Base45Tests;

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
  TTestBase45 = class(TSimpleBaseLibTestCase)
  strict private
    FDecodedData: TSimpleBaseLibStringArray;
    FEncodedData: TSimpleBaseLibStringArray;
    FInvalidInputs: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_ReturnsCorrectValues;
    procedure Test_Decode_ReturnsCorrectValues;
    procedure Test_Decode_ThrowsOnInvalidEncoding;
    procedure Test_Encode_Stream_EncodesCorrectly;
    procedure Test_Decode_Stream_DecodesCorrectly;
  end;

implementation

procedure TTestBase45.SetUp;
begin
  inherited;
  FDecodedData := TSimpleBaseLibStringArray.Create(
    '', 'AB', 'base-45', 'ietf!', 'SSG', 'SSG1', 'SSG12', 'SSG123', 'A');
  FEncodedData := TSimpleBaseLibStringArray.Create(
    '', 'BB8', 'UJCLQE7W581', 'QED8WEX0', '1OAQ1', '1OA009', '1OA00951',
    '1OA009QF6', 'K1');
  FInvalidInputs := TSimpleBaseLibStringArray.Create('1', '1231', '1231231', '???');
end;

procedure TTestBase45.TearDown;
begin
  inherited;
end;

procedure TTestBase45.Test_Encode_ReturnsCorrectValues;
var
  LI: Int32;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FDecodedData) to High(FDecodedData) do
  begin
    LBytes := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    CheckEquals(FEncodedData[LI], TBase45.Default.Encode(LBytes),
      Format('Encode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase45.Test_Decode_ReturnsCorrectValues;
var
  LI: Int32;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    LBytes := TBase45.Default.Decode(FEncodedData[LI]);
    CheckEquals(FDecodedData[LI], TEncoding.UTF8.GetString(LBytes),
      Format('Decode mismatch at index %d', [LI]));
  end;
end;

procedure TTestBase45.Test_Decode_ThrowsOnInvalidEncoding;
var
  LI: Int32;
begin
  for LI := Low(FInvalidInputs) to High(FInvalidInputs) do
  begin
    try
      TBase45.Default.Decode(FInvalidInputs[LI]);
      Fail(Format('Expected EArgumentSimpleBaseLibException for input "%s"',
        [FInvalidInputs[LI]]));
    except
      on EArgumentSimpleBaseLibException do
      begin
        // expected
      end;
    end;
  end;
end;

procedure TTestBase45.Test_Encode_Stream_EncodesCorrectly;
var
  LI: Int32;
  LBytes: TSimpleBaseLibByteArray;
  LInput: TMemoryStream;
  LOutput: TStringBuilder;
begin
  for LI := Low(FDecodedData) to High(FDecodedData) do
  begin
    LBytes := TEncoding.UTF8.GetBytes(FDecodedData[LI]);
    LInput := TMemoryStream.Create;
    LOutput := TStringBuilder.Create;
    try
      if Length(LBytes) > 0 then
      begin
        LInput.WriteBuffer(LBytes[0], Length(LBytes));
      end;
      LInput.Position := 0;
      TBase45.Default.Encode(LInput, LOutput);
      CheckEquals(FEncodedData[LI], LOutput.ToString,
        Format('Stream encode mismatch at index %d', [LI]));
    finally
      LOutput.Free;
      LInput.Free;
    end;
  end;
end;

procedure TTestBase45.Test_Decode_Stream_DecodesCorrectly;
var
  LI: Int32;
  LInput: TStringBuilder;
  LOutput: TMemoryStream;
  LBytes: TSimpleBaseLibByteArray;
begin
  for LI := Low(FEncodedData) to High(FEncodedData) do
  begin
    LInput := TStringBuilder.Create(FEncodedData[LI]);
    LOutput := TMemoryStream.Create;
    try
      TBase45.Default.Decode(LInput, LOutput);
      SetLength(LBytes, LOutput.Size);
      if LOutput.Size > 0 then
      begin
        LOutput.Position := 0;
        LOutput.ReadBuffer(LBytes[0], LOutput.Size);
      end;
      CheckEquals(FDecodedData[LI], TEncoding.UTF8.GetString(LBytes),
        Format('Stream decode mismatch at index %d', [LI]));
    finally
      LOutput.Free;
      LInput.Free;
    end;
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestBase45);
{$ELSE}
  RegisterTest(TTestBase45.Suite);
{$ENDIF FPC}

end.
