[Code]
const
 GWL_EXSTYLE = -20;
 WS_EX_COMPOSITED = $02000000;
 GWL_WNDPROC = -4;
 WM_MOUSEMOVE = $0200;
 WM_MOUSEWHEEL = $020A;
 WM_MOUSEHOVER = $02A1;
 WM_MOUSELEAVE = $02A3;
 LB_ITEMFROMPOINT = $01A9;
 PM_REMOVE = 1;
 WAIT_TIMEOUT = $00000102;
 SEE_MASK_NOCLOSEPROCESS = $00000040;

type
 WPARAM = UINT_PTR;
 LPARAM = LongInt;
 LRESULT = LongInt;

 TMsg = record
  hwnd: HWND;
  message: UINT;
  wParam: Longint;
  lParam: Longint;
  time: DWORD;
  pt: TPoint;
 end;

 TShellExecuteInfo = record
  cbSize: DWORD;
  fMask: Cardinal;
  Wnd: HWND;
  lpVerb: string;
  lpFile: string;
  lpParameters: string;
  lpDirectory: string;
  nShow: Integer;
  hInstApp: THandle;    
  lpIDList: DWORD;
  lpClass: string;
  hkeyClass: THandle;
  dwHotKey: DWORD;
  hMonitor: THandle;
  hProcess: THandle;
 end;

function SetTimer(Wnd: LongWord; IDEvent, Elapse: LongWord; TimerFunc: LongWord): LongWord;
 external 'SetTimer@user32.dll stdcall';
function KillTimer(hWnd: LongWord; uIDEvent: LongWord): BOOL;
 external 'KillTimer@user32.dll stdcall';
procedure ExitProcess(uExitCode: UINT);
 external 'ExitProcess@kernel32.dll stdcall';
function ShellExecute(hwnd: HWND; lpOperation: string; lpFile: string;
 lpParameters: string; lpDirectory: string; nShowCmd: Integer): THandle;
 external 'ShellExecuteW@shell32.dll stdcall';
Function GetCursorPos(var lpPoint: TPoint): BOOL;
 external 'GetCursorPos@user32.dll stdcall';
Function MapWindowPoints(hWndFrom, hWndTo: HWND; var lpPoints: TPoint; cPoints: UINT): Integer;
 external 'MapWindowPoints@user32.dll stdcall';
function ClientToScreen(hWnd: HWND; var lpPoint: TPoint): Boolean;
 external 'ClientToScreen@user32.dll stdcall';
function ScreenToClient(hWnd: HWND; var lpPoint: TPoint): BOOL;
 external 'ScreenToClient@user32.dll stdcall';
Function SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: Longint): Longint;
 external 'SetWindowLongW@user32.dll stdcall';
Function GetWindowLong(hWnd: HWND; nIndex: Integer): Longint;
 external 'GetWindowLongW@user32.dll stdcall';
function CallWindowProc(lpPrevWndFunc: LongInt; hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
 external 'CallWindowProcW@user32.dll stdcall';
function ShellExecuteEx(var lpExecInfo: TShellExecuteInfo): BOOL; 
 external 'ShellExecuteExW@shell32.dll stdcall';
function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD; 
 external 'WaitForSingleObject@kernel32.dll stdcall';
function TerminateProcess(hProcess: THandle; uExitCode: UINT): BOOL;
 external 'TerminateProcess@kernel32.dll stdcall';
function GetExitCodeProcess(hProcess: THandle; var uExitCode: UINT): BOOL;
 external 'GetExitCodeProcess@kernel32.dll stdcall';
function GetLastError(): UINT;
 external 'GetLastError@kernel32.dll stdcall';
function PeekMessage(var lpMsg: TMsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL;
 external 'PeekMessageA@user32.dll stdcall';
function TranslateMessage(const lpMsg: TMsg): BOOL;
 external 'TranslateMessage@user32.dll stdcall';
function DispatchMessage(const lpMsg: TMsg): Longint;
 external 'DispatchMessageW@user32.dll stdcall';

procedure AppProcessMessage;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, WizardForm.Handle, 0, 0, PM_REMOVE) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;
