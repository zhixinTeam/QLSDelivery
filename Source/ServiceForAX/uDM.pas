unit uDM;

interface

uses
  SysUtils, Classes, IniFiles, DB, ADODB, USysLoger;

type
  TDM = class(TDataModule)
    ADOCLoc: TADOConnection;
    ADOCRem: TADOConnection;
    qryLoc: TADOQuery;
    qryRem: TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TLocDB= record
    DBUser:string;
    DBPwd:string;
    DBCatalog:string;
    DBSource:string;
  end;

type
  TRemDB= record
    DBUser:string;
    DBPwd:string;
    DBCatalog:string;
    DBSource:string;
  end;

var
  DM: TDM;
  LocalDBConn,RemDBConn:string;

implementation

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
var
  myini:TIniFile;
  RemDB:TRemDB;
  LocDB:TLocDB;
begin
  myini:=TIniFile.Create('.\DBConn.Ini');
  try
    RemDB.DBUser:=myini.ReadString('远程','DBUser','');
    RemDB.DBPwd:=myini.ReadString('远程','DBPwd','');
    RemDB.DBCatalog:=myini.ReadString('远程','DBCatalog','');
    RemDB.DBSource:=myini.ReadString('远程','DBSource','');
    LocDB.DBUser:=myini.ReadString('本地','DBUser','');
    LocDB.DBPwd:=myini.ReadString('本地','DBPwd','');
    LocDB.DBCatalog:=myini.ReadString('本地','DBCatalog','');
    LocDB.DBSource:=myini.ReadString('本地','DBSource','');
  finally
    myini.Free;
  end;
  RemDBConn:='Provider=SQLOLEDB.1;'+
             'Password='+RemDB.DBPwd+';'+
             'Persist Security Info=True;'+
             'User ID='+RemDB.DBUser+';'+
             'Initial Catalog='+RemDB.DBCatalog+';'+
             'Data Source='+RemDB.DBSource;
  LocalDBConn:='Provider=SQLOLEDB.1;'+
                 'Password='+LocDB.DBPwd+';'+
                 'Persist Security Info=True;'+
                 'User ID='+LocDB.DBUser+';'+
                 'Initial Catalog='+LocDB.DBCatalog+';'+
                 'Data Source='+LocDB.DBSource;
  ADOCRem.ConnectionString:=RemDBConn;
  ADOCRem.Connected:=True;
  ADOCLoc.ConnectionString:=LocalDBConn;
  ADOCLoc.Connected:=True;
end;


end.
