//=============================================================================
// BackAndTP.
//=============================================================================
class BackAndTP expands Mutator;

var LocAndRotStorage TeleportLocAndRotStorage[256];
var string players[256]; // PRI.PlayerID seems unreliable, just recognize players by their name, that will be good enough.


function PostBeginPlay() {
	settimer(1, true);
}

event timer() {
	local Pawn aPawn;
	
	// Save the current position and rotation of each player.

	/* Information older than 10 seconds can be ditched.
	 
		Information younger than 10 seconds needs to be saved, because
		the location of 8 seconds ago will be relevant 2 seconds later for example.
	*/

	for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn ) {
		if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None) {
			addLocationAndRotationForPlayer(PlayerPawn(aPawn));
		}
	}
}

function addLocationAndRotationForPlayer(PlayerPawn player) {
	local int i;
	local int playerID;
	
	// Get the playerid
	playerID = getPlayerID(player.PlayerReplicationInfo.Playername);
	
	// Rotate the TeleportLocations and TeleportRotations for this player.
	for (i=9;i>0;i--) { // ID 9 will be overwritten with the info from ID 8 etc. ID 0 does not need to be handled here so i>0.
		TeleportLocAndRotStorage[playerID].TeleportLocations[i] = TeleportLocAndRotStorage[playerID].TeleportLocations[i-1];
		TeleportLocAndRotStorage[playerID].TeleportRotations[i] = TeleportLocAndRotStorage[playerID].TeleportRotations[i-1];

	}
	
	TeleportLocAndRotStorage[playerID].TeleportLocations[0] = player.Location;
	TeleportLocAndRotStorage[playerID].TeleportRotations[0] = player.Rotation;

	Log(TeleportLocAndRotStorage[playerID].TeleportLocations[0]);
	
}


function int getPlayerID(string playername) {
	local int i;
	
	// Loop through the players array and when the name matches, return the id.
	for (i = 0; i < 256; i++) {
		if (players[i] == playername) {
			return i;
		}
	}

	// Player not found, find an unused ID and then assign it.
	for (i = 0; i < 256; i++) {
		if (players[i] == "") {
			players[i] = playername;
			
			// At the same time spawn in a LocAndRotStorage object for the player.
			TeleportLocAndRotStorage[i] = Spawn(class'BackAndTP.LocAndRotStorage');
			return i;
		}
	}
	
	// This point will probably never be reached, just return -1.
	return -1;
}

function Mutate(string MutateString, PlayerPawn Sender) {

	local int playerID;
	local string playerName;
	local vector unSetVector, destination;
	local pawn aPawn;

	Super.Mutate(MutateString, Sender);


	if(left(Caps(MutateString),4) == "BACK") {
		
		// Teleport back to the location and rotation of 10 seconds ago.
		// That will highly probably be a safe and valid location.

		playerID = getPlayerID(Sender.PlayerReplicationInfo.Playername);
		
		if (TeleportLocAndRotStorage[playerID].TeleportLocations[9].Z == 0 &&
				TeleportLocAndRotStorage[playerID].TeleportLocations[9].Y == 0 &&
				TeleportLocAndRotStorage[playerID].TeleportLocations[9].Z == 0 ) {
			
			Sender.ClientMessage("You need to have been playing for 10 seconds to be able to use the back function.");
			
			return;
		}
		
		Sender.SetLocation(TeleportLocAndRotStorage[playerID].TeleportLocations[9]);
		Sender.SetRotation(TeleportLocAndRotStorage[playerID].TeleportRotations[9]);

		Level.Game.PlayTeleportEffect(Sender, false, true);

	}
	if(left(Caps(MutateString),4) == "WARP") {
		
		playerName = Mid(Caps(MutateString), 5);

   		for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn ) {
			if(aPawn.bIsPlayer && PlayerPawn(aPawn) != None) {
				if(Caps(PlayerPawn(aPawn).PlayerReplicationInfo.PlayerName) == playerName) {
	
					destination = aPawn.Location;
					destination.X += 60; // On good luck that we don't end up in a wall.
					
					Sender.SetLocation(destination);
					Level.Game.PlayTeleportEffect(Sender, false, true);
					return;
				}
			}
		}

		Sender.ClientMessage("Could not find a player with the specified name.");
	}

	

}

function warp() {
	/*

	native(277) final function Actor Trace
	(
		out vector      HitLocation,
		out vector      HitNormal,
		vector          TraceEnd,
		optional vector TraceStart,
		optional bool   bTraceActors,
		optional vector Extent
	);
	*/

}
