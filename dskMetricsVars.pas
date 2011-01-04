{ **********************************************************************}
{                                                                       }
{     DeskMetrics DLL - dskMetricsVars.pas                              }
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

unit dskMetricsVars;

interface

uses
  dskMetricsInternals, SyncObjs;

var
  FJSONData: string;

  FThreadSafe: TCriticalSection;

  FThreadStart: TPostThread = nil;
  FThreadStop: TPostThread = nil;

  FLastErrorID: Integer;

  FStarted: Boolean;
  FStopped: Boolean;
  FEnabled: Boolean;

  FTestMode: Boolean;
  FTestData: string;

  FAppID: string;
  FAppVersion: string;

  FNetFramework: string;
  FNetFrameworkSP: Integer;

  FUserID: string;
  FSessionID: string;

  FFlowNumber: Integer;

  FPostServer: string;
  FPostPort: Integer;
  FPostTimeOut: Integer;
  FPostAgent: string;
  FPostWaitResponse: Boolean;

  FDailyData: Integer;
  FCurrentDailyData: Integer;
  FMaxStorage: Integer;

  FProxyServer: string;
  FProxyPort: Integer;
  FProxyUser: string;
  FProxyPass: string;

implementation

end.
