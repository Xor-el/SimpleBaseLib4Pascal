program Make;
{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  StrUtils,
  FileUtil,
  Zipper,
  fphttpclient,
  openssl,
  opensslsockets,
  Process;

const
  Src: string = 'SimpleBaseLib.Benchmark/FreePascal.Benchmark';
  Use: string = 'SimpleBaseLib/src/Packages/FPC/';
  Tst: string = 'SimpleBaseLibConsole.Tests.lpi';
  Pkg: array of string = ();

var
  Each, Item, PackagePath, TempFile, Url: string;
  Output, Line: ansistring;
  List: TStringList;
  Zip: TStream;

begin
  InitSSLInterface;
  if FileExists('.gitmodules') then
    if RunCommand('git', ['submodule', 'update', '--init', '--recursive',
      '--force', '--remote'], Output) then
      Writeln(stderr, #27'[33m', Output, #27'[0m')
    else
    begin
      ExitCode += 1;
      Writeln(stderr, #27'[31m', Output, #27'[0m');
    end;
  List := FindAllFiles(Use, '*.lpk', True);
  try
    for Each in List do
      if RunCommand('lazbuild', ['--add-package-link', Each], Output) then
        Writeln(stderr, #27'[33m', 'added ', Each, #27'[0m')
      else
      begin
        ExitCode += 1;
        Writeln(stderr, #27'[31m', 'added ', Each, #27'[0m');
      end;
  finally
    List.Free;
  end;
  for Each in Pkg do
  begin
    PackagePath :=
      {$IFDEF MSWINDOWS}
      GetEnvironmentVariable('APPDATA') + '\.lazarus\onlinepackagemanager\packages\'
      {$ELSE}
      GetEnvironmentVariable('HOME') + '/.lazarus/onlinepackagemanager/packages/'
      {$ENDIF}
      + Each;
    TempFile := GetTempFileName;
    Url := 'https://packages.lazarus-ide.org/' + Each + '.zip';
    if not DirectoryExists(PackagePath) then
    begin
      Zip := TFileStream.Create(TempFile, fmCreate or fmOpenWrite);
      with TFPHttpClient.Create(nil) do
      begin
        try
          AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
          AllowRedirect := True;
          Get(Url, Zip);
          WriteLn(stderr, 'Download from ', Url, ' to ', TempFile);
        finally
          Free;
        end;
      end;
      Zip.Free;
      CreateDir(PackagePath);
      with TUnZipper.Create do
      begin
        try
          FileName := TempFile;
          OutputPath := PackagePath;
          Examine;
          UnZipAllFiles;
          WriteLn(stderr, 'Unzip from ', TempFile, ' to ', PackagePath);
        finally
          Free;
        end;
      end;
      DeleteFile(TempFile);
      List := FindAllFiles(PackagePath, '*.lpk', True);
      try
        for Item in List do
        try
          if RunCommand('lazbuild', ['--add-package-link', Item], Output) then
            Writeln(stderr, #27'[33m', 'added ', Item, #27'[0m')
          else
          begin
            ExitCode += 1;
            Writeln(stderr, #27'[31m', 'added ', Item, #27'[0m');
          end;
        except
          on E: Exception do
            WriteLn(stderr, 'Error: ' + E.ClassName + #13#10 + E.Message);
        end;
      finally
        List.Free;
      end;
    end;
  end;
  List := FindAllFiles('.', Tst, True);
  try
    for Each in List do
    begin
      Writeln(stderr, #27'[33m', 'build ', Each, #27'[0m');
      try
        if RunCommand('lazbuild', ['--build-all', '--recursive',
          '--no-write-project', Each], Output) then
          for Line in SplitString(Output, LineEnding) do
          begin
            if Pos('Linking', Line) <> 0 then
            try
              begin
                if not RunCommand(
                  {$IFDEF MSWINDOWS}
                  '&'
                  {$ELSE}
                  'command'
                  {$ENDIF}
                  , [SplitString(Line, ' ')[2], '--all', '--format=plain', '--progress'],
                  Output) then
                  ExitCode += 1;
                WriteLn(stderr, Output);
              end;
            except
              on E: Exception do
                WriteLn(stderr, 'Error: ' + E.ClassName + #13#10 + E.Message);
            end;
          end
        else
          for Line in SplitString(Output, LineEnding) do
            if Pos('Fatal', Line) <> 0 or Pos('Error', Line) then
              Writeln(stderr, #27'[31m', Line, #27'[0m');
      except
        on E: Exception do
          WriteLn(stderr, 'Error: ' + E.ClassName + #13#10 + E.Message);
      end;
    end;
  finally
    List.Free;
  end;
  List := FindAllFiles(Src, '*.lpi', True);
  try
    for Each in List do
    begin
      Write(#27'[33m', 'build from ', Each, #27'[0m');
      if RunCommand('lazbuild', ['--build-all', '--recursive',
        '--no-write-project', Each], Output) then
        for Line in SplitString(Output, LineEnding) do
        begin
          if Pos('Linking', Line) <> 0 then
            Writeln(stderr, #27'[32m', ' to ', SplitString(Line, ' ')[2], #27'[0m');
        end
      else
      begin
        ExitCode += 1;
        for Line in SplitString(Output, LineEnding) do
          if Pos('Fatal:', Line) <> 0 or Pos('Error:', Line) then
          begin
            WriteLn(stderr);
            Writeln(stderr, #27'[31m', Line, #27'[0m');
          end;
      end;
    end;
  finally
    List.Free;
  end;
  WriteLn(stderr, 'Errors: ', ExitCode);
end.
