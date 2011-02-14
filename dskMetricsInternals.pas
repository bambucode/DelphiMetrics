{ **********************************************************************}
{                                                                       }
{     DeskMetrics DLL - dskMetricsInternals.pas                         }
{     Copyright (c) 2010-2011 DeskMetrics Limited                       }
{                                                                       }
{     http://deskmetrics.com                                            }
{     http://support.deskmetrics.com                                    }
{                                                                       }
{     support@deskmetrics.com                                           }
{                                                                       }
{     This code is provided under the DeskMetrics Modified BSD License  }
{     A copy of this license has been distributed in a file called      }
{     LICENSE with this source code.                                    }
{                                                                       }
{ **********************************************************************}

unit dskMetricsInternals;

interface

uses
  Classes;

{ Internal Functions }
function _GetOperatingSystemVersion: string;
function _GetOperatingSystemServicePack: string;
function _GetOperatingSystemArchicteture: string;
function _GetOperatingSystemLanguage: string;
function _GetOperatingSystemScreen: string;
function _GetJavaVM: string;
function _GetDotNetVersion: string;
function _GetDotNetServicePack: string;
function _GetProcessorName: string;
function _GetProcessorBrand: string;
function _GetProcessorFrequency: Integer;
function _GetProcessorArchicteture: string;
function _GetProcessorCores: string;
function _GetMemoryTotal: string;
function _GetMemoryFree: string;
function _GetDiskTotal: string;
function _GetDiskFree: string;
function _GetTimeStamp: string;
function _GetFlowNumber: string;

{ Internal Sessions Functions }
function _GenerateSessionID: string;
function _SetSessionID: Boolean;
function _GetSessionID: string;

{ .NET Data }
function _GetDotNetData(var FVersion: string; var FServicePack: Integer): Boolean;

{ Internal Internet / HTTP / Post Functions }
function _URLEncode(const FText: string): string;
function _SendPost(var FErrorID: Integer; const FAction: string): string;

{ Proxy Configuration }
function _SetProxy(const FServerAddress: string; FPort: Integer; const FUserName, FPassword: string): Boolean;
function _GetProxy(var FServerAddress: string; var FPort: Integer): Boolean;
function _DisableProxy: Boolean;

{ Internal User ID Functions }
function _GenerateUserID: string;
function _SetUserID(const FID: string): Boolean;
function _GetUserID: string;
function _UserIDExists: Boolean;
function _SaveUserIDReg(const FUserID: string): Boolean;
function _LoadUserIDReg: string;

{ Internal General Functions }
function _SetAppID(const FApplicationID: string): Boolean;
function _GetAppID: string;
function _SetAppVersion (const FVersion: string): Boolean;
function _GetAppVersion: string;

{ Internal Debug / Test Mode }
function  _SetDebugMode(const FEnabled: Boolean): Boolean;
function  _GetDebugMode: Boolean;
function  _GetDebugData: string;

{ Internal Logs }
function  _InsertLogText(const FFunction: string; const FErrorID: Integer): Boolean;
function  _SaveTestLogFile(const FFileName: string): Boolean;

{ Internal Cache Mode }
function _CheckCacheFile: Boolean;
function _DeleteCacheFile: Boolean;
function _GetCacheData: string;
function _GetCacheSize: Int64;
function _SaveCacheFile: Boolean;

{ Encrypt / Decrypt Cache }
function _Rot13(const FString: string): string;

{ Analytics Status }
function _SetStarted(const FEnabled: Boolean): Boolean;
function _GetStarted: Boolean;
function _SetStopped(const FEnabled: Boolean): Boolean;
function _GetStopped: Boolean;

{ Network Bandwidth }
function _GetMaxDailyNetwork: Integer;
function _SetMaxDailyNetwork(const FSize: Integer): Boolean;

{ Storage File }
function _GetMaxStorageFile: Integer;
function _SetMaxStorageFile(const FSize: Integer): Boolean;

{ JSON Functions }
function _GetJSONData(const FField, FJSON: string): string;

{ Internal Errors Functions }
function _ErrorToString(const FErrorID: Integer): string;

{ WMI Functions }
function _GetWMIValue(const FValue, FClass: string): string;

{ GUID Functions }
function _GenerateGUID: string;

{ Stop Thread }
//type
//  TStopThread = class(TThread)
//  protected
//    procedure Execute; override;
//  public
//    constructor Create;
//    destructor Destroy; override;
//end;

{ Post Thread }
type
  TPostThread = class (TThread)
  private
    FErrorID: Integer;
    FAction: string;
    FResponse: string;
    FJSON: string;
  protected
    procedure Execute; override;
  public
    constructor Create(JSON: string; Action: string; ErrorID: Integer);
    destructor Destroy; override;
  end;

implementation

uses
  dskMetricsConsts, dskMetricsVars, dskMetricsWMI, dskMetricsBase64,
  dskMetricsCPUInfo,dskMetricsCommon, dskMetricsWinInfo,
  ActiveX, Windows, SysUtils, Registry, WinInet, Variants,
  DateUtils;

function _SetAppID(const FApplicationID: string): Boolean;
begin
  try
    FAppID := FApplicationID;
    Result := True;
  except
    Result := False;
  end;
end;

function _GetAppID: string;
begin
  try
    Result := Trim(FAppID);
  except
    Result  := '';
  end;
end;

function _SetAppVersion(const FVersion: string): Boolean;
begin
  try
    FAppVersion := FVersion;
    Result      := True;
  except
    Result      := False;
  end;
end;

function _GetAppVersion: string;
begin
  try
    if FAppVersion = NULL_STR then
      Result := Trim(_GetExecutableVersion(ParamStr(0)))
    else
      Result := Trim(FAppVersion);
  except
    Result := NULL_STR;
  end;
end;

function _SetDebugMode(const FEnabled: Boolean): Boolean;
begin
  try
    FDebugMode := FEnabled;
    Result     := True;
  except
    Result     := False;
  end;
end;

function _GetDebugMode: Boolean;
begin
  try
    Result := FDebugMode;
  except
    Result := False;
  end;
end;

function _GetDebugData: string;
begin
  try
    Result := Trim(FDebugData);
  except
    Result := '';
  end;
end;

function _InsertLogText(const FFunction: string; const FErrorID: Integer): Boolean;
begin
  try
    FDebugData := FDebugData + '[' + _GetTimeStamp + '] Method ' + FFunction  + ' (Error: ' + IntToStr(FErrorID) + ' - ' + _ErrorToString(FErrorID) + ')';
    Result    :=_SaveTestLogFile(LOGFILENAME);
  except
    Result    := False;
  end;
end;

function _SaveTestLogFile(const FFileName: string): Boolean;
var
  FFile : TextFile;
begin
  Result := True;
  try
    AssignFile(FFile,IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + FFileName);
    try
      if FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + FFileName) then
        Append(FFile)
      else
        Rewrite(FFile);

      WriteLn(FFile, _GetDebugData);
    finally
      CloseFile(FFile);
    end;
  except
    Result := False;
  end;
end;

function _URLEncode(const FText: string): string;
var
  I: Integer;
  Ch: Char;
begin
  try
    for I := 1 to Length(FText) do
    begin
        Ch := FText[I];
        if ((Ch >= '0') and (Ch <= '9')) or
           ((Ch >= 'a') and (Ch <= 'z')) or
           ((Ch >= 'A') and (Ch <= 'Z')) or
           (Ch = '.') or (Ch = '-') or (Ch = '_') or (Ch = '~') then
            Result := Result + Ch
        else
          Result := Result + '%' +  SysUtils.IntToHex(Ord(Ch), 2);
    end;
  except
    Result := '';
  end;
end;

function _GenerateSessionID: string;
begin
  try
    Result := _GenerateGUID;
  except
    Result := '';
  end;
end;

function _SetSessionID: Boolean;
begin
  try
    FSessionID := _GenerateSessionID;
    Result     := True;
  except
    Result     := False;
    FSessionID := NULL_STR;
  end;
end;

function _GetSessionID: string;
begin
  try
    if FSessionID <> NULL_STR then
      Result := Trim(FSessionID)
    else
    begin
      if _SetSessionID then
        Result := Trim(FSessionID);
    end;
  except
    Result := NULL_STR;
  end;
end;

function _GetTimeStamp: string;
begin
  try
    Result := IntToStr(DateTimeToUnix(Now));
  except
    Result := NULL_STR;
  end;
end;

function _GetUserID: string;
begin
  try
    if FUserID = '' then
    begin
      if _UserIDExists = False then
      begin
        Result := Trim(_GenerateUserID);
        _SaveUserIDReg(Result);
      end
      else
        Result := Trim(_LoadUserIDReg);
    end
    else
      Result := Trim(FUserID);
  except
    Result := '';
  end;
end;

function _SetUserID(const FID: string): Boolean;
begin
  try
    FUserID := FID;
    Result  := True;
  except
    FUserID := '';
    Result  := False;
  end;
end;

function _GenerateUserID: string;
begin
  try
    Result := _GenerateGUID;
  except
    Result := '';
  end;
end;

function _UserIDExists: Boolean;
var
  FRegistry: TRegistry;
begin
  Result := False;
  try
    FRegistry := TRegistry.Create;
    try
      FRegistry.RootKey := REGROOTKEY;
      if FRegistry.OpenKey(REGPATH, True) then
      begin
        Result := FRegistry.ValueExists('ID');
        if Result then
          Result := FRegistry.ReadString('ID') <> '';
      end;
    finally
      FreeAndNil(FRegistry);
    end;
  except
    Result := False;
  end;
end;

function _SaveUserIDReg(const FUserID: string): Boolean;
var
  FRegistry: TRegistry;
begin
  Result := False;
  try
    FRegistry := TRegistry.Create;
    try
      FRegistry.RootKey := REGROOTKEY;
      if FRegistry.OpenKey(REGPATH, True) then
        FRegistry.WriteString('ID', FUserID);
    finally
      FreeAndNil(FRegistry);
    end;
  except
    Result := False;
  end;
end;

function _LoadUserIDReg: string;
var
  FRegistry: TRegistry;
begin
  Result := '';
  try
    FRegistry := TRegistry.Create;
    try
      FRegistry.RootKey := REGROOTKEY;
      if FRegistry.OpenKey(REGPATH, True) then
      begin
        if FRegistry.ValueExists('ID') then;
          Result := FRegistry.ReadString('ID');
      end;
    finally
      FreeAndNil(FRegistry);
    end;
  except
    Result := '';
  end;
end;

function _GetFlowNumber: string;
begin
  try
    FFlowNumber := FFlowNumber + 1;
    Result      := Trim(IntToStr(FFlowNumber));
  except
    Result := '0';
  end;
end;

function _GetOperatingSystemVersion: string;
begin
  try
    Result := Trim(_GetWindowsVersionName);
  except
    Result := NULL_STR;
  end;
end;

function _GetOperatingSystemServicePack: string;
begin
  try
    if Win32CSDVersion = '' then
      Result := '0'
    else
      if Pos('Pack 1', Win32CSDVersion) > 0 then
        Result := '1'
      else
        if Pos('Pack 2', Win32CSDVersion) > 0 then
          Result := '2'
        else
          if Pos('Pack 3', Win32CSDVersion) > 0 then
            Result := '3'
          else
            if Pos('Pack 4', Win32CSDVersion) > 0 then
              Result := '4'
            else
              if Pos('Pack 5', Win32CSDVersion) > 0 then
                Result := '5'
              else
                if Pos('Pack 6', Win32CSDVersion) > 0 then
                  Result := '6'
                else
                  Result := Trim(Win32CSDVersion);
  except
    Result := NULL_STR;
  end;
end;

function _GetOperatingSystemArchicteture: string;
begin
  try
    Result := Trim(IntToStr(_GetOperatingSystemArchictetureInternal));
  except
    Result := NULL_STR;
  end;
end;

function _GetOperatingSystemLanguage: string;
begin
  try
    Result := Trim(IntToStr(GetSystemDefaultLCID));
  except
    Result := NULL_STR;
  end;
end;

function _GetOperatingSystemScreen: string;
var
  FHeight, FWidth: Integer;
begin
  try
    FHeight := GetSystemMetrics(SM_CXSCREEN); { Screen height in pixels }
    FWidth  := GetSystemMetrics(SM_CYSCREEN); { Screen width in pixels  }
    Result  := Trim(IntToStr(FHeight) + 'x' + IntToStr(FWidth));
  except
    Result := NULL_STR;
  end;
end;

function _GetJavaVM: string;
var
  FRegistry: TRegistry;
begin
  Result := NULL_STR;
  try
    Result := NONE_STR;
    FRegistry := TRegistry.Create;
    try
      FRegistry.RootKey := HKEY_LOCAL_MACHINE;
      if FRegistry.OpenKeyReadOnly('\SOFTWARE\JavaSoft\Java Runtime Environment') then
      begin
        if FRegistry.ValueExists('CurrentVersion') then
          Result := Trim(FRegistry.ReadString('CurrentVersion'));
      end;
    finally
      FreeAndNil(FRegistry);
    end;
  except
    Result := NULL_STR;
  end;
end;

function _GetDotNetData(var FVersion: string; var FServicePack: Integer): Boolean;
var
  FRegistry: TRegistry;
begin
  Result := True;
  try
    FVersion     := NONE_STR;
    FServicePack := -1;

    FRegistry := TRegistry.Create;
    try
      FRegistry.RootKey := HKEY_LOCAL_MACHINE;

      if FRegistry.OpenKeyReadOnly('SOFTWARE\Microsoft\NET Framework Setup\NDP\v4') then
      begin
        FVersion     := '4.0';
        FServicePack := 0;
        Exit;
      end;

      if FRegistry.OpenKeyReadOnly('SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5') then
      begin
        FVersion := '3.5';

        if FRegistry.ValueExists('SP') then
          FServicePack := FRegistry.ReadInteger('SP');

        Exit;
      end;

      if FRegistry.OpenKeyReadOnly('SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0') then
      begin
        FVersion := '3.0';

        if FRegistry.ValueExists('SP') then
          FServicePack := FRegistry.ReadInteger('SP');

        Exit;
      end;

      if FRegistry.OpenKeyReadOnly('SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727') then
      begin
        FVersion := '2.0.50727';

        if FRegistry.ValueExists('SP') then
          FServicePack := FRegistry.ReadInteger('SP');

        Exit;
      end;

      if FRegistry.OpenKeyReadOnly('SOFTWARE\Microsoft\NET Framework Setup\NDP\v1.1.4322') then
      begin
        FVersion := '1.1.4322';

        if FRegistry.ValueExists('SP') then
          FServicePack := FRegistry.ReadInteger('SP');

        Exit;
      end;

      if FRegistry.OpenKeyReadOnly('SOFTWARE\Microsoft\.NETFramework\policy\v1.0') then
      begin
        FVersion := '1.0';

        if FRegistry.ValueExists('SP') then
          FServicePack := FRegistry.ReadInteger('SP');

        Exit;
      end;
    finally
      FreeAndNil(FRegistry);
    end;
  except
    Result := False;
  end;
end;

function _GetDotNetVersion: string;
var
  FVersion: string;
  FServicePack: Integer;
begin
  try
    _GetDotNetData(FVersion, FServicePack);
    if FVersion <> '' then
      Result := Trim(FVersion)
    else
      Result := NULL_STR;
  except
    Result := NULL_STR;
  end;
end;

function _GetDotNetServicePack: string;
var
  FVersion: string;
  FServicePack: Integer;
begin
  try
    _GetDotNetData(FVersion, FServicePack);
    if FServicePack > 0 then
      Result := Trim(IntToStr(FServicePack))
    else
      Result := NULL_STR;
  except
    Result := NULL_STR;
  end;
end;

function _GetProcessorName: string;
var
  FRegistry: TRegistry;
begin
  try
    FRegistry := TRegistry.Create;
    try
      FRegistry.RootKey := HKEY_LOCAL_MACHINE;
      if FRegistry.OpenKeyReadOnly('\HARDWARE\DESCRIPTION\System\CentralProcessor\0') then
      begin
        if FRegistry.ValueExists('ProcessorNameString') then
          Result := FRegistry.ReadString('ProcessorNameString');

        if Result <> '' then Result := StringReplace(Result, '(R)', '', [rfReplaceAll,rfIgnoreCase]);
        if Result <> '' then Result := StringReplace(Result, '(TM)', '', [rfReplaceAll,rfIgnoreCase]);

        Result := StringReplace(Result, '  ', '', [rfReplaceAll, rfIgnoreCase]);
        Result := Trim(Result);
      end;
    finally
      FreeAndNil(FRegistry);
    end;
  except
    Result := NULL_STR;
  end;
end;

function _GetProcessorBrand: string;
var
  FProcessorBrand: string;
begin
  try
    FProcessorBrand := _GetProcessorVendorInternal;

    if (FProcessorBrand = '') or (FProcessorBrand = UNKNOWN_STR) then
    begin
      FProcessorBrand  := _GetProcessorName;

      { Detect Intel CPUs }
      if (Pos('Intel', FProcessorBrand) > 0)   or
         (Pos('Pentium', FProcessorBrand) > 0) or
         (Pos('Celeron', FProcessorBrand) > 0) or
         (Pos('GenuineIntel', FProcessorBrand) > 0)
      then
      begin
        Result := 'Intel';
        Exit;
      end;

      { Detect AMD CPUs }
      if (Pos('AMD', FProcessorBrand) > 0) or
         (Pos('Athlon', FProcessorBrand) > 0) or
         (Pos('Sempron', FProcessorBrand) > 0)
      then
      begin
        Result := 'AMD';
        Exit;
      end;
    end
    else
      Result := Trim(FProcessorBrand);
  except
    Result := NULL_STR;
  end;
end;

function _GetProcessorFrequency: Integer;
var
  FProcessorFrequency: Integer;
begin
  try
    FProcessorFrequency     := StrToInt(_GetWMIValue('CurrentClockSpeed', 'Win32_Processor'));
    if (FProcessorFrequency = 0) then
      Result := _GetProcessorFrequencyInternal
    else
      Result := FProcessorFrequency;
  except
    Result := 0;
  end;
end;

function _GetProcessorArchicteture: string;
begin
  try
    Result := Trim(_GetProcessorArchitectureInternal);
  except
    Result := NULL_STR;
  end;
end;

function _GetProcessorCores: string;
var
  FProcessorName: string;
begin
  try
    Result    := _GetWMIValue('NumberOfCores', 'Win32_Processor');
    if (Result = '0') or (Result = '') then
    begin
      FProcessorName := _GetProcessorName;

      if (Pos('DualCore', FProcessorName) > 0)  or (Pos('Dual Core', FProcessorName) > 0) or
        (Pos('Core 2 Duo', FProcessorName) > 0) or (Pos('Core2Duo', FProcessorName) > 0) or
        (Pos('Core2 Duo', FProcessorName) > 0)
      then
        Result := '2'
      else
        Result := NULL_STR;
    end;
  except
    Result := NULL_STR;
  end;
end;

function _GetMemoryTotal: string;
var
  recMemoryStatus: TMemoryStatus;
begin
  try
    recMemoryStatus.dwLength := SizeOf(recMemoryStatus);
    GlobalMemoryStatus(recMemoryStatus);
    Result := Trim(IntToStr(recMemoryStatus.dwTotalPhys));
  except
    Result := NULL_STR;
  end;
end;

function _GetMemoryFree: string;
var
  recMemoryStatus: TMemoryStatus;
begin
  try
    recMemoryStatus.dwLength := SizeOf(recMemoryStatus);
    GlobalMemoryStatus(recMemoryStatus);
    Result := Trim(IntToStr(recMemoryStatus.dwAvailPhys));
  except
    Result := NULL_STR;
  end;
end;

function _GetDiskTotal: string;
begin
  try
    Result := Trim(IntToStr(DiskSize(Ord(_GetWindowsChar) - 64)));
  except
    Result := NULL_STR;
  end;
end;

function _GetDiskFree: string;
begin
  try
    Result := Trim(IntToStr(DiskFree(Ord(_GetWindowsChar) - 64)));
  except
    Result := NULL_STR;
  end;
end;

function _SendPost(var FErrorID: Integer; const FAction: string): string;
var
  FJSONTemp: string;
  hint,hconn,hreq:hinternet;
  hdr: UTF8String;
  buf:array[0..READBUFFERSIZE-1] of PAnsiChar;
  bufsize:dword;
  i,flags:integer;
  data: UTF8String;
  dwSize, dwFlags: DWORD;
begin
  FErrorID  := 0;
  try
    FJSONTemp := FJSONData;

    { have bandwidth? }
    if (FCurrentDailyData >= _GetMaxDailyNetwork) and (_GetMaxDailyNetwork <> -1) then
    begin
      FErrorID := 9;
      Exit;
    end;

    { check type - WebService API Call }
    if FAction = API_SENDDATA then
    begin
      hdr       := UTF8Encode('Content-Type: application/json');
      data      := UTF8Encode('[' + FJSONTemp + ']');
    end;

    hint := InternetOpenW(PWideChar(FPostAgent),INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
    if hint = nil then
    begin
      FErrorID := 2;
      Exit;
    end;

    try
      { Set HTTP request timeout }
      if FPostTimeOut > 0 then
      begin
        InternetSetOption(hint, INTERNET_OPTION_CONNECT_TIMEOUT, @FPostTimeOut, SizeOf(FPostTimeOut));
        InternetSetOption(hint, INTERNET_OPTION_SEND_TIMEOUT,    @FPostTimeOut, SizeOf(FPostTimeOut));
        InternetSetOption(hint, INTERNET_OPTION_RECEIVE_TIMEOUT, @FPostTimeOut, SizeOf(FPostTimeOut));
      end;

      { Set HTTP port }
      hconn := InternetConnect(hint,PChar(FAppID + FPostServer),FPostPort,nil,nil,INTERNET_SERVICE_HTTP,0,1);
      if hconn = nil then
      begin
        FErrorID := 3;
        Exit;
      end;

      try
        if FPostPort = INTERNET_DEFAULT_HTTPS_PORT then
          flags := INTERNET_FLAG_NO_UI or INTERNET_FLAG_SECURE or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
        else
          flags := INTERNET_FLAG_NO_UI;

        hreq := HttpOpenRequest(hconn, 'POST', PChar(FAction), nil, nil, nil, flags, 1);
        if Assigned(hreq) and (FPostPort = INTERNET_DEFAULT_HTTPS_PORT) then
        begin
          dwSize := SizeOf(dwFlags);
          if (InternetQueryOption(hreq, INTERNET_OPTION_SECURITY_FLAGS, @dwFlags, dwSize)) then
          begin
            dwFlags := dwFlags or SECURITY_FLAG_IGNORE_UNKNOWN_CA;
            if not (InternetSetOption(hreq, INTERNET_OPTION_SECURITY_FLAGS, @dwFlags, dwSize)) then
              FErrorID := 4;
          end
          else
            FErrorID := 5;  //InternetQueryOption failed
        end;

        if hreq = nil then
        begin
          FErrorID := 2;
          Exit;
        end;

        try
          if HttpSendRequestA(hreq,PAnsiChar(hdr),Length(hdr), PAnsiChar(Data),Length(Data)) then
          begin
            if (FPostWaitResponse) then
            begin
              { Read server Response }
              bufsize := READBUFFERSIZE;
              while (bufsize > 0) do
              begin
                if not InternetReadFile(hreq,@buf,READBUFFERSIZE,bufsize) then
                begin
                  FErrorID := 7;
                  Break;
                end;

                if (bufsize > 0) and (bufsize <= READBUFFERSIZE) then
                begin
                  for i := 0 to bufsize - 1 do
                    Result := Result + string(buf[i]);
                end;
              end;
            end;

            if _GetMaxDailyNetwork <> -1 then
              FCurrentDailyData := FCurrentDailyData + (SizeOf(Result) * Length(Result));
          end
          else
            FErrorID := 6;
        finally
          InternetCloseHandle(hreq);
        end;
      finally
        InternetCloseHandle(hconn);
      end;
    finally
      InternetCloseHandle(hint);
    end;
  except
    Result   := '';
    FErrorID := 5;
  end;
end;

function _SetProxy(const FServerAddress: string; FPort: Integer; const FUserName, FPassword: string): Boolean;
var
  list: INTERNET_PER_CONN_OPTION_LIST;
  dwBufSize: DWORD;
  hInternet, hInternetConnect: Pointer;
  Options: array[1..3] of INTERNET_PER_CONN_OPTION;
begin
  Result := False;
  try
    if FServerAddress = '' then
    begin
      Result := _DisableProxy;
      Exit;
    end;

    if FPort <= 0 then
      FPort := DEFAULTPROXYPORT;

    dwBufSize                 := SizeOf(list);
    list.dwSize               := SizeOf(list);
    list.pszConnection        := nil;
    list.dwOptionCount        := High(Options);
    Options[1].dwOption       := INTERNET_PER_CONN_FLAGS;
    Options[1].Value.dwValue  := PROXY_TYPE_DIRECT or PROXY_TYPE_PROXY;
    Options[2].dwOption       := INTERNET_PER_CONN_PROXY_SERVER;
    Options[2].Value.pszValue := PAnsiChar(AnsiString(FServerAddress));
    Options[3].dwOption       := INTERNET_PER_CONN_PROXY_BYPASS;
    Options[3].Value.pszValue := '<local>';
    list.pOptions             := @Options;

    hInternet := InternetOpen(PChar('DeskMetrics'), INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
    if hInternet <> nil then
    try
      hInternetConnect := InternetConnect(hInternet, PChar(FServerAddress), FPort, PChar(FUserName), PChar(FPassword),INTERNET_SERVICE_HTTP, 0, 0);
      if hInternetConnect <> nil then
      begin
        Result := InternetSetOption(hInternet, INTERNET_OPTION_PER_CONNECTION_OPTION, @list, dwBufSize);
        if Result then
          Result := InternetSetOption(hInternet, INTERNET_OPTION_REFRESH, nil, 0);
      end;

      if Result then
      begin
        FProxyServer := FServerAddress;
        FProxyPort   := FPort;
        FProxyUser   := FUserName;
        FProxyPass   := FPassword;
      end;
    finally
      InternetCloseHandle(hInternet)
    end;
  except
    Result := False;
  end;
end;

function _GetProxy(var FServerAddress: string; var FPort: Integer): Boolean;
begin
  Result           := True;
  try
    FServerAddress := FProxyServer;
    FPort          := FProxyPort;
  except
    Result         := False;
  end;
end;

function _DisableProxy: Boolean;
var
  list: INTERNET_PER_CONN_OPTION_LIST;
  dwBufSize: DWORD;
  hInternet: Pointer;
  Options: array[1..3] of INTERNET_PER_CONN_OPTION;
begin
  Result := False;
  try
    dwBufSize                 := SizeOf(list);
    list.dwSize               := SizeOf(list);
    list.pszConnection        := nil;
    list.dwOptionCount        := High(Options);
    Options[1].dwOption       := INTERNET_PER_CONN_FLAGS;
    Options[1].Value.dwValue  := PROXY_TYPE_DIRECT or PROXY_TYPE_PROXY;
    Options[2].dwOption       := INTERNET_PER_CONN_PROXY_SERVER;
    Options[2].Value.pszValue := PAnsiChar('');
    Options[3].dwOption       := INTERNET_PER_CONN_PROXY_BYPASS;
    Options[3].Value.pszValue := '<local>';
    list.pOptions             := @Options;

    hInternet := InternetOpen(PChar('DeskMetrics'), INTERNET_OPEN_TYPE_DIRECT, nil, nil, 0);
    if hInternet <> nil then
    try
      Result := InternetSetOption(hInternet, INTERNET_OPTION_PER_CONNECTION_OPTION, @list, dwBufSize);
      if Result then
        Result := InternetSetOption(hInternet, INTERNET_OPTION_REFRESH, nil, 0);
    finally
      InternetCloseHandle(hInternet)
    end;
  except
    Result := False;
  end;
end;

function _GetJSONData(const FField, FJSON: string): string;
var
  iFieldPos, iPos, iFirstQuote, iQuotes: Integer;
begin
  try
    iFirstQuote := 0;
    if Pos(FField, FJSON) > 0 then
    begin
      iFieldPos := Pos('"' + FField + '":', FJSON) + Length(FField) + 2;

      iQuotes := 0;
      iPos    := iFieldPos;
      while iFieldPos <= Length(FJSON) do
      begin
        Inc(iPos);
        if FJSON[iPos] = '"' then
        begin
          Inc(iQuotes);
          if iQuotes = 2 then
          begin
            Result := Copy(FJSON, iFirstQuote + 1, iPos - iFirstQuote - 1);
            Break;
          end;
          iFirstQuote := iPos;
        end;
      end;
    end;
  except
    Result := '';
  end;
end;

function _ErrorToString(const FErrorID: Integer): string;
begin
  try
    case FErrorID of
      0, 1:   Result := 'OK';
      2:      Result := 'Could not open HTTP component (InternetOpen)';
      3:      Result := 'Could not connect to server (InternetConnect)';
      4:      Result := 'Could not modify HTTP options (InternetSetOption)';
      5:      Result := 'Could not modify HTTP security parameters (InternetQueryOption)';
      6:      Result := 'Could not send HTTP request to server (HttpSendRequest)';
      7:      Result := 'Could not read server response (InternetReadFile)';
      8:      Result := 'Could not detect internet connection (InternetGetConnectedState)';
      9:      Result := 'Exceeded the available bandwidth';
      -8:     Result := 'Empty POST data';
      -9:     Result := 'Invalid JSON file';
      -10:    Result := 'Missing required JSON data';
      -11:    Result := 'AppID not found';
      -12:    Result := 'UserID not found';
      -13:    Result := 'Use POST Request';
      -14:    Result := 'Application version not found';
    else
      Result := UNKNOWN_STR;
    end;
  except
    Result := UNKNOWN_STR;
  end;
end;

function _GetWMIValue(const FValue, FClass: string): string;
var
  wmiLocator: TSWbemLocator;
  wmiServices: ISWbemServices;
  wmiObjectSet: ISWbemObjectSet;
  wmiObject: ISWbemObject;
  wmiRefresher: ISWbemRefresher;
  Enum: IEnumVariant;
  ovVar: OleVariant;
  ovResult: OleVariant;
  iCount: Cardinal;
  prop: ISWBEMProperty;
begin
  try
    wmiLocator   := TSWbemLocator.Create(nil);
    wmiRefresher := CoSWbemRefresher.Create;
    try
      wmiServices := wmiLocator.ConnectServer
      (
        '.',
        'root\cimv2',
        '',
        '',
        '', '', 0, nil
      );

      // Obtain an instance of the WMI class
      wmiObjectSet := wmiServices.ExecQuery
      (
        'SELECT ' + FValue + ' FROM ' + FClass,
        'WQL',
        wbemFlagReturnImmediately,
        nil
      );

      // Replicate VBScript's "for each" construct
      Enum := (wmiObjectSet._NewEnum) as IEnumVariant;
      while (Enum.Next(1, ovVar, iCount) = S_OK) do
      begin
        wmiObject := IUnknown(ovVar) as ISWBemObject;
        prop      := wmiObject.Properties_.Item(FValue, 0);
        ovResult  := prop.Get_Value;
        if (not VarIsNull(ovResult)) and (not VarIsEmpty(ovResult)) then
          Result := Trim(ovResult);
        Break;
      end;
    finally
      wmiLocator.Free;
    end;
  except
    Result := '';
  end;
end;

function _GenerateGUID: string;
var
  FGUIDString: string;
  FGUID: TGUID;
begin
  try
    CreateGUID(FGUID);
    FGUIDString := GUIDToString(FGUID);

    Result      := StringReplace(FGUIDString, '{', '', [rfReplaceAll, rfIgnoreCase]);
    Result      := StringReplace(Result, '}', '', [rfReplaceAll, rfIgnoreCase]);
    Result      := StringReplace(Result, '-', '', [rfReplaceAll, rfIgnoreCase]);
    Result      := Trim(Result);
  except
    Result := '00000000000000000000000000000000';
  end;
end;

{ Network Bandwidth }
function _GetMaxDailyNetwork: Integer;
begin
  try
    Result := FDailyData;
  except
    Result := MAXDAILYNETWORK;
  end;
end;

function _SetMaxDailyNetwork(const FSize: Integer): Boolean;
begin
  try
    FDailyData := FSize;
    Result     := True;
  except
    Result := False;
  end;
end;

{ Storage File }
function _GetMaxStorageFile: Integer;
begin
  try
    Result := FMaxStorage;
  except
    Result := MAXSTORAGEDATA;
  end;
end;

function _SetMaxStorageFile(const FSize: Integer): Boolean;
begin
  Result := True;
  try
    FMaxStorage := FSize;
  except
    Result := False;
  end;
end;

function _SetStarted(const FEnabled: Boolean): Boolean;
begin
  Result   := True;
  try
    FStarted := FEnabled;
  except
    Result   := False;
  end;
end;

function _GetStarted: Boolean;
begin
  try
    Result := FStarted;
  except
    Result := False;
  end;
end;

function _SetStopped(const FEnabled: Boolean): Boolean;
begin
  Result := True;
  try
    FStopped := FEnabled;
  except
    Result := False;
  end;
end;
function _GetStopped: Boolean;
begin
  try
    Result := FStopped;
  except
    Result := False;
  end;
end;

{ Internal Cache Mode }

function _CheckCacheFile: Boolean;
begin
  Result := True;
  try
    if (FLastErrorID = 0) then
      _DeleteCacheFile
    else
    begin
      if (_GetCacheSize < _GetMaxStorageFile) then
        _SaveCacheFile;
    end;
  except
    Result := False;
  end;
end;

function _GetCacheData: string;
var
  FData: string;
  FFileName: string;
  FTempFolder: string;
  FFile: TextFile;
begin
  Result := '';
  try
    FTempFolder := _GetTemporaryFolder;

    if (FTempFolder = '') or (DirectoryExists(FTempFolder) = False) then
    begin
      Result := '';
      Exit;
    end;

    FFileName := FTempFolder + _GetAppID + '.dsmk';

    AssignFile(FFile, FFileName);
    if FileExists(FFileName) then
    begin
      try
        Reset(FFile);
        ReadLn(FFile, FData);
        Result := Base64DecodeStr(FData);
      finally
        CloseFile(FFile);
      end;
    end;
  except
    Result := '';
  end;
end;

function _GetCacheSize: Int64;
var
  FFileName: string;
  FTempFolder: string;
  FSearchRec: TSearchRec;
begin
  Result := -1;
  try
    if (FTempFolder = '') or (DirectoryExists(FTempFolder) = False) then
    begin
      Result := -1;
      Exit;
    end;

    FFileName := FTempFolder + _GetAppID + '.dsmk';

    if FileExists(FFileName) then
    begin
      try
        if FindFirst(FFileName, faAnyFile, FSearchRec) = 0 then
          Result := Int64(FSearchRec.FindData.nFileSizeHigh) shl Int64(32) + Int64(FSearchRec.FindData.nFileSizeLow);
      finally
        FindClose(FSearchRec);
      end;
    end;
  except
    Result := -1;
  end;
end;

function _SaveCacheFile: Boolean;
var
  FTempFolder: string;
  FFileName: string;
  FFile: TextFile;
begin
  Result := True;
  try
    FTempFolder := _GetTemporaryFolder;

    if (FTempFolder = '') or (DirectoryExists(FTempFolder) = False) then
    begin
      Result := False;
      Exit;
    end;

    FFileName := FTempFolder + _GetAppID + '.dsmk';

    AssignFile(FFile, FFileName);
    try
      if FileExists(FFileName) then
      begin
        Append(FFile);
        Write(FFile, Base64EncodeStr(','));
      end
      else
        Rewrite(FFile);

      Write(FFile, Base64EncodeStr(FJSONData));

      SetFileAttributes(PChar(FFileName), faHidden);
    finally
      CloseFile(FFile);
    end;
  except
    Result := False;
  end;
end;

function _DeleteCacheFile: Boolean;
var
  FFileName: string;
begin
  Result := True;
  try
    FFileName := _GetTemporaryFolder + _GetAppID + '.dsmk';
    if FileExists(FFileName) then
    begin
      SetFileAttributes(PChar(FFileName), faArchive);
      Result := SysUtils.DeleteFile(FFileName);
    end;
  except
    Result := False;
  end;
end;

{ Internal Encrypt / Decrypt }
function _Rot13(const FString: string): string;
var
  StrLen, I, charNum : Word;
begin
  try
    StrLen := Length(FString);
    for I  := 1 to StrLen do
    begin
      charNum:= Ord(FString[I]);
      if CharInSet(UpCase(FString[I]), ['A'..'M']) then
        Inc(charNum, 13)
      else
        if CharInSet(UpCase(FString[I]), ['N'..'Z']) then
          Dec(charNum, 13);

      Result := Trim(Result + chr(charNum));
    end;
  except
    Result := '';
  end;
end;

{ TPostThread }

constructor TPostThread.Create(JSON: string; Action: string; ErrorID: Integer);
begin
  FJSON := JSON;
  FAction  := Action;
  FErrorID := ErrorID;

  inherited Create(True);
end;

destructor TPostThread.Destroy;
begin
  inherited Destroy;
end;

procedure TPostThread.Execute;
var
  hint,hconn,hreq:hinternet;
  hdr: UTF8String;
  buf:array[0..READBUFFERSIZE-1] of AnsiChar;
  bufsize:dword;
  i,flags:integer;
  data: UTF8String;
  dwSize, dwFlags: DWORD;
begin
  if not Terminated then
  begin
    FErrorID  := 0;
    try
      { have bandwidth? }
      if (FCurrentDailyData >= _GetMaxDailyNetwork) and (_GetMaxDailyNetwork <> -1) then
      begin
        FErrorID := 9;
        Exit;
      end;

      { check type - WebService API Call }
      if FAction = API_SENDDATA then
      begin
        hdr       := UTF8Encode('Content-Type: application/json');
        data      := UTF8Encode('[' + FJSON + ']');
      end;

      hint := InternetOpenW(PChar(FPostAgent),INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
      if hint = nil then
      begin
        FErrorID := 2;
        Exit;
      end;

      try
        { Set HTTP request timeout }
        if FPostTimeOut > 0 then
        begin
          InternetSetOption(hint, INTERNET_OPTION_CONNECT_TIMEOUT, @FPostTimeOut, SizeOf(FPostTimeOut));
          InternetSetOption(hint, INTERNET_OPTION_SEND_TIMEOUT,    @FPostTimeOut, SizeOf(FPostTimeOut));
          InternetSetOption(hint, INTERNET_OPTION_RECEIVE_TIMEOUT, @FPostTimeOut, SizeOf(FPostTimeOut));
        end;

        { Set HTTP port }
        hconn := InternetConnect(hint,PChar(FAppID + FPostServer),FPostPort,nil,nil,INTERNET_SERVICE_HTTP,0,1);
        if hconn = nil then
        begin
          FErrorID := 3;
          Exit;
        end;

        try
          if FPostPort = INTERNET_DEFAULT_HTTPS_PORT then
            flags := INTERNET_FLAG_NO_UI or INTERNET_FLAG_SECURE or INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
          else
            flags := INTERNET_FLAG_NO_UI;

          hreq := HttpOpenRequest(hconn, 'POST', PChar(FAction), nil, nil, nil, flags, 1);
          if Assigned(hreq) and (FPostPort = INTERNET_DEFAULT_HTTPS_PORT) then
          begin
            dwSize := SizeOf(dwFlags);
            if (InternetQueryOption(hreq, INTERNET_OPTION_SECURITY_FLAGS, @dwFlags, dwSize)) then
            begin
              dwFlags := dwFlags or SECURITY_FLAG_IGNORE_UNKNOWN_CA;
              if not (InternetSetOption(hreq, INTERNET_OPTION_SECURITY_FLAGS, @dwFlags, dwSize)) then
                FErrorID := 4;
            end
            else
              FErrorID := 5;  //InternetQueryOption failed
          end;

          if hreq = nil then
          begin
            FErrorID := 2;
            Exit;
          end;

          try
            if HttpSendRequestA(hreq,PAnsiChar(hdr),Length(hdr),PAnsiChar(Data),Length(Data)) then
            begin
              if (FPostWaitResponse) then
              begin
                { Read server Response }
                bufsize := READBUFFERSIZE;
                while (bufsize > 0) do
                begin
                  if not InternetReadFile(hreq,@buf,READBUFFERSIZE,bufsize) then
                  begin
                    FErrorID := 7;
                    Break;
                  end;

                  if (bufsize > 0) and (bufsize <= READBUFFERSIZE) then
                  begin
                    for i := 0 to bufsize - 1 do
                      FResponse := FResponse + string(buf[i]);
                  end;
                end;
              end;

              if _GetMaxDailyNetwork <> -1 then
                FCurrentDailyData := FCurrentDailyData + (SizeOf(FResponse) * Length(FResponse));
            end
            else
              FErrorID := 6;
          finally
            InternetCloseHandle(hreq);
          end;
        finally
          InternetCloseHandle(hconn);
        end;
      finally
        InternetCloseHandle(hint);
      end;
    except
      FResponse   := '';
      FErrorID := 5;
    end;
  end;
  { Returning from the Execute function effectively terminate the thread  }
  ReturnValue := 0;
end;

{ TStopThread }

//constructor TStopThread.Create;
//begin
//  FreeOnTerminate := True;
//  inherited Create(False);
//end;
//
//destructor TStopThread.Destroy;
//begin
//  FreeOnTerminate := False;
//  Terminate;
//  inherited Destroy;
//end;
//
//procedure TStopThread.Execute;
//var
//  FSingleJSON: string;
//  FCacheData: string;
//  FWait: Cardinal;
//begin
//  while (not Terminated) do
//  begin
//    try
//      if _GetStarted then
//      begin
//        FJSONData   := FJSONData + ',{"tp":"stApp","ts":' + _GetTimeStamp + ',"ss":"' + _GetSessionID + '"}';
//        FSingleJSON := FJSONData;
//
//        { Exists Cache }
//        FCacheData := _GetCacheData;
//        if FCacheData <> '' then
//          FJSONData := FJSONData + ',' + FCacheData;
//
//        try
//          { Send HTTP request }
//          _SendPost(FLastErrorID, API_SENDDATA);
//        finally
//          FJSONData := FSingleJSON;
//        end;
//
//        FThreadEvent.SetEvent;
//
//        { Debug / Test Mode }
//        if _GetTestMode then
//          _InsertLogText('Stop', FLastErrorID);
//      end;
//    except
//    end;
//  end;
//end;

end.
