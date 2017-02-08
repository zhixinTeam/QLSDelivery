unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UMgrTruckProbe, StdCtrls, UMgrControl, UMemDataPool;

type
  TForm1 = class(TForm)
    btn1: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormDestroy(Sender: TObject);
begin
   gProberManager.StopProber;
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  if not Assigned(gProberManager) then
  begin
    gProberManager := TProberManager.Create;
    gProberManager.LoadConfig('.\TruckProber.xml');
  end;
  gProberManager.StartProber;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
end;

initialization
  gControlManager.RegCtrl(TForm1, $0035);

end.
 