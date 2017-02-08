program Counter;

uses
  FastMM4,
  Windows,
  Forms,
  UFormMain in 'UFormMain.pas' {fFormMain},
  UFrameJS in 'UFrameJS.pas' {fFrameCounter: TFrame},
  UFormLog in 'UFormLog.pas' {fFormLog},
  USysConst in 'USysConst.pas',
  UFormCard in 'UFormCard.pas' {fFormCard};

{$R *.res}

var
  gMutexHwnd: Hwnd;
  //互斥句柄

begin
  gMutexHwnd := CreateMutex(nil, True, 'RunSoft_HX_Counter');
  //创建互斥量
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    ReleaseMutex(gMutexHwnd);
    CloseHandle(gMutexHwnd); Exit;
  end; //已有一个实例

  Application.Initialize;
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;

  ReleaseMutex(gMutexHwnd);
  CloseHandle(gMutexHwnd);
end.
