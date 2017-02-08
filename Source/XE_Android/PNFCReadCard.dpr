program PNFCReadCard;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMainFrom in 'UMainFrom.pas' {MainForm},
  UAndroidFormBase in 'Form\UAndroidFormBase.pas' {frmFormBase};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmFormBase, frmFormBase);
  Application.Run;
end.
