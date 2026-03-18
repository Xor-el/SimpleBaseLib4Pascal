unit SbpBase85Alphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibConstants,
  SbpIBase85Alphabet,
  SbpCodingAlphabet;

type
  TBase85Alphabet = class(TCodingAlphabet, IBase85Alphabet)
  strict private
    FAllZeroShortcut: Char;
    FAllSpaceShortcut: Char;
    FHasAllZeroShortcut: Boolean;
    FHasAllSpaceShortcut: Boolean;

    class var FZ85: IBase85Alphabet;
    class var FAscii85: IBase85Alphabet;

    class function GetZ85: IBase85Alphabet; static;
    class function GetAscii85: IBase85Alphabet; static;

  strict protected
    function GetAllZeroShortcut: Char;
    function GetAllSpaceShortcut: Char;
    function GetHasAllZeroShortcut: Boolean;
    function GetHasAllSpaceShortcut: Boolean;
    function GetHasShortcut: Boolean;
  public
    class constructor Create;

    constructor Create(const AAlphabet: String); overload;
    constructor Create(const AAlphabet: String; AAllZeroShortcut, AAllSpaceShortcut: Char;
      AHasAllZeroShortcut, AHasAllSpaceShortcut: Boolean); overload;

    class property Z85: IBase85Alphabet read GetZ85;
    class property Ascii85: IBase85Alphabet read GetAscii85;

    property AllZeroShortcut: Char read GetAllZeroShortcut;
    property AllSpaceShortcut: Char read GetAllSpaceShortcut;
    property HasAllZeroShortcut: Boolean read GetHasAllZeroShortcut;
    property HasAllSpaceShortcut: Boolean read GetHasAllSpaceShortcut;
    property HasShortcut: Boolean read GetHasShortcut;
  end;

implementation

{ TBase85Alphabet }

class constructor TBase85Alphabet.Create;
begin
  FZ85 := nil;
  FAscii85 := nil;
end;

constructor TBase85Alphabet.Create(const AAlphabet: String);
begin
  inherited Create(85, AAlphabet);
  FAllZeroShortcut := TSimpleBaseLibConstants.NullChar;
  FAllSpaceShortcut := TSimpleBaseLibConstants.NullChar;
  FHasAllZeroShortcut := False;
  FHasAllSpaceShortcut := False;
end;

constructor TBase85Alphabet.Create(const AAlphabet: String; AAllZeroShortcut,
  AAllSpaceShortcut: Char; AHasAllZeroShortcut, AHasAllSpaceShortcut: Boolean);
begin
  Create(AAlphabet);
  FAllZeroShortcut := AAllZeroShortcut;
  FAllSpaceShortcut := AAllSpaceShortcut;
  FHasAllZeroShortcut := AHasAllZeroShortcut;
  FHasAllSpaceShortcut := AHasAllSpaceShortcut;
end;

class function TBase85Alphabet.GetZ85: IBase85Alphabet;
begin
  if FZ85 = nil then
  begin
    FZ85 := TBase85Alphabet.Create(
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#');
  end;
  Result := FZ85;
end;

class function TBase85Alphabet.GetAscii85: IBase85Alphabet;
begin
  if FAscii85 = nil then
  begin
    FAscii85 := TBase85Alphabet.Create(
      '!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstu',
      'z', 'y', True, True);
  end;
  Result := FAscii85;
end;

function TBase85Alphabet.GetAllZeroShortcut: Char;
begin
  Result := FAllZeroShortcut;
end;

function TBase85Alphabet.GetAllSpaceShortcut: Char;
begin
  Result := FAllSpaceShortcut;
end;

function TBase85Alphabet.GetHasAllZeroShortcut: Boolean;
begin
  Result := FHasAllZeroShortcut;
end;

function TBase85Alphabet.GetHasAllSpaceShortcut: Boolean;
begin
  Result := FHasAllSpaceShortcut;
end;

function TBase85Alphabet.GetHasShortcut: Boolean;
begin
  Result := FHasAllZeroShortcut or FHasAllSpaceShortcut;
end;

end.
