{*******************************************************************************
  作者: fendou116688@163.com 2016-8-22
  描述: 模块工作对象,用于响应框架事件
*******************************************************************************}
unit UEventSelfRemote;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UMITConst, UPlugConst;

type
  TEventRemoteWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    procedure InitSystemObject; override;
    //主程序启动时初始化
    procedure BeforeStartServer; override;
    //服务启动之前调用
    procedure AfterStopServer; override;
    //服务关闭之后调用
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //运行参数

implementation

uses
  SysUtils, USysLoger, UMgrParam;

class function TEventRemoteWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := sPlug_ModuleRemote;
    FModuleName := '服务器互访';
    FModuleVersion := '2016-08-22';
    FModuleDesc := '提供水泥一卡通发货的中间件互访处理对象';
    FModuleBuildTime:= Str2DateTime('2016-08-22 15:01:01');
  end;
end;

procedure TEventRemoteWorker.RunSystemObject(const nParam: PPlugRunParameter);
begin
end;

{$IFDEF DEBUG}
procedure TEventRemoteWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_3';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := 'MIT互访测试';
  nItem.FFormID := 11;
  nItem.FDefault := False;
end;
{$ENDIF}

procedure TEventRemoteWorker.InitSystemObject;
begin
end;

procedure TEventRemoteWorker.BeforeStartServer;
begin
end;

procedure TEventRemoteWorker.AfterStopServer;
begin
end;

end.
