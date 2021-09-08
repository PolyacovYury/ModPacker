// © Kotyarko_O, 2020 \\

[Files]
Source: "data\img\gui\pages\1_welcome\bg.jpg"; DestDir: "data\img\gui\pages\1_welcome\"; Flags: ignoreversion nocompression dontcopy;

[Code]
Var
 WelcomePage: TWizardPage;
 WelcomeBackground: Longint;

<event('CurPageChanged')>
Procedure WelcomePageOnActivate(PageID: Integer);
begin
 with WizardForm.InnerNotebook do begin
  if PageID = WelcomePage.ID then
   Top := 0
  else
   Top := ScaleY(80);
  ClientHeight := ScaleY(467) - Top;
 end;
 if (PageID = WelcomePage.ID) and (WelcomeBackground = -1) then
  WelcomeBackground := ImgLoad(
   WelcomePage.Surface.Handle, 'data\img\gui\pages\1_welcome\bg.jpg',
   0, 0, WizardForm.ClientWidth, ScaleY(477), True, False);
 ImgApplyChanges(WelcomePage.Surface.Handle);
end;

<event('InitializeWizard')>
Procedure InitializeWelcomePage();
begin
 WelcomePage := CreateCustomPage(wpWelcome, '', '');
 WelcomeBackground := -1;
end;
