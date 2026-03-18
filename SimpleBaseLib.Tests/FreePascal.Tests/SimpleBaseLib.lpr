program SimpleBaseLib.Tests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, Base16Tests, Base16StreamRegressionTests,
  Base32Tests,
  Base32StreamRegressionTests, Base32AlphabetTests,
  Base58Tests, Base64Tests, Base64StreamRegressionTests,
  Base85Tests, Base85StreamRegressionTests, MultibaseTests,
  EncodingAlphabetTests, CodingAlphabetTests, BitsTests, Base8Tests,
  Base8StreamRegressionTests, Base62Tests, Base45Tests,
  Base45StreamRegressionTests, Base2StreamRegressionTests, Base2Tests,
  Base10Tests, Base36Tests;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

