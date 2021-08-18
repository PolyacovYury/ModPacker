// © Kotyarko_O, 2020 \\
[Files]
Source: "data\img\gui\window\widgets\logoBtn1.png"; Flags: dontcopy;
Source: "data\img\gui\window\widgets\logoBtn2.png"; Flags: dontcopy;
Source: "data\img\gui\window\widgets\logoBtn3.png"; Flags: dontcopy;

[Code]
Var
 LogoBtn1, LogoBtn2, LogoBtn3: Longint;

Procedure WidgetsOnClick(hBtn: Longint);
var
 ErrorCode: Integer;
begin
 case hBtn of
  LogoBtn1: ShellExec('', '{#URL_Logo1}', '', '', SW_SHOW, ewNoWait, ErrorCode);
  LogoBtn2: ShellExec('', '{#URL_Logo2}', '', '', SW_SHOW, ewNoWait, ErrorCode);
  LogoBtn3: ShellExec('', '{#URL_Logo3}', '', '', SW_SHOW, ewNoWait, ErrorCode);
 end;
end;

<event('InitializeWizard')>
Procedure InitializeWidgets();
begin
 LogoBtn1 := BtnCreate(WizardForm.Handle, ScaleX(8), WizardForm.ClientHeight - ScaleY(44), 40, 40, 'logoBtn1.png', 0, False);
 BtnSetCursor(LogoBtn1, GetSysCursorHandle(OCR_HAND));
 BtnSetEvent(LogoBtn1, BtnClickEventID, WrapBtnCallback(@WidgetsOnClick, 1));

 LogoBtn2 := BtnCreate(WizardForm.Handle, ScaleX(44), WizardForm.ClientHeight - ScaleY(44), 40, 40, 'logoBtn2.png', 0, False);
 BtnSetCursor(LogoBtn2, GetSysCursorHandle(OCR_HAND));
 BtnSetEvent(LogoBtn2, BtnClickEventID, WrapBtnCallback(@WidgetsOnClick, 1));

 LogoBtn3 := BtnCreate(WizardForm.Handle, ScaleX(80), WizardForm.ClientHeight - ScaleY(44), 40, 40, 'logoBtn3.png', 0, False);
 BtnSetCursor(LogoBtn3, GetSysCursorHandle(OCR_HAND));
 BtnSetEvent(LogoBtn3, BtnClickEventID, WrapBtnCallback(@WidgetsOnClick, 1));
end;

//https://krinkels.org/threads/botva2.1931/post-31509
[Code]
var
 HintLabel: TLabel;
 HintShape: TBevel;

procedure HintVisible(aVisible: Boolean);
begin
  HintLabel.Visible:=aVisible;
  HintShape.Visible:=aVisible;
end;

procedure WidgetBtnEnter(Sender: hWnd);
begin
 with HintLabel do begin
  case Sender of
   LogoBtn1: Caption := '{#URL_Logo1}';
   LogoBtn2: Caption := '{#URL_Logo2}';
   LogoBtn3: Caption := '{#URL_Logo3}';
  end;
  HintShape.SetBounds(Left - ScaleX(4), Top - ScaleX(2), HintLabel.Width + ScaleX(8), HintLabel.Height + ScaleY(4));
 end;
 HintVisible(True);
end;

procedure WidgetBtnLeave(Sender: hWnd);
begin
 HintVisible(False);
end;

<event('InitializeWizard')>
Procedure InitializeWidgetHints();
begin
 HintShape:=TBevel.Create(WizardForm);
 with HintShape do begin
  Parent := WizardForm;
 end;

 HintLabel:=TLabel.Create(WizardForm);
 with HintLabel do begin
  Parent := WizardForm;
  Left := ScaleX(10);
  Top := WizardForm.ClientHeight - ScaleY(44) - ScaleY(20);
 end;

 HintVisible(False);
 BtnSetEvent(LogoBtn1, BtnMouseEnterEventID, WrapBtnCallback(@WidgetBtnEnter, 1));
 BtnSetEvent(LogoBtn1, BtnMouseLeaveEventID, WrapBtnCallback(@WidgetBtnLeave, 1));
 BtnSetEvent(LogoBtn2, BtnMouseEnterEventID, WrapBtnCallback(@WidgetBtnEnter, 1));
 BtnSetEvent(LogoBtn2, BtnMouseLeaveEventID, WrapBtnCallback(@WidgetBtnLeave, 1));
 BtnSetEvent(LogoBtn3, BtnMouseEnterEventID, WrapBtnCallback(@WidgetBtnEnter, 1));
 BtnSetEvent(LogoBtn3, BtnMouseLeaveEventID, WrapBtnCallback(@WidgetBtnLeave, 1));
end;