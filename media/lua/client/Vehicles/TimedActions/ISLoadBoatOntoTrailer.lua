--**************************************************************
--**                    Developer: Aiteron                    **
--**************************************************************

require "TimedActions/ISBaseTimedAction"

ISLoadBoatOntoTrailer = ISBaseTimedAction:derive("ISLoadBoatOntoTrailer")


function ISLoadBoatOntoTrailer:isValid()
	return self.trailer and not self.trailer:isRemovedFromWorld();
end

function ISLoadBoatOntoTrailer:update()
	self.character:faceThisObject(self.trailer)

	-- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
	local speedCoeff = { [1] = 1, [2] = 5, [3] = 20, [4] = 40 }

	local timeLeftNow =  (1 - self:getJobDelta()) * self.maxTime

	if self.isFadeOut == false and timeLeftNow < 250 * speedCoeff[uispeed] then
		UIManager.FadeOut(self.character:getPlayerNum(), 1)
		self.isFadeOut = true
	end

    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ISLoadBoatOntoTrailer:start()
	self:setActionAnim("Loot")
	self.trailer:getEmitter():playSound("boat_on_trailer")
end

function ISLoadBoatOntoTrailer:stop()
	if self.isFadeOut == true then
		UIManager.FadeIn(self.character:getPlayerNum(), 1)
		UIManager.setFadeBeforeUI(self.character:getPlayerNum(), false)
	end
	self.trailer:getEmitter():stopSoundByName("boat_on_trailer")
	ISBaseTimedAction.stop(self)
end

function ISLoadBoatOntoTrailer:perform()
	local newTrailerName = AquaConfig.Trailers[self.trailer:getScript():getName()].trailerWithBoatTable[self.boat:getScript():getName()]
	ISVehicleMenuForTrailerWithBoat.replaceTrailer(self.trailer, newTrailerName)
	ISVehicleMenuForTrailerWithBoat.replaceTrailerBoat(self.boat, self.trailer)
	self.boat:removeFromWorld()

	local playerNum = self.character:getPlayerNum()
	UIManager.FadeIn(playerNum, 1)
	UIManager.setFadeBeforeUI(playerNum, false)

	ISBaseTimedAction.perform(self)
end


function ISLoadBoatOntoTrailer:new(character, trailer, boat)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
    o.trailer = trailer
    o.boat = boat

	o.isFadeOut = false
    o.maxTime = 500;  -- TODO исправить на 1000
    
	if character:isTimedActionInstant() then o.maxTime = 10 end
	return o
end

