program RationLoadingOPC;

uses
  Forms,
  main in 'main.pas' {FormMain},
  UFrame in 'UFrame.pas' {e: TFrame},
  UDataModule in 'UDataModule.pas' {FDM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFDM, FDM);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
