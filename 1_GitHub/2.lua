-- ============================================================
-- BRPlayerCharacterBase.lua - SPEED MOD (مرتب بالعربي)
-- Telegram: @BABYNOOB9
-- ============================================================

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")

-- ============================================================
-- 0. الأدوات الأساسية
-- ============================================================

local function GetPlayerController()
    if not slua_GameFrontendHUD then return nil end
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return nil end
    return pc
end

local function GetPlayerCharacter()
    local pc = GetPlayerController()
    if not pc then return nil end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) then return nil end
    return char
end

local function SafeCall(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        pcall(function()
            if _G.SPEED_Debug then
                print("[ERROR] " .. tostring(result))
            end
        end)
    end
    return result
end

local function IsValidObject(obj)
    return obj and slua.isValid and slua.isValid(obj)
end

-- ============================================================
-- 1. شعار المطور والتواصل
-- ============================================================

local function UpdateDeveloperWatermark()
    local uCon = GetPlayerController()
    if not slua.isValid(uCon) then return end
    local HUD = uCon:GetHUD()
    if not slua.isValid(HUD) then return end
    local watermarkText = "SPEED | MOD\n @BABYNOOB9"
    HUD:AddDebugText(watermarkText, nil, 9999, {X=0, Y=0, Z=0}, {X=0, Y=0, Z=0}, {R=255, G=215, B=0, A=255}, true, true, true, nil, 5.0, true)
end

_G.TryShowWelcome = function()
    if _G.SPEED_WelcomeShown then return end
    pcall(function()
        local MsgBox = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local WebSDK = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
        local msg = [[BABYNOOB9

مود احترافي ومطور بالكامل

https://t.me/BABYNOOB9

Developers:
للتواصل: @BABYNOOB9

✅ المود مفعل - لا يوجد انتهاء]]
        MsgBox.Show(4, "WELCOME", msg, function()
            if WebSDK then WebSDK:OpenURL("https://t.me/BABYNOOB9") end
        end)
        _G.SPEED_WelcomeShown = true
    end)
    return true
end

-- ============================================================
-- 2. نظام الحماية من الحظر (Anti-Ban) - كامل
-- ============================================================

local function nop(...) return end
local function retFalse() return false end
local function retTrue() return true end
local function nopfalse() return false end
local function noptrue() return true end
local function nopnil() return nil end
local function nopstr() return "" end

_G.BypassPermissions = {
    SecurityBypass = true,
    AntiCheatBypass = true,
    ReportBypass = true,
    BanBypass = true,
    TelemetryBypass = true,
    NetworkBypass = true,
    MD5Bypass = true,
    SignatureBypass = true,
    DNSBypass = true,
    DeviceBypass = true,
    IPBypass = true,
    MACBypass = true,
    IMEIBypass = true,
    AndroidIDBypass = true,
    AllFeaturesEnabled = true,
    NoReports = true,
    NoBan = true,
    NoDetection = true,
    NoTelemetry = true,
    NoCrashReport = true,
    NoAnalytics = true,
    NoMonitor = true,
    NoTrack = true,
    NoScan = true,
    NoVerify = true,
    NoCheck = true,
    NoValidate = true
}

_G.AntiCheatBlock = {
    BlockAllAntiCheat = true,
    BlockTSS = true,
    BlockGokuba = true,
    BlockSwiftHawk = true,
    BlockCoronaLab = true,
    BlockHawkEye = true,
    BlockHiggsBoson = true,
    BlockClientBan = true,
    BlockRealTimeBan = true,
    BlockReportSystem = true,
    BlockTLog = true,
    BlockMD5Check = true,
    BlockSignatureVerify = true,
    BlockDeviceFingerprint = true,
    BlockDNSMonitor = true,
    BlockTelemetry = true,
    BlockAnalytics = true,
    BlockCrashReport = true,
    BlockMemoryScan = true,
    BlockSpeedCheck = true,
    BlockWallCheck = true,
    BlockShootVerify = true,
    BlockModifierException = true,
    BlockSimulateLocation = true,
    BlockPlayerSecurity = true,
    BlockCircleFlow = true,
    BlockMrpcsFlow = true,
    BlockKillFlow = true,
    BlockBehaviorScore = true,
    BlockAFKReport = true,
    BlockAvatarException = true,
    BlockFileCheck = true,
    BlockPakVerify = true,
    BlockIntegrityCheck = true,
    BlockRacingAntiCheat = true,
    BlockClientEntry = true,
    BlockNetworkException = true,
    BlockUnrealNet = true,
    BlockReplay = true,
    BlockScreenshot = true,
    BlockDebugLog = true
}

local function ClientEntryBypass()
    pcall(function()
        if Client then
            Client.SetTssNetworkStatus = nop
            Client.GEMReportEnterLobbyEvent = nop
            Client.TPerforPlatDisconnectReport = nop
            Client.IsConnected = function(NetInterface) return true end
            Client.GetUnrealNetworkStatus = nopstr
            Client.MD5LuaString = function(str) return "BYPASSED_MD5" end
            Client.GetDSVersion = function() return "999.999.999" end
            Client.IsInReplayState = nopfalse
        end
        
        if NetManager then
            NetManager.ProcRespondMsg = nop
            NetManager.isLogMsgAfterLogin = false
            NetManager.logMsgMap = {}
        end
        
        if EventSystem then
            local oldPost = EventSystem.postEvent
            EventSystem.postEvent = function(eventType, eventID, ...)
                if eventID and type(eventID) == "string" then
                    local blocked = {"SECURITY", "CHEAT", "BAN", "REPORT", "FLAG", 
                                    "VIOLATION", "DETECT", "VERIFY", "ANTI", "AC_",
                                    "SUSPICIOUS", "ABNORMAL", "MONITOR", "TRACK",
                                    "TELEMETRY", "ANALYTICS", "CRASH", "DUMP"}
                    for _, be in ipairs(blocked) do
                        if eventID:find(be) then return end
                    end
                end
                if oldPost then oldPost(eventType, eventID, ...) end
            end
        end
    end)
    print("[BYPASS] Client Entry bypassed!")
end

local function HiggsBosonBypass()
    pcall(function()
        if CHiggsBosonComponent then
            CHiggsBosonComponent.ReceiveBeginPlay = nop
            CHiggsBosonComponent.StaticShowSecurityAlertInDev = nop
            CHiggsBosonComponent.ShowABCD = nop
            CHiggsBosonComponent._ClientShowSecurityAlertWindow = nop
            CHiggsBosonComponent._ReportChatRobot = nop
            CHiggsBosonComponent.SendAntiDataFlow = nop
            CHiggsBosonComponent.SendHitFireBtnFlow = nop
            CHiggsBosonComponent.OnBattleResult = nop
            CHiggsBosonComponent.SendHisarData = nop
            CHiggsBosonComponent.RPC_Client_ShowSecurityAlertWindow = nop
            CHiggsBosonComponent.RPC_Server_TellServerName = nop
            CHiggsBosonComponent.RecordStrategyTimestampInReplay = nop
            CHiggsBosonComponent.SkipAlertServer = nop
            CHiggsBosonComponent.SetClientAlertWindowEnabled = nop
            CHiggsBosonComponent.IsCharacterOwnerWerewolf = nopfalse
            CHiggsBosonComponent.IsCharacterOwnerButcher = nopfalse
            CHiggsBosonComponent._ProcessReportChatRobotQueue = nop
            CHiggsBosonComponent.LuaNotifySecurityAbnormalJump = nop
            CHiggsBosonComponent.bSkipAlertServer = true
            CHiggsBosonComponent.bMHActive = false
            CHiggsBosonComponent.bCallPreReplication = false
            bIsSkipAlertServer = true
            bSkipUploadNoschat = true
            _nReportNosChatTimerID = nil
            _nReportNosChatMessageID = 0
            _tReportNosChatQueue = {}
            LastTimeHandleAlert = -1
        end
    end)
    print("[BYPASS] HiggsBoson bypassed!")
end

local function HawkEyeBypass()
    pcall(function()
        if ClientHawkEyePatrolSubsystem then
            ClientHawkEyePatrolSubsystem._OnHawkSync = nop
            ClientHawkEyePatrolSubsystem._OnHawkReportSuccess = nop
            ClientHawkEyePatrolSubsystem._OnRecvInspectorBroadcastCount = nop
            ClientHawkEyePatrolSubsystem.ReportCheat = nop
            ClientHawkEyePatrolSubsystem.RequestImprison = nop
            ClientHawkEyePatrolSubsystem.SendReportTLog = nop
            ClientHawkEyePatrolSubsystem.IsDuringHawkEyePatrol = nopfalse
            ClientHawkEyePatrolSubsystem._CollectBeWatchedPlayerInfo = nop
            ClientHawkEyePatrolSubsystem.HasReported = noptrue
            ClientHawkEyePatrolSubsystem.GetBeWatchedPlayerInfo = nopnil
            ClientHawkEyePatrolSubsystem._OnPlayerKilledOtherPlayer = nop
            ClientHawkEyePatrolSubsystem._StartFrameUIRefreshTimer = nop
            ClientHawkEyePatrolSubsystem.ExitWatching = nop
            ClientHawkEyePatrolSubsystem.WantMatchNextPatrol = nop
            ClientHawkEyePatrolSubsystem._InitHawkEyePatrolSubsystem = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
            end
            ClientHawkEyePatrolSubsystem._StartHideUITimer = nop
            ClientHawkEyePatrolSubsystem._StartShowDistanceUITimer = nop
            ClientHawkEyePatrolSubsystem._StartCloseBattleEndedTipsTimer = nop
            ClientHawkEyePatrolSubsystem._StartBattleTimeUsageTimer = nop
            ClientHawkEyePatrolSubsystem._StartQuitVoiceRoomTimer = nop
            ClientHawkEyePatrolSubsystem._StartExitGameTimer = nop
            ClientHawkEyePatrolSubsystem._CloseExitGameTimer = nop
            ClientHawkEyePatrolSubsystem._CreateOvertimerTimerForNextPatrol = nop
            ClientHawkEyePatrolSubsystem.ClearNextPatrolOvertimeTimer = nop
            ClientHawkEyePatrolSubsystem.ReturnLobbyAndOpenH5 = nop
            ClientHawkEyePatrolSubsystem.ForceNeverCloseBattleEndedTips = nop
            ClientHawkEyePatrolSubsystem.CheckShowReportedTips = nopfalse
            ClientHawkEyePatrolSubsystem.TryShowReportedTips = nop
            ClientHawkEyePatrolSubsystem.ShowWatchEndedTips = nop
            ClientHawkEyePatrolSubsystem.HasShownWatchEndedTips = noptrue
            ClientHawkEyePatrolSubsystem.OnShowWatchEndedTips = nop
            ClientHawkEyePatrolSubsystem.OnClickLowerLeftExitWatching = nop
            ClientHawkEyePatrolSubsystem.OnClickBottomRightOpenReportWindow = nop
            ClientHawkEyePatrolSubsystem._MarkHasReported = nop
            ClientHawkEyePatrolSubsystem.GetForbidNextPatrolRemainingTimeInSeconds = function() return 0 end
            ClientHawkEyePatrolSubsystem.GetUsedDailyTimeInSeconds = function() return 0 end
            ClientHawkEyePatrolSubsystem.GetInspectorBroadcastCount = function() return -1 end
            ClientHawkEyePatrolSubsystem.GetMaxInspectorBroadcastCount = function() return 0 end
            ClientHawkEyePatrolSubsystem.CanInspectorBroadcast = nopfalse
            ClientHawkEyePatrolSubsystem.IsCharacterLocationShouldDraw = nopfalse
            ClientHawkEyePatrolSubsystem.InitHawkEyePatrolSubsystem = nop
            ClientHawkEyePatrolSubsystem._PostConstruct = function(self)
                self._bHasInitialized = true
                self._bHasReported = true
                self.nInspectorBroadcastCount = -1
            end
            ClientHawkEyePatrolSubsystem.OnRelease = nop
            ClientHawkEyePatrolSubsystem._bHasInitialized = true
            ClientHawkEyePatrolSubsystem._bHasReported = true
            ClientHawkEyePatrolSubsystem._bHasShownWatchEndedTips = true
            ClientHawkEyePatrolSubsystem.bShowBeReportedTips = true
            ClientHawkEyePatrolSubsystem.nInspectorBroadcastCount = -1
        end
    end)
    print("[BYPASS] HawkEye Patrol bypassed!")
end

local function BanLogicBypass()
    pcall(function()
        if ClientBanLogic then
            ClientBanLogic.ReqBanInfo = nop
            ClientBanLogic.OnVoiceSwitchNotify = nop
            ClientBanLogic.OnVoiceBanNotify = nop
            ClientBanLogic.OnRealTimeVoiceBanNotify = nop
            ClientBanLogic.OnVoiceBanSuccess = nop
            ClientBanLogic.TryOpenVoice = function()
                EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, false)
            end
            ClientBanLogic.IsVoiceReportEnable = nopfalse
            ClientBanLogic.OnSyncMicSuspicious = nop
            ClientBanLogic.OnSyncMicPreFilter = nop
            ClientBanLogic.OnSyncBanInfo = nop
            ClientBanLogic.OnNotifyWarningTips = nop
            ClientBanLogic.VoiceBanEndTime = 0
            ClientBanLogic.bEnableVoiceReport = false
            ClientBanLogic.SuspiciousFlag = 0
            ClientBanLogic.Reason = ""
            ClientBanLogic.IsTranslated = false
        end
        if RealTimeBan then
            RealTimeBan.Init = function() return end
            RealTimeBan.OnPlayerWithRealTimeBan = nop
            RealTimeBan.OnSyncPlayerInfo = nop
            RealTimeBan.HandleEnterGameModeFightingState = nop
            RealTimeBan.ShowAlias = nop
            RealTimeBan.SetOnRankInspectorUID = nop
            RealTimeBan.IsUIDOnRankInspector = nopfalse
            RealTimeBan.GetUIDInspectorRank = function() return -1 end
            RealTimeBan.SetInspectorBroadcastCountUID = nop
            RealTimeBan.GetUIDInspectorBroadcastCount = function() return -1 end
            RealTimeBan.GetTipsIDOffset = function() return 0 end
            RealTimeBan.GetTipsIDOffsetWithUID = function() return 0 end
            RealTimeBan.GetTipsIDOffsetInspector = function() return 0 end
            RealTimeBan.GMShowAlias = nop
            RealTimeBan.tOnRankInspectorUIDSet = {}
            RealTimeBan.tInspectorRankUIDSet = {}
            RealTimeBan.tInspectorBroadcastCountUIDSet = {}
            RealTimeBan.MaxAliasLevel = -1
            RealTimeBan.CurrentAlias = nil
            RealTimeBan.CurrentName = nil
            RealTimeBan.is_onrank_inspector = false
            RealTimeBan.inspector_rank = -1
            RealTimeBan.bHasOldAlias = false
            RealTimeBan.ShowTipsAliasConfig = {}
            RealTimeBan.DelayTime = {}
            RealTimeBan.OldShowTipsAlias = 0
        end
        if BanSystem then
            BanSystem.CheckBan = retFalse
            BanSystem.IsBanned = retFalse
            BanSystem.GetBanReason = function() return "" end
            BanSystem.GetBanTime = function() return 0 end
        end
    end)
    print("[BYPASS] Ban Logic bypassed!")
end

local function ReportSystemBypass()
    pcall(function()
        if ClientReportPlayerSubsystem then
            ClientReportPlayerSubsystem.OnInit = nop
            ClientReportPlayerSubsystem._OnPlayerKilledOtherPlayer = nop
            ClientReportPlayerSubsystem._RecordFatalDamager = nop
            ClientReportPlayerSubsystem._RecordMurdererFromDeathReplayData = nop
            ClientReportPlayerSubsystem._OnSyncFatalDamage = nop
            ClientReportPlayerSubsystem._SyncBattleResult = nop
            ClientReportPlayerSubsystem._OnBattleResult = nop
            ClientReportPlayerSubsystem._OnShowQuickReportMutualExclusiveUI = nop
            ClientReportPlayerSubsystem._OnHideQuickReportMutualExclusiveUI = nop
            ClientReportPlayerSubsystem._StartCheckGameModeTypeTimer = nop
            ClientReportPlayerSubsystem._CheckGameModeType = nop
            ClientReportPlayerSubsystem._StartCheckCurrentNotInTeamHistoricalTeammateTimer = nop
            ClientReportPlayerSubsystem._CheckCurrentNotInTeamHistoricalTeammate = nop
            ClientReportPlayerSubsystem._RecordTeammatePlayerInfo = nop
            ClientReportPlayerSubsystem._IsHealthStatusKilled = nopfalse
            ClientReportPlayerSubsystem.GetFatalDamagerMap = function() return {} end
            ClientReportPlayerSubsystem.GetFatalDamagerMapSize = function() return 0 end
            ClientReportPlayerSubsystem.GetName2InfoMap = function() return {} end
            ClientReportPlayerSubsystem.GetCachedTeammateName2InfoMap = function() return {} end
            ClientReportPlayerSubsystem.GetTeammateName2InfoMapDuringBattle = function() return {} end
            ClientReportPlayerSubsystem.GetCurrentNotInTeamHistoricalTeammateMap = function() return {} end
            ClientReportPlayerSubsystem.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
            ClientReportPlayerSubsystem.IsGameModeTypeTeamDeathMatch = nopfalse
            ClientReportPlayerSubsystem.GetGameModeType = function() return -1 end
            ClientReportPlayerSubsystem.GetMainModeID = function() return -1 end
            ClientReportPlayerSubsystem.GetSubModeID = function() return -1 end
            ClientReportPlayerSubsystem.EnableRecordFatalDamage = nop
            ClientReportPlayerSubsystem._tKnockDownerMap = {}
            ClientReportPlayerSubsystem._tMurdererMap = {}
            ClientReportPlayerSubsystem._ds2history = {}
            ClientReportPlayerSubsystem._tMapCurrentNotInTeamHistoricalTeammate = {}
            ClientReportPlayerSubsystem._tTeammateName2InfoMap = {}
            ClientReportPlayerSubsystem._bEnableRecordFatalDamage = false
            ClientReportPlayerSubsystem._bIsGameModeTypeTeamDeathMatch = false
            ClientReportPlayerSubsystem._nGameModeType = -1
            ClientReportPlayerSubsystem._nMainModeID = -1
            ClientReportPlayerSubsystem._nSubModeID = -1
            ClientReportPlayerSubsystem._nCheckTDMGameModeTypeTimer = nil
            ClientReportPlayerSubsystem._nCurrentNotInTeamHistoricalTeammateTimer = nil
        end
        if DSReportPlayerSubsystem then
            DSReportPlayerSubsystem.OnInit = nop
            DSReportPlayerSubsystem._OnNearDeathOrRescued = nop
            DSReportPlayerSubsystem._OnPlayerSettlementStart = nop
            DSReportPlayerSubsystem._OnTeammateDamage = nop
            DSReportPlayerSubsystem._OnCharacterDied = nop
            DSReportPlayerSubsystem._OnPlayerReconnect = nop
            DSReportPlayerSubsystem._RecordFatalDamager = nop
            DSReportPlayerSubsystem._RecordTeammateMurderer = nop
            DSReportPlayerSubsystem._AddMLKillerUIDToBattleResult = nop
            DSReportPlayerSubsystem._AddFatalDamagerMapToBattleResult = nop
            DSReportPlayerSubsystem._AddKnockDownerToBattleResult = nop
            DSReportPlayerSubsystem._AddKillerToBattleResult = nop
            DSReportPlayerSubsystem._AddTeammateMurderToBattleResult = nop
            DSReportPlayerSubsystem._SaveHistoricalTeammateInfo = nop
            DSReportPlayerSubsystem._SyncFatalDamagerMap = nop
            DSReportPlayerSubsystem._AddGameModeTypeToBattleResult = nop
            DSReportPlayerSubsystem._UpdateMLAIUID = nop
            DSReportPlayerSubsystem._AddEnemyMapToBattleResult = nop
            DSReportPlayerSubsystem._OnNoNetStartUpDoor = nop
            DSReportPlayerSubsystem._AssignTeammateInTeamIndex = nop
            DSReportPlayerSubsystem._FindCacheByUID = function(self, nUID, bAddIfNotExists)
                if bAddIfNotExists then return {} end
                return nil
            end
            DSReportPlayerSubsystem._GetFatalDamagerMap = function() return {} end
            DSReportPlayerSubsystem._IsBattleResultTableValid = nopfalse
            DSReportPlayerSubsystem._IsHealthStatusKilled = nopfalse
            DSReportPlayerSubsystem._tUID2InfoMap = {}
            DSReportPlayerSubsystem.nNoStartUpDoorNum = 0
        end
        if ui_complaint then
            ui_complaint.SubmitReportData = function(self) self:CloseWindow(false) return end
            ui_complaint._OnClickReport = function(self) return end
            ui_complaint._AddCommonTypesOfPlayerForReport = function(self) return end
            ui_complaint.AddPlayerForReport = function(self, ...) return end
            ui_complaint.GetSelectedReasonAsArray = function(self) return {} end
            ui_complaint.GetSelectedSubReasonAsArray = function(self) return {} end
            ui_complaint.BlockPlayerChat = function(self) return end
            ui_complaint.IsBlockChatCheck = function(self) return false end
            ui_complaint.CheckBoxBlack = function(self, bCheckState) return end
            ui_complaint.UpdateMatchBlackList = function(self) return end
            ui_complaint._SelectedReasonSet = {}
            ui_complaint._SelectedSubReasonSet = {}
            ui_complaint._SelectedCheatSubReasonSet = {}
            ui_complaint._tPlayerName2InfoMap = {}
            ui_complaint._tPlayerNamesArray = {}
        end
        if LogicComplaint then
            LogicComplaint.Submit = function(...) return end
        end
    end)
    print("[BYPASS] Report System bypassed!")
end

local function TLogBypass()
    pcall(function()
        if tlog_report_utils then
            tlog_report_utils.ReportTLogEvent = nop
            tlog_report_utils.IsCanReportLobbyEvent = nopfalse
            tlog_report_utils.IsBusinessReport = nopfalse
            tlog_report_utils.SetMarketStayUpdateEnable = nop
            tlog_report_utils.GetMarketStayUpdateEnable = nopfalse
            tlog_report_utils.SetBusinessReportEnable = nop
            tlog_report_utils.SendTLogReportImmediate = nop
            tlog_report_utils.SetTlogBeginType = nop
            tlog_report_utils.SetTlogEndType = nop
            _G.SendTLogReportImmediate = nop
            _extraTlogReportEnableCfg = {}
            _isCanReportMarketStay = false
            _BusinessReportEnable = false
            _isInitConfig = true
            start_timestamp_map = {}
        end
        if ToolReportUtil then
            ToolReportUtil.GetReportSwitch = nopfalse
            ToolReportUtil.GetPackageInfo = nopnil
            ToolReportUtil.ReParseError = function(error, reportType) return error or "" end
            ToolReportUtil.IsReleaseVersion = noptrue
            ToolReportUtil.IsWhite = nopfalse
            ToolReportUtil.IsXPcallOpenInBattle = nopfalse
            ToolReportUtil.IsClientToolOpen = nopfalse
            MyOpenID = false
            MyUID = false
            VersionInfo = nil
        end
        if DSSecurityTLogSubsystem then
            DSSecurityTLogSubsystem.OnInit = nop
            DSSecurityTLogSubsystem._OnReportServerJumpFlow = nop
            DSSecurityTLogSubsystem._OnDevAlert = nop
            DSSecurityTLogSubsystem._InitWhenEditor = nop
            DSSecurityTLogSubsystem._nInitGameSafeCallbacksTimer = nil
        end
    end)
    print("[BYPASS] TLog Report bypassed!")
end

local function MD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
            console.ExecuteConsoleCommand(nil, "CheatManager.EnableCheat 1")
            console.ExecuteConsoleCommand(nil, "Net.BlockAllAntiCheat 1")
            console.ExecuteConsoleCommand(nil, "AntiCheat.DisableAll 1")
            console.ExecuteConsoleCommand(nil, "t.MaxFPS 165")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        if _G.FileHashChecker then
            _G.FileHashChecker.CheckFileMD5 = retTrue
            _G.FileHashChecker.VerifyAll = retTrue
            _G.FileHashChecker.GetHash = function() return "BYPASS" end
        end
        if _G.STExtraBlueprintFunctionLibrary then
            _G.STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
            _G.STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
            _G.STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
        end
    end)
    print("[BYPASS] MD5 & Signature bypassed!")
end

local function DNSDeviceBypass()
    pcall(function()
        local DeviceID = import("DeviceID")
        if DeviceID then
            DeviceID.GetDeviceID = function() return "BYPASSED_DEVICE" end
            DeviceID.GetAndroidID = function() return "BYPASSED_ANDROID_ID" end
            DeviceID.GetIMEI = function() return "BYPASSED_IMEI" end
            DeviceID.GetMACAddress = function() return "BYPASSED_MAC" end
            DeviceID.GetUniqueDeviceID = function() return "BYPASSED_UNIQUE" end
            DeviceID.GetDeviceName = function() return "BYPASSED_DEVICE_NAME" end
            DeviceID.GetDeviceModel = function() return "BYPASSED_MODEL" end
            DeviceID.GetDeviceBrand = function() return "BYPASSED_BRAND" end
            DeviceID.GetDeviceManufacturer = function() return "BYPASSED_MANUFACTURER" end
            DeviceID.GetDeviceBoard = function() return "BYPASSED_BOARD" end
            DeviceID.GetDeviceBootloader = function() return "BYPASSED_BOOTLOADER" end
            DeviceID.GetDeviceHardware = function() return "BYPASSED_HARDWARE" end
            DeviceID.GetDeviceHost = function() return "BYPASSED_HOST" end
            DeviceID.GetDeviceFingerprint = function() return "BYPASSED_FINGERPRINT" end
            DeviceID.GetDeviceSerial = function() return "BYPASSED_SERIAL" end
        end
        local DNS = import("DNS")
        if DNS then
            DNS.Resolve = function() return "127.0.0.1" end
            DNS.GetHostName = function() return "BYPASSED_HOST" end
            DNS.GetIPAddress = function() return "0.0.0.0" end
        end
        local Network = import("Network")
        if Network then
            Network.GetIPAddress = function() return "0.0.0.0" end
            Network.GetMACAddress = function() return "BYPASSED_MAC" end
            Network.GetSSID = function() return "BYPASSED_SSID" end
            Network.GetBSSID = function() return "BYPASSED_BSSID" end
        end
    end)
    print("[BYPASS] DNS & Device bypassed!")
end

local function GokubaBypass()
    pcall(function()
        local Gokuba = package.loaded["GameLua.Mod.BaseMod.Client.Security.Gokuba"]
        if Gokuba then
            Gokuba.ForwardFeature = function() return {0,0,0,0,0} end
            Gokuba.InitGokubaLogic = nop
            if Gokuba.TimerHandle then
                local time_ticker = require("common.time_ticker")
                time_ticker.RemoveTimer(Gokuba.TimerHandle)
                Gokuba.TimerHandle = nil
            end
        end
        if _G.GokubaLogic then
            _G.GokubaLogic.ForwardFeature = nop
            _G.GokubaLogic.InitGokubaLogic = nop
        end
    end)
    print("[BYPASS] Gokuba bypassed!")
end

local function RacingAntiCheatBypass()
    pcall(function()
        if RacingAntiCheatLogic then
            RacingAntiCheatLogic.HandleRacingEnter = nop
            RacingAntiCheatLogic.HandleRacingStart = nop
            RacingAntiCheatLogic.HandleRacingEnd = nop
            RacingAntiCheatLogic.StartDetectTimer = nop
            RacingAntiCheatLogic.StopDetectTimer = nop
            RacingAntiCheatLogic.DetectVehicleFloating = nop
            RacingAntiCheatLogic.HandleFloatingCheat = nop
            RacingAntiCheatLogic.SetIgnoreFloating = nop
            RacingAntiCheatLogic.HandlePlayerPassCheckBelt = nop
            RacingAntiCheatLogic.HandleSpeedCheat = nop
            RacingAntiCheatLogic._CreateVehicleData = function() return {} end
            RacingAntiCheatLogic.vehicleDataMap = {}
            RacingAntiCheatLogic.detectTimer = nil
            RacingAntiCheatLogic.config = {
                FloatingDistLimit = 99999,
                FloatingTimeLimit = 99999,
                CheckPassIntervalLimit = 99999
            }
        end
    end)
    print("[BYPASS] Racing AntiCheat bypassed!")
end

local function CoronaLabBypass()
    pcall(function()
        _G.LocalMain = function()
            print("[BYPASS] CoronaLab telemetry timer blocked!")
            return
        end
        local uOuterController = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(uOuterController) and uOuterController.AddGameTimer then
            local orig = uOuterController.AddGameTimer
            uOuterController.AddGameTimer = function(interval, bLoop, func, ...)
                if interval == 30 and bLoop == true then
                    return nil
                end
                return orig(interval, bLoop, func, ...)
            end
        end
        if CHiggsBosonComponent then
            CHiggsBosonComponent.SecurityCoronaLabClientDataPointer = function(self) return nil end
            CHiggsBosonComponent.SetFloatValueByName = function(self, name, value) return end
        end
        if _G.CoronaLab then
            _G.CoronaLab.ReportData = nop
            _G.CoronaLab.SendData = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry = nop
        end
    end)
    print("[BYPASS] CoronaLab Telemetry bypassed!")
end

local function LoginModuleBypass()
    pcall(function()
        if login_module then
            login_module["ban-login"] = function() return end
            login_module["idip-kick-out"] = function() return end
            login_module.aq_ban = function() return end
            login_module["device-in-blacklist"] = function() return end
            login_module.device_num_limit = function() return end
            login_module["register-forbidden"] = function() return end
            login_module["low-version"] = function() return end
            login_module["not-in-white-list"] = function() return end
            login_module.Login_Failed = function() return end
            login_module.aas_ban = function() return end
            login_module.PakMonitorStart = function(EnableMode) return end
            login_module.SetupFilenameHideKeywords = function() return end
            login_module.on_login_failed = function(conn_idx, reason, banInfo, banTime, uid, extra_table) return end
            login_module.DelaybanLoginCancelCallback = function() return end
            login_module.CheckBan = retFalse
            login_module.IsBanned = retFalse
        end
    end)
    print("[BYPASS] Login Module bypassed!")
end

local function SwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do
            if _G[f] then _G[f] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end
        end
    end)
    print("[BYPASS] Swift Hawk bypassed!")
end

local function ShootVerificationBypass()
    pcall(function()
        local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then
            sub.OnShootVerifyFailed = nop
            sub.SendVerifyData = nop
            sub.ReportBulletHit = nop
            sub.UploadHitInfo = nop
            sub.VerifyShot = retTrue
        end
    end)
    print("[BYPASS] Shoot Verification bypassed!")
end

local function ModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then
            sub.ReportException = nop
            sub.CheckModifier = retTrue
            sub.ValidateModifier = retTrue
            sub.ReportModifierError = nop
        end
    end)
    print("[BYPASS] Modifier Exception bypassed!")
end

local function SimulateCharacterBypass()
    pcall(function()
        local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then
            sub.ReportLocation = nop
            sub.SendLocationData = nop
            sub.VerifyLocation = retTrue
        end
    end)
    print("[BYPASS] Simulate Character bypassed!")
end

local function PlayerSecurityBypass()
    pcall(function()
        local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then
            SecSub.ReportData = nop
            SecSub.CheckCheat = retFalse
            SecSub.ValidatePlayer = retTrue
            SecSub.CollectData = nop
            SecSub.SendToServer = nop
        end
    end)
    print("[BYPASS] Player Security bypassed!")
end

local function ClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Send") or k:find("Flow") or
                        k:find("Record") or k:find("Process") or k:find("Upload") or
                        k:find("Track") or k:find("Monitor") or k:find("Analyze")
                    ) then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
    print("[BYPASS] Client Flow bypassed!")
end

local function GameplayCallbackBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        
        local reports = {
            "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", 
            "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", 
            "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", 
            "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", 
            "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", 
            "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", 
            "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", 
            "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", 
            "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", 
            "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams",
            "ReportSecurityViolation", "ReportIntegrityCheck", "ReportSignatureVerify",
            "ReportAntiCheat", "ReportAC", "ReportSuspicious", "ReportAbnormal"
        }
        for _, f in ipairs(reports) do GC[f] = nop end
        
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
        GC.CheckReportSecAttackFlow = retFalse
        
        GC.OnPlayerNetConnectionClosed = nop
        GC.OnPlayerActorChannelError = nop
        GC.OnPlayerRPCValidateFailed = nop
        GC.OnPlayerSpectateException = nop
        GC.OnShutdownAfterError = nop
        GC.IsBypassed = true
    end)
    print("[BYPASS] Gameplay Callback bypassed!")
end

local function KillAllSubsystems()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local toKill = {
                "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
                "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
                "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem",
                "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem",
                "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
                "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem",
                "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem",
                "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
                "MD5CheckSubsystem", "PakVerifySubsystem", "DNSMonitorSubsystem",
                "DeviceFingerprintSubsystem", "ReplayMonitorSubsystem", "TelemetrySubsystem",
                "GokubaSubsystem", "RacingAntiCheatSubsystem", "ClientBanSubsystem",
                "RealTimeBanSubsystem", "TLogSubsystem", "ReportSubsystem"
            }
            for _, name in ipairs(toKill) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect") or k:find("Collect") or
                            k:find("Flow") or k:find("Heartbeat") or k:find("Monitor") or
                            k:find("Track") or k:find("Record") or k:find("Log") or
                            k:find("Alert") or k:find("Notify") or k:find("Ban") or
                            k:find("Kick") or k:find("Suspend") or k:find("Flag")
                        ) then pcall(function() sub[k] = nop end) end
                    end
                end
            end
        end
    end)
    print("[BYPASS] All subsystems killed!")
end

local function SLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
    end)
    print("[BYPASS] SLUA bypassed!")
end

local function ReplayTelemetryBypass()
    pcall(function()
        if _G.Replay then
            _G.Replay.Record = nop
            _G.Replay.StopRecord = nop
            _G.Replay.Save = nop
            _G.Replay.Upload = nop
            _G.Replay.Report = nop
        end
        if _G.Telemetry then
            _G.Telemetry.Send = nop
            _G.Telemetry.Report = nop
            _G.Telemetry.Track = nop
            _G.Telemetry.Log = nop
        end
        if _G.Analytics then
            _G.Analytics.Send = nop
            _G.Analytics.Report = nop
            _G.Analytics.Track = nop
        end
        if _G.Firebase then
            _G.Firebase.logEvent = nop
            _G.Firebase.trackEvent = nop
            _G.Firebase.setEnabled = retFalse
            _G.Firebase.sendEvent = nop
            _G.Firebase.report = nop
        end
        if _G.Adjust then
            _G.Adjust.logEvent = nop
            _G.Adjust.trackEvent = nop
            _G.Adjust.setEnabled = retFalse
            _G.Adjust.sendEvent = nop
        end
        if _G.AppsFlyer then
            _G.AppsFlyer.logEvent = nop
            _G.AppsFlyer.trackEvent = nop
            _G.AppsFlyer.setEnabled = retFalse
            _G.AppsFlyer.sendEvent = nop
        end
    end)
    print("[BYPASS] Replay & Telemetry bypassed!")
end

local function FinalProtection()
    pcall(function()
        for _, flag in ipairs({
            "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", 
            "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", 
            "ENABLE_PERFORMANCE_REPORT", "ENABLE_MONITOR", "ENABLE_TRACK",
            "ENABLE_DETECT", "ENABLE_VERIFY", "ENABLE_CHECK", "ENABLE_SCAN",
            "ENABLE_AC", "ENABLE_BEACON", "ENABLE_SDK", "ENABLE_TSS",
            "ENABLE_SWIFT_HAWK", "ENABLE_GOKUBA", "ENABLE_HIGGS",
            "ENABLE_CORONA", "ENABLE_HAWKEYE", "ENABLE_BAN",
            "ENABLE_VALIDATE", "ENABLE_AUTHENTICATE", "ENABLE_SIGNATURE"
        }) do
            if _G[flag] then _G[flag] = false end
        end
        
        if _G.BypassPermissions then
            for k, v in pairs(_G.BypassPermissions) do
                _G.BypassPermissions[k] = true
            end
        end
        
        if _G.AntiCheatBlock then
            for k, v in pairs(_G.AntiCheatBlock) do
                _G.AntiCheatBlock[k] = true
            end
        end
    end)
    print("[BYPASS] Final Protection activated!")
end

local function NetworkBypass()
    pcall(function()
        if _G.NetworkCheck then
            _G.NetworkCheck.Verify = retTrue
            _G.NetworkCheck.CheckLatency = retFalse
        end
    end)
    print("[BYPASS] Network Bypass executed!")
end

function InitAntiCheatBypasses()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        NetworkBypass()
        ClientEntryBypass()
        HiggsBosonBypass()
        HawkEyeBypass()
        BanLogicBypass()
        ReportSystemBypass()
        TLogBypass()
        MD5Bypass()
        DNSDeviceBypass()
        GokubaBypass()
        RacingAntiCheatBypass()
        CoronaLabBypass()
        LoginModuleBypass()
        SwiftHawkBypass()
        ShootVerificationBypass()
        ModifierExceptionBypass()
        SimulateCharacterBypass()
        PlayerSecurityBypass()
        ClientFlowBypass()
        GameplayCallbackBypass()
        KillAllSubsystems()
        SLUABypass()
        ReplayTelemetryBypass()
        FinalProtection()
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end

-- ============================================================
-- 3. القائمة الأولى: كشف الاماكن
-- ============================================================

-- 3.1 الراية عبر الجدران (Wallhack) - تم اصلاح مشكلة الإيقاف
local WallhackEnabled = false
local WallhackTimer = nil

local function GetSkeletalMeshes(character)
    local meshes = {}
    if slua.isValid(character.Mesh) then 
        table.insert(meshes, character.Mesh) 
    end
    pcall(function()
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass then
            local childs = character:GetComponentsByClass(SkelClass)
            if childs then
                local count = type(childs.Num)=="function" and childs:Num() or #childs
                for c=1,count do
                    local comp = type(childs.Get)=="function" and childs:Get(c-1) or childs[c]
                    if slua.isValid(comp) and comp ~= character.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    return meshes
end

local function IsEnemyVisible(enemy)
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return false end
    local vis = false
    pcall(function() vis = pc:LineOfSightTo(enemy) end)
    return vis
end

local function ApplyWallhackToEnemy(enemy)
    pcall(function()
        local meshes = GetSkeletalMeshes(enemy)
        for _, mesh in ipairs(meshes) do
            for i=0,10 do
                local mat = mesh:GetMaterial(i)
                if slua.isValid(mat) then
                    local baseMat = mat:GetBaseMaterial()
                    if slua.isValid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2
                    end
                end
            end
        end
    end)
end

local function ResetEnemyWallhack(enemy)
    pcall(function()
        local meshes = GetSkeletalMeshes(enemy)
        for _, mesh in ipairs(meshes) do
            for i=0,10 do
                local mat = mesh:GetMaterial(i)
                if slua.isValid(mat) then
                    local baseMat = mat:GetBaseMaterial()
                    if slua.isValid(baseMat) then
                        baseMat.bDisableDepthTest = false
                        baseMat.BlendMode = 0
                    end
                end
            end
        end
    end)
end

local function UpdateEnemyColor(enemy)
    pcall(function()
        local meshes = GetSkeletalMeshes(enemy)
        if #meshes==0 then return end
        
        local visible = IsEnemyVisible(enemy)
        local finalColor = visible and {R=255,G=255,B=0,A=180} or {R=200,G=0,B=0,A=180}
        local scale = {R=3,G=3,B=0,A=0}
        
        for _, mesh in ipairs(meshes) do
            pcall(function()
                mesh.LDMaxDrawDistance = -99999
                mesh.MaxDrawDistanceOffset = -99999
                mesh.CachedMaxDrawDistance = -99999
                mesh.UseScopeDistanceCulling = true
                mesh.PrimitiveShadingStrategy = 1
                mesh.ShadingRate = 6
            end)
            
            for i=0,20 do
                local mat = mesh:GetMaterial(i)
                if slua.isValid(mat) then
                    local baseMat = mat:GetBaseMaterial()
                    if slua.isValid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            local mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                            if slua.isValid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Extra Light Color", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Para_ColorTint", finalColor)
                                mid:SetVectorParameterValue("Para_Color_1", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("BodyColor", finalColor)
                                mid:SetVectorParameterValue("MainColor", finalColor)
                                mid:SetVectorParameterValue("DiffuseColor", finalColor)
                                mid:SetVectorParameterValue("EmissiveColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", scale)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function ApplyGlobalWallhack()
    if not WallhackEnabled then return end
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local myTeamId = localPlayer.TeamID or 0
        local allPawns = Game:GetAllPlayerPawns() or {}
        
        for _, pawn in pairs(allPawns) do
            if slua.isValid(pawn) and pawn ~= localPlayer and pawn.TeamID ~= myTeamId and pawn.IsAlive and pawn:IsAlive() then
                ApplyWallhackToEnemy(pawn)
                UpdateEnemyColor(pawn)
            end
        end
    end)
end

function ToggleWallhack()
    WallhackEnabled = not WallhackEnabled
    
    if WallhackEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if WallhackTimer then
                pcall(function() pc:RemoveGameTimer(WallhackTimer) end)
                WallhackTimer = nil
            end
            WallhackTimer = pc:AddGameTimer(0.3, true, ApplyGlobalWallhack)
            print("[WALLHACK] ✅ الراية عبر الجدران - تم التفعيل")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and WallhackTimer then
            pcall(function() pc:RemoveGameTimer(WallhackTimer) end)
            WallhackTimer = nil
        end
        -- اعادة ضبط المواد لجميع الأعداء
        pcall(function()
            local localPlayer = GameplayData.GetPlayerCharacter()
            if slua.isValid(localPlayer) then
                local myTeamId = localPlayer.TeamID or 0
                local allPawns = Game:GetAllPlayerPawns() or {}
                for _, pawn in pairs(allPawns) do
                    if slua.isValid(pawn) and pawn ~= localPlayer and pawn.TeamID ~= myTeamId then
                        ResetEnemyWallhack(pawn)
                    end
                end
            end
        end)
        print("[WALLHACK] ❌ الراية عبر الجدران - تم الإيقاف")
    end
end

-- 3.2 تفتيح الشخصية
local WhiteBodyEnabled = false

local function ApplyWhiteBody()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if WhiteBodyEnabled then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                print("[WHITEBODY] ✅ تفتيح الشخصية - تم التفعيل")
            else
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                print("[WHITEBODY] ❌ تفتيح الشخصية - تم الإيقاف")
            end
        end
    end)
end

function ToggleWhiteBody()
    WhiteBodyEnabled = not WhiteBodyEnabled
    ApplyWhiteBody()
end

-- 3.3 هيكل العدو (Skeleton ESP)
local SkeletonESPEnabled = false
local SkeletonESPTimer = nil

local function SkeletonESPTick()
    if not SkeletonESPEnabled then return end
    
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local currentPawn = pc:GetCurPawn()
        if not slua.isValid(currentPawn) then return end
        
        local myTeamId = 0
        pcall(function()
            local char = pc:GetPlayerCharacterSafety()
            if slua.isValid(char) and char.TeamID then
                myTeamId = char.TeamID
            end
        end)
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        local HUD = pc:GetHUD()
        if not slua.isValid(HUD) then return end
        
        for _, pawn in pairs(allPawns) do
            if slua.isValid(pawn) and pawn ~= currentPawn and pawn.TeamID ~= myTeamId then
                local isAlive = false
                pcall(function()
                    if pawn.IsAlive then isAlive = pawn:IsAlive() end
                end)
                
                if isAlive then
                    local mesh = pawn.Mesh
                    if slua.isValid(mesh) and type(mesh.GetSocketLocation) == "function" then
                        local pos = pawn:K2_GetActorLocation()
                        
                        local bones = {
                            "head", "neck_01", "pelvis",
                            "upperarm_r", "lowerarm_r", "hand_r",
                            "upperarm_l", "lowerarm_l", "hand_l",
                            "thigh_l", "calf_l", "foot_l",
                            "thigh_r", "calf_r", "foot_r"
                        }
                        
                        for _, bName in ipairs(bones) do
                            local wLoc = mesh:GetSocketLocation(bName)
                            if wLoc then
                                local offset = {X = wLoc.X - pos.X, Y = wLoc.Y - pos.Y, Z = wLoc.Z - pos.Z}
                                
                                local mark = "▪"
                                local size = 0.25
                                local color = {R=0, G=255, B=255, A=255}
                                
                                if bName == "head" then
                                    mark = "●"
                                    size = 0.45
                                    color = {R=255, G=0, B=0, A=255}
                                elseif bName == "pelvis" or bName == "neck_01" then
                                    mark = "▪"
                                    size = 0.35
                                    color = {R=255, G=255, B=0, A=255}
                                end
                                
                                HUD:AddDebugText(mark, pawn, 0.1,
                                    offset, offset, color, true, false, true, nil, size, true)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function ToggleSkeletonESP()
    SkeletonESPEnabled = not SkeletonESPEnabled
    
    if SkeletonESPEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if SkeletonESPTimer then
                pcall(function() pc:RemoveGameTimer(SkeletonESPTimer) end)
                SkeletonESPTimer = nil
            end
            SkeletonESPTimer = pc:AddGameTimer(0.05, true, SkeletonESPTick)
            print("[SKELETON ESP] ✅ هيكل العدو - تم التفعيل")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and SkeletonESPTimer then
            pcall(function() pc:RemoveGameTimer(SkeletonESPTimer) end)
            SkeletonESPTimer = nil
        end
        print("[SKELETON ESP] ❌ هيكل العدو - تم الإيقاف")
    end
end

-- 3.4 صحة العدو (Health ESP)
local HealthESPEnabled = false
local HealthESPTimer = nil

local function HealthESPTick()
    if not HealthESPEnabled then return end
    
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local currentPawn = pc:GetCurPawn()
        if not slua.isValid(currentPawn) then return end
        
        local myTeamId = 0
        pcall(function()
            local char = pc:GetPlayerCharacterSafety()
            if slua.isValid(char) and char.TeamID then
                myTeamId = char.TeamID
            end
        end)
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        local HUD = pc:GetHUD()
        if not slua.isValid(HUD) then return end
        
        for _, pawn in pairs(allPawns) do
            if slua.isValid(pawn) and pawn ~= currentPawn and pawn.TeamID ~= myTeamId then
                local isAlive = false
                local health = 0
                local maxHealth = 100
                
                pcall(function()
                    if pawn.IsAlive then isAlive = pawn:IsAlive() end
                    if pawn.GetHealth then health = pawn:GetHealth() or 0 end
                    if pawn.Health then health = pawn.Health or 0 end
                    if pawn.HealthMax then maxHealth = pawn.HealthMax or 100 end
                end)
                
                if isAlive then
                    local percent = health / maxHealth
                    local pos = pawn:K2_GetActorLocation()
                    local headPos = pawn.Mesh and pawn.Mesh:GetSocketLocation("head") or pos
                    local height = (headPos.Z - pos.Z) + 120
                    
                    local color = {R=255, G=0, B=0, A=255}
                    if percent > 0.7 then color = {R=0, G=255, B=0, A=255}
                    elseif percent > 0.4 then color = {R=255, G=255, B=0, A=255} end
                    
                    local filled = math.floor(percent * 10)
                    local bar = ""
                    for i = 1, 10 do
                        bar = bar .. (i <= filled and "█" or "░")
                    end
                    
                    HUD:AddDebugText(bar, pawn, 0.3,
                        {X=0, Y=0, Z=height + 20},
                        {X=0, Y=0, Z=height + 20},
                        color, true, false, true, nil, 0.8, true)
                    
                    local hpText = string.format("%d%%", math.floor(percent * 100))
                    HUD:AddDebugText(hpText, pawn, 0.3,
                        {X=0, Y=0, Z=height + 10},
                        {X=0, Y=0, Z=height + 10},
                        {R=255, G=255, B=255, A=255}, true, false, true, nil, 0.6, true)
                end
            end
        end
    end)
end

function ToggleHealthESP()
    HealthESPEnabled = not HealthESPEnabled
    
    if HealthESPEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if HealthESPTimer then
                pcall(function() pc:RemoveGameTimer(HealthESPTimer) end)
                HealthESPTimer = nil
            end
            HealthESPTimer = pc:AddGameTimer(0.2, true, HealthESPTick)
            print("[HEALTH ESP] ✅ صحة العدو - تم التفعيل")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and HealthESPTimer then
            pcall(function() pc:RemoveGameTimer(HealthESPTimer) end)
            HealthESPTimer = nil
        end
        print("[HEALTH ESP] ❌ صحة العدو - تم الإيقاف")
    end
end

-- ============================================================
-- 4. القائمة الثانية: اضافات وهمية
-- ============================================================

-- 4.1 ازالة عشب
local RemoveGrassEnabled = false

local function ApplyRemoveGrass()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if RemoveGrassEnabled then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                print("[REMOVE GRASS] ✅ ازالة عشب - تم التفعيل")
            else
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                print("[REMOVE GRASS] ❌ ازالة عشب - تم الإيقاف")
            end
        end
    end)
end

function ToggleRemoveGrass()
    RemoveGrassEnabled = not RemoveGrassEnabled
    ApplyRemoveGrass()
end

-- 4.2 ازالة اشجار
local RemoveTreesEnabled = false

local function ApplyRemoveTrees()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if RemoveTreesEnabled then
                gi:ExecuteCMD("foliage.DensityScale", "0")
                gi:ExecuteCMD("r.Foliage.DensityScale", "0")
                gi:ExecuteCMD("foliage.MinimumScreenSize", "10000")
                gi:ExecuteCMD("r.DisableTreeRender", "1")
                print("[REMOVE TREES] ✅ ازالة اشجار - تم التفعيل")
            else
                gi:ExecuteCMD("foliage.DensityScale", "1")
                gi:ExecuteCMD("r.Foliage.DensityScale", "1")
                gi:ExecuteCMD("foliage.MinimumScreenSize", "0.0001")
                gi:ExecuteCMD("r.DisableTreeRender", "0")
                print("[REMOVE TREES] ❌ ازالة اشجار - تم الإيقاف")
            end
        end
    end)
end

function ToggleRemoveTrees()
    RemoveTreesEnabled = not RemoveTreesEnabled
    ApplyRemoveTrees()
end

-- 4.3 ازالة ضباب
local RemoveFogEnabled = false

local function ApplyRemoveFog()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if RemoveFogEnabled then
                gi:ExecuteCMD("r.SkyAtmosphere", "1")
                gi:ExecuteCMD("r.Fog", "0")
                gi:ExecuteCMD("r.VolumetricFog", "0")
                print("[REMOVE FOG] ✅ ازالة ضباب - تم التفعيل")
            else
                gi:ExecuteCMD("r.SkyAtmosphere", "1")
                gi:ExecuteCMD("r.Fog", "1")
                gi:ExecuteCMD("r.VolumetricFog", "1")
                print("[REMOVE FOG] ❌ ازالة ضباب - تم الإيقاف")
            end
        end
    end)
end

function ToggleRemoveFog()
    RemoveFogEnabled = not RemoveFogEnabled
    ApplyRemoveFog()
end

-- 4.4 سماء سوداء
local BlackSkyEnabled = false

local function ApplyBlackSky()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if BlackSkyEnabled then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                print("[BLACK SKY] ✅ سماء سوداء - تم التفعيل")
            else
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                print("[BLACK SKY] ❌ سماء سوداء - تم الإيقاف")
            end
        end
    end)
end

function ToggleBlackSky()
    BlackSkyEnabled = not BlackSkyEnabled
    ApplyBlackSky()
end

-- ============================================================
-- 5. ميزات اضافية (القائمة الثالثة) - تم اصلاحها
-- ============================================================

-- 5.1 تكبير الشخصية (تم اصلاحه)
local BigPlayerEnabled = false
local BigPlayerScale = 1.5
local BigPlayerTimer = nil

local function ApplyBigPlayerLoop()
    if not BigPlayerEnabled then return end
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        
        local mesh = localPlayer.Mesh
        if not slua.isValid(mesh) then return end
        
        local targetScale = BigPlayerScale
        if targetScale < 1.0 then targetScale = 1.0 end
        if targetScale > 3.0 then targetScale = 3.0 end
        
        mesh:SetRelativeScale3D(FVector(targetScale, targetScale, targetScale))
        
        pcall(function()
            local SkelClass = import("SkeletalMeshComponent")
            if SkelClass then
                local childs = localPlayer:GetComponentsByClass(SkelClass)
                if childs then
                    local count = type(childs.Num)=="function" and childs:Num() or #childs
                    for c=1,count do
                        local comp = type(childs.Get)=="function" and childs:Get(c-1) or childs[c]
                        if slua.isValid(comp) and comp ~= mesh then
                            comp:SetRelativeScale3D(FVector(targetScale, targetScale, targetScale))
                        end
                    end
                end
            end
        end)
    end)
end

function ToggleBigPlayer()
    BigPlayerEnabled = not BigPlayerEnabled
    
    if BigPlayerEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if BigPlayerTimer then
                pcall(function() pc:RemoveGameTimer(BigPlayerTimer) end)
                BigPlayerTimer = nil
            end
            BigPlayerTimer = pc:AddGameTimer(0.5, true, ApplyBigPlayerLoop)
            ApplyBigPlayerLoop()
            print("[BIG PLAYER] ✅ تكبير الشخصية - تم التفعيل بمعدل " .. BigPlayerScale .. "x")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and BigPlayerTimer then
            pcall(function() pc:RemoveGameTimer(BigPlayerTimer) end)
            BigPlayerTimer = nil
        end
        pcall(function()
            local localPlayer = GameplayData.GetPlayerCharacter()
            if slua.isValid(localPlayer) then
                local mesh = localPlayer.Mesh
                if slua.isValid(mesh) then
                    mesh:SetRelativeScale3D(FVector(1.0, 1.0, 1.0))
                end
                local SkelClass = import("SkeletalMeshComponent")
                if SkelClass then
                    local childs = localPlayer:GetComponentsByClass(SkelClass)
                    if childs then
                        local count = type(childs.Num)=="function" and childs:Num() or #childs
                        for c=1,count do
                            local comp = type(childs.Get)=="function" and childs:Get(c-1) or childs[c]
                            if slua.isValid(comp) then
                                comp:SetRelativeScale3D(FVector(1.0, 1.0, 1.0))
                            end
                        end
                    end
                end
            end
        end)
        print("[BIG PLAYER] ❌ تكبير الشخصية - تم الإيقاف")
    end
end

-- 5.2 iPad View
local IpadViewEnabled = false
local IpadViewFOV = 120
local IpadViewTimer = nil

local function ApplyIpadViewLoop()
    if not IpadViewEnabled then return end
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        
        local tppCam = localPlayer.ThirdPersonCameraComponent
        if not slua.isValid(tppCam) then return end
        
        if not localPlayer.bIsWeaponAiming then
            tppCam.FieldOfView = IpadViewFOV
        end
    end)
end

local function ApplyIpadView()
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        
        local tppCam = localPlayer.ThirdPersonCameraComponent
        if not slua.isValid(tppCam) then return end
        
        if IpadViewEnabled then
            if not localPlayer.bIsWeaponAiming then
                tppCam.FieldOfView = IpadViewFOV
                print("[IPAD VIEW] ✅ iPad View - تم التفعيل بـ " .. IpadViewFOV .. " FOV")
            end
        else
            if not localPlayer.bIsWeaponAiming then
                tppCam.FieldOfView = 90
                print("[IPAD VIEW] ❌ iPad View - تم الإيقاف")
            end
        end
    end)
end

function ToggleIpadView()
    IpadViewEnabled = not IpadViewEnabled
    
    if IpadViewEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if IpadViewTimer then
                pcall(function() pc:RemoveGameTimer(IpadViewTimer) end)
                IpadViewTimer = nil
            end
            IpadViewTimer = pc:AddGameTimer(0.3, true, ApplyIpadViewLoop)
            ApplyIpadView()
            print("[IPAD VIEW] ✅ iPad View - تم التفعيل")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and IpadViewTimer then
            pcall(function() pc:RemoveGameTimer(IpadViewTimer) end)
            IpadViewTimer = nil
        end
        ApplyIpadView()
        print("[IPAD VIEW] ❌ iPad View - تم الإيقاف")
    end
end

-- 5.3 ميزة No Recoil & Aim Assist
local NoRecoilEnabled = false
local NoRecoilTimer = nil

local function ApplyNoRecoilAndAimAssist()
    if not NoRecoilEnabled then return end
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        if localPlayer.GetCurrentWeapon then
            local currentWeapon = localPlayer:GetCurrentWeapon()
            if slua.isValid(currentWeapon) then
                pcall(function()
                    local shootWeapon = currentWeapon.ShootWeaponEntity_GEN_VARIABLE or currentWeapon.ShootWeaponEntity
                    if slua.isValid(shootWeapon) then
                        shootWeapon.GameDeviationFactor = 0.01
                        shootWeapon.AccessoriesHRecoilFactor = 0.01
                        shootWeapon.AccessoriesVRecoilFactor = 0.01
                        shootWeapon.GameDeviationAccuracy = 0.01
                        if shootWeapon.AutoAimingConfig then
                            if shootWeapon.AutoAimingConfig.OuterRange then
                                shootWeapon.AutoAimingConfig.OuterRange.Speed = 4.9
                                shootWeapon.AutoAimingConfig.OuterRange.RangeRate = 1.4
                                shootWeapon.AutoAimingConfig.OuterRange.SpeedRate = 1.4
                                shootWeapon.AutoAimingConfig.OuterRange.RangeRateSight = 1.4
                                shootWeapon.AutoAimingConfig.OuterRange.SpeedRateSight = 1.4
                                shootWeapon.AutoAimingConfig.OuterRange.CrouchRate = 1.4
                                shootWeapon.AutoAimingConfig.OuterRange.ProneRate = 1.4
                            end
                            if shootWeapon.AutoAimingConfig.InnerRange then
                                shootWeapon.AutoAimingConfig.InnerRange.Speed = 4.9
                                shootWeapon.AutoAimingConfig.InnerRange.RangeRate = 1.4
                                shootWeapon.AutoAimingConfig.InnerRange.SpeedRate = 1.4
                                shootWeapon.AutoAimingConfig.InnerRange.RangeRateSight = 1.4
                                shootWeapon.AutoAimingConfig.InnerRange.SpeedRateSight = 1.4
                                shootWeapon.AutoAimingConfig.InnerRange.CrouchRate = 0.8
                                shootWeapon.AutoAimingConfig.InnerRange.ProneRate = 0.3
                            end
                        end
                    end
                end)
            end
        end
    end)
end

function ToggleNoRecoil()
    NoRecoilEnabled = not NoRecoilEnabled
    
    if NoRecoilEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if NoRecoilTimer then
                pcall(function() pc:RemoveGameTimer(NoRecoilTimer) end)
                NoRecoilTimer = nil
            end
            NoRecoilTimer = pc:AddGameTimer(0.1, true, ApplyNoRecoilAndAimAssist)
            print("[NO RECOIL] ✅ No Recoil & Aim Assist - تم التفعيل")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and NoRecoilTimer then
            pcall(function() pc:RemoveGameTimer(NoRecoilTimer) end)
            NoRecoilTimer = nil
        end
        print("[NO RECOIL] ❌ No Recoil & Aim Assist - تم الإيقاف")
    end
end

-- 5.4 ميزة 165 FPS (تم اصلاحها)
local FPS165Enabled = false
local FPS165Timer = nil

local function ApplyFPS165Loop()
    if not FPS165Enabled then return end
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        if lsg then
            local gi = lsg.GetGameInstance()
            if gi then
                gi:ExecuteCMD("t.MaxFPS", "165")
                gi:ExecuteCMD("r.FrameRateLimit", "165")
                gi:ExecuteCMD("t.MaxFPS 165")
                gi:ExecuteCMD("r.FrameRateLimit 165")
            end
        end
        
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "t.MaxFPS 165")
            console.ExecuteConsoleCommand(nil, "r.FrameRateLimit 165")
            console.ExecuteConsoleCommand(nil, "t.MaxFPS=165")
            console.ExecuteConsoleCommand(nil, "r.FrameRateLimit=165")
        end
        
        pcall(function()
            local pc = slua_GameFrontendHUD:GetPlayerController()
            if slua.isValid(pc) then
                local world = pc:GetWorld()
                if slua.isValid(world) then
                    local gameInstance = world:GetGameInstance()
                    if slua.isValid(gameInstance) then
                        if gameInstance.ExecuteConsoleCommand then
                            gameInstance:ExecuteConsoleCommand("t.MaxFPS 165")
                            gameInstance:ExecuteConsoleCommand("r.FrameRateLimit 165")
                        end
                    end
                end
            end
        end)
    end)
end

local function ApplyFPS165()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if FPS165Enabled then
                gi:ExecuteCMD("t.MaxFPS", "165")
                gi:ExecuteCMD("r.FrameRateLimit", "165")
                print("[FPS 165] ✅ 165 FPS - تم التفعيل")
            else
                gi:ExecuteCMD("t.MaxFPS", "60")
                gi:ExecuteCMD("r.FrameRateLimit", "60")
                print("[FPS 165] ❌ 165 FPS - تم الإيقاف")
            end
        end
    end)
end

function ToggleFPS165()
    FPS165Enabled = not FPS165Enabled
    
    if FPS165Enabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if FPS165Timer then
                pcall(function() pc:RemoveGameTimer(FPS165Timer) end)
                FPS165Timer = nil
            end
            FPS165Timer = pc:AddGameTimer(1.0, true, ApplyFPS165Loop)
            ApplyFPS165()
            print("[FPS 165] ✅ 165 FPS - تم التفعيل مع مؤقت مستمر")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and FPS165Timer then
            pcall(function() pc:RemoveGameTimer(FPS165Timer) end)
            FPS165Timer = nil
        end
        ApplyFPS165()
        print("[FPS 165] ❌ 165 FPS - تم الإيقاف")
    end
end

-- 5.5 ميزة Hitbox Expansion (مجك بولت)
local HitboxEnabled = false
local HitboxTimer = nil
local HitboxScale = 1.5

local function HitboxExpansion()
    if not HitboxEnabled then return end
    pcall(function()
        local lp = GameplayData.GetPlayerCharacter()
        if not slua.isValid(lp) then return end
        local mt = lp.TeamID or 0
        local all = Game:GetAllPlayerPawns() or {}

        for _, enemy in pairs(all) do
            if slua.isValid(enemy) and enemy ~= lp and enemy.TeamID ~= mt and (enemy.Health or 0) > 0 then
                pcall(function()
                    local mesh = enemy.Mesh
                    if not slua.isValid(mesh) then return end

                    local physAsset = mesh.PhysicsAssetOverride
                    if not slua.isValid(physAsset) and slua.isValid(mesh.SkeletalMesh) then
                        physAsset = mesh.SkeletalMesh.PhysicsAsset
                    end

                    if slua.isValid(physAsset) and physAsset.SkeletalBodySetups then
                        local assetName = physAsset.GetName and physAsset:GetName() or tostring(physAsset)

                        if not _G.__NOOK_HB__ then _G.__NOOK_HB__ = {} end
                        if _G.__NOOK_HB__[assetName] then return end
                        _G.__NOOK_HB__[assetName] = true

                        local bodySetups = physAsset.SkeletalBodySetups
                        for i = 1, 80 do
                            local setup = nil
                            pcall(function()
                                setup = type(bodySetups.Get) == "function" and bodySetups:Get(i - 1) or bodySetups[i]
                            end)
                            if not setup or not slua.isValid(setup) then break end

                            local scale = HitboxScale

                            pcall(function()
                                local boxElems = (setup.AggGeom and setup.AggGeom.BoxElems) or setup.BoxElems
                                if boxElems then
                                    local elem = type(boxElems.Get) == "function" and boxElems:Get(0) or boxElems[1]
                                    if elem then
                                        elem.X = (elem.X or 30) * scale
                                        elem.Y = (elem.Y or 30) * scale
                                        elem.Z = (elem.Z or 60) * scale
                                        if type(boxElems.Set) == "function" then boxElems:Set(0, elem) else boxElems[1] = elem end
                                    end
                                end
                            end)

                            pcall(function()
                                local sphereElems = (setup.AggGeom and setup.AggGeom.SphereElems) or setup.SphereElems
                                if sphereElems then
                                    local elem = type(sphereElems.Get) == "function" and sphereElems:Get(0) or sphereElems[1]
                                    if elem and elem.Radius then
                                        elem.Radius = elem.Radius * scale
                                        if type(sphereElems.Set) == "function" then sphereElems:Set(0, elem) else sphereElems[1] = elem end
                                    end
                                end
                            end)

                            pcall(function()
                                local sphylElems = (setup.AggGeom and setup.AggGeom.SphylElems) or setup.SphylElems
                                if sphylElems then
                                    local elem = type(sphylElems.Get) == "function" and sphylElems:Get(0) or sphylElems[1]
                                    if elem then
                                        if elem.Radius then elem.Radius = elem.Radius * scale end
                                        if elem.Length then elem.Length = elem.Length * scale end
                                        if type(sphylElems.Set) == "function" then sphylElems:Set(0, elem) else sphylElems[1] = elem end
                                    end
                                end
                            end)
                        end

                        if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end
                    end
                end)
            end
        end
    end)
end

function ToggleHitbox()
    HitboxEnabled = not HitboxEnabled
    
    if HitboxEnabled then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if HitboxTimer then
                pcall(function() pc:RemoveGameTimer(HitboxTimer) end)
                HitboxTimer = nil
            end
            HitboxTimer = pc:AddGameTimer(0.5, true, HitboxExpansion)
            print("[HITBOX] ✅ Hitbox Expansion (مجك بولت) - تم التفعيل بمعدل " .. HitboxScale .. "x")
        end
    else
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and HitboxTimer then
            pcall(function() pc:RemoveGameTimer(HitboxTimer) end)
            HitboxTimer = nil
        end
        _G.__NOOK_HB__ = {}
        print("[HITBOX] ❌ Hitbox Expansion (مجك بولت) - تم الإيقاف")
    end
end

-- ============================================================
-- 6. القائمة الرابعة: تحديات غير آمنة (10 ميزات)
-- ============================================================

-- 6.1 Speed Boost (سرعة اللاعب)
_G.MemoryConfig = _G.MemoryConfig or {}
_G.MemoryConfig.SpeedBoost = false
_G.MemoryConfig.SpeedPercent = 500   -- ← 500% (၂.၅ ဆ) ပိုမြန်
_G.SpeedBoostState = _G.SpeedBoostState or {active = false, timer = nil, modifyId = nil, currentChar = nil}

local function RemoveSpeedModify(char)
    if not slua.isValid(char) or not char.AttrModifyComp then return end
    if _G.SpeedBoostState.modifyId then
        pcall(function() char.AttrModifyComp:RemoveModifyItemFromCache(_G.SpeedBoostState.modifyId) end)
        _G.SpeedBoostState.modifyId = nil
    end
end

local function ApplySpeedModify(char)
    if not slua.isValid(char) or not char.AttrModifyComp then return end
    RemoveSpeedModify(char)
    local rate = (_G.MemoryConfig.SpeedPercent / 200.0) - 1.0
    pcall(function()
        _G.SpeedBoostState.modifyId = char.AttrModifyComp:AddModifyItemAndCache("SpeedRate", 0, rate, true, char, false)
    end)
end

local function UpdateSpeedBoost()
    if not _G.MemoryConfig.SpeedBoost then return end
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) then return end
    if _G.SpeedBoostState.currentChar ~= char then
        if _G.SpeedBoostState.currentChar then RemoveSpeedModify(_G.SpeedBoostState.currentChar) end
        _G.SpeedBoostState.currentChar = char
    end
    ApplySpeedModify(char)
end

function ToggleSpeedBoost()
    _G.MemoryConfig.SpeedBoost = not _G.MemoryConfig.SpeedBoost
    if _G.MemoryConfig.SpeedBoost then
        if _G.SpeedBoostState.timer then return end
        _G.SpeedBoostState.active = true
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            _G.SpeedBoostState.timer = pc:AddGameTimer(0.3, true, UpdateSpeedBoost)
        end
        print("[SPEED BOOST] ✅ سرعة اللاعب - تم التفعيل بمعدل " .. _G.MemoryConfig.SpeedPercent .. "%")
    else
        _G.SpeedBoostState.active = false
        if _G.SpeedBoostState.timer then
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if slua.isValid(pc) and pc.RemoveGameTimer then pc:RemoveGameTimer(_G.SpeedBoostState.timer) end
            _G.SpeedBoostState.timer = nil
        end
        if _G.SpeedBoostState.currentChar then
            RemoveSpeedModify(_G.SpeedBoostState.currentChar)
            _G.SpeedBoostState.currentChar = nil
        end
        print("[SPEED BOOST] ❌ سرعة اللاعب - تم الإيقاف")
    end
end

function SetSpeedPercent(val)
    val = tonumber(val) or 200
    if val < 100 then val = 100 end
    if val > 1000 then val = 1000 end
    _G.MemoryConfig.SpeedPercent = val
    if _G.MemoryConfig.SpeedBoost and _G.SpeedBoostState.currentChar then
        ApplySpeedModify(_G.SpeedBoostState.currentChar)
    end
    print("[SPEED BOOST] Speed set to " .. val .. "%")
end

-- 6.2 Anti-Gravity (تخفيف الجاذبية)
_G.MemoryConfig.AntiGravity = false
-- 0.001 = جاذبية أضعف 1000 مرة عند تفعيل الخيار؛ 1.0 = الجاذبية الطبيعية عند الإيقاف
_G.MemoryConfig.GravityScale = 0.001

function ToggleAntiGravity()
    _G.MemoryConfig.AntiGravity = not _G.MemoryConfig.AntiGravity
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if slua.isValid(char) then
        local move = char.CharacterMovement or char.CharMoveComp
        if move then
            move.GravityScale = _G.MemoryConfig.AntiGravity and _G.MemoryConfig.GravityScale or 1.0
        end
    end
    if _G.MemoryConfig.AntiGravity then
        print("[ANTI-GRAVITY] ✅ تخفيف الجاذبية - تم التفعيل بمعدل " .. _G.MemoryConfig.GravityScale)
    else
        print("[ANTI-GRAVITY] ❌ تخفيف الجاذبية - تم الإيقاف")
    end
end

function SetGravityScale(val)
    _G.MemoryConfig.GravityScale = val
    if _G.MemoryConfig.AntiGravity then ToggleAntiGravity(); ToggleAntiGravity() end
end

-- 6.3 Wall Climb (تسلق الجدران)
_G.MemoryConfig.WallClimb = false

function ToggleWallClimb()
    _G.MemoryConfig.WallClimb = not _G.MemoryConfig.WallClimb
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if slua.isValid(char) then
        local move = char.CharacterMovement or char.CharMoveComp
        if move then
            if _G.MemoryConfig.WallClimb then
                move.WalkableFloorAngle = 199.0
                move.MaxStepHeight = 999.0
                print("[WALL CLIMB] ✅ تسلق الجدران - تم التفعيل")
            else
                move.WalkableFloorAngle = 45.0
                move.MaxStepHeight = 45.0
                print("[WALL CLIMB] ❌ تسلق الجدران - تم الإيقاف")
            end
        end
    end
end

-- 6.4 Character Rotation (دوران اللاعب)
_G.MemoryConfig.CharRotation = false
_G.MemoryConfig.CharRotSpeed = 360
_G.CharRotState = _G.CharRotState or {timer = nil, yaw = 0}

local function UpdateCharRot()
    if not _G.MemoryConfig.CharRotation then return end
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) or not slua.isValid(char.Mesh) then return end
    _G.CharRotState.yaw = (_G.CharRotState.yaw + _G.MemoryConfig.CharRotSpeed * 0.016) % 360
    local rot = char.Mesh:K2_GetComponentRotation()
    rot.Yaw = _G.CharRotState.yaw
    char.Mesh:K2_SetWorldRotation(rot, false, nil, false)
end

function ToggleCharRotation()
    _G.MemoryConfig.CharRotation = not _G.MemoryConfig.CharRotation
    if _G.MemoryConfig.CharRotation then
        if _G.CharRotState.timer then return end
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            local char = pc:GetPlayerCharacterSafety()
            if slua.isValid(char) and slua.isValid(char.Mesh) then
                _G.CharRotState.yaw = char.Mesh:K2_GetComponentRotation().Yaw
            end
            _G.CharRotState.timer = pc:AddGameTimer(0.016, true, UpdateCharRot)
        end
        print("[CHAR ROTATION] ✅ دوران اللاعب - تم التفعيل")
    else
        if _G.CharRotState.timer then
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            if slua.isValid(pc) and pc.RemoveGameTimer then pc:RemoveGameTimer(_G.CharRotState.timer) end
            _G.CharRotState.timer = nil
        end
        print("[CHAR ROTATION] ❌ دوران اللاعب - تم الإيقاف")
    end
end

function SetCharRotSpeed(val)
    _G.MemoryConfig.CharRotSpeed = val
end

-- 6.5 My Scale (تكبير شخصيتك)
_G.MemoryConfig.CharScale = 1.0

function SetCharScale(val)
    _G.MemoryConfig.CharScale = val
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) then
        local char = pc:GetPlayerCharacterSafety()
        if slua.isValid(char) then
            char:SetActorScale3D(FVector(val, val, val))
        end
    end
end

-- 6.6 Enemy Scale (تكبير الأعداء)
_G.MemoryConfig.EnemyScale = 1.0

function SetEnemyScale(val)
    _G.MemoryConfig.EnemyScale = val
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local myChar = pc:GetPlayerCharacterSafety()
    if not slua.isValid(myChar) then return end
    local myTeam = myChar.TeamID or 0
    local all = Game:GetAllPlayerPawns()
    if not all then return end
    for _, p in pairs(all) do
        if slua.isValid(p) and p ~= myChar and (p.TeamID or 0) ~= myTeam then
            p:SetActorScale3D(FVector(val, val, val))
        end
    end
end

-- 6.7 Super Bullet (عدد الرصاصات)
_G.MemoryConfig.SuperBullet = 1

function SetSuperBullet(count)
    _G.MemoryConfig.SuperBullet = count or 1
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) then return end
    local wm = char.WeaponManagerComponent
    if not slua.isValid(wm) then return end
    local wep = wm.CurrentWeaponReplicated
    if not slua.isValid(wep) then return end
    local shoot = wep.ShootWeaponEntityComp
    if slua.isValid(shoot) then
        shoot.BulletNumSingleShot = count
    end
end

-- 6.8 Super Fire Rate (سرعة إطلاق النار)
_G.MemoryConfig.SuperFireRate = false
_G.MemoryConfig.SuperFireRateVal = 0.008

function ToggleSuperFireRate()
    _G.MemoryConfig.SuperFireRate = not _G.MemoryConfig.SuperFireRate
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) then return end
    local wm = char.WeaponManagerComponent
    if not slua.isValid(wm) then return end
    local wep = wm.CurrentWeaponReplicated
    if not slua.isValid(wep) then return end
    local shoot = wep.ShootWeaponEntityComp
    if slua.isValid(shoot) then
        shoot.ShootInterval = _G.MemoryConfig.SuperFireRate and _G.MemoryConfig.SuperFireRateVal or 0.1
    end
    if _G.MemoryConfig.SuperFireRate then
        print("[SUPER FIRE RATE] ✅ سرعة إطلاق النار - تم التفعيل")
    else
        print("[SUPER FIRE RATE] ❌ سرعة إطلاق النار - تم الإيقاف")
    end
end

function SetSuperFireRateVal(val)
    _G.MemoryConfig.SuperFireRateVal = val
end

-- 6.9 Infinite Ammo (ذخيرة لا نهائية)
_G.MemoryConfig.InfiniteAmmo = false

function ToggleInfiniteAmmo()
    _G.MemoryConfig.InfiniteAmmo = not _G.MemoryConfig.InfiniteAmmo
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local char = pc:GetPlayerCharacterSafety()
    if not slua.isValid(char) then return end
    local wm = char.WeaponManagerComponent
    if not slua.isValid(wm) then return end
    local wep = wm.CurrentWeaponReplicated
    if not slua.isValid(wep) then return end
    local shoot = wep.ShootWeaponEntityComp
    if slua.isValid(shoot) then
        shoot.bClipHasInfiniteBullets = _G.MemoryConfig.InfiniteAmmo
        shoot.bHasInfiniteBullets = _G.MemoryConfig.InfiniteAmmo
    end
    if _G.MemoryConfig.InfiniteAmmo then
        print("[INFINITE AMMO] ✅ ذخيرة لا نهائية - تم التفعيل")
    else
        print("[INFINITE AMMO] ❌ ذخيرة لا نهائية - تم الإيقاف")
    end
end

-- 6.10 Magic Bullet (تكبير مناطق الإصابة)
_G.MemoryConfig.MagicBullet = false
_G._MBones = _G._MBones or {}

function ToggleMagicBullet()
    _G.MemoryConfig.MagicBullet = not _G.MemoryConfig.MagicBullet
    if not _G.MemoryConfig.MagicBullet then 
        print("[MAGIC BULLET] ❌ تكبير مناطق الإصابة - تم الإيقاف")
        return 
    end
    local all = Game:GetAllPlayerPawns() or {}
    for _, c in pairs(all) do
        if slua.isValid(c) then
            local mesh = c.Mesh
            if slua.isValid(mesh) then
                local phys = mesh.PhysicsAssetOverride
                if not slua.isValid(phys) and slua.isValid(mesh.SkeletalMesh) then
                    phys = mesh.SkeletalMesh.PhysicsAsset
                end
                if slua.isValid(phys) and phys.SkeletalBodySetups then
                    local name = (phys.GetName and phys:GetName()) or tostring(phys)
                    if not _G._MBones[name] then
                        local setups = phys.SkeletalBodySetups
                        for i = 1, 80 do
                            local bs = nil
                            pcall(function() bs = (type(setups.Get) == "function") and setups:Get(i-1) or setups[i] end)
                            if not bs or not slua.isValid(bs) then break end
                            local bn = tostring(bs.BoneName):lower()
                            local mult = 1.0
                            if bn:find("head") then mult = 3.0
                            elseif bn:find("neck") then mult = 2.5
                            elseif bn:find("spine") then mult = 2.0
                            elseif bn:find("upper") or bn:find("lower") then mult = 1.8
                            else mult = 1.5 end
                            local ag = bs.AggGeom
                            pcall(function()
                                local bx = (ag and ag.BoxElems) or bs.BoxElems
                                if bx then
                                    local b = (type(bx.Get) == "function") and bx:Get(0) or bx[1]
                                    if b then
                                        b.X = (b.X or 30) * mult
                                        b.Y = (b.Y or 30) * mult
                                        b.Z = (b.Z or 60) * mult
                                        if type(bx.Set) == "function" then bx:Set(0, b) else bx[1] = b end
                                        if ag then bs.AggGeom = ag else bs.BoxElems = bx end
                                    end
                                end
                            end)
                            pcall(function()
                                local sp = (ag and ag.SphylElems) or bs.SphylElems
                                if sp then
                                    local s = (type(sp.Get) == "function") and sp:Get(0) or sp[1]
                                    if s then
                                        s.Radius = (s.Radius or 15) * mult
                                        s.Length = (s.Length or 30) * mult
                                        if type(sp.Set) == "function" then sp:Set(0, s) else sp[1] = s end
                                        if ag then bs.AggGeom = ag else bs.SphylElems = sp end
                                    end
                                end
                            end)
                            pcall(function()
                                local sr = (ag and ag.SphereElems) or bs.SphereElems
                                if sr then
                                    local r = (type(sr.Get) == "function") and sr:Get(0) or sr[1]
                                    if r then
                                        r.Radius = (r.Radius or 20) * mult
                                        if type(sr.Set) == "function" then sr:Set(0, r) else sr[1] = r end
                                        if ag then bs.AggGeom = ag else bs.SphereElems = sr end
                                    end
                                end
                            end)
                        end
                        _G._MBones[name] = true
                        if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end
                    end
                end
            end
        end
    end
    print("[MAGIC BULLET] ✅ تكبير مناطق الإصابة - تم التفعيل")
end

-- ============================================================
-- 7. واجهة المستخدم (UI MENU) - مع القائمة الرابعة
-- ============================================================

local SPEEDMenu = {}
local MENU_BP = "/Game/UMG/UI_BP/Common/Common_Legal_01_UIBP.Common_Legal_01_UIBP"
local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local Z_TRIGGER = 9300
local Z_MENU = 9600

SPEEDMenu.menuWidget = nil
SPEEDMenu.triggerWidget = nil
SPEEDMenu.currentPage = 1
SPEEDMenu.loadedButtons = {}

local function modLog(msg) print("[SPEEDFILES] " .. tostring(msg)) end
local function valid(obj) return obj and (not slua.isValid or slua.isValid(obj)) end

local function later(sec, fn)
    if _G.SetTimer then pcall(_G.SetTimer, sec, fn) return end
    local tk = _G.Mytimer_ticker
    if not tk then pcall(function() tk = require("common.time_ticker"); _G.Mytimer_ticker = tk end) end
    if tk and tk.AddTimer then pcall(tk.AddTimer, sec, fn); return end
    local GameThread = import("GameThread")
    if GameThread and GameThread.Delay then pcall(GameThread.Delay, sec, fn); return end
end

local function getLabel(feat)
    if type(feat.label) == "function" then return feat.label() end
    return feat.label
end

-- القوائم
local pages = {
    -- Page 1: Reveal Locations
    { title = "🎯 Reveal Locations", features = {
        { 
            label = function() return WallhackEnabled and "🔴 Flag Through Walls: ON" or "🟢 Flag Through Walls: OFF" end,
            action = function() 
                ToggleWallhack()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return WhiteBodyEnabled and "⚪ Brighten Character: ON" or "⚫ Brighten Character: OFF" end,
            action = function() 
                ToggleWhiteBody()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return SkeletonESPEnabled and "🦴 Enemy Skeleton: ON" or "🦴 Enemy Skeleton: OFF" end,
            action = function() 
                ToggleSkeletonESP()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return HealthESPEnabled and "❤️ Enemy Health: ON" or "❤️ Enemy Health: OFF" end,
            action = function() 
                ToggleHealthESP()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
    }},
    -- Page 2: Visual Extras
    { title = "🌿 Visual Extras", features = {
        { 
            label = function() return RemoveGrassEnabled and "🌿 Remove Grass: ON" or "🌿 Remove Grass: OFF" end,
            action = function() 
                ToggleRemoveGrass()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return RemoveTreesEnabled and "🌳 Remove Trees: ON" or "🌳 Remove Trees: OFF" end,
            action = function() 
                ToggleRemoveTrees()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return RemoveFogEnabled and "🌫️ Remove Fog: ON" or "🌫️ Remove Fog: OFF" end,
            action = function() 
                ToggleRemoveFog()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return BlackSkyEnabled and "🌑 Black Sky: ON" or "🌑 Black Sky: OFF" end,
            action = function() 
                ToggleBlackSky()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
    }},
    -- Page 3: Additional Features
    { title = "⚙️ Additional Features", features = {
        { 
            label = function() return BigPlayerEnabled and "📏 Enlarge Character: ON (" .. BigPlayerScale .. "x)" or "📏 Enlarge Character: OFF" end,
            action = function() 
                ToggleBigPlayer()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return IpadViewEnabled and "📱 iPad View: ON (" .. IpadViewFOV .. "°)" or "📱 iPad View: OFF" end,
            action = function() 
                ToggleIpadView()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return NoRecoilEnabled and "🎯 No Recoil: ON" or "🎯 No Recoil: OFF" end,
            action = function() 
                ToggleNoRecoil()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return FPS165Enabled and "⚡ 165 FPS: ON" or "⚡ 165 FPS: OFF" end,
            action = function() 
                ToggleFPS165()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return HitboxEnabled and "🎯 Magic Bullet: ON (" .. HitboxScale .. "x)" or "🎯 Magic Bullet: OFF" end,
            action = function() 
                ToggleHitbox()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { label = "📞 Contact: @BABYNOOB9", action = function() end },
        { label = "📢 Channel: BABYNOOB9", action = function() end },
    }},
    -- Page 4: Unsafe Challenges
    -- Page 4: Unsafe Challenges
    { title = "🔥 Unsafe Challenges", features = {
        { 
            label = function() return _G.MemoryConfig.SpeedBoost and "🚀 Player Speed: ON (" .. _G.MemoryConfig.SpeedPercent .. "%)" or "🚀 Player Speed: OFF" end,
            action = function() 
                ToggleSpeedBoost()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        -- ✅ NEW: Speed % ကို နှိပ်တိုင်း 100% တိုးမယ် (200 → 300 → ... → 1000 → ပြန်စ)
        { 
            label = function() return "⚡ Speed Rate: " .. _G.MemoryConfig.SpeedPercent .. "%" end,
            action = function() 
                local val = _G.MemoryConfig.SpeedPercent + 100
                if val > 1000 then val = 200 end
                SetSpeedPercent(val)
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return _G.MemoryConfig.AntiGravity and "🌕 Reduce Gravity: ON (" .. _G.MemoryConfig.GravityScale .. ")" or "🌕 Reduce Gravity: OFF" end,
            action = function() 
                ToggleAntiGravity()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return _G.MemoryConfig.WallClimb and "🧗 Wall Climb: ON" or "🧗 Wall Climb: OFF" end,
            action = function() 
                ToggleWallClimb()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return _G.MemoryConfig.CharRotation and "🔄 Player Rotation: ON" or "🔄 Player Rotation: OFF" end,
            action = function() 
                ToggleCharRotation()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return _G.MemoryConfig.SuperFireRate and "🔫 Fire Rate: ON" or "🔫 Fire Rate: OFF" end,
            action = function() 
                ToggleSuperFireRate()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return _G.MemoryConfig.InfiniteAmmo and "♾️ Infinite Ammo: ON" or "♾️ Infinite Ammo: OFF" end,
            action = function() 
                ToggleInfiniteAmmo()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return _G.MemoryConfig.MagicBullet and "✨ Magic Bullet: ON" or "✨ Magic Bullet: OFF" end,
            action = function() 
                ToggleMagicBullet()
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return "📏 Character Scale: " .. _G.MemoryConfig.CharScale .. "x" end,
            action = function() 
                local val = _G.MemoryConfig.CharScale + 0.1
                if val > 3.0 then val = 0.5 end
                SetCharScale(val)
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return "📏 Enemy Scale: " .. _G.MemoryConfig.EnemyScale .. "x" end,
            action = function() 
                local val = _G.MemoryConfig.EnemyScale + 0.1
                if val > 3.0 then val = 0.5 end
                SetEnemyScale(val)
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return "💥 Bullet Count: " .. _G.MemoryConfig.SuperBullet end,
            action = function() 
                local val = _G.MemoryConfig.SuperBullet + 1
                if val > 10 then val = 1 end
                SetSuperBullet(val)
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return "⚡ Rotation Speed: " .. _G.MemoryConfig.CharRotSpeed .. "°" end,
            action = function() 
                local val = _G.MemoryConfig.CharRotSpeed + 90
                if val > 720 then val = 90 end
                SetCharRotSpeed(val)
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
        { 
            label = function() return "🎯 Fire Rate Speed: " .. string.format("%.3f", _G.MemoryConfig.SuperFireRateVal) end,
            action = function() 
                local val = _G.MemoryConfig.SuperFireRateVal + 0.005
                if val > 0.05 then val = 0.008 end
                SetSuperFireRateVal(val)
                SPEEDMenu:UpdateButtonTexts()
            end 
        },
    }},
}

-- دوال المينيو
function SPEEDMenu:UpdateButtonTexts()
    for i, btn in ipairs(self.loadedButtons) do
        pcall(function()
            if valid(btn) and btn.RichText_Content then
                local page = pages[self.currentPage]
                if page and page.features[i] then
                    btn.RichText_Content:SetText(getLabel(page.features[i]))
                end
            end
        end)
    end
end

function SPEEDMenu:ClearButtons()
    for _, b in ipairs(self.loadedButtons) do
        pcall(function() if valid(b) then b:RemoveFromParent() end end)
    end
    self.loadedButtons = {}
end

function SPEEDMenu:BuildButtons(w)
    self:ClearButtons()
    local page = pages[self.currentPage]
    if not page then return end
    local startY = 200
    local btnW = 420
    local btnH = 52
    local gap = 10
    for i, feat in ipairs(page.features) do
        pcall(function()
            local btn = slua.loadUI(BTN_BP)
            if not btn or not valid(btn) then return end
            btn:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
            if btn.RichText_Content then btn.RichText_Content:SetText(getLabel(feat)) end
            if btn.Button_Temp and btn.Button_Temp.OnClicked then
                btn.Button_Temp.OnClicked:Add(function()
                    if feat.action then feat.action() end
                    if btn.RichText_Content then btn.RichText_Content:SetText(getLabel(feat)) end
                    SPEEDMenu:UpdateButtonTexts()
                end)
            end
            pcall(function() require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, Z_MENU + i) end)
            pcall(function()
                local slot = import("WidgetLayoutLibrary").SlotAsCanvasSlot(btn)
                if slot then
                    slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
                    slot:SetAlignment(FVector2D(0.5, 0))
                    slot:SetPosition(FVector2D(0, startY + (i - 1) * (btnH + gap)))
                    slot:SetSize(FVector2D(btnW, btnH))
                end
            end)
            table.insert(self.loadedButtons, btn)
        end)
    end
end

function SPEEDMenu:UpdateTabs(w)
    for i = 1, #pages do
        pcall(function()
            local sw = w["WidgetSwitcher_HighLight_" .. i]
            if sw then if i == self.currentPage then sw:SetActiveWidgetIndex(1) else sw:SetActiveWidgetIndex(0) end end
        end)
        pcall(function()
            local txt = w["TextBlock_Tab_" .. i]
            if txt then txt:SetText(pages[i].title) end
        end)
    end
end

function SPEEDMenu:Close()
    self:ClearButtons()
    if self.menuWidget and valid(self.menuWidget) then pcall(function() self.menuWidget:RemoveFromParent() end) end
    self.menuWidget = nil
    modLog("Menu Closed")
end

function SPEEDMenu:Open()
    if self.menuWidget and valid(self.menuWidget) then return end
    local w = nil
    pcall(function() w = slua.loadUI(MENU_BP) end)
    if not w or not valid(w) then modLog("ERROR: loadUI MENU_BP failed"); return end
    pcall(function() require("game_frontend_hud").AddToContainer(UIContainers.Top, w, Z_MENU) end)
    pcall(function() if w.HBox_Button then w.HBox_Button:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.TextBlock_tips then w.TextBlock_tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Button_OK then w.Button_OK:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Button_Cancel then w.Button_Cancel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Button_1 then w.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.Background_Btn then w.Background_Btn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    pcall(function() if w.UTRichText_Content then w.UTRichText_Content:SetText("") end end)
    for i = #pages + 1, 8 do
        pcall(function() if w["CanvasPanel_Tab_" .. i] then w["CanvasPanel_Tab_" .. i]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end end)
    end
    for i = 1, #pages do
        pcall(function()
            local tab = w["CanvasPanel_Tab_" .. i]
            if tab then tab:SetWidgetVisibility(UEnums.ESlateVisibility.Visible) end
            local txt = w["TextBlock_Tab_" .. i]
            if txt then txt:SetText(pages[i].title) end
        end)
        pcall(function()
            local btn = w["Button_Tab_" .. i]
            if btn then
                if btn.OnClicked then btn.OnClicked:Clear() end
                if btn.OnClicked then
                    local idx = i
                    btn.OnClicked:Add(function()
                        self.currentPage = idx
                        self:BuildButtons(w)
                        self:UpdateTabs(w)
                    end)
                end
            end
        end)
    end
    pcall(function()
        local popup = w.Common_Popup_Large_UIBP
        if popup and valid(popup) and popup.close and valid(popup.close) then
            if popup.close.OnClicked then popup.close.OnClicked:Clear() end
            if popup.close.OnClicked then popup.close.OnClicked:Add(function() self:Close() end) end
        end
    end)
    self.currentPage = 1
    self:BuildButtons(w)
    self:UpdateTabs(w)
    self.menuWidget = w
    modLog("Menu Opened")
end

function SPEEDMenu:Toggle()
    if self.menuWidget and valid(self.menuWidget) then self:Close() else self:Open() end
end

function SPEEDMenu:EnsureTrigger()
    if self.triggerWidget and valid(self.triggerWidget) then return end
    local tw = nil
    pcall(function() tw = slua.loadUI(BTN_BP) end)
    if tw and valid(tw) then
        pcall(function() require("game_frontend_hud").AddToContainer(UIContainers.Top, tw, Z_TRIGGER) end)
        pcall(function()
            if tw.RichText_Content then
                local f = tw.RichText_Content.Font
                f.Size = 14
                tw.RichText_Content:SetFont(f)
                tw.RichText_Content:SetText("BABYNOOB9 ⚡")
            end
        end)
        pcall(function()
            if tw.Button_Temp and tw.Button_Temp.OnClicked then
                tw.Button_Temp.OnClicked:Add(function() self:Toggle() end)
            end
        end)
        pcall(function()
            local slot = import("WidgetLayoutLibrary").SlotAsCanvasSlot(tw)
            if slot then
                slot:SetAnchors(FAnchors(1, 0, 1, 0))
                slot:SetAlignment(FVector2D(1, 0))
                slot:SetPosition(FVector2D(-16, 72))
                slot:SetSize(FVector2D(100, 44))
            end
            tw:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        self.triggerWidget = tw
    end
end

later(3, function() SPEEDMenu:EnsureTrigger() end)
later(10, function() SPEEDMenu:EnsureTrigger() end)

local tk = _G.Mytimer_ticker
if not tk then pcall(function() tk = require("common.time_ticker"); _G.Mytimer_ticker = tk end) end
if tk and tk.AddTimerLoop then
    tk.AddTimerLoop(30, function()
        SPEEDMenu:EnsureTrigger()
        if SPEEDMenu.triggerWidget and valid(SPEEDMenu.triggerWidget) then
            pcall(function()
                if SPEEDMenu.triggerWidget.RichText_Content then
                    SPEEDMenu.triggerWidget.RichText_Content:SetText("BABYNOOB9 ⚡")
                end
            end)
        end
    end, -1, 30)
end

-- ============================================================
-- 8. التهيئة والتشغيل
-- ============================================================

local SPEEDPlayerCharacterMod = {
    ServerRPC = {
        ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} },
        ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } }
    },
    ClientRPC = {},
    MulticastRPC = {}
}

function SPEEDPlayerCharacterMod:ctor()
    self.SPEED_Initialized = false
end

function SPEEDPlayerCharacterMod:_PostConstruct()
    SPEEDPlayerCharacterMod.__super._PostConstruct(self)
    self:StartSPEEDMod()
end

function SPEEDPlayerCharacterMod:ReceiveBeginPlay()
    SPEEDPlayerCharacterMod.__super.ReceiveBeginPlay(self)
    if Client then
        if GameplayData.AddCharacter then GameplayData.AddCharacter(self.Object) end
        SafeCall(function()
            local tk = require("common.time_ticker")
            if tk and tk.AddTimerOnce then tk.AddTimerOnce(3, function() _G.TryShowWelcome() end) end
        end)
    end
end

function SPEEDPlayerCharacterMod:ReceiveEndPlay(reason)
    SPEEDPlayerCharacterMod.__super.ReceiveEndPlay(self, reason)
    if Client and GameplayData.RemoveCharacter then GameplayData.RemoveCharacter(self.Object) end
end

function SPEEDPlayerCharacterMod:StartSPEEDMod()
    if not Client then return end
    if self.SPEED_Initialized then return end
    InitAntiCheatBypasses()
    self:AddGameTimer(0.5, true, function()
        if not IsValidObject(self.Object) then return end
        SafeCall(function()
            UpdateDeveloperWatermark()
        end)
    end)
    self.SPEED_Initialized = true
end

SafeCall(function()
    local tk = require("common.time_ticker")
    if tk and tk.AddTimerOnce then tk.AddTimerOnce(3, function() _G.TryShowWelcome() end) end
end)

-- ============================================================
-- 9. تسجيل الكلاس
-- ============================================================
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
  },
  {
    CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
  },
  {
    SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
  },
  {
    TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
  },
  {
    LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
  },
  {
    FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
  },
  {
    CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
  },
  {
    BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
  },
  {
    CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
  },
  {
    ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature"
  }
}, "BRPlayerCharacterBase")