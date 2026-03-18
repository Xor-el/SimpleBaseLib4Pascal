unit SbpMultibaseEncoding;

{$I ..\Include\SimpleBaseLib.inc}

interface

type
  TMultibaseEncoding = (
    Base16Lower = Ord('f'),
    Base16Upper = Ord('F'),
    Base32Lower = Ord('b'),
    Base32Upper = Ord('B'),
    Base58Bitcoin = Ord('z'),
    Base64 = Ord('m'),
    Base64Pad = Ord('M'),
    Base64Url = Ord('u'),
    Base64UrlPad = Ord('U'),

    Base8 = Ord('7'),
    Base10 = Ord('9'),
    Base32Z = Ord('h'),
    Base36Lower = Ord('k'),
    Base36Upper = Ord('K'),
    Base45 = Ord('R'),

    Base2 = Ord('0'),
    Base58Flickr = Ord('Z'),
    Base32HexLower = Ord('v'),
    Base32HexUpper = Ord('V')
  );

implementation

end.
