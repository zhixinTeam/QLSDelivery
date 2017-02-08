{*******************************************************************************
  作者: dmzn@163.com 2013-11-23
  描述: 模块工作对象,用于响应框架事件
*******************************************************************************}
unit UEventWorker;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UPlugConst;

type
  TPlugWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
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
    FModuleID := sPlug_ModuleBus;
    FModuleName := '发货业务';
    FModuleVersion := '2014-09-01';
    FModuleDesc := '提供水泥一卡通发货的业务逻辑处理对象';
    FModuleBuildTime:= Str2DateTime('2014-09-01 15:01:01');
  end;
end;

procedure TPlugWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
  gPlugRunParam := nParam^;
end;

{$IFDEF DEBUG}
procedure TPlugWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_1';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := '业务测试';
  nItem.FFormID := cFI_FormTest1;
  nItem.FDefault := False;
end;
{$ENDIF}

end.
