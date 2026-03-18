unit SbpCodingAlphabet;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils,
  SbpSimpleBaseLibTypes,
  SbpICodingAlphabet,
  SbpCharUtilities;

type
  /// <summary>
  /// Base class for ASCII-only coding alphabets with reverse lookup support
  /// </summary>
  TCodingAlphabet = class(TInterfacedObject, ICodingAlphabet)
  strict private
  const
    MaxAlphabetChar = 127;
  var
    FValue: String;
    FLength: Int32;
    FReverseLookupTable: TSimpleBaseLibByteArray;

  strict protected
    function GetValue: String;
    function GetLength: Int32;
    function GetReverseLookupTable: TSimpleBaseLibByteArray;
    /// <summary>
    /// Map a character to a value index.
    /// </summary>
    procedure Map(AChar: Char; AValue: Int32);
  public
    constructor Create(ALength: Int32; const AAlphabet: String; const ACaseInsensitive: Boolean = False);

    function ToString: String; override;
    function GetHashCode: {$IFDEF DELPHI}Int32;{$ELSE}PtrInt;{$ENDIF DELPHI}override;

    property Value: String read GetValue;
    property Length: Int32 read GetLength;
    property ReverseLookupTable: TSimpleBaseLibByteArray read GetReverseLookupTable;
  end;

implementation

{ TCodingAlphabet }

constructor TCodingAlphabet.Create(ALength: Int32; const AAlphabet: String;
  const ACaseInsensitive: Boolean);
var
  LI: Int32;
  LChar, LCounterpart: Char;
begin
  inherited Create;

  if System.Length(AAlphabet) <> ALength then
  begin
    raise EArgumentSimpleBaseLibException.CreateFmt
      ('Required alphabet length is %d but provided alphabet is %d characters long',
      [ALength, System.Length(AAlphabet)]);
  end;

  FLength := ALength;
  FValue := AAlphabet;

  System.SetLength(FReverseLookupTable, MaxAlphabetChar);

  for LI := 0 to FLength - 1 do
  begin
    LChar := FValue[LI + 1];

    if ACaseInsensitive and TCharUtilities.IsLetter(LChar) then
    begin
      if TCharUtilities.IsAsciiUpper(LChar) then
      begin
        LCounterpart := TCharUtilities.ToAsciiLower(LChar);
      end
      else
      begin
        LCounterpart := TCharUtilities.ToAsciiUpper(LChar);
      end;

      if System.Pos(LCounterpart, FValue) <> 0 then
      begin
        raise EArgumentSimpleBaseLibException.Create
          ('Case-sensitivity cannot be selected with an alphabet that contains both cases of the same letter');
      end;

      Map(LCounterpart, LI);
    end;

    Map(LChar, LI);
  end;
end;

function TCodingAlphabet.GetLength: Int32;
begin
  Result := FLength;
end;

function TCodingAlphabet.GetReverseLookupTable: TSimpleBaseLibByteArray;
begin
  Result := FReverseLookupTable;
end;

function TCodingAlphabet.GetValue: String;
begin
  Result := FValue;
end;

function TCodingAlphabet.ToString: String;
begin
  Result := FValue;
end;

function TCodingAlphabet.GetHashCode: {$IFDEF DELPHI}Int32;{$ELSE}PtrInt;{$ENDIF DELPHI}
var
  LHash: UInt32;
  LChar: Char;
begin
  // Simple FNV-1a style hash over the alphabet value.
  LHash := 2166136261;
  for LChar in FValue do
  begin
    LHash := LHash xor Ord(LChar);
    LHash := LHash * 16777619;
  end;
  Result := Int32(LHash);
end;

procedure TCodingAlphabet.Map(AChar: Char; AValue: Int32);
begin
{$IFDEF DEBUG}
 Assert(Ord(AChar) < MaxAlphabetChar, Format('Alphabet contains character above %d', [MaxAlphabetChar]));
{$ENDIF DEBUG}
 FReverseLookupTable[Ord(AChar)] := Byte(AValue + 1);
end;

end.

