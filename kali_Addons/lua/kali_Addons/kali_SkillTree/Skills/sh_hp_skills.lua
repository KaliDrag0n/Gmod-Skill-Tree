kAddSkillGroup( "Health Upgrade", "HP", {
	DispName = "Health Upgrade",
	Desc = "This Skill Line Adds To Your Maximum HP!",

	AvailableRoles = {
		All_Jobs = true
	},
	
	NonAvailableRoles = {
	},
	
	RequiredSkills = {
	}
} )

kAddSkill( "Health Upgrade", "HP", 1, {
	AddHP = 25,
	DispName = "Health Upgrade [1]",
	Desc = "Adds 25HP To Your Max.",
	
	Cost = 25,
	
	AvailableRoles = {
		All_Jobs = true
	},
	
	NonAvailableRoles = {
	},
	
	RequiredSkills = {
	}
} )

kAddSkill( "Health Upgrade", "HP", 2, {
	AddHP = 25,
	DispName = "Health Upgrade [2]",
	Desc = "Adds 25HP To Your Max.",
	
	Cost = 50,
	
	AvailableRoles = {
		All_Jobs = true
	},
	
	NonAvailableRoles = {
	},
	
	RequiredSkills = {
		HP = {
			Name = "Health Upgrade",
			IDs = {
				[1]=true
			}
		}
	}
} )

kAddSkill( "Health Upgrade", "HP", 3, {
	AddHP = 25,
	DispName = "Health Upgrade [3]",
	Desc = "Adds 25HP To Your Max.",
	
	Cost = 75,
	
	AvailableRoles = {
		All_Jobs = true
	},
	
	NonAvailableRoles = {
	},
	
	RequiredSkills = {
		HP = {
			Name = "Health Upgrade",
			IDs = {
				[2]=true
			}
		}
	}
} )

kAddSkill( "Health Upgrade", "HP", 4, {
	AddHP = 25,
	DispName = "Health Upgrade [4]",
	Desc = "Adds 25HP To Your Max.",
	
	Cost = 100,
	
	AvailableRoles = {
		All_Jobs = true
	},
	
	NonAvailableRoles = {
	},
	
	RequiredSkills = {
		HP = {
			Name = "Health Upgrade",
			IDs = {
				[3]=true
			}
		}
	}
} )