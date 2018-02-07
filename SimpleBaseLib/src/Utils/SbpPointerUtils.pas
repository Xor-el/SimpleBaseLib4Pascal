unit SbpPointerUtils;

{$I ..\Include\SimpleBaseLib.inc}

interface

uses
  SbpSimpleBaseLibTypes,
  SysUtils;

resourcestring
  SBufferOverFlow = 'Buffer overflow -- buffer too large?';

type
  TPointerUtils = class sealed(TObject)
  public
    class function Offset(ptr: PByte; length: Int32): PByte; overload;
      static; inline;
    class function Offset(ptr: PChar; length: Int32): PChar; overload;
      static; inline;
  end;

implementation

{ TPointerUtils }

class function TPointerUtils.Offset(ptr: PByte; length: Int32): PByte;
begin
  result := ptr + length;
  if ((length < 0) or (result < ptr)) then
  begin
    raise EInvalidOperationSimpleBaseLibException.CreateRes(@SBufferOverFlow);
  end;
end;

class function TPointerUtils.Offset(ptr: PChar; length: Int32): PChar;
begin
  result := ptr + length;
  if ((length < 0) or (result < ptr)) then
  begin
    raise EInvalidOperationSimpleBaseLibException.CreateRes(@SBufferOverFlow);
  end;
end;

end.
