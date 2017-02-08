unit UFormTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormBase, StdCtrls, ExtCtrls;

type
  TBaseForm1 = class(TBaseForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Edit1: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FListA,FListB: TStrings;
    function ServerNow: string;
    function GetSerialNo(const nGroup,nObject: string): string;
    function IsSystemExpired: string;
    function GetCustomeMoney(const nCusID,nLimit: string): string;
    function GetZKMoney(const nZK: string): string;
    function CustomerHasMoney(const nCID: string): Boolean;
    function GetPostBills(const nCard, nPost: string): string;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TFormCreateResult; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  UBusinessWorker, UBusinessPacker, UBusinessConst, UMgrControl, UMgrDBConn,
  UEventWorker, UPlugConst, USysDB, ULibFun;

var
  gForm: TBaseForm1 = nil;

class function TBaseForm1.CreateForm(const nPopedom: string;
  const nParam: Pointer): TFormCreateResult;
begin
  if not Assigned(gForm) then
    gForm := TBaseForm1.Create(Application);
  //xxxxx
  
  Result.FFormItem := gForm;
  gForm.Show;
end;

class function TBaseForm1.FormID: integer;
begin
  Result := cFI_FormTest1;
end;

procedure TBaseForm1.FormCreate(Sender: TObject);
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
end;

procedure TBaseForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  gForm := nil;
  FListA.Free;
  FListB.Free;
end;

procedure TBaseForm1.Button1Click(Sender: TObject);
begin
  Memo1.Text := GetPostBills(Edit1.Text, '');
end;

//------------------------------------------------------------------------------
function CallBusinessCommand(const nCmd: Integer; const nData,nParma: string;
  const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPack: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPack := nil;
  nWorker := nil;
  try
    nPack := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);

    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nParma;
    nStr := nPack.PackIn(@nIn);

    Result := nWorker.WorkActive(nStr);
    if not Result then
    begin
      ShowDlg(nStr, sWarn);
      Exit;
    end;

    nPack.UnPackOut(nStr, nOut);
  finally
    gBusinessPackerManager.RelasePacker(nPack);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

function CallBusinessBills(const nCmd: Integer; const nData,nParma: string;
  const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPack: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPack := nil;
  nWorker := nil;
  try
    nPack := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);

    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nParma;
    nStr := nPack.PackIn(@nIn);

    Result := nWorker.WorkActive(nStr);
    if not Result then
    begin
      ShowDlg(nStr, sWarn);
      Exit;
    end;

    nPack.UnPackOut(nStr, nOut);
  finally
    gBusinessPackerManager.RelasePacker(nPack);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

function TBaseForm1.GetSerialNo(const nGroup,nObject: string): string;
var nOut: TWorkerBusinessCommand;
begin
  FListA.Values['Group'] := nGroup;
  FListA.Values['Object'] := nObject;

  if CallBusinessCommand(cBC_GetSerialNO, FListA.Text, sFlag_Yes, @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

function TBaseForm1.ServerNow: string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_ServerNow, '', '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

function TBaseForm1.IsSystemExpired: string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

function TBaseForm1.GetCustomeMoney(const nCusID, nLimit: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetCustomerMoney, nCusID, nLimit, @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

function TBaseForm1.GetZKMoney(const nZK: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetZhiKaMoney, nZK, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

function TBaseForm1.CustomerHasMoney(const nCID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_CustomerHasMoney, nCID, '', @nOut) then
    Result := nOut.FData = sFlag_Yes;
  //xxxxx
end;

function TBaseForm1.GetPostBills(const nCard, nPost: string): string;
var nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if not CallBusinessBills(cBC_GetPostBills, nCard, nPost, @nOut) then Exit;

  nList := TStringList.Create;
  try
    nList.Text := PackerDecodeStr(nOut.FData);
    for nIdx:=0 to nList.Count - 1 do
      Result := Result + PackerDecodeStr(nList[nIdx]) + #13#10;
    //xxxxx
  finally
    nList.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TBaseForm1, TBaseForm1.FormID, TPlugWorker.ModuleInfo.FModuleID);
end.
