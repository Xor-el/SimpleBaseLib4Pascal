unit SbpBase64Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpIBase64Alphabet;

type
  TBase64Alphabet = class sealed(TInterfacedObject, IBase64Alphabet)

  strict private
  const
    B64CharacterSet
      : String =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    class var

      FDefault, FDefaultNoPadding, FUrlEncoding, FXmlEncoding, FRegExEncoding,
      FFileEncoding: IBase64Alphabet;

  var
    FPaddingEnabled: Boolean;
    FEncodingTable: TSimpleBaseLibCharArray;
    FDecodingTable: TSimpleBaseLibByteArray;

    function GetPaddingEnabled: Boolean; inline;
    function GetEncodingTable: TSimpleBaseLibCharArray; inline;
    function GetDecodingTable: TSimpleBaseLibByteArray; inline;

    procedure CreateDecodingTable(const chars: TSimpleBaseLibCharArray); inline;
    class function GetDefault: IBase64Alphabet; static; inline;
    class function GetDefaultNoPadding: IBase64Alphabet; static; inline;
    class function GetFileEncoding: IBase64Alphabet; static; inline;
    class function GetRegExEncoding: IBase64Alphabet; static; inline;
    class function GetUrlEncoding: IBase64Alphabet; static; inline;
    class function GetXmlEncoding: IBase64Alphabet; static; inline;

    class constructor Base64Alphabet();

  public
    property EncodingTable: TSimpleBaseLibCharArray read GetEncodingTable;
    property DecodingTable: TSimpleBaseLibByteArray read GetDecodingTable;
    property PaddingEnabled: Boolean read GetPaddingEnabled;
    class property Default: IBase64Alphabet read GetDefault;
    class property DefaultNoPadding: IBase64Alphabet read GetDefaultNoPadding;
    class property UrlEncoding: IBase64Alphabet read GetUrlEncoding;
    class property XmlEncoding: IBase64Alphabet read GetXmlEncoding;
    class property RegExEncoding: IBase64Alphabet read GetRegExEncoding;
    class property FileEncoding: IBase64Alphabet read GetFileEncoding;
    constructor Create(const chars: String; plusChar, slashChar: Char;
      PaddingEnabled: Boolean);
    destructor Destroy; override;
  end;

implementation

{ TBase64Alphabet }

procedure TBase64Alphabet.CreateDecodingTable(const chars
  : TSimpleBaseLibCharArray);
var
  bytes: TSimpleBaseLibByteArray;
  idx: Int32;
begin
  System.SetLength(bytes, 123);
  for idx := System.Low(chars) to System.High(chars) do
  begin
    bytes[Byte(chars[idx])] := idx;
  end;

  FDecodingTable := bytes;
end;

class constructor TBase64Alphabet.Base64Alphabet;
begin
  FDefault := TBase64Alphabet.Create(B64CharacterSet, '+', '/', true);
  FDefaultNoPadding := TBase64Alphabet.Create(B64CharacterSet, '+', '/', false);
  FUrlEncoding := TBase64Alphabet.Create(B64CharacterSet, '-', '_', false);
  FXmlEncoding := TBase64Alphabet.Create(B64CharacterSet, '_', ':', false);
  FRegExEncoding := TBase64Alphabet.Create(B64CharacterSet, '!', '-', false);
  FFileEncoding := TBase64Alphabet.Create(B64CharacterSet, '+', '-', false);
end;

constructor TBase64Alphabet.Create(const chars: String;
  plusChar, slashChar: Char; PaddingEnabled: Boolean);
var
  idx, LowPoint, HighPoint: Int32;
  newChars: String;
begin
  Inherited Create();
  newChars := chars + plusChar + slashChar;
  System.SetLength(FEncodingTable, System.Length(newChars));
{$IFDEF DELPHIXE3_UP}
  LowPoint := System.Low(newChars);
  HighPoint := System.High(newChars);
{$ELSE}
  LowPoint := 1;
  HighPoint := System.Length(newChars);
{$ENDIF DELPHIXE3_UP}
  for idx := LowPoint to HighPoint do
  begin
    FEncodingTable[idx - 1] := newChars[idx];
  end;

  FPaddingEnabled := PaddingEnabled;
  CreateDecodingTable(FEncodingTable);

end;

destructor TBase64Alphabet.Destroy;
begin
  inherited Destroy;
end;

function TBase64Alphabet.GetDecodingTable: TSimpleBaseLibByteArray;
begin
  Result := FDecodingTable;
end;

class function TBase64Alphabet.GetDefault: IBase64Alphabet;
begin
  Result := FDefault;
end;

class function TBase64Alphabet.GetDefaultNoPadding: IBase64Alphabet;
begin
  Result := FDefaultNoPadding;
end;

function TBase64Alphabet.GetEncodingTable: TSimpleBaseLibCharArray;
begin
  Result := FEncodingTable;
end;

class function TBase64Alphabet.GetFileEncoding: IBase64Alphabet;
begin
  Result := FFileEncoding;
end;

function TBase64Alphabet.GetPaddingEnabled: Boolean;
begin
  Result := FPaddingEnabled;
end;

class function TBase64Alphabet.GetRegExEncoding: IBase64Alphabet;
begin
  Result := FRegExEncoding;
end;

class function TBase64Alphabet.GetUrlEncoding: IBase64Alphabet;
begin
  Result := FUrlEncoding;
end;

class function TBase64Alphabet.GetXmlEncoding: IBase64Alphabet;
begin
  Result := FXmlEncoding;
end;

end.
