local offsets = debug.getupvaluex(GetMaterialXYOffset, "kTechIdToMaterialOffset")
offsets[kTechId.FlameSentry] = offsets[kTechId.Sentry]
