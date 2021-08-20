[CustomMessages]
en.licenseAccept=Accept
ru.licenseAccept=Принимаю

[Code]
Var
 LicensePage: TWizardPage;
 LicenseRichViewer: TRichEditViewer;
 LicenseLabel: TLabel;

Procedure SetLicensePageVisibility(Value: Boolean);
begin
 LicenseLabel.Visible := Value;
 LicenseRichViewer.Visible := Value;
 if Value then
  WizardForm.NextButton.Caption := CustomMessage('licenseAccept');
end;

Procedure LicensePageOnActivate(Sender: TWizardPage);
begin
 SetLicensePageVisibility(True);
end;

Function LicensePageOnBackButtonClick(Sender: TWizardPage): Boolean;
begin
 Result := True;
 SetLicensePageVisibility(False);
end;

Function LicensePageOnNextButtonClick(Sender: TWizardPage): Boolean;
begin
 Result := True;
 SetLicensePageVisibility(False);
end;

<event('ShouldSkipPage')>
Function LicenseShouldSkipPage(CurPageID: Integer): Boolean;
begin
 Result := False;
 case CurPageID of
  wpLicense: Result := True;
 end;
end;

<event('InitializeWizard')>
Procedure InitializeLicensePage();
var
  RTFStr: AnsiString;
begin
 LicensePage := CreateCustomPage(WelcomePage.ID, '', '');
 with LicensePage do begin
  OnActivate := @LicensePageOnActivate;
  OnBackButtonClick := @LicensePageOnBackButtonClick;
  OnNextButtonClick := @LicensePageOnNextButtonClick;
 end;
 LicenseLabel := TLabel.Create(LicensePage);
 with LicenseLabel do
 begin
  Parent := WizardForm;
  AutoSize := True;
  WordWrap := True;
  Left := ScaleX(8);
  Top := ScaleY(80 + 24);
  Width := WizardForm.ClientWidth - ScaleX(16);
  Caption := SetupMessage(msgLicenseLabel3);
  Font.Size := 10;
  Transparent := True;
 end;

 if not FileExists(ExpandConstant('{tmp}\' + Format('data\lang\%s\license.rtf', [ActiveLanguage()]))) then
  ExtractTemporaryFiles(Format('data\lang\%s\license.rtf', [ActiveLanguage()]));
 LoadStringFromFile(ExpandConstant('{tmp}\' + Format('data\lang\%s\license.rtf', [ActiveLanguage()])), RTFStr);
 LicenseRichViewer := TRichEditViewer.Create(WizardForm);
 with LicenseRichViewer do begin
  Parent := WizardForm;
  BorderStyle := bsSingle;
  TabStop := False;
  ReadOnly := True;
  BorderStyle := bsSingle;
  BevelKind := bkTile;
  Font.Size := 10;
  Color := clGray;
  ScrollBars := ssVertical;
  SetBounds(ScaleX(8), LicenseLabel.Top + LicenseLabel.Height + ScaleY(16), WizardForm.ClientWidth - ScaleX(16), ScaleY(477 - 16) - LicenseLabel.Top - LicenseLabel.Height);
  RTFText := RTFStr;
 end;
 SetLicensePageVisibility(False);
end;
