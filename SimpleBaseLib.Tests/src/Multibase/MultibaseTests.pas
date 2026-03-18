unit MultibaseTests;

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
  SbpMultibase,
  SbpMultibaseEncoding,
  SimpleBaseLibTestBase;

type
  TMultibaseVector = record
    Encoding: TMultibaseEncoding;
    Expected: String;
    constructor Create(AEncoding: TMultibaseEncoding; const AExpected: String);
  end;

  TTestMultibase = class(TSimpleBaseLibTestCase)
  published
    procedure Test_Encode_PrependsBufferWithCorrectCharacter;
    procedure Test_Encode_InvalidEncoding_ThrowsArgumentException;
    procedure Test_Encode_EncodesDataCorrectly;
    procedure Test_Encode_OfficialEncodingData_EncodesDataCorrectly;
    procedure Test_Encode_OfficialZeroPrefixedEncodingData_EncodesDataCorrectly;
    procedure Test_Encode_EncodedDataDecodesBack;
    procedure Test_TryDecode_DecodesCorrectly;
    procedure Test_Decode_EmptyString_Throws;
    procedure Test_TryDecode_EmptyString_ReturnsFalse;
    procedure Test_Decode_MixedCaseInput_DecodesCorrectly;
  end;

implementation

constructor TMultibaseVector.Create(AEncoding: TMultibaseEncoding;
  const AExpected: String);
begin
  Encoding := AEncoding;
  Expected := AExpected;
end;

const
  SupportedEncodings: array [0 .. 18] of TMultibaseEncoding = (
    TMultibaseEncoding.Base16Lower, TMultibaseEncoding.Base16Upper,
    TMultibaseEncoding.Base32Lower, TMultibaseEncoding.Base32Upper,
    TMultibaseEncoding.Base58Bitcoin, TMultibaseEncoding.Base64,
    TMultibaseEncoding.Base64Pad, TMultibaseEncoding.Base64Url,
    TMultibaseEncoding.Base64UrlPad, TMultibaseEncoding.Base8,
    TMultibaseEncoding.Base10, TMultibaseEncoding.Base32Z,
    TMultibaseEncoding.Base36Lower, TMultibaseEncoding.Base36Upper,
    TMultibaseEncoding.Base45, TMultibaseEncoding.Base2,
    TMultibaseEncoding.Base58Flickr, TMultibaseEncoding.Base32HexLower,
    TMultibaseEncoding.Base32HexUpper
  );

procedure TTestMultibase.Test_Encode_PrependsBufferWithCorrectCharacter;
var
  LI: Int32;
  LTestBuffer: TSimpleBaseLibByteArray;
  LResult: String;
begin
  LTestBuffer := TSimpleBaseLibByteArray.Create(1, 2, 3, 4, 5);
  for LI := Low(SupportedEncodings) to High(SupportedEncodings) do
  begin
    LResult := TMultibase.Encode(LTestBuffer, SupportedEncodings[LI]);
    CheckEquals(Ord(Char(Ord(SupportedEncodings[LI]))), Ord(LResult[1]));
  end;
end;

procedure TTestMultibase.Test_Encode_InvalidEncoding_ThrowsArgumentException;
var
  LTestBuffer: TSimpleBaseLibByteArray;
begin
  LTestBuffer := TSimpleBaseLibByteArray.Create(1, 2, 3, 4, 5);
  try
    TMultibase.Encode(LTestBuffer, TMultibaseEncoding(0));
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestMultibase.Test_Encode_EncodesDataCorrectly;
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
  LVectors: array [0 .. 14] of TMultibaseVector;
begin
  LVectors[0] := TMultibaseVector.Create(TMultibaseEncoding.Base16Lower,
    'f535347205741532048455245202121c2abc38dc39ec3bf');
  LVectors[1] := TMultibaseVector.Create(TMultibaseEncoding.Base16Upper,
    'F535347205741532048455245202121C2ABC38DC39EC3BF');
  LVectors[2] := TMultibaseVector.Create(TMultibaseEncoding.Base32Lower,
    'bknjuoicxifjsascfkjcsaijbykv4hdodt3b36');
  LVectors[3] := TMultibaseVector.Create(TMultibaseEncoding.Base32Upper,
    'BKNJUOICXIFJSASCFKJCSAIJBYKV4HDODT3B36');
  LVectors[4] := TMultibaseVector.Create(TMultibaseEncoding.Base32HexLower,
    'vad9ke82n859i0i25a92i0891oals73e3jr1ru');
  LVectors[5] := TMultibaseVector.Create(TMultibaseEncoding.Base32HexUpper,
    'VAD9KE82N859I0I25A92I0891OALS73E3JR1RU');
  LVectors[6] := TMultibaseVector.Create(TMultibaseEncoding.Base36Lower,
    'k2p81m7y66k71a7teel1hfa4ldp6bneq0hj9b');
  LVectors[7] := TMultibaseVector.Create(TMultibaseEncoding.Base36Upper,
    'K2P81M7Y66K71A7TEEL1HFA4LDP6BNEQ0HJ9B');
  LVectors[8] := TMultibaseVector.Create(TMultibaseEncoding.Base32Z,
    'hkpjwqenzefj1y1nfkjn1yejbakih8dqdu5b56');
  LVectors[9] := TMultibaseVector.Create(TMultibaseEncoding.Base45,
    'R1OAS:8H1B+MA6691IAZ242C46WLL-H83KB4');
  LVectors[10] := TMultibaseVector.Create(TMultibaseEncoding.Base58Flickr,
    'Z2HPxwKnQi8s2ugkrzPrrR6nyDEpMhoe6');
  LVectors[11] := TMultibaseVector.Create(TMultibaseEncoding.Base58Bitcoin,
    'z2ipYXkNqJ8T2VGLSapSSr6NZefQnHPE6');
  LVectors[12] := TMultibaseVector.Create(TMultibaseEncoding.Base64,
    'mU1NHIFdBUyBIRVJFICEhwqvDjcOew78');
  LVectors[13] := TMultibaseVector.Create(TMultibaseEncoding.Base64Pad,
    'MU1NHIFdBUyBIRVJFICEhwqvDjcOew78=');
  LVectors[14] := TMultibaseVector.Create(TMultibaseEncoding.Base64Url,
    'uU1NHIFdBUyBIRVJFICEhwqvDjcOew78');

  LInput := TEncoding.UTF8.GetBytes('SSG WAS HERE !!' + #$AB + #$CD + #$DE + #$FF);
  for LI := Low(LVectors) to High(LVectors) do
  begin
    CheckEquals(LVectors[LI].Expected,
      TMultibase.Encode(LInput, LVectors[LI].Encoding));
  end;
end;

procedure TTestMultibase.Test_Encode_OfficialEncodingData_EncodesDataCorrectly;
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
  LVectors: array [0 .. 17] of TMultibaseVector;
begin
  LVectors[0] := TMultibaseVector.Create(TMultibaseEncoding.Base2,
    '001111001011001010111001100100000011011010110000101101110011010010010000000100001');
  LVectors[1] := TMultibaseVector.Create(TMultibaseEncoding.Base8,
    '7362625631006654133464440102');
  LVectors[2] := TMultibaseVector.Create(TMultibaseEncoding.Base10,
    '9573277761329450583662625');
  LVectors[3] := TMultibaseVector.Create(TMultibaseEncoding.Base16Lower,
    'f796573206d616e692021');
  LVectors[4] := TMultibaseVector.Create(TMultibaseEncoding.Base16Upper,
    'F796573206D616E692021');
  LVectors[5] := TMultibaseVector.Create(TMultibaseEncoding.Base32Lower,
    'bpfsxgidnmfxgsibb');
  LVectors[6] := TMultibaseVector.Create(TMultibaseEncoding.Base32Upper,
    'BPFSXGIDNMFXGSIBB');
  LVectors[7] := TMultibaseVector.Create(TMultibaseEncoding.Base32HexLower,
    'vf5in683dc5n6i811');
  LVectors[8] := TMultibaseVector.Create(TMultibaseEncoding.Base32HexUpper,
    'VF5IN683DC5N6I811');
  LVectors[9] := TMultibaseVector.Create(TMultibaseEncoding.Base32Z,
    'hxf1zgedpcfzg1ebb');
  LVectors[10] := TMultibaseVector.Create(TMultibaseEncoding.Base36Lower,
    'k2lcpzo5yikidynfl');
  LVectors[11] := TMultibaseVector.Create(TMultibaseEncoding.Base36Upper,
    'K2LCPZO5YIKIDYNFL');
  LVectors[12] := TMultibaseVector.Create(TMultibaseEncoding.Base58Flickr,
    'Z7Pznk19XTTzBtx');
  LVectors[13] := TMultibaseVector.Create(TMultibaseEncoding.Base58Bitcoin,
    'z7paNL19xttacUY');
  LVectors[14] := TMultibaseVector.Create(TMultibaseEncoding.Base64,
    'meWVzIG1hbmkgIQ');
  LVectors[15] := TMultibaseVector.Create(TMultibaseEncoding.Base64Pad,
    'MeWVzIG1hbmkgIQ==');
  LVectors[16] := TMultibaseVector.Create(TMultibaseEncoding.Base64Url,
    'ueWVzIG1hbmkgIQ');
  LVectors[17] := TMultibaseVector.Create(TMultibaseEncoding.Base64UrlPad,
    'UeWVzIG1hbmkgIQ==');

  LInput := TEncoding.UTF8.GetBytes('yes mani !');
  for LI := Low(LVectors) to High(LVectors) do
  begin
    CheckEquals(LVectors[LI].Expected,
      TMultibase.Encode(LInput, LVectors[LI].Encoding));
  end;
end;

procedure TTestMultibase.Test_Encode_OfficialZeroPrefixedEncodingData_EncodesDataCorrectly;
var
  LI: Int32;
  LInput: TSimpleBaseLibByteArray;
  LVectors: array [0 .. 17] of TMultibaseVector;
begin
  LVectors[0] := TMultibaseVector.Create(TMultibaseEncoding.Base2,
    '00000000001111001011001010111001100100000011011010110000101101110011010010010000000100001');
  LVectors[1] := TMultibaseVector.Create(TMultibaseEncoding.Base8,
    '7000745453462015530267151100204');
  LVectors[2] := TMultibaseVector.Create(TMultibaseEncoding.Base10,
    '90573277761329450583662625');
  LVectors[3] := TMultibaseVector.Create(TMultibaseEncoding.Base16Lower,
    'f00796573206d616e692021');
  LVectors[4] := TMultibaseVector.Create(TMultibaseEncoding.Base16Upper,
    'F00796573206D616E692021');
  LVectors[5] := TMultibaseVector.Create(TMultibaseEncoding.Base32Lower,
    'bab4wk4zanvqw42jaee');
  LVectors[6] := TMultibaseVector.Create(TMultibaseEncoding.Base32Upper,
    'BAB4WK4ZANVQW42JAEE');
  LVectors[7] := TMultibaseVector.Create(TMultibaseEncoding.Base32HexLower,
    'v01smasp0dlgmsq9044');
  LVectors[8] := TMultibaseVector.Create(TMultibaseEncoding.Base32HexUpper,
    'V01SMASP0DLGMSQ9044');
  LVectors[9] := TMultibaseVector.Create(TMultibaseEncoding.Base32Z,
    'hybhskh3ypiosh4jyrr');
  LVectors[10] := TMultibaseVector.Create(TMultibaseEncoding.Base36Lower,
    'k02lcpzo5yikidynfl');
  LVectors[11] := TMultibaseVector.Create(TMultibaseEncoding.Base36Upper,
    'K02LCPZO5YIKIDYNFL');
  LVectors[12] := TMultibaseVector.Create(TMultibaseEncoding.Base58Flickr,
    'Z17Pznk19XTTzBtx');
  LVectors[13] := TMultibaseVector.Create(TMultibaseEncoding.Base58Bitcoin,
    'z17paNL19xttacUY');
  LVectors[14] := TMultibaseVector.Create(TMultibaseEncoding.Base64,
    'mAHllcyBtYW5pICE');
  LVectors[15] := TMultibaseVector.Create(TMultibaseEncoding.Base64Pad,
    'MAHllcyBtYW5pICE=');
  LVectors[16] := TMultibaseVector.Create(TMultibaseEncoding.Base64Url,
    'uAHllcyBtYW5pICE');
  LVectors[17] := TMultibaseVector.Create(TMultibaseEncoding.Base64UrlPad,
    'UAHllcyBtYW5pICE=');

  LInput := TEncoding.UTF8.GetBytes(#0 + 'yes mani !');
  for LI := Low(LVectors) to High(LVectors) do
  begin
    CheckEquals(LVectors[LI].Expected,
      TMultibase.Encode(LInput, LVectors[LI].Encoding));
  end;
end;

procedure TTestMultibase.Test_Encode_EncodedDataDecodesBack;
var
  LI: Int32;
  LInput, LDecoded: TSimpleBaseLibByteArray;
  LEncoded: String;
begin
  LInput := TEncoding.UTF8.GetBytes('SSG WAS HERE !!' + #$AB + #$CD + #$DE + #$FF);
  for LI := Low(SupportedEncodings) to High(SupportedEncodings) do
  begin
    LEncoded := TMultibase.Encode(LInput, SupportedEncodings[LI]);
    LDecoded := TMultibase.Decode(LEncoded);
    CheckTrue(AreEqual(LInput, LDecoded));
  end;
end;

procedure TTestMultibase.Test_TryDecode_DecodesCorrectly;
const
  Encoded: array [0 .. 14] of String = (
    'f535347205741532048455245202121c2abc38dc39ec3bf',
    'F535347205741532048455245202121C2ABC38DC39EC3BF',
    'bknjuoicxifjsascfkjcsaijbykv4hdodt3b36',
    'BKNJUOICXIFJSASCFKJCSAIJBYKV4HDODT3B36',
    'vad9ke82n859i0i25a92i0891oals73e3jr1ru',
    'VAD9KE82N859I0I25A92I0891OALS73E3JR1RU',
    'k2p81m7y66k71a7teel1hfa4ldp6bneq0hj9b',
    'K2P81M7Y66K71A7TEEL1HFA4LDP6BNEQ0HJ9B',
    'hkpjwqenzefj1y1nfkjn1yejbakih8dqdu5b56',
    'R1OAS:8H1B+MA6691IAZ242C46WLL-H83KB4',
    'Z2HPxwKnQi8s2ugkrzPrrR6nyDEpMhoe6',
    'z2ipYXkNqJ8T2VGLSapSSr6NZefQnHPE6',
    'mU1NHIFdBUyBIRVJFICEhwqvDjcOew78',
    'MU1NHIFdBUyBIRVJFICEhwqvDjcOew78=',
    'uU1NHIFdBUyBIRVJFICEhwqvDjcOew78'
  );
var
  LI, LBytesWritten: Int32;
  LBytes: TSimpleBaseLibByteArray;
begin
  SetLength(LBytes, 1024);
  for LI := Low(Encoded) to High(Encoded) do
  begin
    CheckTrue(TMultibase.TryDecode(Encoded[LI], LBytes, LBytesWritten));
  end;
end;

procedure TTestMultibase.Test_Decode_EmptyString_Throws;
begin
  try
    TMultibase.Decode('');
    Fail('Expected EArgumentSimpleBaseLibException');
  except
    on EArgumentSimpleBaseLibException do
    begin
      // expected
    end;
  end;
end;

procedure TTestMultibase.Test_TryDecode_EmptyString_ReturnsFalse;
var
  LBytes: TSimpleBaseLibByteArray;
  LBytesWritten: Int32;
begin
  SetLength(LBytes, 1);
  CheckFalse(TMultibase.TryDecode('', LBytes, LBytesWritten));
end;

procedure TTestMultibase.Test_Decode_MixedCaseInput_DecodesCorrectly;
const
  Encoded: array [0 .. 7] of String = (
    'f68656c6c6f20776F726C64',
    'F68656c6c6f20776F726C64',
    'bnbswy3dpeB3W64TMMQ',
    'Bnbswy3dpeB3W64TMMQ',
    'Vd1imor3f41RMUSJCCG',
    'kfUvrsIvVnfRbjWaJo',
    'KfUVrSIVVnFRbJWAJo',
    'vd1imor3f41RMUSJCCG'
  );
var
  LI: Int32;
  LDecoded, LExpected: TSimpleBaseLibByteArray;
begin
  LExpected := TEncoding.UTF8.GetBytes('hello world');
  for LI := Low(Encoded) to High(Encoded) do
  begin
    LDecoded := TMultibase.Decode(Encoded[LI]);
    CheckTrue(AreEqual(LExpected, LDecoded));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestMultibase);
{$ELSE}
  RegisterTest(TTestMultibase.Suite);
{$ENDIF FPC}

end.
