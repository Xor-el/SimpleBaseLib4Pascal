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

{$IF FPC_FULLVERSION < 30202}
   {$MESSAGE ERROR 'This Library requires FreePascal 3.2.2 or higher.'}
{$IFEND}

{============================== CPU Architecture ==============================}

{$IFDEF FPC_LITTLE_ENDIAN}
  {$DEFINE SIMPLEBASELIB_LITTLE_ENDIAN}
{$ENDIF}

{$IFDEF FPC_REQUIRES_PROPER_ALIGNMENT}
  {$DEFINE SIMPLEBASELIB_REQUIRES_PROPER_ALIGNMENT}
{$ENDIF}

{========================= Compiler Mode & Optimizations ======================}

{$MODE DELPHI}
{$MACRO ON}
{$NOTES OFF}

(*
{$OPTIMIZATION LEVEL3}
{$OPTIMIZATION NOREGVAR}
{$OPTIMIZATION NOUSELOADMODIFYSTORE}
{$OPTIMIZATION ORDERFIELDS}
{$OPTIMIZATION DEADVALUES}

{$IFDEF CPUI386}
   {$OPTIMIZATION USEEBP}
{$ENDIF}

{$IFDEF CPUX86_64}
   {$OPTIMIZATION USERBP}
{$ENDIF}
*)
