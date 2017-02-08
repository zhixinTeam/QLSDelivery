unit USearchTruck;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit;

type
  TFrmGetTruck = class(TForm)
    Label1: TLabel;
    EditTruck: TEdit;
    BtnOK: TSpeedButton;
    BtnCancel: TSpeedButton;
    procedure BtnOKClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmGetTruck: TFrmGetTruck;

implementation
{$R *.fmx}

procedure TFrmGetTruck.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmGetTruck.BtnOKClick(Sender: TObject);
begin
  //
end;

end.
