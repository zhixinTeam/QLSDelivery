{*******************************************************************************
  作者: dmzn@163.com 2013-11-23
  描述: 模块工作对象,用于响应框架事件
*******************************************************************************}
unit UEventWorker;

interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UPlugConst;

type
  TPlugWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //运行参数

implementation

class function TPlugWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := '';
    FModuleName := '测试模块';
  end;
end;

procedure TPlugWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
  gPlugRunParam := nParam^;
end;

end.
