
global function MpWeaponSniper_Init

global function OnWeaponActivate_weapon_sniper
global function OnWeaponPrimaryAttack_weapon_sniper
global function OnProjectileCollision_weapon_sniper

// fuppy
// global function OnWeaponPrimaryAttack_weapon_custombolt
// global function OnWeaponNpcPrimaryAttack_weapon_custombolt

#if CLIENT
global function OnClientAnimEvent_weapon_sniper
#endif // #if CLIENT

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_sniper
#endif // #if SERVER

void function MpWeaponSniper_Init()
{
	SniperPrecache()
}

void function SniperPrecache()
{
	PrecacheParticleSystem( $"wpn_mflash_snp_hmn_smoke_side_FP" )
	PrecacheParticleSystem( $"wpn_mflash_snp_hmn_smoke_side" )
	PrecacheParticleSystem( $"Rocket_Smoke_SMR_Glow" )
}

void function OnWeaponActivate_weapon_sniper( entity weapon )
{
#if CLIENT
	UpdateViewmodelAmmo( false, weapon )
#endif // #if CLIENT
}

#if CLIENT
void function OnClientAnimEvent_weapon_sniper( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )

	if ( name == "muzzle_flash" )
	{

		if ( IsOwnerViewPlayerFullyADSed( weapon ) )
			return

		weapon.PlayWeaponEffect( $"wpn_mflash_snp_hmn_smoke_side_FP", $"wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_L" )
		weapon.PlayWeaponEffect( $"wpn_mflash_snp_hmn_smoke_side_FP", $"wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_R" )
	}
}

#endif // #if CLIENT

var function OnWeaponPrimaryAttack_weapon_sniper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	// float volume = 0.01
	//var volumeField = weapon.GetWeaponInfoFileKeyField( "sound_volume" )
	//if(volumeField != null)
	//	volume = expect float( volumeField )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2)


	// fuppy: sound test
	// string conversationName = "elimEnemyPilot"
	// int priority = GetConversationPriority( conversationName )
	// string primeTitanString = ""
	// string titanCharacterName = "vanguard"
	// string soundAlias = "diag_gs_titan" + titanCharacterName + primeTitanString + "_" + conversationName
	// PlayOneLinerConversationOnEntWithPriority( conversationName, soundAlias, weapon.GetWeaponOwner(), priority )
	//PlayFactionDialogueOnLocalClientPlayer("aichat_killed_enemy_titan")


	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_sniper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( weapon, attackParams, false )
}
#endif // #if SERVER

int function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	#if CLIENT
	// fuppy: we want NPCs to fire projectiles
		// if ( !playerFired )
		// 	shouldCreateProjectile = false
	#endif

	if ( shouldCreateProjectile )
	{
		int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
		int damageFlags = weapon.GetWeaponDamageFlags()
		entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )

		if ( bolt != null )
		{
			bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )

#if CLIENT
				StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
#endif // #if CLIENT
		}
	}

	return 1
}

// var function OnWeaponPrimaryAttack_weapon_custombolt( entity weapon, WeaponPrimaryAttackParams attackParams ) {
// 	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
// 	FireCustomBolt(weapon, attackParams, true)
// }
// var function OnWeaponNpcPrimaryAttack_weapon_custombolt( entity weapon, WeaponPrimaryAttackParams attackParams ) {
// 	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
// 	FireCustomBolt(weapon, attackParams, false)
// }

var function FireCustomBolt( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired ) {
	int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
	int damageFlags = weapon.GetWeaponDamageFlags()
	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )

	if ( bolt != null ) {
		bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )

#if CLIENT
		StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
#endif // #if CLIENT
	}

	return 1
}

void function OnProjectileCollision_weapon_sniper( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		int bounceCount = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_ricochet_max_count )
		if ( projectile.proj.projectileBounceCount >= bounceCount )
			return

		if ( hitEnt == svGlobal.worldspawn )
			EmitSoundAtPosition( TEAM_UNASSIGNED, pos, "Bullets.DefaultNearmiss" )

		projectile.proj.projectileBounceCount++
	#endif
}