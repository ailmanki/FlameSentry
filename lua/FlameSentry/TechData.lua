
local old = assert(BuildTechData)
function BuildTechData()
	local data = old()
	table.insert(data, {
		[kTechDataId]                       = kTechId.FlameSentry,
		[kTechDataSupply]                   = kSentrySupply,
		[kTechDataBuildMethodFailedMessage] = "COMMANDERERROR_TOO_MANY_SENTRIES",
		[kTechDataHint]                     = "SENTRY_HINT",
		[kTechDataGhostModelClass]          = "MarineGhostModel",

		[kTechDataMapName]                  = FlameSentry.kMapName,
		[kTechDataDisplayName]              = "FLAME_SENTRY_TURRET",
		[kTechDataCostKey]                  = kSentryCost,
		[kTechDataPointValue]               = kSentryPointValue,
		[kTechDataModel]                    = assert(FlameSentry.kModelName),

		[kTechDataBuildTime]                = kSentryBuildTime,
		[kTechDataMaxHealth]                = kSentryHealth,
		[kTechDataMaxArmor]                 = kSentryArmor,
		[kTechDataDamageType]               = kFlamethrowerDamageType,
		[kTechDataSpecifyOrientation]       = true,
		[kTechDataInitialEnergy]            = kSentryInitialEnergy,
		[kTechDataMaxEnergy]                = kSentryMaxEnergy,
		[kTechDataNotOnInfestation]         = kPreventMarineStructuresOnInfestation,
		[kTechDataEngagementDistance]       = kSentryEngagementDistance,
		[kTechDataTooltipInfo]              = "SENTRY_TOOLTIP",

		[kStructureBuildNearClass]          = "SentryBattery",
		[kStructureAttachRange]             = SentryBattery.kRange,
		[kTechDataBuildRequiresMethod]      = GetCheckSentryLimit,
		[kTechDataGhostGuidesMethod]        = GetBatteryInRange,
		[kTechDataObstacleRadius]           = 0.25,
	})
	return data
end
