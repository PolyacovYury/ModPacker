[Files]
Source: "src\utils\botva2\botva2.dll"; Flags: ignoreversion nocompression dontcopy;
Source: "src\utils\botva2\CallbackCtrl.dll"; Flags: ignoreversion nocompression dontcopy;

[Code]
//модуль для работы с библиотекой botva2.dll версии  0.9.9
//Created by South.Tver 03.2015

const
  //идентификаторы событий для кнопок и чекбоксов/радибатонов
  BtnClickEventID      = 1;
  BtnMouseEnterEventID = 2;
  BtnMouseLeaveEventID = 3;
  BtnMouseMoveEventID  = 4;
  BtnMouseDownEventID  = 5;
  BtnMouseUpEventID    = 6;

  //https://msdn.microsoft.com/en-us/library/windows/desktop/ms648395%28v=vs.85%29.aspx
  OCR_HAND = 32649;
  OCR_HELP = 32651;
  OCR_WAIT = 32514;
  OCR_NORMAL = 32512;

  //выравнивание текста на кнопках
  balLeft    = 0;  //выравнивание текста по левому краю
  balCenter  = 1;  //горизонтальное выравнивание текста по центру
  balRight   = 2;  //выравнивание текста по правому краю
  balVCenter = 4;  //вертикальное выравнивание текста по центру

type
  TBtnEventProc = procedure(h:HWND);

//для выполнения нажатий на кнопки нужен innocallback
function WrapBtnCallback(Callback: TBtnEventProc; ParamCount: Integer): Longword; external 'wrapcallbackaddr@files:CallbackCtrl.dll stdcall';

function _ImgLoad(Wnd :HWND; FileName :PAnsiChar; Left, Top, Width, Height :integer; Stretch, IsBkg :boolean) :Longint; external 'ImgLoad@files:botva2.dll stdcall';
//загружает изображение в память, сохраняет переданные параметры
//Wnd          - хэндл окна, в котором будет выведено изображение
//FileName     - файл изображения
//Left,Top     - координаты верхнего левого угла вывода изображения (в координатах клиентской области Wnd)
//Width,Height - ширина, высота изображения
//               если Stretch=True, то изображение будет растянуто/сжато в прямоугольной области
//               Rect.Left:=Left;
//               Rect.Top:=Top;
//               Rect.Right:=Left+Width;
//               Rect.Bottom:=Top+Height;
//               если Stretch=False, то параметры Width,Height игнорируются и вычисляются самой ImgLoad, т.е. можно передать 0
//Stretch      - масштабировать изображение или нет
//IsBkg        - если IsBkg=True, изображение будет выведено на фоне формы,
//               поверх него будут отрисованы графические объекты (TLabel, TBitmapImage и т.д.),
//               затем поверх всего будут выведены изображения с флагом IsBkg=False
//возвращаемое значение - указатель на структуру, хранящей изображение и его парметры, приведенный к типу Longint
//изображения будут выведены в той последовательности, в которой вызывается ImgLoad

procedure ImgSetVisiblePart(img:Longint; NewLeft, NewTop, NewWidth, NewHeight : integer); external 'ImgSetVisiblePart@files:botva2.dll stdcall';
//сохраняет новые координаты видимой части изображения, новую ширину и высоту. в координатах оригинального изображения
//img                - значение полученное при вызове ImgLoad.
//NewLeft,NewTop     - новый левый верхний угол видимой области.
//NewWidth,NewHeight - новая ширина, высота видимой области.
//PS изначально (при вызове ImgLoad) изображение считается полностью видимым.
//   если возникла необходимость отображать только часть картинки, то используем эту процедуру

procedure ImgGetVisiblePart(img:Longint; var Left, Top, Width, Height : integer); external 'ImgGetVisiblePart@files:botva2.dll stdcall';
//возвращает координаты видимой части изображения, ширину и высоту
//img                - значение полученное при вызове ImgLoad
//NewLeft,NewTop     - левый верхний угол видимой области
//NewWidth,NewHeight - ширина, высота видимой области.

procedure ImgSetPosition(img :Longint; NewLeft, NewTop, NewWidth, NewHeight :integer); external 'ImgSetPosition@files:botva2.dll stdcall';
//сохраняет новые координаты для вывода изображения, новую ширину и высоту. в координатах родительского окна
//img                - значение полученное при вызове ImgLoad
//NewLeft,NewTop     - новый левый верхний угол
//NewWidth,NewHeight - новая ширина, высота. если в ImgLoad был передан Stretch=False, то NewWidth,NewHeight игнорируются

procedure ImgGetPosition(img:Longint; var Left, Top, Width, Height:integer); external 'ImgGetPosition@files:botva2.dll stdcall';
//возвращает координаты вывода изображения, ширину и высоту
//img          - значение полученное при вызове ImgLoad
//Left,Top     - левый верхний угол
//Width,Height - ширина, высота.

procedure ImgSetVisibility(img :Longint; Visible :boolean); external 'ImgSetVisibility@files:botva2.dll stdcall';
//сохраняет параметр видимости изображения
//img     - значение полученное при вызове ImgLoad
//Visible - видимость

function ImgGetVisibility(img:Longint):boolean; external 'ImgGetVisibility@files:botva2.dll stdcall';
//img - значение полученное при вызове ImgLoad
//возвращаемое значение - видимость изображения

procedure ImgSetTransparent(img:Longint; Value:integer); external 'ImgSetTransparent@files:botva2.dll stdcall';
//устанавливает прозрачность изображения
//img   - значение полученное при вызове ImgLoad
//Value - прозрачность (0-255)

function ImgGetTransparent(img:Longint):integer; external 'ImgGetTransparent@files:botva2.dll stdcall';
//получить значение прозрачности
//img   - значение полученное при вызове ImgLoad
//возвращаемое значение - текущая прозрачность изображения

procedure ImgRelease(img :Longint); external 'ImgRelease@files:botva2.dll stdcall';
//удаляет изображение из памяти
//img - значение полученное при вызове ImgLoad

procedure ImgApplyChanges(h:HWND); external 'ImgApplyChanges@files:botva2.dll stdcall';
//формирует окончательное изображение для вывода экран,
//учитывая все изменения внесенные вызовами ImgLoad, ImgSetPosition, ImgSetVisibility, ImgRelease и обновляет окно
//h - хэндл окна, для которого необходимо сформировать новое изображение


function _BtnCreate(hParent :HWND; Left, Top, Width, Height :integer; FileName :PAnsiChar; ShadowWidth :integer; IsCheckBtn :boolean) :HWND; external 'BtnCreate@files:botva2.dll stdcall';
//hParent           - хэндл окна-родителя, на котором будет создана кнопка
//Left,Top,
//Width,Height      - без комментариев. то же что и для обычных кнопок
//FileName          - файл с изображением состояний кнопки
//                    для обычной кнопки нужно 4 состояния кнопки (соответственно 4 изображения)
//                    для кнопки с IsCheckBtn=True нужно 8 изображений (как для чекбокса)
//                    изображения состояний должны располагаться вертикально
//ShadowWidth       - кол-во пикселей от края рисунка кнопки, до реальной ее границы на рисунке.
//                    нужно чтобы состояние кнопки и курсор на ней менялись как положено
//IsCheckBtn        - если True, то будет создана кнопка (аналог CheckBox) имеющая включенное и выключенное состояние
//                    если False, то создастся обычная кнопка
//возвращаемое значение - хэндл созданной кнопки

procedure BtnSetText(h :HWND; Text :PAnsiChar); external 'BtnSetText@files:botva2.dll stdcall';
//устанавливает текст на кнопке (аналог Button.Caption:='bla-bla-bla')
//h    - хэндл кнопки (результат возвращенный BtnCreate)
//Text - текст, который мы хотим увидеть на кнопке

procedure BtnGetText_(h: HWND; Text: PAnsiChar; var NewSize: integer); external 'BtnGetText@files:botva2.dll stdcall';
//получает текст кнопки
//h    - хэндл кнопки (результат возвращенный BtnCreate)
//Text - буфер принимающий текст кнопки
//возвращаемое значение - длина текста

procedure BtnSetTextAlignment(h :HWND; HorIndent, VertIndent :integer; Alignment :DWORD); external 'BtnSetTextAlignment@files:botva2.dll stdcall';
//устанавливает выравнивание текста на кнопке
//h          - хэндл кнопки (результат возвращенный BtnCreate)
//HorIndent  - горизонтальный отступ текста от края кнопки
//VertIndent - вертикальный отступ текста от края кнопки
//Alignment  - выравнивание текста. задается константами balLeft, balCenter, balRight, balVCenter,
//             или комбинацией balVCenter с остальными. например, balVCenter or balRight

procedure BtnSetFont(h :HWND; Font :Cardinal); external 'BtnSetFont@files:botva2.dll stdcall';
//устанавливает шрифт для кнопки
//h    - хэндл кнопки (результат возвращенный BtnCreate)
//Font - дескриптор устанавливаемого шрифта
//       чтобы не мучаться с WinAPI-шными функциями можно создать шрифт стандартными средствами инно и передать его хэндл
//       например,
//       var
//         Font:TFont;
//         . . .
//       begin
//         . . .
//         Font:=TFont.Create;
//         все свойства можно не устанавливать, при создании свойства заполняются значениями по умолчанию. меняем только то что нам нужно
//         with Font do begin
//           Name:='Tahoma';
//           Size:=10;
//           . . .
//         end;
//         BtnSetFont(hBtn,Font.Handle);
//         . . .
//       end;
//       ну и при выходе из программы (или когда он станет не нужен) не забываем уничтожить свой шрифт Font.Free;

procedure BtnSetFontColor(h :HWND; NormalFontColor, FocusedFontColor, PressedFontColor, DisabledFontColor :Cardinal); external 'BtnSetFontColor@files:botva2.dll stdcall';
//устанавливает цвет шрифта для кнопки во включенном и выключенном сосотоянии
//h                 - хэндл кнопки (результат возвращенный BtnCreate)
//NormalFontColor   - цвет текста на кнопе в нормальном состоянии
//FocusedFontColor  - цвет текста на кнопе в подсвеченном состоянии
//PressedFontColor  - цвет текста на кнопе в нажатом состоянии
//DisabledFontColor - цвет текста на кнопе в отключенном состоянии

function BtnGetVisibility(h :HWND) :boolean; external 'BtnGetVisibility@files:botva2.dll stdcall';
//получает видимость кнопки (аналог f:=Button.Visible)
//h - хэндл кнопки (результат возвращенный BtnCreate)
//возвращаемое значение - видимость кнопки

procedure BtnSetVisibility(h :HWND; Value :boolean); external 'BtnSetVisibility@files:botva2.dll stdcall';
//устанавливает видимость кнопки (аналог Button.Visible:=True / Button.Visible:=False)
//h     - хэндл кнопки (результат возвращенный BtnCreate)
//Value - значение видимости

function BtnGetEnabled(h :HWND) :boolean; external 'BtnGetEnabled@files:botva2.dll stdcall';
//получает доступность кнопки (аналог f:=Button.Enabled)
//h - хэндл кнопки (результат возвращенный BtnCreate)
//возвращаемое значение - доступность кнопки

procedure BtnSetEnabled(h :HWND; Value :boolean); external 'BtnSetEnabled@files:botva2.dll stdcall';
//устанвливает доступность кнопки (аналог Button.Enabled:=True / Button.Enabled:=False)
//h - хэндл кнопки (результат возвращенный BtnCreate)
//Value - значение доступности кнопки

function BtnGetChecked(h :HWND) :boolean; external 'BtnGetChecked@files:botva2.dll stdcall';
//получает состояние (включена/выключена) кнопки (аналог f:=Checkbox.Checked)
//h - хэндл кнопки (результат возвращенный BtnCreate)

procedure BtnSetChecked(h :HWND; Value :boolean); external 'BtnSetChecked@files:botva2.dll stdcall';
//устанвливает состояние (включена/выключена) кнопки (аналог Сheckbox.Checked:=True / Сheckbox.Checked:=False)
//h - хэндл кнопки (результат возвращенный BtnCreate)
//Value - значение состояния кнопки

procedure BtnSetEvent(h :HWND; EventID :integer; Event :Longword); external 'BtnSetEvent@files:botva2.dll stdcall';
//устанавливает событие для кнопки
//h       - хэндл кнопки (результат возвращенный BtnCreate)
//EventID - идентификатор события, заданный константами   BtnClickEventID, BtnMouseEnterEventID, BtnMouseLeaveEventID, BtnMouseMoveEventID
//Event   - адрес процедуры выполняемой при наступлении указанного события
//пример использования - BtnSetEvent(hBtn, BtnClickEventID, WrapBtnCallback(@BtnClick,1));

procedure BtnGetPosition(h:HWND; var Left, Top, Width, Height: integer);  external 'BtnGetPosition@files:botva2.dll stdcall';
//получает координаты левого верхнего угла и размер кнопки
//h             - хэндл кнопки (результат возвращенный BtnCreate)
//Left, Top     - координаты верхнего левого угла (в координатах родительского окна)
//Width, Height - ширина, высота кнопки

procedure BtnSetPosition(h:HWND; NewLeft, NewTop, NewWidth, NewHeight: integer);  external 'BtnSetPosition@files:botva2.dll stdcall';
//устанавливает координаты левого верхнего угла и размер кнопки
//h                   - хэндл кнопки (результат возвращенный BtnCreate)
//NewLeft, NewTop     - новые координаты верхнего левого угла (в координатах родительского окна)
//NewWidth, NewHeight - новые ширина, высота кнопки

procedure BtnRefresh(h :HWND); external 'BtnRefresh@files:botva2.dll stdcall';
//немедленно перерисовывает кнопку, в обход очереди сообщений. вызывать, если кнопка не успевает перерисовываться
//h - хэндл кнопки (результат возвращенный BtnCreate)

procedure BtnSetCursor(h:HWND; hCur:Cardinal); external 'BtnSetCursor@files:botva2.dll stdcall';
//устанавливает курсор для кнопки
//h    - хэндл кнопки (результат возвращенный BtnCreate)
//hCur - дескриптор устанавливаемого курсора
//DestroyCursor вызывать не обязательно, он будет уничтожен при вызове gdipShutDown;

function GetSysCursorHandle(id:integer):Cardinal; external 'GetSysCursorHandle@files:botva2.dll stdcall';
//загружает стандартный курсор по его идентификатору
//id - идентификатор стандартного курсора. идентификаторы стандартных курсоров задаются константами OCR_... , значения которых ищем в инете
//возвращаемое значение  - дескриптор загруженного курсора

procedure gdipShutdown(); external 'gdipShutdown@files:botva2.dll stdcall';
//обязательно вызвать при завершении приложения


procedure _CreateFormFromImage(h:HWND; FileName:PAnsiChar); external 'CreateFormFromImage@files:botva2.dll stdcall';
//создать форму по PNG-рисунку (в принципе можно использовать другие форматы изображений)
//h        - хэндл окна
//FileName - путь к файлу изображения
//на такой форме не будут видны контролы (кнопки, чекбоксы, эдиты и т.д.) !!!

function CreateBitmapRgn(DC: LongWord; Bitmap: HBITMAP; TransClr: DWORD; dX:integer; dY:integer): LongWord; external 'CreateBitmapRgn@files:botva2.dll stdcall';
//создать регион из битмапа
//DC       - контекст формы
//Bitmap   - битмап по которому будем строить регион
//TransClr - цвет пикселей, которые не будут включены в регион (прозрачный цвет)
//dX,dY    - смещение региона на форме

procedure SetMinimizeAnimation(Value: Boolean); external 'SetMinimizeAnimation@files:botva2.dll stdcall';
//включить/выклюсить анимацию при сворачивании окон

function GetMinimizeAnimation: Boolean; external 'GetMinimizeAnimation@files:botva2.dll stdcall';
//получить текущее состояние анимации сворачивания окон


function _CheckBoxCreate(hParent:HWND; Left,Top,Width,Height:integer; FileName:PAnsiChar; GroupID, TextIndent:integer) :HWND; external 'CheckBoxCreate@files:botva2.dll stdcall';
//hParent,Left,Top,Width,Height,FileName как у кнопок
//GroupID - для радиобатонов. в одной группе может быть выбран только 1 радибатон. 
//GroupID=0 - без группы. это будет чекбокс. остальное радиобатоны
//TextIndent - отступ текста от картинки чекбокса/радиобатона (в пикселях)

//все остальные процедры/функции по аналогии с кнопками
procedure CheckBoxSetText(h :HWND; Text :PAnsiChar); external 'CheckBoxSetText@files:botva2.dll stdcall';
procedure CheckBoxGetText_(h: HWND; Text: PAnsiChar; var NewSize: integer); external 'CheckBoxGetText@files:botva2.dll stdcall'; //скорее всего работает криво
procedure CheckBoxSetFont(h:HWND; Font:LongWord); external 'CheckBoxSetFont@files:botva2.dll stdcall';
procedure CheckBoxSetEvent(h:HWND; EventID:integer; Event:Longword); external 'CheckBoxSetEvent@files:botva2.dll stdcall';
procedure CheckBoxSetFontColor(h:HWND; NormalFontColor, FocusedFontColor, PressedFontColor, DisabledFontColor: Cardinal); external 'CheckBoxSetFontColor@files:botva2.dll stdcall';
function CheckBoxGetEnabled(h:HWND):boolean; external 'CheckBoxGetEnabled@files:botva2.dll stdcall';
procedure CheckBoxSetEnabled(h:HWND; Value:boolean); external 'CheckBoxSetEnabled@files:botva2.dll stdcall';
function CheckBoxGetVisibility(h:HWND):boolean; external 'CheckBoxGetVisibility@files:botva2.dll stdcall';
procedure CheckBoxSetVisibility(h:HWND; Value:boolean); external 'CheckBoxSetVisibility@files:botva2.dll stdcall';
procedure CheckBoxSetCursor(h:HWND; hCur:LongWord); external 'CheckBoxSetCursor@files:botva2.dll stdcall';
procedure CheckBoxSetChecked(h:HWND; Value:boolean); external 'CheckBoxSetChecked@files:botva2.dll stdcall';
function CheckBoxGetChecked(h:HWND):boolean; external 'CheckBoxGetChecked@files:botva2.dll stdcall';
procedure CheckBoxRefresh(h:HWND); external 'CheckBoxRefresh@files:botva2.dll stdcall';
procedure CheckBoxSetPosition(h:HWND; NewLeft, NewTop, NewWidth, NewHeight: integer); external 'CheckBoxSetPosition@files:botva2.dll stdcall';
procedure CheckBoxGetPosition(h:HWND; var Left, Top, Width, Height: integer); external 'CheckBoxGetPosition@files:botva2.dll stdcall';

function BtnGetText(hBtn: HWND): string;
var
  buf: AnsiString;
  NewSize: integer;
begin
  buf:='';
  NewSize:=0;
  BtnGetText_(hBtn, PAnsiChar(buf), NewSize);
  if NewSize > 0 then begin
    SetLength(buf, NewSize);
    BtnGetText_(hBtn, PAnsiChar(buf), NewSize);
  end;
  Result := string(buf);
end;

Function ImgLoad(Wnd: HWND; FileName: PAnsiChar; Left, Top, Width, Height: Integer; Stretch, IsBkg: Boolean): Longint;
begin
 if not FileExists(ExpandConstant('{tmp}\' + FileName)) then
  ExtractTemporaryFiles(FileName);
 Result := _ImgLoad(Wnd, ExpandConstant('{tmp}\' + FileName), Left, Top, Width, Height, Stretch, IsBkg);
end;

Function BtnCreate(hParent: HWND; Left, Top, Width, Height: Integer; FileName: PAnsiChar; ShadowWidth: Integer; IsCheckBtn: Boolean): HWND;
begin
 if not FileExists(ExpandConstant('{tmp}\' + FileName)) then
  ExtractTemporaryFiles(FileName);
 Result := _BtnCreate(hParent, Left, Top, Width, Height, ExpandConstant('{tmp}\' + FileName), ShadowWidth, IsCheckBtn);
end;

Function CheckBoxCreate(hParent: HWND; Left, Top, Width, Height: Integer; FileName: PAnsiChar; GroupID, TextIndent: Integer): HWND;
begin
 if not FileExists(ExpandConstant('{tmp}\' + FileName)) then
  ExtractTemporaryFiles(FileName);
 Result := _CheckBoxCreate(hParent, Left, Top, Width, Height, ExpandConstant('{tmp}\' + FileName), GroupID, TextIndent);
end;

function CheckBoxGetText(hBtn: HWND): string;
var
  buf: AnsiString;
  NewSize: integer;
begin
  buf:='';
  NewSize:=0;
  CheckBoxGetText_(hBtn, PAnsiChar(buf), NewSize);
  if NewSize > 0 then begin
    SetLength(buf, NewSize);
    CheckBoxGetText_(hBtn, PAnsiChar(buf), NewSize);
  end;
  Result := string(buf);
end;

<event('DeinitializeSetup')>
procedure DeinitializeBotva();
begin
 gdipShutdown();
end;
