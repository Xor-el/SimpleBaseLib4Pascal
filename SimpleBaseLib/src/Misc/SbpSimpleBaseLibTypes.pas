unit SbpSimpleBaseLibTypes;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SysUtils;

type
  // Plain procedure pointer overloads
  TSimpleBaseLibProc = procedure;
  TSimpleBaseLibProc<T1> = procedure(Arg1: T1);
  TSimpleBaseLibProc<T1, T2> = procedure(Arg1: T1; Arg2: T2);
  TSimpleBaseLibProc<T1, T2, T3> = procedure(Arg1: T1; Arg2: T2; Arg3: T3);
  TSimpleBaseLibProc<T1, T2, T3, T4> = procedure(Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4);

  // Plain function pointer overloads
  TSimpleBaseLibFunc<TResult> = function: TResult;
  TSimpleBaseLibFunc<T1, TResult> = function(Arg1: T1): TResult;
  TSimpleBaseLibFunc<T1, T2, TResult> = function(Arg1: T1; Arg2: T2): TResult;
  TSimpleBaseLibFunc<T1, T2, T3, TResult> = function(Arg1: T1; Arg2: T2; Arg3: T3): TResult;
  TSimpleBaseLibFunc<T1, T2, T3, T4, TResult> = function(Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4): TResult;

  TSimpleBaseLibPredicate<T> = function(Arg1: T): Boolean;

  // Method-of-object procedure overloads
  TSimpleBaseLibMethodProc = procedure of object;
  TSimpleBaseLibMethodProc<T1> = procedure(Arg1: T1) of object;
  TSimpleBaseLibMethodProc<T1, T2> = procedure(Arg1: T1; Arg2: T2) of object;
  TSimpleBaseLibMethodProc<T1, T2, T3> = procedure(Arg1: T1; Arg2: T2; Arg3: T3) of object;
  TSimpleBaseLibMethodProc<T1, T2, T3, T4> = procedure(Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4) of object;

  // Method-of-object function overloads
  TSimpleBaseLibMethodFunc<TResult> = function: TResult of object;
  TSimpleBaseLibMethodFunc<T1, TResult> = function(Arg1: T1): TResult of object;
  TSimpleBaseLibMethodFunc<T1, T2, TResult> = function(Arg1: T1; Arg2: T2): TResult of object;
  TSimpleBaseLibMethodFunc<T1, T2, T3, TResult> = function(Arg1: T1; Arg2: T2; Arg3: T3): TResult of object;
  TSimpleBaseLibMethodFunc<T1, T2, T3, T4, TResult> = function(Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4): TResult of object;

  TSimpleBaseLibMethodPredicate<T> = function(Arg1: T): Boolean of object;

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

  /// <summary>
  /// Represents a dynamic array of Byte.
  /// </summary>
  TSimpleBaseLibByteArray = TBytes;

  /// <summary>
  /// Represents a dynamic generic array of Type T.
  /// </summary>
  TSimpleBaseLibGenericArray<T> = array of T;

  /// <summary>
  /// Represents a dynamic generic array of array of Type T.
  /// </summary>
  TSimpleBaseLibMatrixGenericArray<T> = array of TSimpleBaseLibGenericArray<T>;

  /// <summary>
  /// Represents a dynamic array of Boolean.
  /// </summary>
  TSimpleBaseLibBooleanArray = TSimpleBaseLibGenericArray<Boolean>;

  /// <summary>
  /// Represents a dynamic array of ShortInt.
  /// </summary>
  TSimpleBaseLibShortIntArray = TSimpleBaseLibGenericArray<ShortInt>;

  /// <summary>
  /// Represents a dynamic array of Int32.
  /// </summary>
  TSimpleBaseLibInt32Array = TSimpleBaseLibGenericArray<Int32>;

  /// <summary>
  /// Represents a dynamic array of Int64.
  /// </summary>
  TSimpleBaseLibInt64Array = TSimpleBaseLibGenericArray<Int64>;

  /// <summary>
  /// Represents a dynamic array of UInt16.
  /// </summary>
  TSimpleBaseLibUInt16Array = TSimpleBaseLibGenericArray<UInt16>;

  /// <summary>
  /// Represents a dynamic array of UInt32.
  /// </summary>
  TSimpleBaseLibUInt32Array = TSimpleBaseLibGenericArray<UInt32>;

  /// <summary>
  /// Represents a dynamic array of UInt64.
  /// </summary>
  TSimpleBaseLibUInt64Array = TSimpleBaseLibGenericArray<UInt64>;

  /// <summary>
  /// Represents a dynamic array of String.
  /// </summary>
  TSimpleBaseLibStringArray = TSimpleBaseLibGenericArray<String>;

  /// <summary>
  /// Represents a dynamic array of Char.
  /// </summary>
  TSimpleBaseLibCharArray = TSimpleBaseLibGenericArray<Char>;

  /// <summary>
  /// Represents a dynamic array of array of ShortInt.
  /// </summary>
  TSimpleBaseLibMatrixShortIntArray = TSimpleBaseLibGenericArray<TSimpleBaseLibShortIntArray>;

  /// <summary>
  /// Represents a dynamic array of array of byte.
  /// </summary>
  TSimpleBaseLibMatrixByteArray = TSimpleBaseLibGenericArray<TSimpleBaseLibByteArray>;

  /// <summary>
  /// Represents a dynamic array of array of Int32.
  /// </summary>
  TSimpleBaseLibMatrixInt32Array = TSimpleBaseLibGenericArray<TSimpleBaseLibInt32Array>;

  /// <summary>
  /// Represents a dynamic array of array of UInt32.
  /// </summary>
  TSimpleBaseLibMatrixUInt32Array = TSimpleBaseLibGenericArray<TSimpleBaseLibUInt32Array>;

  /// <summary>
  /// Represents a dynamic array of array of UInt64.
  /// </summary>
  TSimpleBaseLibMatrixUInt64Array = TSimpleBaseLibGenericArray<TSimpleBaseLibUInt64Array>;

implementation

{$IFDEF FPC}

initialization

// Set UTF-8 in AnsiStrings, just like Lazarus
SetMultiByteConversionCodePage(CP_UTF8);
// SetMultiByteFileSystemCodePage(CP_UTF8); not needed, this is the default under Windows
SetMultiByteRTLFileSystemCodePage(CP_UTF8);
{$ENDIF FPC}

end.

