{$DEFINE DELPHI}
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
{$IFDEF FPC}
{$UNDEF DELPHI}
{$MODE DELPHI}
{$ENDIF FPC}
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{$IFDEF DELPHI}
// XE7 and Above
{$IF CompilerVersion >= 28.0}
{$DEFINE DELPHIXE7_UP}
{$IFEND}
// 10.2 Tokyo and Above
{$IF CompilerVersion >= 32.0}
{$DEFINE DELPHI10.2_TOKYO_UP}
{$IFEND}

// 10.2 Tokyo and Above
{$IFDEF DELPHI10.2_TOKYO_UP}
{$WARN COMBINING_SIGNED_UNSIGNED OFF}
{$WARN COMBINING_SIGNED_UNSIGNED64 OFF}
{$ENDIF}
{$ENDIF DELPHI}
(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit uBase64;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

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
