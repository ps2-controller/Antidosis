contract DeploymentCore{

	uint taxRate;
	uint defaultValue = 0;
	uint defaultDuration = 0;

	struct HarbingerSet{
		uint userValue;
		uint userDuration;
	}

	mapping(address => HarbingerSet) harbingerSetByUser;


	constructor DeploymentCore{

	}


	function setHarbinger(_userValue, _userDuration) {
		require (_value != 0);
		require (_duration != 0);
		harbingerSetByUser[msg.sender].userValue = _userValue;
		harbingerSetByUser[msg.sender].userDuration = _userDuration;
	}

}