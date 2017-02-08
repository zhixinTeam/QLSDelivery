{*******************************************************************************
  作者: dmzn@163.com 2012-5-3
  描述: 数据模块
*******************************************************************************}
unit UDataModule;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TFDM = class(TDataModule)
    ADOConn: TADOConnection;
    SQLQuery1: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function SQLQuery(const nSQL: string): TDataSet;
    //查询数据库
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

//Date: 2012-5-3
//Parm: SQL;是否保持连接
//Desc: 执行SQL数据库查询
function TFDM.SQLQuery(const nSQL: string): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    SQLQuery1.Close;
    SQLQuery1.SQL.Text := nSQL;
    SQLQuery1.Open;

    Result := SQLQuery1;
    Exit;
  except
    ADOConn.Connected := False;
    Inc(nInt);
  end;
end;

end.
