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
  Base64Tests,
  Ascii85Tests,
  BaseZ85Tests;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

