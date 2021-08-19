// © Kotyarko_O, 2020 \\

[Files]
Source: "data\img\gui\pages\1_welcome\bg.jpg"; DestDir: "data\img\gui\pages\1_welcome\"; Flags: dontcopy;

[Code]
Var
 WelcomePage: TWizardPage;
 WelcomeBackground: Longint;

Procedure SetWelcomePageVisibility(Value: Boolean);
begin
 WizardForm.BackButton.Visible := not Value;
 ImgSetVisibility(WelcomeBackground, Value);
 ImgApplyChanges(WizardForm.Handle);
end;

Procedure WelcomePageOnActivate(Sender: TWizardPage);
begin
 SetWelcomePageVisibility(True);
end;

Function WelcomePageOnNextButtonClick(Sender: TWizardPage): Boolean;
begin
 Result := True;
 SetWelcomePageVisibility(False);
end;

<event('InitializeWizard')>
Procedure InitializeWelcomePage();
begin
 WelcomePage := CreateCustomPage(wpWelcome, '', '');
 with WelcomePage do begin
  OnActivate := @WelcomePageOnActivate;
  OnNextButtonClick := @WelcomePageOnNextButtonClick;
 end;

 WelcomeBackground := ImgLoad(WizardForm.Handle, 'data\img\gui\pages\1_welcome\bg.jpg', 0, 0, WizardForm.ClientWidth, ScaleY(477), True, True);
 SetWelcomePageVisibility(False);
end;
