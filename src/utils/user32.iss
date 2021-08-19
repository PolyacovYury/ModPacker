[Code]
const
  GWL_WNDPROC = -4;
  WM_MOUSEMOVE = $0200;

type
  WPARAM = UINT_PTR;
  LPARAM = LongInt;
  LRESULT = LongInt;

function SetTimer(
  Wnd: LongWord; IDEvent, Elapse: LongWord; TimerFunc: LongWord): LongWord;
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
function CallWindowProc(
  lpPrevWndFunc: LongInt; hWnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; external 'CallWindowProcW@user32.dll stdcall';
