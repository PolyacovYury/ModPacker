// © Kotyarko_O, 2020 \\

[Code]
Var
 WelcomePage: TWizardPage;

Procedure SetWelcomePageVisibility(Value: Boolean);
begin
 WizardForm.BackButton.Visible := not Value;
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
 with WelcomePage do
 begin
  OnActivate := @WelcomePageOnActivate;
  OnNextButtonClick := @WelcomePageOnNextButtonClick;
 end;

 SetWelcomePageVisibility(False);
end;
