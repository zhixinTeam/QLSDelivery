{*******************************************************************************
  作者: dmzn@163.com 2012-4-29
  描述: 运行日志
*******************************************************************************}
unit UFormLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  USysLoger, ULibFun, StdCtrls;

type
  TfFormLog = class(TForm)
    MemoLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ShowLog(const nStr: string);
  public
    { Public declarations }
  end;

procedure ShowLogForm;
//入口函数

implementation

{$R *.dfm}

var
  gForm: TfFormLog = nil;

procedure ShowLogForm;
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormLog.Create(Application);
    gForm.FormStyle := fsStayOnTop;
  end;

  if not gForm.Showing then
    gForm.Show;
  //xxxxx
end;

procedure TfFormLog.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
  gSysLoger.LogEvent := ShowLog;
  gSysLoger.LogSync := True;
end;

procedure TfFormLog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  gSysLoger.LogSync := False;
  gSysLoger.LogEvent := nil;

  Action := caFree;
  gForm := nil;
end;

procedure TfFormLog.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

end.
