{$DEFINE DELPHI}
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
{$IFDEF FPC}
{$UNDEF DELPHI}
{$MODE delphi}
{$DEFINE USE_UNROLLED_VARIANT}
// Disable Overflow and RangeChecks.
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
// Enable Pointer Math
{$POINTERMATH ON}
// Disable Warnings and Hints.
{$WARNINGS OFF}
{$HINTS OFF}
{$NOTES OFF}
// Optimizations
{$OPTIMIZATION LEVEL3}
{$OPTIMIZATION PEEPHOLE}
{$OPTIMIZATION REGVAR}
{$OPTIMIZATION LOOPUNROLL}
{$OPTIMIZATION STRENGTH}
{$OPTIMIZATION CSE}
{$OPTIMIZATION DFA}
{$IFDEF CPUI386}
{$OPTIMIZATION USEEBP}
{$ENDIF}
{$IFDEF CPUX86_64}
{$OPTIMIZATION USERBP}
{$ENDIF}
{$ENDIF FPC}
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{$IFDEF DELPHI}
{$DEFINE USE_UNROLLED_VARIANT}
// This option is needed to enable code browsing (aka Ctrl+Click)
// It does not affect the binary size or generated code
{$DEFINITIONINFO ON}
// Disable Hints.
{$HINTS OFF}
// Disable Overflow and RangeChecks.
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
// Enable Pointer Math
{$POINTERMATH ON}
// Disable String Checks
{$STRINGCHECKS OFF}
// Disable Duplicate Constructor Warnings
{$WARN DUPLICATE_CTOR_DTOR OFF}
// 2010 only
{$IF CompilerVersion = 21.0}
{$DEFINE DELPHI2010}
{$IFEND}
// 2010 and Above
{$IF CompilerVersion >= 21.0}
{$DEFINE DELPHI2010_UP}
{$IFEND}
// XE and Above
{$IF CompilerVersion >= 22.0}
{$DEFINE DELPHIXE_UP}
{$IFEND}
// XE2 and Above
{$IF CompilerVersion >= 23.0}
{$DEFINE DELPHIXE2_UP}
{$DEFINE HAS_UNITSCOPE}
{$IFEND}
// XE3 and Below
{$IF CompilerVersion <= 24.0}
{$DEFINE DELPHIXE3_DOWN}
{$IFEND}
// XE3 and Above
{$IF CompilerVersion >= 24.0}
{$DEFINE DELPHIXE3_UP}
{$LEGACYIFEND ON}
{$ZEROBASEDSTRINGS OFF}
{$IFEND}
// XE7 and Above
{$IF CompilerVersion >= 28.0}
{$DEFINE DELPHIXE7_UP}
{$IFEND}
// 10.2 Tokyo and Above
{$IF CompilerVersion >= 32.0}
{$DEFINE DELPHI10.2_TOKYO_UP}
{$IFEND}
// 2010 and Above
{$IFNDEF DELPHI2010_UP}
{$MESSAGE ERROR 'This Library requires Delphi 2010 or higher.'}
{$ENDIF}
// 10.2 Tokyo and Above
{$IFDEF DELPHI10.2_TOKYO_UP}
{$WARN COMBINING_SIGNED_UNSIGNED OFF}
{$WARN COMBINING_SIGNED_UNSIGNED64 OFF}
{$ENDIF}
{$ENDIF DELPHI}
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit uBase64;

interface

uses
{$IFDEF DELPHIXE7_UP}
  System.NetEncoding,
{$ELSE}
{$IFDEF DELPHI}
  Classes,
  EncdDecd,
{$ENDIF DELPHI}
{$ENDIF DELPHIXE7_UP}
{$IFDEF FPC}
  base64,
{$ENDIF FPC}
  SysUtils;

type
  TRTLBase64 = class sealed(TObject)

  public
    class function Encode(Input: TBytes): String; static;
    class function Decode(const Input: String): TBytes; static;
  end;

implementation

{ TRTLBase64 }

class function TRTLBase64.Decode(const Input: String): TBytes;
begin
{$IFDEF DELPHIXE7_UP}
  Result := TNetEncoding.base64.DecodeStringToBytes(Input);
{$ELSE}
{$IFDEF DELPHI}
  Result := DecodeBase64(Input);
{$ENDIF DELPHI}
{$ENDIF DELPHIXE7_UP}
{$IFDEF FPC}
  Result := TEncoding.Default.GetBytes
    (UnicodeString(DecodeStringBase64(Input)));
{$ENDIF FPC}
end;

class function TRTLBase64.Encode(Input: TBytes): String;
{$IFDEF DELPHI}
{$IFNDEF DELPHIXE7_UP}
var
  TempHolder: TBytesStream;
{$ENDIF DELPHIXE7_UP}
{$ENDIF DELPHI}
begin
{$IFDEF DELPHIXE7_UP}
  // Result := StringReplace(TNetEncoding.base64.EncodeBytesToString(Input),
  // sLineBreak, '', [rfReplaceAll]);
  Result := TNetEncoding.base64.EncodeBytesToString(Input);
{$ELSE}
{$IFDEF DELPHI}
  TempHolder := TBytesStream.Create(Input);
  try
    // Result := StringReplace(String(EncodeBase64(TempHolder.Memory,
    // TempHolder.Size)), sLineBreak, '', [rfReplaceAll]);
    Result := String(EncodeBase64(TempHolder.Memory, TempHolder.Size));
  finally
    TempHolder.Free;
  end;
{$ENDIF DELPHI}
{$ENDIF DELPHIXE7_UP}
{$IFDEF FPC}
  Result := EncodeStringBase64(String(TEncoding.Default.GetString(Input)));
{$ENDIF FPC}
end;

end.
