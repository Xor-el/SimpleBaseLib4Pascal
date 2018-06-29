unit uBenchmark;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  Math,
  SysUtils,
  Classes,
  uBase64,
  SbpBase64,
  SbpIBase64,
  uStringGenerator;

type

  TStringArray = array of string;
  TBytesArray = array of TBytes;

type
  TBenchmark = class sealed(TObject)

  strict private
  class var

    FContainer: TStringArray;
    FBytesContainer: TBytesArray;

  public

    class procedure GenerateString(array_length: Int32);
    class procedure Benchmark();

  end;

implementation

{ TBenchmark }

class procedure TBenchmark.Benchmark;
var
  i: Int32;
  a, b: UInt32;
  Encoded: TStringArray;
  Decoded: TBytesArray;
  b64: IBase64;
  temp: TBytes;

begin
  b64 := TBase64.Default;
  SetLength(Encoded, Length(FContainer));
  SetLength(Decoded, Length(Encoded));
  Writeln('Starting Benchmark' + sLineBreak);
  Writeln('Benchmarking Default RTL Encode Implementation' + sLineBreak);
  a := TThread.GetTickCount;
  for i := Low(FBytesContainer) to High(FBytesContainer) do
  begin
    Encoded[i] := TRTLBase64.Encode(FBytesContainer[i]);
  end;
  b := TThread.GetTickCount;
  Writeln('Finished Benchmarking Default RTL Encode Implementation' +
    sLineBreak);
  Writeln(Format('RTL Encode Implementation Took %d milliseconds', [(b - a)]) +
    sLineBreak);

  Writeln('Asserting RTL Encode = SimpleBaseLib Encode' + sLineBreak);
  for i := Low(FBytesContainer) to High(FBytesContainer) do
  begin

    Assert(StringReplace(Encoded[i], sLineBreak, '', [rfReplaceAll])
      = b64.Encode(FBytesContainer[i]));
  end;
  Writeln('Finished Asserting RTL Encode = SimpleBaseLib Encode' + sLineBreak);

  Writeln('Benchmarking Default RTL Decode Implementation' + sLineBreak);
  a := TThread.GetTickCount;
  for i := Low(Encoded) to High(Encoded) do
  begin
    Decoded[i] := TRTLBase64.Decode(Encoded[i]);
  end;
  b := TThread.GetTickCount;
  Writeln('Finished Benchmarking Default RTL Decode Implementation' +
    sLineBreak);
  Writeln(Format('RTL Decode Implementation Took %d milliseconds', [(b - a)]) +
    sLineBreak);

  Writeln('Asserting RTL Decode = SimpleBaseLib Decode' + sLineBreak);
  for i := Low(Encoded) to High(Encoded) do
  begin
    temp := b64.Decode(StringReplace(Encoded[i], sLineBreak, '',
      [rfReplaceAll]));

    Assert(CompareMem(Decoded[i], temp, System.Length(Decoded[i]) *
      System.SizeOf(Byte)));
  end;
  Writeln('Finished Asserting RTL Decode = SimpleBaseLib Decode' + sLineBreak);

  Writeln('Benchmarking SimpleBase4Pascal Encode Implementation' + sLineBreak);
  a := TThread.GetTickCount;
  for i := Low(FBytesContainer) to High(FBytesContainer) do
  begin
    Encoded[i] := b64.Encode(FBytesContainer[i]);
  end;
  b := TThread.GetTickCount;
  Writeln('Finished Benchmarking SimpleBase4Pascal Encode Implementation' +
    sLineBreak);
  Writeln(Format('SimpleBase4Pascal Encode Implementation Took %d milliseconds',
    [(b - a)]) + sLineBreak);

  Writeln('Benchmarking SimpleBase4Pascal Decode Implementation' + sLineBreak);
  a := TThread.GetTickCount;
  for i := Low(Encoded) to High(Encoded) do
  begin
    Decoded[i] := b64.Decode(Encoded[i]);
  end;
  b := TThread.GetTickCount;
  Writeln('Finished Benchmarking SimpleBase4Pascal Decode Implementation' +
    sLineBreak);
  Writeln(Format('SimpleBase4Pascal Decode Implementation Took %d milliseconds',
    [(b - a)]) + sLineBreak);

end;

class procedure TBenchmark.GenerateString(array_length: Int32);
var
  i: Int32;
begin
  System.SetLength(FContainer, array_length);
  System.SetLength(FBytesContainer, array_length);
  Writeln('Generating Test Data' + sLineBreak);
  Writeln('This may take some time. please be patient' + sLineBreak);
  for i := Low(FContainer) to High(FContainer) do
  begin
    FContainer[i] := TStringGenerator.GetRandom(RandomRange(10, 1000),
      Boolean(RandomRange(0, 2)));
  end;

  for i := Low(FBytesContainer) to High(FBytesContainer) do
  begin
    FBytesContainer[i] := TEncoding.ASCII.GetBytes(FContainer[i]);
  end;

  Writeln('Finished Generating Test Data' + sLineBreak);
end;

end.
