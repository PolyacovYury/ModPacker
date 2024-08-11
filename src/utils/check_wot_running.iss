// © Kotyarko_O, 2020 \\

[CustomMessages]
en.runningApplicationFound=Running "World of Tanks" application found.%nIt is recommended that you allow Setup to automatically close the application.
ru.runningApplicationFound=Обнаружено запущенное приложение "World of Tanks".%nПеред продолжением требуется закрыть все экземпляры приложения.

[Code]

Function CheckForGameRun(List: TNewComboBox): Boolean;
begin
 Result := True;
 if WotList_Selected_IsStarted(List) then begin
  if MsgBox(CustomMessage('runningApplicationFound'), mbError, MB_YESNO or MB_DEFBUTTON1) = IDYES then
   WotList_Selected_Terminate(List)
  else
   Result := False;
 end;
end;
