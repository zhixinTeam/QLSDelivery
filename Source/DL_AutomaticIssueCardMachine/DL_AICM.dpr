program DL_AICM;

uses
  Forms,
  USysModule,
  UMITPacker,
  UWorkerBussinessWebchat,
  UDataModule in 'forms\UDataModule.pas' {FDM: TDataModule},
  UFormMain in 'forms\UFormMain.pas' {fFormMain},
  uReadCardThread in 'uReadCardThread.pas',
  UFormBase in 'Forms\UFormBase.pas' {BaseForm},
  UFormNormal in 'Forms\UFormNormal.pas' {fFormNormal};

{$R *.res}

begin
  Application.Initialize;
  InitSystemObject;
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TfFormMain, fFormMain);
  Application.Run;
end.
