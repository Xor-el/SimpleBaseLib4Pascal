program SimpleBaseLib.Tests;

{$mode objfpc}{$H+}

uses
  consoletestrunner,
  Base16Tests,
  CrockfordTests,
  ExtendedHexTests,
  Rfc4648Tests,
  Base58AlphabetTests,
  Base58Tests,
  Base64Tests,
  Ascii85Tests,
  BaseZ85Tests;

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
                                
