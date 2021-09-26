[Code]
function StripAndCheckExists(path: string; defaulted: Boolean): string;
var
  I: Integer;
begin
  Result := '';
  path := Trim(path);
  if defaulted then
    Result := path;
  I := Pos('\worldoftanks.exe', AnsiLowercase(path));
  if Boolean(I) then
    Result := Copy(path, 1, I);
  StringChangeEx(Result, '"', '', True);
  if not DirExists(Result) then
    Result := '';
end;

<event('DeinitializeSetup')>
procedure DeinitializeTemp();
begin
 DelTree(ExpandConstant('{tmp}'), True, True, True);
end;
