//=============================================================================
// BackAndTP.
//=============================================================================
class BackAndTP expands Mutator;

var vector DeadLocations[256];
var rotator DeadRotations[256];

function ScoreKill(Pawn Killer, Pawn Other) {
	local int playerID;

	playerID = PlayerPawn(Other).PlayerReplicationInfo.PlayerID;

	DeadLocations[playerID] = Other.Location;
	DeadRotations[playerID] = Other.Rotation;
}


function Mutate(string MutateString, PlayerPawn Sender) {

	local int playerID;
	local string playerName;
	local vector unSetVector;
	local pawn aPawn;

	Super.Mutate(MutateString, Sender);


	if(left(Caps(MutateString),4) == "BACK") {

		playerID = Sender.PlayerReplicationInfo.PlayerID;
		
		if (DeadLocations[playerID].Z == 0 && DeadLocations[playerID].Y == 0 && DeadLocations[playerID].Z == 0 ) {
			Sender.ClientMessage("You have not died yet so there is nothing to go back to.");
			
			return;
		}
		
		Sender.SetLocation(DeadLocations[playerID]);
		Level.Game.PlayTeleportEffect(Sender, false, true);

	}
	if(left(Caps(MutateString),4) == "WARP") {
		
		playerName = Mid(Caps(MutateString), 5);

   		for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn ) {
			if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None) {
				if(Caps(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName) == playerName) {
					
					Sender.SetLocation(aPawn.Location);
					Level.Game.PlayTeleportEffect(Sender, false, true);
					return;
				}
			}
		}

		Sender.ClientMessage("Could not find a player with the specified name.");
	}

	

}
