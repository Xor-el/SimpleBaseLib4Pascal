unit SbpMultibase;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpMultibaseEncoding,
  SbpBase2,
  SbpBase8,
  SbpBase10,
  SbpBase16,
  SbpBase32,
  SbpBase36,
  SbpBase45,
  SbpBase58,
  SbpBase64;

type
  TMultibase = class sealed(TObject)
  strict private
    class function TryDecodeBase64Pad(const AText: String;
      const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean; static;
  public
    class function Decode(const AText: String): TSimpleBaseLibByteArray; static;
    class function TryDecode(const AText: String;
      const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean; static;
    class function Encode(const ABytes: TSimpleBaseLibByteArray;
      AEncoding: TMultibaseEncoding): String; static;
  end;

implementation

class function TMultibase.Decode(const AText: String): TSimpleBaseLibByteArray;
var
  LC: Char;
  LRest: String;
  LEncoding: TMultibaseEncoding;
begin
  if System.Length(AText) = 0 then
  begin
    raise EArgumentSimpleBaseLibException.Create('Text cannot be empty');
  end;

  LC := AText[1];
  LEncoding := TMultibaseEncoding(Ord(LC));
  LRest := System.Copy(AText, 2, MaxInt);

  case LEncoding of
    TMultibaseEncoding.Base2:
      Result := TBase2.Default.Decode(LRest);
    TMultibaseEncoding.Base8:
      Result := TBase8.Default.Decode(LRest);
    TMultibaseEncoding.Base10:
      Result := TBase10.Default.Decode(LRest);
    TMultibaseEncoding.Base16Lower:
      Result := TBase16.LowerCase.Decode(LRest);
    TMultibaseEncoding.Base16Upper:
      Result := TBase16.UpperCase.Decode(LRest);
    TMultibaseEncoding.Base32Lower:
      Result := TBase32.FileCoin.Decode(LRest);
    TMultibaseEncoding.Base32Upper:
      Result := TBase32.Rfc4648.Decode(LRest);
    TMultibaseEncoding.Base32HexLower:
      Result := TBase32.ExtendedHexLower.Decode(LRest);
    TMultibaseEncoding.Base32HexUpper:
      Result := TBase32.ExtendedHex.Decode(LRest);
    TMultibaseEncoding.Base32Z:
      Result := TBase32.ZBase32.Decode(LRest);
    TMultibaseEncoding.Base36Lower:
      Result := TBase36.LowerCase.Decode(LRest);
    TMultibaseEncoding.Base36Upper:
      Result := TBase36.UpperCase.Decode(LRest);
    TMultibaseEncoding.Base45:
      Result := TBase45.Default.Decode(LRest);
    TMultibaseEncoding.Base58Bitcoin:
      Result := TBase58.Bitcoin.Decode(LRest);
    TMultibaseEncoding.Base58Flickr:
      Result := TBase58.Flickr.Decode(LRest);
    TMultibaseEncoding.Base64Pad:
      Result := TBase64.Default.Decode(LRest);
    TMultibaseEncoding.Base64:
      Result := TBase64.DefaultNoPad.Decode(LRest);
    TMultibaseEncoding.Base64Url:
      Result := TBase64.Url.Decode(LRest);
    TMultibaseEncoding.Base64UrlPad:
      Result := TBase64.UrlPadded.Decode(LRest);
  else
    raise EInvalidOperationSimpleBaseLibException.CreateFmt(
      'Unsupported multibase prefix: %s', [LC]);
  end;
end;

class function TMultibase.TryDecodeBase64Pad(const AText: String;
  const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
begin
  Result := TBase64.Default.TryDecode(AText, ABytes, ABytesWritten);
end;

class function TMultibase.TryDecode(const AText: String;
  const ABytes: TSimpleBaseLibByteArray; out ABytesWritten: Int32): Boolean;
var
  LC: Char;
  LRest: String;
  LEncoding: TMultibaseEncoding;
begin
  ABytesWritten := 0;
  if System.Length(AText) = 0 then
  begin
    Result := False;
    Exit;
  end;

  LC := AText[1];
  LEncoding := TMultibaseEncoding(Ord(LC));
  LRest := System.Copy(AText, 2, MaxInt);

  case LEncoding of
    TMultibaseEncoding.Base2:
      Result := TBase2.Default.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base8:
      Result := TBase8.Default.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base10:
      Result := TBase10.Default.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base16Lower:
      Result := TBase16.LowerCase.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base16Upper:
      Result := TBase16.UpperCase.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base32Lower:
      Result := TBase32.FileCoin.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base32Upper:
      Result := TBase32.Rfc4648.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base32HexLower:
      Result := TBase32.ExtendedHexLower.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base32HexUpper:
      Result := TBase32.ExtendedHex.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base32Z:
      Result := TBase32.ZBase32.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base36Lower:
      Result := TBase36.LowerCase.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base36Upper:
      Result := TBase36.UpperCase.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base45:
      Result := TBase45.Default.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base58Bitcoin:
      Result := TBase58.Bitcoin.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base58Flickr:
      Result := TBase58.Flickr.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base64:
      Result := TBase64.DefaultNoPad.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base64Pad:
      Result := TryDecodeBase64Pad(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base64Url:
      Result := TBase64.Url.TryDecode(LRest, ABytes, ABytesWritten);
    TMultibaseEncoding.Base64UrlPad:
      Result := TBase64.UrlPadded.TryDecode(LRest, ABytes, ABytesWritten);
  else
    Result := False;
  end;
end;

class function TMultibase.Encode(const ABytes: TSimpleBaseLibByteArray;
  AEncoding: TMultibaseEncoding): String;
begin
  Result := Char(Ord(AEncoding));
  case AEncoding of
    TMultibaseEncoding.Base2:
      Result := Result + TBase2.Default.Encode(ABytes);
    TMultibaseEncoding.Base8:
      Result := Result + TBase8.Default.Encode(ABytes);
    TMultibaseEncoding.Base10:
      Result := Result + TBase10.Default.Encode(ABytes);
    TMultibaseEncoding.Base16Lower:
      Result := Result + TBase16.LowerCase.Encode(ABytes);
    TMultibaseEncoding.Base16Upper:
      Result := Result + TBase16.UpperCase.Encode(ABytes);
    TMultibaseEncoding.Base32Lower:
      Result := Result + TBase32.FileCoin.Encode(ABytes);
    TMultibaseEncoding.Base32Upper:
      Result := Result + TBase32.Rfc4648.Encode(ABytes);
    TMultibaseEncoding.Base32HexLower:
      Result := Result + TBase32.ExtendedHexLower.Encode(ABytes);
    TMultibaseEncoding.Base32HexUpper:
      Result := Result + TBase32.ExtendedHex.Encode(ABytes);
    TMultibaseEncoding.Base32Z:
      Result := Result + TBase32.ZBase32.Encode(ABytes);
    TMultibaseEncoding.Base36Lower:
      Result := Result + TBase36.LowerCase.Encode(ABytes);
    TMultibaseEncoding.Base36Upper:
      Result := Result + TBase36.UpperCase.Encode(ABytes);
    TMultibaseEncoding.Base45:
      Result := Result + TBase45.Default.Encode(ABytes);
    TMultibaseEncoding.Base58Bitcoin:
      Result := Result + TBase58.Bitcoin.Encode(ABytes);
    TMultibaseEncoding.Base58Flickr:
      Result := Result + TBase58.Flickr.Encode(ABytes);
    TMultibaseEncoding.Base64:
      Result := Result + TBase64.DefaultNoPad.Encode(ABytes);
    TMultibaseEncoding.Base64Pad:
      Result := Result + TBase64.Default.Encode(ABytes);
    TMultibaseEncoding.Base64Url:
      Result := Result + TBase64.Url.Encode(ABytes);
    TMultibaseEncoding.Base64UrlPad:
      Result := Result + TBase64.UrlPadded.Encode(ABytes);
  else
    raise EArgumentSimpleBaseLibException.CreateFmt('Unsupported encoding type: %d',
      [Ord(AEncoding)]);
  end;
end;

end.
