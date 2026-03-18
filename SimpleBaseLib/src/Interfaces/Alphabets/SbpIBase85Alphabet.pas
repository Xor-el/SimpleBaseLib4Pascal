unit SbpIBase85Alphabet;

{$I ..\..\Include\SimpleBaseLib.inc}

interface

uses
  SbpICodingAlphabet;

type
  IBase85Alphabet = interface(ICodingAlphabet)
    ['{39F7A271-9190-4104-9D4B-8B90CB611408}']
    function GetAllZeroShortcut: Char;
    function GetAllSpaceShortcut: Char;
    function GetHasAllZeroShortcut: Boolean;
    function GetHasAllSpaceShortcut: Boolean;
    function GetHasShortcut: Boolean;

    property AllZeroShortcut: Char read GetAllZeroShortcut;
    property AllSpaceShortcut: Char read GetAllSpaceShortcut;
    property HasAllZeroShortcut: Boolean read GetHasAllZeroShortcut;
    property HasAllSpaceShortcut: Boolean read GetHasAllSpaceShortcut;
    property HasShortcut: Boolean read GetHasShortcut;
  end;

implementation

end.
