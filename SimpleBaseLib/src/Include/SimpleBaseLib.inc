{ * ************************************************************************ * }
{ *                           SimpleBaseLib Library                          * }
{ *                       Author - Ugochukwu Mmaduekwe                       * }
{ *              Github Repository <https://github.com/Xor-el>               * }
{ *                                                                          * }
{ *  Distributed under the MIT software license, see the accompanying file   * }
{ *                                 LICENSE                                  * }
{ *         or visit http://www.opensource.org/licenses/mit-license.         * }
{ *                                                                          * }
{ * ************************************************************************ * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

{========================== Common Compiler Settings ==========================}

{$HINTS OFF}
{$WARNINGS OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}
{$SCOPEDENUMS ON}
{$POINTERMATH ON}

{========================= Compiler Specific Settings =========================}

{$IFDEF FPC}
  {$I SimpleBaseLibFPC.inc}
{$ELSE}
   // Delphi 2010 and Above
  {$IF CompilerVersion < 21.0}
    {$MESSAGE ERROR 'This Library requires Delphi 2010 or higher.'}
  {$IFEND}

  {$DEFINE DELPHI}

  {$DEFINITIONINFO ON} // Enable code browsing (Ctrl+Click)
  {$STRINGCHECKS OFF}
  {$WARN DUPLICATE_CTOR_DTOR OFF}

  // XE and Above
  {$IF CompilerVersion >= 22.0}
     {$DEFINE DELPHIXE_UP}
  {$IFEND}

{$ENDIF}

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)
