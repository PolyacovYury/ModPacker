// © Kotyarko_O, 2020 \\

[CustomMessages]
en.instProgressLabelText=Progress: %.1d%%. Please wait while Setup installs...
ru.instProgressLabelText=Выполнено: %.1d%%. Пожалуйста, дождитесь завершения установки...

[Code]
Var
 InstComponentLabel, InstProgressLabel: TLabel;
 InstFilesLog, FinishedFilesLog: TNewListBox;
 InstBgShape1: TBevel;

Procedure SetInstallStatus(const Status: String);
begin
 InstProgressLabel.Width := WizardForm.ClientWidth - InstProgressLabel.Left * 2;
 InstProgressLabel.Caption := Format(CustomMessage('instProgressLabelText'), [(WizardForm.ProgressGauge.Position * 100) / WizardForm.ProgressGauge.Max]);
 InstComponentLabel.Width := WizardForm.ClientWidth - InstComponentLabel.Left * 2;
 InstComponentLabel.Caption := CustomMessage(Status);
 WizardForm.FilenameLabel.Width := WizardForm.ClientWidth - WizardForm.FilenameLabel.Left * 2;
end;

Procedure AddInstalledFile(const Status: String);
begin
 InstFilesLog.Items.Add(ExpandConstant(CurrentFilename()));
 InstFilesLog.ItemIndex := InstFilesLog.Items.Count - 1;
 FinishedFilesLog.Items.Add(ExpandConstant(CurrentFilename()));
 FinishedFilesLog.ItemIndex := FinishedFilesLog.Items.Count - 1;
end;

<event('CurInstallProgressChanged')>
procedure InstallProgressChanged(CurProgress, MaxProgress: Integer);
begin
 if (WizardForm.StatusLabel.Caption <> SetupMessage(msgStatusExtractFiles)) then begin
  InstComponentLabel.Width := WizardForm.ClientWidth - InstComponentLabel.Left * 2;
  InstComponentLabel.Caption := WizardForm.StatusLabel.Caption;
 end;
 InstProgressLabel.Width := WizardForm.ClientWidth - InstProgressLabel.Left * 2;
 InstProgressLabel.Caption := Format(CustomMessage('instProgressLabelText'), [(CurProgress * 100) / MaxProgress]);
end;

<event('InitializeWizard')>
Procedure InitializeInstallingPage();
begin
 InstProgressLabel := TLabel.Create(WizardForm.ProgressGauge.Parent);
 with InstProgressLabel do begin
  Parent := WizardForm.ProgressGauge.Parent;
  Transparent := True;
  Font.Size := 11;
  Font.Style := [fsBold];
  AutoSize := True;
  WordWrap := True;
  Left := ScaleX(16);
  Top := ScaleY(8 + 8);
  Width := WizardForm.ClientWidth - Left * 2;
 end;

 with WizardForm.ProgressGauge do begin
  SetBounds(ScaleX(16), InstProgressLabel.Top + InstProgressLabel.Height + ScaleY(10), WizardForm.ClientWidth - ScaleX(32), ScaleY(30));
 end;

 WizardForm.StatusLabel.Visible := False;

 InstComponentLabel := TLabel.Create(WizardForm.ProgressGauge.Parent);
 with InstComponentLabel do begin
  Parent := WizardForm.ProgressGauge.Parent;
  Transparent := True;
  Font.Size := 11;
  Font.Style := [fsBold];
  AutoSize := True;
  WordWrap := True;
  Left := ScaleX(16);
  Top := WizardForm.ProgressGauge.Top + WizardForm.ProgressGauge.Height + ScaleY(10);
  Width := WizardForm.ClientWidth - Left * 2;
  Caption := WizardForm.StatusLabel.Caption;
 end;

 with WizardForm.FilenameLabel do begin
  Parent := WizardForm.ProgressGauge.Parent;
  Font.Size := 7;
  Font.Style := [];
  AutoSize := True;
  WordWrap := False;
  Left := ScaleX(16);
  Top := InstComponentLabel.Top + InstComponentLabel.Height + ScaleY(10);
  Width := WizardForm.ClientWidth - Left * 2;
  Caption := WizardForm.FilenameLabel.Caption;
 end;

 InstBgShape1:=TBevel.Create(WizardForm.ProgressGauge.Parent);
 with InstBgShape1 do begin
  Parent := WizardForm.ProgressGauge.Parent;
  Shape := bsFrame;
  Left := ScaleX(8);
  Top := ScaleY(8);
  Width := WizardForm.ClientWidth - Left * 2;
  Height := WizardForm.FilenameLabel.Top + WizardForm.FilenameLabel.Height + ScaleY(4);
 end;

 InstFilesLog := TNewListBox.Create(WizardForm.ProgressGauge.Parent);
 with InstFilesLog do begin
  Parent := WizardForm.ProgressGauge.Parent;
  BorderStyle := bsSingle;
  Font.Size := 7;
  Font.Style := [];
  Style := lbStandard;
  Left := InstBgShape1.Left;
  Top := InstBgShape1.Top + InstBgShape1.Height + ScaleY(8);
  Width := InstBgShape1.Width;
  Height := WizardForm.InnerNotebook.Height - Top;
 end;
end;
