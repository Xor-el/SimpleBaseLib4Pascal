unit Base58Tests;

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
  SbpBase16,
  SbpBase58;

type

  TCryptoLibTestCase = class abstract(TTestCase)

  end;

type

  TTestBase58 = class(TCryptoLibTestCase)
  private
  var
    FRawDataInHex, FBase58EncodedData: TSimpleBaseLibStringArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Encode_Bitcoin_Returns_Expected_Results;
    procedure Test_Constructor_Nil_Alphabet_Raise;
    procedure Test_Encode_Empty_Buffer_Returns_Empty_String;
    procedure Test_Decode_Empty_String_Returns_Empty_Buffer;
    procedure Test_Decode_Invalid_Character_Raise;
    procedure Test_Decode_Bitcoin_Returns_Expected_Results;

  end;

implementation

procedure TTestBase58.SetUp;
begin
  inherited;
  FRawDataInHex := TSimpleBaseLibStringArray.Create('', '0000010203',
    '009C1CA2CBA6422D3988C735BB82B5C880B0441856B9B0910F',
    '000860C220EBBAF591D40F51994C4E2D9C9D88168C33E761F6',
    '00313E1F905554E7AE2580CD36F86D0C8088382C9E1951C44D010203', '0000000000',
    '1111111111', 'FFEEDDCCBBAA', '00', '21',
    // Test cases from https://gist.github.com/CodesInChaos/3175971
    '00000001', '61', '626262', '636363',
    '73696D706C792061206C6F6E6720737472696E67',
    '00EB15231DFCEB60925886B67D065299925915AEB172C06647', '516B6FCD0F',
    'BF4F89001E670274DD', '572E4794', 'ECAC89CAD93923C02321', '10C8511E',
    '00000000000000000000'

    );
  FBase58EncodedData := TSimpleBaseLibStringArray.Create('', '11Ldp',
    '1FESiat4YpNeoYhW3Lp7sW1T6WydcW7vcE', '1mJKRNca45GU2JQuHZqZjHFNktaqAs7gh',
    '17f1hgANcLE5bQhAGRgnBaLTTs23rK4VGVKuFQ', '11111', '2vgLdhi',
    '3CSwN61PP', '1', 'a',
    // Test cases from https://gist.github.com/CodesInChaos/3175971
    '1112', '2g', 'a3gV', 'aPEr', '2cFupjhnEsSn59qHXstmK2ffpLv2',
    '1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L', 'ABnLTmg', '3SEo3LWLoPntC', '3EFU7m',
    'EJDM8drfXA6uyA', 'Rt5zm', '1111111111'

    );
end;

procedure TTestBase58.TearDown;
begin
  inherited;

end;

procedure TTestBase58.Test_Encode_Bitcoin_Returns_Expected_Results;
var
  Idx: Int32;
  buffer: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawDataInHex) to System.High(FRawDataInHex) do
  begin
    buffer := TBase16.Decode(FRawDataInHex[Idx]);
    result := TBase58.Bitcoin.Encode(buffer);
    CheckEquals(FBase58EncodedData[Idx], result,
      Format('Encoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase58.Test_Constructor_Nil_Alphabet_Raise;
begin
  try

    TBase58.Create(Nil);
    Fail('expected EArgumentNilSimpleBaseLibException');

  except
    on e: EArgumentNilSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

procedure TTestBase58.Test_Decode_Bitcoin_Returns_Expected_Results;
var
  Idx: Int32;
  buffer: TSimpleBaseLibByteArray;
  result: String;
begin
  for Idx := System.Low(FRawDataInHex) to System.High(FRawDataInHex) do
  begin
    buffer := TBase58.Bitcoin.Decode(FBase58EncodedData[Idx]);
    result := TBase16.EncodeUpper(buffer);
    CheckEquals(FRawDataInHex[Idx], result,
      Format('Decoding Failed at Index %d', [Idx]));
  end;
end;

procedure TTestBase58.Test_Decode_Empty_String_Returns_Empty_Buffer;
begin
  CheckEquals(0, System.Length(TBase58.Bitcoin.Decode('')));
end;

procedure TTestBase58.Test_Decode_Invalid_Character_Raise;
begin
  try

    TBase58.Bitcoin.Decode('?');
    Fail('expected EArgumentSimpleBaseLibException');

  except
    on e: EArgumentSimpleBaseLibException do
    begin
      // pass
    end;

  end;
end;

procedure TTestBase58.Test_Encode_Empty_Buffer_Returns_Empty_String;
begin
  CheckEquals('', TBase58.Bitcoin.Encode(Nil));
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestBase58);
{$ELSE}
  RegisterTest(TTestBase58.Suite);
{$ENDIF FPC}

end.
