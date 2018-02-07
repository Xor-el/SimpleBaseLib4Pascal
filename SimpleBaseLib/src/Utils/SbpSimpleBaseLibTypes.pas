unit SbpSimpleBaseLibTypes;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
{$IFDEF FPC}
  fgl,
{$ELSE}
  Generics.Collections,
{$ENDIF FPC}
  SysUtils;

type

  ESimpleBaseLibException = class(Exception);
  EArgumentSimpleBaseLibException = class(ESimpleBaseLibException);
  EArgumentNilSimpleBaseLibException = class(ESimpleBaseLibException);
  EInvalidOperationSimpleBaseLibException = class(ESimpleBaseLibException);

{$IFDEF FPC}
  TDictionary<TKey, TValue> = class(TFPGMap<TKey, TValue>);
{$ELSE}
  TDictionary<TKey, TValue> = class
    (Generics.Collections.TDictionary<TKey, TValue>);
{$ENDIF FPC}

/// <summary>
  /// Represents a dynamic array of Byte.
  /// </summary>
  TSimpleBaseLibByteArray = TBytes;
  /// <summary>
  /// Represents a dynamic generic array of Type T.
  /// </summary>
  TSimpleBaseLibGenericArray<T> = array of T;

{$IFDEF DELPHIXE_UP}
  /// <summary>
  /// Represents a dynamic array of Char.
  /// </summary>
  TSimpleBaseLibCharArray = TArray<Char>;

  /// <summary>
  /// Represents a dynamic array of String.
  /// </summary>
  TSimpleBaseLibStringArray = TArray<String>;

{$ELSE}
  /// <summary>
  /// Represents a dynamic array of Char.
  /// </summary>
  TSimpleBaseLibCharArray = array of Char;

  /// <summary>
  /// Represents a dynamic array of String.
  /// </summary>
  TSimpleBaseLibStringArray = array of String;

{$ENDIF DELPHIXE_UP}

implementation

end.
