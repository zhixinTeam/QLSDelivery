program SrvForAX;

{#ROGEN:MyLibrary.rodl} // RemObjects: Careful, do not remove!

uses
  uROComInit,
  Forms,
  fServerForm in 'fServerForm.pas' {ServerForm},
  MyLibrary_Intf in 'MyLibrary_Intf.pas',
  MyLibrary_Invk in 'MyLibrary_Invk.pas',
  RemService_Impl in 'RemService_Impl.pas',
  USysBusiness in 'USysBusiness.pas',
  uDM in 'uDM.pas' {DM: TDataModule};

{$R *.res}
{$R RODLFile.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
