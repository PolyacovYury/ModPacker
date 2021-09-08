[CustomMessages]
en.licenseAccept=Accept
ru.licenseAccept=Принимаю

[Code]
<event('CurPageChanged')>
Procedure LicensePageOnActivate(PageID: Integer);
begin
 if PageID <> wpLicense then Exit;
 WizardForm.NextButton.Caption := CustomMessage('licenseAccept');
end;

<event('InitializeWizard')>
Procedure InitializeLicensePage();
var
 RTFStr: AnsiString;
begin
 with WizardForm.LicenseLabel1 do begin
  Font.Size := 11;
  Font.Style := [fsBold];
  AutoSize := True;
  WordWrap := True;
  Left := ScaleX(8);
  Top := ScaleY(14);
  Width := WizardForm.ClientWidth - Left * 2;
 end;

 WizardForm.LicenseMemo.Visible := False; // refuses to work properly
 if not FileExists(ExpandConstant('{tmp}\' + Format('data\lang\%s\license.rtf', [ActiveLanguage()]))) then
  ExtractTemporaryFiles(Format('data\lang\%s\license.rtf', [ActiveLanguage()]));
 LoadStringFromFile(ExpandConstant('{tmp}\' + Format('data\lang\%s\license.rtf', [ActiveLanguage()])), RTFStr);
 with TRichEditViewer.Create(WizardForm.LicensePage) do begin
  Parent := WizardForm.LicensePage;
  BorderStyle := bsSingle;
  TabStop := False;
  ReadOnly := True;
  BorderStyle := bsSingle;
  BevelKind := bkTile;
  Font.Size := 10;
  Color := clGray;
  ScrollBars := ssVertical;
  Left := ScaleX(8);
  Top := WizardForm.LicenseLabel1.Top + WizardForm.LicenseLabel1.Height + ScaleY(14);
  Width := WizardForm.ClientWidth - Left * 2;
  Height := WizardForm.InnerNotebook.Height - Top;
  RTFText := RTFStr;
 end;
 WizardForm.LicenseAcceptedRadio.Checked := True;
 WizardForm.LicenseAcceptedRadio.Visible := False;
 WizardForm.LicenseNotAcceptedRadio.Visible := False;
end;
