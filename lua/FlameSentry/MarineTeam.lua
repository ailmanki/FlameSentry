local old = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
	old(self)
	self.techTree:AddBuildNode(kTechId.FlameSentry, kTechId.RoboticsFactory, kTechId.None, true)
	self.techTree.complete = false
	self.techTree:SetComplete()
end
