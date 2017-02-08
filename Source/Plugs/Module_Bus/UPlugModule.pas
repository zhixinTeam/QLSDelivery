{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 单元模块

  备注: 由于模块有自注册能力,只要Uses一下即可.
*******************************************************************************}
unit UPlugModule;

{$I Link.Inc}
interface

uses
  {$IFDEF Debug}UFormTest, {$ENDIF}
  UModuleWorker, UModulePacker, UMITPacker;

implementation

end.
