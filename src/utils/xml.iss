// Author: Sherogat \\
// http://krinkels.org/threads/xml.1902/ \\

[Code]
type
  XMLString = AnsiString;
  
  TTagPoint = record
    Name: String;
    BeginPosI: Integer;
    BeginPosII: Integer;
    EndPosI: Integer;
    EndPosII: Integer;
    Level: Integer;
    IsSingle: Boolean;
  end;

const
  CP_ACP        = 0;
  CP_UTF8       = 65001;
  CodePageUTF8  = 'utf-8';
  
Function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD; lpMultiByteStr: PAnsiChar; cbMultiByte: integer; lpWideCharStr: PAnsiChar; cchWideChar: integer): longint; external 'MultiByteToWideChar@kernel32.dll stdcall';
Function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD; lpWideCharStr: PAnsiChar; cchWideChar: integer; lpMultiByteStr: PAnsiChar; cbMultiByte: integer; lpDefaultChar: integer; lpUsedDefaultChar: integer): longint; external 'WideCharToMultiByte@kernel32.dll stdcall';

function AnsiToUtf8(strSource: String): string;
var
  nRet2, len: integer;
  WideCharBuf, MultiByteBuf: AnsiString;
begin
  Len:= Length(strSource);
  SetLength(WideCharBuf, Len * 2);
  SetLength(MultiByteBuf, Len * 2);
  MultiByteToWideChar(CP_ACP, 0, PAnsiChar(strSource), Len, WideCharBuf, Length(WideCharBuf));
  nRet2:= WideCharToMultiByte(CP_UTF8, 0, PAnsiChar(WideCharBuf), Len, MultiByteBuf, Length(MultiByteBuf), 0, 0);
  Result:= Trim(Copy(MultiByteBuf, 1, nRet2));
end;

function Utf8ToAnsi(strSource: String): string;
var
  nRet2, len: integer;
  WideCharBuf, MultiByteBuf: AnsiString;
begin
  Len:= Length(strSource);
  SetLength(WideCharBuf, Len*2);
  SetLength(MultiByteBuf, Len*2);
  MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(strSource), -1, WideCharBuf, Length(WideCharBuf));
  nRet2:= WideCharToMultiByte(CP_ACP, 0, PAnsiChar(WideCharBuf), -1, MultiByteBuf, Length(MultiByteBuf), 0, 0);
  Result:= Trim(Copy(MultiByteBuf, 1, nRet2));
end;

function GetExists(TagArr: array of TTagPoint): Boolean;
var
  n: integer;
begin
  Result:= False;
  if (GetArrayLength(TagArr) > 1) then begin
    Result:= True;
    for n:= GetArrayLength(TagArr)-1 downto 1 do begin
      Result:= Result and (TagArr[n].BeginPosI > TagArr[n-1].BeginPosI);
      Result:= Result and (TagArr[n].EndPosII < TagArr[n-1].EndPosII);
    end;
  end else begin
    Result:= (TagArr[0].BeginPosI > 0)and(TagArr[0].EndPosII > 0);
  end;
end;

function ExpandTags(const sFileText, sTagName: string): array of TTagPoint;
var
  i, k, n, d: integer;
  sTags: array of TTagPoint;
  tmp, tmp2: String;
begin
  SetArrayLength(Result, 0);
  If Pos('\', STagName) > 0 then try
    repeat
      i:= GetArrayLength(sTags); SetArrayLength(sTags, i+1);
      sTags[i].Name:= Copy(sTagName, 1, Pos('\', sTagName)-1);
      sTags[i].Level:= i; Delete(sTagName, 1, Pos('\', sTagName));
    until Pos('\', STagName) = 0;
  finally begin i:= GetArrayLength(sTags); SetArrayLength(sTags, i+1); sTags[i].Level:= i;
                sTags[i].Name:= Copy(sTagName, 1, Length(sTagName));
          end;
  end else begin
    SetArrayLength(sTags, 1);
    sTags[0].Name:= sTagName;
  end;
  for i:=0 to GetArrayLength(sTags)-1 do begin
    if i=0 then begin
      k:=0;
      tmp:= sFileText;
    end else begin
      k:= sTags[i-1].BeginPosII;
      tmp:= copy(sFileText, sTags[i-1].BeginPosII+1, sTags[i-1].EndPosI-sTags[i-1].BeginPosII-1);
    end;
    n:= Pos('<'+sTags[i].Name, tmp);
    if n<>0 then begin
      d:= n;
      while tmp[n]<>'>' do n:=n+1;
      sTags[i].BeginPosI:= k+d;
      sTags[i].BeginPosII:= n+k;
      sTags[i].EndPosI:= Pos('</'+sTags[i].Name+'>', tmp)+k;
      
      if sTags[i].EndPosI<=k then begin
        tmp2:= Copy(tmp, d, 2);
        while (d<=Length(tmp))and(tmp2<>'</')and(tmp2<>'/>') do begin
          d:= d+1;
          tmp2:= Copy(tmp, d, 2);
        end;
        if d<Length(tmp) then begin
          if d<n then
            sTags[i].IsSingle:= True;
          sTags[i].EndPosI:= d+k;
        end;
      end;
      if sTags[i].EndPosI>0 then begin
        sTags[i].EndPosII:= sTags[i].EndPosI;
        while sFileText[sTags[i].EndPosII]<>'>' do
          sTags[i].EndPosII:= sTags[i].EndPosII+1;
      end;
    end;
  end;
  Result:= sTags;
end;

function XMLStringChangeValue(var sFileText: XMLString; sTagName, sTagParam: string): Boolean;
var
  Tags: array of TTagPoint;
  i: Integer;
begin
  Result:= False;
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    If GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      if Tags[i].IsSingle then Exit;
      Result:= True;
      sFileText:= Copy(sFileText,1,Tags[i].BeginPosII) + AnsiToUtf8(sTagParam) + Copy(sFileText,Tags[i].EndPosI,Length(sFileText));
    end;
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringWriteValue(var sFileText: XMLString; sTagName, sTagType, sTagParam: String; IsSingleTag: Boolean): Boolean;
var
  sSpace, sText: XMLString;
  i, k, n, CopyPos, last: Integer;
  Tags: array of TTagPoint;
begin
  Result:= False;
  if sFileText = '' then
    sFileText:= '<?xml version="1.0" encoding="utf-8" standalone="yes"?>';
  if  sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    i:= GetArrayLength(Tags)-1; sText:='';
    if ((i-1)>=0) then for n:=0 to i-1 do begin
      sSpace:= #13#10; if (Tags[n].Level-1>=0) then
        for k:=0 to Tags[n].Level-1 do sSpace:=sSpace+#9;
      if (Tags[n].BeginPosII=0)and(Tags[n].EndPosI=0) then sText:= sText+sSpace+'<'+Tags[n].Name+'>';
    end;
    sSpace:=#13#10; if (i<>0) then for k:= 0 to Tags[i].Level-1 do sSpace:= sSpace+#9;

    sText:= sText+sSpace+'<'+Tags[i].Name;
    if (sTagType <> '') then sText:= sText+' type="'+sTagType+'"';
    if not IsSingleTag then begin
      sText:= sText+'>';
      if (sTagParam <> '') then sText:= sText+AnsiToUtf8(sTagParam)
      else sText:= sText+sSpace;
      sText:= sText+'</'+Tags[i].Name+'>';
    end else
      sText:= sText+'/>';
      
    if ((i-1)>=0) then for n:=i-1 downto 0 do begin
      sSpace:= #13#10; if (Tags[n].Level-1>=0) then for k:=0 to Tags[n].Level-1 do sSpace:=sSpace+#9;
      if (Tags[n].BeginPosI=0)and(Tags[n].EndPosII=0) then sText:= sText+sSpace+'</'+Tags[n].Name+'>';
    end;
    
    last:= -1; if i<>0 then for k:= i-1 downto 0 do begin
      if Tags[k].EndPosI<>0 then begin last:= k; Break; end;
    end;
    
    if GetExists(Tags) then begin
      CopyPos:= Tags[i].BeginPosI-1;
      n:= Tags[i].EndPosII;
      sText:= Trim(sText);
    end else begin
      if (i=0)or(last=-1) then begin
        CopyPos:= Length(sFileText); while sFileText[CopyPos] <> '>' do CopyPos:= CopyPos-1;
      end else begin
        CopyPos:= Tags[last].EndPosI-1; while sFileText[CopyPos] <> '>' do CopyPos:= CopyPos-1;
      end;
      n:= CopyPos;
    end;
    Result:= True;
    
    sFileText:= Copy(sFileText, 1, CopyPos)+sText+Copy(sFileText,n+1,Length(sFileText));
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringReadValue(sFileText: XMLString; sTagName: string; isNeedToAnsiConvertation: Boolean; var sData: string): Boolean;
var
  i: Integer; Tags: array of TTagPoint;
begin
  Result:= False
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    If GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      if Tags[i].IsSingle then Exit;
      sData:= Copy(sFileText, Tags[i].BeginPosII+1, Tags[i].EndPosI-Tags[i].BeginPosII-1);
      if isNeedToAnsiConvertation then
       sData:= Utf8ToAnsi(sData);
      Result:= True;
    end;
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringDeleteValue(var sFileText: XMLString; sTagName: string): Boolean;
var
  b,e,i: Integer; Tags: array of TTagPoint;
begin
  Result:= False;
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    If GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      b:= Tags[i].BeginPosI-1; e:= Tags[i].EndPosII;
      while (b-1<>1)and(sFileText[b-1] <> '>') do b:=b-1;
      while (e+1<>Length(sFileText))and(sFileText[e-2] <> '>') do e:=e+1;
      Result:= True;
      sFileText:= Copy(sFileText,1,b) + Copy(sFileText,e,Length(sFileText));
    end;
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringKeyExists(sFileText: XMLString; sTagName: String): Boolean;
var
  Tags: array of TTagPoint;
begin
  Result:= False;
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    Result:= GetExists(Tags);
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringGetSubkeys(sFileText: XMLString; sTagName: String; var Data: TArrayOfString): Boolean;
var
  Tags: array of TTagPoint;
  tmp: String;
  i, k, n: Integer;
begin
  Result:= False;
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    if GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      if Tags[i].IsSingle then Exit;
      tmp:= copy(sFileText, Tags[i].BeginPosII+1, Tags[i].EndPosI-Tags[i].BeginPosII-1);
      repeat
        k:= Pos('<', tmp);
        if k<=0 then Break;
        if k<>1 then Delete(tmp, 1, k-1);
        i:= Length(tmp);
        k:= 2;
        while (k<=i)and(tmp[k]<>' ')and(tmp[k]<>'>') do k:=k+1;
        n:= GetArrayLength(Data);
        SetArrayLength(Data, n+1);
        Data[n]:= copy(tmp, 2, k-2);
        k:= Pos('</'+Data[n]+'>', tmp);
        while (k<=i)and(tmp[k]<>'>') do k:=k+1;
        Delete(tmp, 1, k);
      until tmp='';
    end;
    Result:= GetArrayLength(Data)>0;
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringGetTagParam(sFileText: XMLString; sTagName, sParamName: String; var Data: String): Boolean;
var
  Tags: array of TTagPoint;
  tmp: String;
  i, k, n: Integer;
begin
  Result:= False;
  Data:= '';
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    if GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      tmp:= Copy(sFileText, Tags[i].BeginPosI, tags[i].BeginPosII-Tags[i].BeginPosI+1);
      Delete(tmp, 1, Pos(' ', tmp));
      i:= Pos(AnsiLowercase(sParamName)+'=', AnsiLowercase(tmp));
      if i>0 then begin
        while tmp[i]<>'"' do i:= i+1;
        k:= i+1;
        while tmp[k]<>'"' do k:=k+1;
        n:= k-i-1;
        if n<>0 then begin
          Data:= Utf8ToAnsi(Copy(tmp, i+1, n));
          Result:= True;
        end;
      end;
    end;
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringSetTagParam(var sFileText: XMLString; sTagName, sParamName, sParamValue: String): Boolean;
var
  Tags: array of TTagPoint;
  tmp, tmp2: String;
  i, k, n, c, d: Integer;
begin
  Result:= False;
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    if GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      tmp:= Copy(sFileText, Tags[i].BeginPosI, Tags[i].BeginPosII-Tags[i].BeginPosI+1);
      k:= Pos(AnsiLowercase(sParamName)+'=', AnsiLowercase(tmp));
      if k>0 then begin
        while tmp[k]<>'"' do k:= k+1;
        n:= k+1;
        while tmp[n]<>'"' do n:= n+1;
        c:= Tags[i].BeginPosI+k-1;
        d:= Tags[i].BeginPosI+n-1;
        tmp2:= AnsiToUtf8(sParamValue);
      end else begin
        tmp2:= ' '+AnsiToUtf8(sParamName+'="'+sParamValue+'"');
        if (not Tags[i].IsSingle) then begin
          d:= Tags[i].BeginPosII;
          c:= Tags[i].BeginPosII-1;
        end else begin
          d:= Tags[i].EndPosI;
          c:= Tags[i].EndPosI-1;
        end;
      end;
      sFileText:= Copy(sFileText, 1, c)+tmp2+Copy(sFileText, d, Length(sFileText));
      Result:= true;
    end;
  end;
  SetArrayLength(Tags, 0);
end;

function XMLStringDeleteTagParam(var sFileText: XMLString; sTagName, sParamName: String): Boolean;
var
  Tags: array of TTagPoint;
  tmp: String;
  i, k, n, c: Integer;
begin
  Result:= False;
  if sFileText <> '' then begin
    Tags:= ExpandTags(sFileText, sTagName);
    if GetExists(Tags) then begin
      i:= GetArrayLength(Tags)-1;
      tmp:= copy(sFileText, Tags[i].BeginPosI, Tags[i].BeginPosII-Tags[i].BeginPosI+1);
      k:= Pos(AnsiLowercase(sParamName), AnsiLowercase(tmp));
      if k>0 then begin
        c:= k;
        while tmp[c]<>'"'do c:=c+1;
        c:=c+1;
        while tmp[c]<>'"'do c:=c+1;
        if (tmp[k-1]=' ')and(tmp[c+1]=' ') then c:=c+1;
        k:= Tags[i].BeginPosI+k-1;
        n:= Tags[i].BeginPosI+c;
        sFileText:= Copy(sFileText, 1, k-1)+Copy(sFileText, n, Length(sFileText));
        Result:= true;
      end;
    end;
  end;
  SetArrayLength(tags, 0);
end;

function XMLFileChangeValue(sFileName, sTagName, sTagParam: string): Boolean;
var
  sFileText: XMLString;
begin
  LoadStringFromFile(sFilename, sFileText);
  Result:= XMLStringChangeValue(sFileText, sTagName, sTagParam);
  if Result then
    SaveStringToFile(sFileName, sFileText, False);
  SetLength(sFileText, 0);
end;

function XMLFileWriteValue(sFileName, sTagName, sTagType, sTagParam: string; IsSingleTag: Boolean): Boolean;
var
  sFileText: XMLString;
begin
  If not FileExists(sFilename) then
    sFileText:= ''
  else
    LoadStringFromFile(sFileName, sFileText);
  Result:= XMLStringWriteValue(sFileText, sTagName, sTagType, sTagParam, IsSingleTag);
  if Result then
    SaveStringToFile(sFilename, sFileText, False);
  SetLength(sFileText, 0);
end;

function XMLFileReadValue(sFileName, sTagName: string; var sData: string): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFileName, sFileText) then
    Result:= XMLStringReadValue(sFileText, sTagName, True, sData);
  SetLength(sFileText, 0);
end;

function XMLFileDeleteValue(sFileName, sTagName: string): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFileName, sFileText) then
    Result:= XMLStringDeleteValue(sFileText, sTagName);
  if Result then
    SaveStringToFile(sFileName, sFileText, False);
  SetLength(sFileText, 0);
end;

function XMLFileKeyExists(sFileName, sTagName: String): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFilename, sFileText) then
    Result:= XMLStringKeyExists(sFileText, sTagName);
  SetLength(sFileText, 0);
end;

function XMLFileGetSubkeys(sFileName, sTagName: String; var Data: TArrayOfString): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFilename, sFileText) then
    Result:= XMLStringGetSubkeys(sFileText, sTagName, Data);
  SetLength(sFileText, 0);
end;

function XMLFileGetTagParam(sFilename, sTagName, sParamName: String; var Data: String): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFilename, sFileText) then
    Result:= XMLStringGetTagParam(sFileText, sTagName, sParamName, Data);
  SetLength(sFileText, 0);
end;

function XMLFileSetTagParam(sFilename, sTagName, sParamName, sParamValue: String): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFilename, sFileText) then
    Result:= XMLStringSetTagParam(sFileText, sTagName, sParamName, sParamValue);
  if Result then
    SaveStringToFile(sFileName, sFileText, False);
  SetLength(sFileText, 0);
end;

function XMLFileDeleteTagParam(sFilename, sTagName, sParamName: String): Boolean;
var
  sFileText: XMLString;
begin
  Result:= False;
  if LoadStringFromFile(sFilename, sFileText) then
    Result:= XMLStringDeleteTagParam(sFileText, sTagName, sParamName);
  if Result then
    SaveStringToFile(sFileName, sFileText, False);
  SetLength(sFileText, 0);
end;