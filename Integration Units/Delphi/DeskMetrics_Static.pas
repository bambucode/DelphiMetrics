{ **********************************************************}
{                                                           }
{     DeskMetrics - Delphi Static Unit                      }
{     Copyright (c) 2010-2011                               }
{                                                           }
{     http://deskmetrics.com                                }
{     support@deskmetrics.com                               }
{                                                           }
{ **********************************************************}

unit DeskMetrics_Static;

interface

uses
  SysUtils;

  function  DeskMetricsStart(FApplicationID: PWideChar; FApplicationVersion: PWideChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsStartA(FApplicationID: PAnsiChar;  FApplicationVersion: PAnsiChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsStop: Boolean; stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackEvent(FEventCategory, FEventName: PWideChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackEventA(FEventCategory, FEventName: PAnsiChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackEventValue(FEventCategory, FEventName, FEventValue: PWideChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackEventValueA(FEventCategory, FEventName, FEventValue: PAnsiChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackEventPeriod(FEventCategory, FEventName: PWideChar; FEventTime: Integer; FEventCompleted: Boolean); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackEventPeriodA(FEventCategory, FEventName: PAnsiChar; FEventTime: Integer; FEventCompleted: Boolean); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackLog(FMessage: PWideChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackLogA(FMessage: PAnsiChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackCustomData(FName, FValue: PWideChar); stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackCustomDataA(FName, FValue: PAnsiChar); stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsTrackCustomDataR(FName: PWideChar; FValue: PWideChar): Integer; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsTrackCustomDataRA(FName: PAnsiChar; FValue: PAnsiChar): Integer; stdcall; external 'DeskMetrics.dll';
  procedure DeskMetricsTrackException(FExcetionObject: Exception); stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetProxy(FHostIP: PWideChar; FPort: Integer; FUserName, FPassword: PWideChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetProxyA(FHostIP: PAnsiChar; FPort: Integer; FUserName, FPassword: PAnsiChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetProxy(var FHostIP: PWideChar; var FPort: Integer): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetProxyA(var FHostIP: PAnsiChar; var FPort: Integer): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetUserID(FID: PWideChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetUserIDA(FID: PAnsiChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetPostServer: PWideChar; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetPostServerA: PAnsiChar; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetPostServer(FServer: PWideChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetPostServerA(FServer: PAnsiChar): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetPostPort: Integer; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetPostPort(FPort: Integer): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetPostTimeOut: Integer; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetPostTimeOut(FTimeOut: Integer): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetPostWaitResponse: Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetPostWaitResponse(FEnabled: Boolean): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetJSON: PWideChar; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetJSONA: PAnsiChar; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetEnabled: Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSendData: Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetDebugMode: Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsSetDebugMode(FEnabled: Boolean): Boolean; stdcall; external 'DeskMetrics.dll';
  function  DeskMetricsGetDebugFile: Boolean; stdcall; external 'DeskMetrics.dll';

 implementation

 end.