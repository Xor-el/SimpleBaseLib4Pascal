unit SbpStreamUtilities;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  Classes,
  SysUtils,
  SbpSimpleBaseLibTypes;

type

  /// <summary>
  /// Provides Stream functionality to any buffer-based encoding operation.
  /// </summary>
  TStreamUtilities = class sealed(TObject)
  strict private
  const
    DefaultBufferSize = Int32(4096);
  public
    class function GetAlignedBufferSize(ABlockSize: Int32;
      ADefaultBufferSize: Int32 = DefaultBufferSize): Int32; static;

    class procedure Encode(const AInput: TStream; const AOutput: TStringBuilder;
      const ABufferEncodeFunc: TSimpleBaseLibMethodFunc<TSimpleBaseLibByteArray, Boolean, String>;
      ABufferSize: Int32 = DefaultBufferSize); static;

    class procedure Decode(const AInput: TStringBuilder; const AOutput: TStream;
      const ADecodeBufferFunc: TSimpleBaseLibMethodFunc<String, TSimpleBaseLibByteArray>;
      ABufferSize: Int32 = DefaultBufferSize); static;
  end;

implementation

{ TStreamUtilities }

class function TStreamUtilities.GetAlignedBufferSize(ABlockSize: Int32;
  ADefaultBufferSize: Int32): Int32;
begin
  if ABlockSize < 1 then
  begin
    raise EArgumentOutOfRangeSimpleBaseLibException.Create(
      'Block size must be positive');
  end;
  if ADefaultBufferSize < 1 then
  begin
    raise EArgumentOutOfRangeSimpleBaseLibException.Create(
      'Default buffer size must be positive');
  end;

  Result := ADefaultBufferSize - (ADefaultBufferSize mod ABlockSize);
  if Result = 0 then
  begin
    Result := ABlockSize;
  end;
end;

class procedure TStreamUtilities.Encode(const AInput: TStream;
  const AOutput: TStringBuilder;
  const ABufferEncodeFunc: TSimpleBaseLibMethodFunc<TSimpleBaseLibByteArray, Boolean, String>;
  ABufferSize: Int32);
var
  LBuffer: TSimpleBaseLibByteArray;
  LBytesRead: Int32;
  LResult: String;
  LChunk: TSimpleBaseLibByteArray;
begin
  System.SetLength(LBuffer, ABufferSize);
  while True do
  begin
    LBytesRead := AInput.Read(LBuffer[0], ABufferSize);
    if LBytesRead < 1 then
    begin
      Break;
    end;

    if LBytesRead < ABufferSize then
    begin
      LChunk := System.Copy(LBuffer, 0, LBytesRead);
    end
    else
    begin
      LChunk := LBuffer;
    end;

    LResult := ABufferEncodeFunc(LChunk, LBytesRead < ABufferSize);
    AOutput.Append(LResult);
  end;
end;

class procedure TStreamUtilities.Decode(const AInput: TStringBuilder;
  const AOutput: TStream;
  const ADecodeBufferFunc: TSimpleBaseLibMethodFunc<String, TSimpleBaseLibByteArray>;
  ABufferSize: Int32);
var
  LBuffer: TSimpleBaseLibCharArray;
  LOffset, LCharsRead, LRemaining: Int32;
  LResult: TSimpleBaseLibByteArray;
  LText: String;
begin
  System.SetLength(LBuffer, ABufferSize);
  LOffset := 0;
  while LOffset < AInput.Length do
  begin
    LRemaining := AInput.Length - LOffset;
    if LRemaining > ABufferSize then
      LCharsRead := ABufferSize
    else
      LCharsRead := LRemaining;

    AInput.CopyTo(LOffset, LBuffer, 0, LCharsRead);
    LOffset := LOffset + LCharsRead;

    if LCharsRead < 1 then
    begin
      Break;
    end;

    SetString(LText, PChar(@LBuffer[0]), LCharsRead);
    LResult := ADecodeBufferFunc(LText);
    if System.Length(LResult) > 0 then
      AOutput.Write(LResult[0], System.Length(LResult));
  end;
end;

end.
