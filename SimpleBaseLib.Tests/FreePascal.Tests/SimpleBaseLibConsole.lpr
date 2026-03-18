program SimpleBaseLib.Tests;

{$mode objfpc}{$H+}

uses
  consoletestrunner, SimpleBaseLibTestBase, Base36Tests, Base10Tests,
  Base16StreamRegressionTests, Base16Tests, Base2StreamRegressionTests,
  Base2Tests, Base32Tests, Base32StreamRegressionTests, Base32AlphabetTests,
  Rfc4648Tests, ExtendedHexTests, CrockfordTests, Base45Tests,
  Base45StreamRegressionTests, Base58Tests, Base58AlphabetTests, Base62Tests,
  Base8Tests, Base8StreamRegressionTests, Base85Tests,
  Base85StreamRegressionTests, BaseZ85Tests, Ascii85Tests,
  EncodingAlphabetTests, CodingAlphabetTests, BitsTests, MultibaseTests,
  Base64Tests, Base64StreamRegressionTests;

type

  { TSimpleBaseLibConsoleTestRunner }

  TSimpleBaseLibConsoleTestRunner = class(TTestRunner)
  protected
    // override the protected methods of TTestRunner to customize its behaviour
end;

var
Application: TSimpleBaseLibConsoleTestRunner;

begin
  Application := TSimpleBaseLibConsoleTestRunner.Create(nil);
  Application.Initialize;
  Application.Run;
  Application.Free;
end.
                                
