program Benchmark;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  SysUtils,
  uBenchmark;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Randomize;
    TBenchmark.GenerateString(100000);
    TBenchmark.Benchmark;
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.





