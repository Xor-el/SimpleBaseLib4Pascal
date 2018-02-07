program SimpleBaseLib.Tests;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms,
  GuiTestRunner,
  Base16Tests,
  CrockfordTests,
  ExtendedHexTests,
  Rfc4648Tests,
  Base58AlphabetTests,
  Base58Tests,
  Base64Tests;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

