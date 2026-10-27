library SimpleBaseLibAndroidTests;

{$mode objfpc}{$H+}

uses
  cthreads, cwstring, jni, AndroidTestHost,
  SimpleBaseLibTestBase, Base36Tests, Base10Tests,
  Base16StreamRegressionTests, Base16Tests, Base2StreamRegressionTests,
  Base2Tests, Base32Tests, Base32StreamRegressionTests, Base32AlphabetTests,
  Base45Tests,
  Base45StreamRegressionTests, Base58Tests, Base62Tests,
  Base8Tests, Base8StreamRegressionTests, Base85Tests,
  Base85StreamRegressionTests,
  EncodingAlphabetTests, CodingAlphabetTests, BitsTests, MultibaseTests,
  Base64Tests, Base64StreamRegressionTests, DividingCoderTests;

function JNI_OnLoad(AVm: PJavaVM; AReserved: Pointer): jint; cdecl;
begin
  Result := TAndroidTestHost.RegisterHost(AVm);
end;

exports
  JNI_OnLoad;

begin
end.
