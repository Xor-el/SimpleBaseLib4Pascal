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

{$IFNDEF TESTINSIGHT}
  {$IFDEF CONSOLE_TESTRUNNER}
    {$APPTYPE CONSOLE}
  {$ENDIF}
{$ENDIF}

uses
{$IFDEF TESTINSIGHT}
  TestInsight.DUnit,
{$ELSE}
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
{$ENDIF }
  SbpBitOperations in '..\..\SimpleBaseLib\src\Misc\SbpBitOperations.pas',
  SbpBinaryPrimitives in '..\..\SimpleBaseLib\src\Misc\SbpBinaryPrimitives.pas',
  SbpSimpleBaseLibTypes in '..\..\SimpleBaseLib\src\Misc\SbpSimpleBaseLibTypes.pas',
  SbpBits in '..\..\SimpleBaseLib\src\Misc\SbpBits.pas',
  SbpCharUtilities in '..\..\SimpleBaseLib\src\Utilities\SbpCharUtilities.pas',
  SbpStreamUtilities in '..\..\SimpleBaseLib\src\Utilities\SbpStreamUtilities.pas',
  SbpArrayUtilities in '..\..\SimpleBaseLib\src\Utilities\SbpArrayUtilities.pas',
  SbpBase16Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase16Alphabet.pas',
  SbpCodingAlphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpCodingAlphabet.pas',
  SbpBase16 in '..\..\SimpleBaseLib\src\Bases\SbpBase16.pas',
  SbpIBase16Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase16Alphabet.pas',
  SbpICodingAlphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpICodingAlphabet.pas',
  SbpIBase16 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase16.pas',
  SbpIBaseCoder in '..\..\SimpleBaseLib\src\Interfaces\Coders\SbpIBaseCoder.pas',
  SbpIBaseStreamCoder in '..\..\SimpleBaseLib\src\Interfaces\Coders\SbpIBaseStreamCoder.pas',
  SbpINonAllocatingBaseCoder in '..\..\SimpleBaseLib\src\Interfaces\Coders\SbpINonAllocatingBaseCoder.pas',
  SbpDividingCoder in '..\..\SimpleBaseLib\src\Coders\SbpDividingCoder.pas',
  SbpIDividingCoder in '..\..\SimpleBaseLib\src\Interfaces\Coders\SbpIDividingCoder.pas',
  SbpBase10Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase10Alphabet.pas',
  SbpBase36Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase36Alphabet.pas',
  SbpBase62Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase62Alphabet.pas',
  SbpBase2 in '..\..\SimpleBaseLib\src\Bases\SbpBase2.pas',
  SbpBase8 in '..\..\SimpleBaseLib\src\Bases\SbpBase8.pas',
  SbpBase10 in '..\..\SimpleBaseLib\src\Bases\SbpBase10.pas',
  SbpBase36 in '..\..\SimpleBaseLib\src\Bases\SbpBase36.pas',
  SbpBase62 in '..\..\SimpleBaseLib\src\Bases\SbpBase62.pas',
  SbpIBase10Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase10Alphabet.pas',
  SbpIBase36Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase36Alphabet.pas',
  SbpIBase62Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase62Alphabet.pas',
  SbpIBase2 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase2.pas',
  SbpIBase8 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase8.pas',
  SbpIBase10 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase10.pas',
  SbpIBase36 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase36.pas',
  SbpIBase62 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase62.pas',
  SbpBase58Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase58Alphabet.pas',
  SbpBase58 in '..\..\SimpleBaseLib\src\Bases\SbpBase58.pas',
  SbpMoneroBase58 in '..\..\SimpleBaseLib\src\Bases\SbpMoneroBase58.pas',
  SbpIBase58Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase58Alphabet.pas',
  SbpIBase58 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase58.pas',
  SbpIMoneroBase58 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIMoneroBase58.pas',
  SbpSimpleBaseLibConstants in '..\..\SimpleBaseLib\src\Misc\SbpSimpleBaseLibConstants.pas',
  SbpBase45Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase45Alphabet.pas',
  SbpBase45 in '..\..\SimpleBaseLib\src\Bases\SbpBase45.pas',
  SbpIBase45Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase45Alphabet.pas',
  SbpIBase45 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase45.pas',
  SbpPlatformUtilities in '..\..\SimpleBaseLib\src\Utilities\SbpPlatformUtilities.pas',
  SbpAliasedBase32Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpAliasedBase32Alphabet.pas',
  SbpBase32Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase32Alphabet.pas',
  SbpBase32 in '..\..\SimpleBaseLib\src\Bases\SbpBase32.pas',
  SbpIBase32 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase32.pas',
  SbpIBase32Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase32Alphabet.pas',
  SbpIAliasedBase32Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIAliasedBase32Alphabet.pas',
  SbpCharMap in '..\..\SimpleBaseLib\src\Misc\SbpCharMap.pas',
  SbpPaddingPosition in '..\..\SimpleBaseLib\src\Misc\SbpPaddingPosition.pas',
  SbpINumericBaseCoder in '..\..\SimpleBaseLib\src\Interfaces\Coders\SbpINumericBaseCoder.pas',
  SbpBase85Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase85Alphabet.pas',
  SbpBase85 in '..\..\SimpleBaseLib\src\Bases\SbpBase85.pas',
  SbpIBase85Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase85Alphabet.pas',
  SbpIBase85 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase85.pas',
  SbpBase64Alphabet in '..\..\SimpleBaseLib\src\Alphabets\SbpBase64Alphabet.pas',
  SbpIBase64Alphabet in '..\..\SimpleBaseLib\src\Interfaces\Alphabets\SbpIBase64Alphabet.pas',
  SbpIBase64 in '..\..\SimpleBaseLib\src\Interfaces\Bases\SbpIBase64.pas',
  SbpBase64 in '..\..\SimpleBaseLib\src\Bases\SbpBase64.pas',
  SbpMultibase in '..\..\SimpleBaseLib\src\Bases\SbpMultibase.pas',
  SbpMultibaseEncoding in '..\..\SimpleBaseLib\src\Misc\SbpMultibaseEncoding.pas',
  SimpleBaseLibTestBase in '..\src\SimpleBaseLibTestBase.pas',
  BitsTests in '..\src\Misc\BitsTests.pas',
  CodingAlphabetTests in '..\src\Misc\CodingAlphabetTests.pas',
  EncodingAlphabetTests in '..\src\Misc\EncodingAlphabetTests.pas',
  MultibaseTests in '..\src\Multibase\MultibaseTests.pas',
  Base10Tests in '..\src\Base10\Base10Tests.pas',
  Base16Tests in '..\src\Base16\Base16Tests.pas',
  Base32AlphabetTests in '..\src\Base32\Base32AlphabetTests.pas',
  Base32StreamRegressionTests in '..\src\Base32\Base32StreamRegressionTests.pas',
  Base32Tests in '..\src\Base32\Base32Tests.pas',
  Base36Tests in '..\src\Base36\Base36Tests.pas',
  Base62Tests in '..\src\Base62\Base62Tests.pas',
  Base58Tests in '..\src\Base58\Base58Tests.pas',
  Base2Tests in '..\src\Base2\Base2Tests.pas',
  Base2StreamRegressionTests in '..\src\Base2\Base2StreamRegressionTests.pas',
  Base16StreamRegressionTests in '..\src\Base16\Base16StreamRegressionTests.pas',
  Base45Tests in '..\src\Base45\Base45Tests.pas',
  Base45StreamRegressionTests in '..\src\Base45\Base45StreamRegressionTests.pas',
  Base85Tests in '..\src\Base85\Base85Tests.pas',
  Base85StreamRegressionTests in '..\src\Base85\Base85StreamRegressionTests.pas',
  Base8Tests in '..\src\Base8\Base8Tests.pas',
  Base8StreamRegressionTests in '..\src\Base8\Base8StreamRegressionTests.pas',
  Base64Tests in '..\src\Base64\Base64Tests.pas',
  Base64StreamRegressionTests in '..\src\Base64\Base64StreamRegressionTests.pas';

begin

{$IFDEF TESTINSIGHT}
   TestInsight.DUnit.RunRegisteredTests;
{$ELSE}
  Application.Initialize;
  if IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
{$ENDIF}

end.
