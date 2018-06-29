program Benchmark;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  SbpSimpleBaseLibTypes in '..\..\SimpleBaseLib\src\Utils\SbpSimpleBaseLibTypes.pas',
  SbpBase58Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase58Alphabet.pas',
  SbpIBase58Alphabet in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase58Alphabet.pas',
  SbpBase58 in '..\..\SimpleBaseLib\src\Bases\SbpBase58.pas',
  SbpIBase58 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase58.pas',
  SbpBits in '..\..\SimpleBaseLib\src\Utils\SbpBits.pas',
  SbpBase16 in '..\..\SimpleBaseLib\src\Bases\SbpBase16.pas',
  SbpBase32Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase32Alphabet.pas',
  SbpIBase32Alphabet in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase32Alphabet.pas',
  SbpCrockfordBase32Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpCrockfordBase32Alphabet.pas',
  SbpICrockfordBase32Alphabet in '..\..\SimpleBaseLib\src\Interfaces\SbpICrockfordBase32Alphabet.pas',
  SbpBase32 in '..\..\SimpleBaseLib\src\Bases\SbpBase32.pas',
  SbpIBase32 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase32.pas',
  SbpBase64Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase64Alphabet.pas',
  SbpIBase64Alphabet in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase64Alphabet.pas',
  SbpBase64 in '..\..\SimpleBaseLib\src\Bases\SbpBase64.pas',
  SbpIBase64 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase64.pas',
  SbpUtilities in '..\..\SimpleBaseLib\src\Utils\SbpUtilities.pas',
  SbpEncodingAlphabet in '..\..\SimpleBaseLib\src\Bases\SbpEncodingAlphabet.pas',
  SbpIEncodingAlphabet in '..\..\SimpleBaseLib\src\Interfaces\SbpIEncodingAlphabet.pas',
  SbpBase85Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase85Alphabet.pas',
  SbpIBase85Alphabet in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase85Alphabet.pas',
  SbpIBase85 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase85.pas',
  SbpBase85 in '..\..\SimpleBaseLib\src\Bases\SbpBase85.pas',
  uBenchmark in '..\src\uBenchmark.pas',
  uBase64 in '..\src\uBase64.pas',
  uStringGenerator in '..\src\uStringGenerator.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Randomize;
    TBenchmark.GenerateString(100000);
    TBenchmark.Benchmark;
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
