unit SbpSimpleBaseLibExceptions;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils;

type
  ESimpleBaseLibException = class(Exception);
  EInvalidCastSimpleBaseLibException = class(EInvalidCast);
  EArithmeticSimpleBaseLibException = class(ESimpleBaseLibException);
  EInvalidOperationSimpleBaseLibException = class(ESimpleBaseLibException);
  EInvalidParameterSimpleBaseLibException = class(ESimpleBaseLibException);
  EIndexOutOfRangeSimpleBaseLibException = class(ESimpleBaseLibException);
  EArgumentSimpleBaseLibException = class(ESimpleBaseLibException);
  EInvalidArgumentSimpleBaseLibException = class(ESimpleBaseLibException);
  EArgumentNilSimpleBaseLibException = class(ESimpleBaseLibException);
  EArgumentOutOfRangeSimpleBaseLibException = class(ESimpleBaseLibException);
  ENullReferenceSimpleBaseLibException = class(ESimpleBaseLibException);
  EUnsupportedTypeSimpleBaseLibException = class(ESimpleBaseLibException);
  EIOSimpleBaseLibException = class(ESimpleBaseLibException);
  EFormatSimpleBaseLibException = class(ESimpleBaseLibException);
  ENotImplementedSimpleBaseLibException = class(ESimpleBaseLibException);
  ENotSupportedSimpleBaseLibException = class(ESimpleBaseLibException);
  EEndOfStreamSimpleBaseLibException = class(EIOSimpleBaseLibException);

implementation

end.
