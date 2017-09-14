{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UModuleWorker;

interface

uses
  UBusinessWorker, UBusinessPacker, UBusinessConst, UPlugWorker, UEventWorker;

implementation

//------------------------------------------------------------------------------
var
  gModuleID: string = '';
  //模块标识

initialization
  gModuleID := TPlugWorker.ModuleInfo.FModuleID;
  
end.
