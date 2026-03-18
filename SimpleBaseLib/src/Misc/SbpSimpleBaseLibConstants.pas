unit SbpSimpleBaseLibConstants;

{$I ..\Include\SimpleBaseLib.inc}

interface

type
  TSimpleBaseLibConstants = class sealed(TObject)
  public
  const
    NullChar = #0;
    WhiteSpaceChar = #$20;
    WhiteSpaceNELChar = #$85;
    WhiteSpaceNBSPChar = #$A0;
    WhiteSpaceControlMinChar = #$09;
    WhiteSpaceControlMaxChar = #$0D;
  end;

implementation

end.
