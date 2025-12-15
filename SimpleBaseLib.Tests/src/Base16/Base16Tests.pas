unit Base16Tests;

{$IFDEF FPC}
{$MODE DELPHI}
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
  SbpUtilities,
  SbpSimpleBaseLibTypes,
  SbpBase16,
  SimpleBaseLibTestBase;

type

  TTestBase16 = class(TSimpleBaseLibTestCase)
  private
  var
    FTestDataBytes: TSimpleBaseLibMatrixByteArray;
    FTestDataString: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_Upper;
    procedure Test_Encode_Lower;
    procedure Test_Decode_LowerCase;
    procedure Test_Decode_Invalid_Char_Raise;
    procedure Test_Decode_Invalid_Length_Raise;

  end;

implementation

procedure TTestBase16.SetUp;
begin
  inherited;
  FTestDataBytes := TSimpleBaseLibMatrixByteArray.Create(Nil,
    TSimpleBaseLibByteArray.Create($AB), TSimpleBaseLibByteArray.Create($00,
    $01, $02, $03), TSimpleBaseLibByteArray.Create($10, $11, $12, $13),
    TSimpleBaseLibByteArray.Create($AB, $CD, $EF, $BA)

    );

  FTestDataString := TSimpleBaseLibStringArray.Create('', 'AB', '00010203',
    '10111213', 'ABCDEFBA'

    );
end;

procedure TTestBase16.TearDown;
begin
  inherited;

end;

procedure TTestBase16.Test_Decode_Invalid_Char_Raise;
begin
  try

    TBase16.Decode('AZ12');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase16.Decode('ZAAA');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase16.Decode('!AAA');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase16.Decode('=AAA');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

procedure TTestBase16.Test_Decode_Invalid_Length_Raise;
begin
  try

    TBase16.Decode('12345');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;

  try

    TBase16.Decode('ABC');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

procedure TTestBase16.Test_Decode_LowerCase;
var
  Idx: Int32;
  result: TSimpleBaseLibByteArray;
begin
  for Idx := System.Low(FTestDataBytes) to System.High(FTestDataBytes) do
  begin
    result := TBase16.Decode(FTestDataString[Idx]);
    CheckTrue(TUtilities.AreArraysEqual(FTestDataBytes[Idx], result),
      Format('Decode_LowerCase Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase16.Test_Encode_Lower;
var
  Idx: Int32;
  result: String;
begin
  for Idx := System.Low(FTestDataBytes) to System.High(FTestDataBytes) do
  begin
    result := TBase16.EncodeLower(FTestDataBytes[Idx]);
    CheckEquals(LowerCase(FTestDataString[Idx]), result,
      Format('EncodeLower Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase16.Test_Encode_Upper;
var
  Idx: Int32;
  result: String;
begin
  for Idx := System.Low(FTestDataBytes) to System.High(FTestDataBytes) do
  begin
    result := TBase16.EncodeUpper(FTestDataBytes[Idx]);
    CheckEquals(FTestDataString[Idx], result,
      Format('EncodeUpper Failed at Index %d', [Idx]));
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestBase16);
{$ELSE}
  RegisterTest(TTestBase16.Suite);
{$ENDIF FPC}

end.
