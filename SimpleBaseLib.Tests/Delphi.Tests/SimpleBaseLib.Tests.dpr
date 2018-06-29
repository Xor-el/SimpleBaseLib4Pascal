program SimpleBaseLib.Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$WARN DUPLICATE_CTOR_DTOR OFF}
{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  SbpSimpleBaseLibTypes
    in '..\..\SimpleBaseLib\src\Utils\SbpSimpleBaseLibTypes.pas',
  SbpBase58Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase58Alphabet.pas',
  SbpIBase58Alphabet
    in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase58Alphabet.pas',
  SbpBase58 in '..\..\SimpleBaseLib\src\Bases\SbpBase58.pas',
  SbpIBase58 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase58.pas',
  SbpBits in '..\..\SimpleBaseLib\src\Utils\SbpBits.pas',
  SbpBase16 in '..\..\SimpleBaseLib\src\Bases\SbpBase16.pas',
  SbpBase32Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase32Alphabet.pas',
  SbpIBase32Alphabet
    in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase32Alphabet.pas',
  SbpCrockfordBase32Alphabet
    in '..\..\SimpleBaseLib\src\Bases\SbpCrockfordBase32Alphabet.pas',
  SbpICrockfordBase32Alphabet
    in '..\..\SimpleBaseLib\src\Interfaces\SbpICrockfordBase32Alphabet.pas',
  SbpBase32 in '..\..\SimpleBaseLib\src\Bases\SbpBase32.pas',
  SbpIBase32 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase32.pas',
  SbpBase64Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase64Alphabet.pas',
  SbpIBase64Alphabet
    in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase64Alphabet.pas',
  SbpBase64 in '..\..\SimpleBaseLib\src\Bases\SbpBase64.pas',
  SbpIBase64 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase64.pas',
  SbpUtilities in '..\..\SimpleBaseLib\src\Utils\SbpUtilities.pas',
  Base58AlphabetTests in '..\src\Base58\Base58AlphabetTests.pas',
  Base58Tests in '..\src\Base58\Base58Tests.pas',
  Base16Tests in '..\src\Base16\Base16Tests.pas',
  CrockfordTests in '..\src\Base32\CrockfordTests.pas',
  Rfc4648Tests in '..\src\Base32\Rfc4648Tests.pas',
  ExtendedHexTests in '..\src\Base32\ExtendedHexTests.pas',
  Base64Tests in '..\src\Base64\Base64Tests.pas',
  SbpEncodingAlphabet
    in '..\..\SimpleBaseLib\src\Bases\SbpEncodingAlphabet.pas',
  SbpIEncodingAlphabet
    in '..\..\SimpleBaseLib\src\Interfaces\SbpIEncodingAlphabet.pas',
  SbpBase85Alphabet in '..\..\SimpleBaseLib\src\Bases\SbpBase85Alphabet.pas',
  SbpIBase85Alphabet
    in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase85Alphabet.pas',
  SbpIBase85 in '..\..\SimpleBaseLib\src\Interfaces\SbpIBase85.pas',
  SbpBase85 in '..\..\SimpleBaseLib\src\Bases\SbpBase85.pas',
  BaseZ85Tests in '..\src\Base85\BaseZ85Tests.pas',
  Ascii85Tests in '..\src\Base85\Ascii85Tests.pas';

begin
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;

end.
