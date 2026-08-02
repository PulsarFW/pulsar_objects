_placedProps = {}

CreateThread(function()
	plsr.Callbacks:RegisterClientCallback("Objects:StartPlacement", function(data, cb)
		plsr.ObjectPlacer:Start(data.model, "Objects:Client:FinishPlacement", data.data, true, nil, true)
		cb()
	end)
end)

AddEventHandler("Objects:Client:FinishPlacement", function(data, endCoords)
	TriggerServerEvent("Objects:Server:Create", data, endCoords)
end)

RegisterNetEvent("Objects:Client:SetupObjects", function(objs)
	for k, v in pairs(objs) do
		plsr.Objects:Create(k, v.type, v.creator, v.model, v.coords, v.heading, v.rotation, v.isFrozen, v.nameOverride)
	end
end)

RegisterNetEvent("Characters:Client:Logout", function()
	for k, v in pairs(_placedProps) do
		plsr.Objects:Delete(k)
	end
end)

RegisterNetEvent("Objects:Client:Create", function(id, type, creator, model, coords, heading, rotation, isFrozen, nameOverride)
	plsr.Objects:Create(id, type, creator, model, coords, heading, rotation, isFrozen, nameOverride)
end)

RegisterNetEvent("Objects:Client:Delete", function(id)
	plsr.Objects:Delete(id)
end)

_OBJECTS = {
	Create = function(self, id, type, creator, model, coords, heading, rotation, isFrozen, nameOverride)
		loadModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, true, false)

		if rotation and rotation.x then
			SetEntityRotation(obj, rotation.x, rotation.y, rotation.z)
		elseif heading then
			SetEntityHeading(obj, heading + 0.0)
		end

		FreezeEntityPosition(obj, isFrozen)
		while not DoesEntityExist(obj) do
			Wait(1)
		end

		local entState = Entity(obj).state
		entState.isPlacedProp = true
		entState.objectId = id

		_placedProps[id] = {
			id = id,
			type = type,
			creator = creator,
			entity = obj,
			model = model,
			coords = coords,
			heading = heading,
			rotation = rotation,
			isFrozen = isFrozen,
			nameOverride = nameOverride,
		}

		plsr.Targeting:AddEntity(obj, "square", {
			{
				icon = "eye",
				text = "Open",
				event = "Objects:Client:OpenInventory",
				data = {
					id = id,
					type = type,
					creator = creator,
					entity = obj,
					model = model,
					coords = coords,
					heading = heading,
					rotation = rotation,
					isFrozen = isFrozen,
					nameOverride = nameOverride,
				},
				isEnabled = function(data, entity)
					local eState = Entity(entity.entity).state
					return eState.isPlacedProp and _placedProps[entState.objectId].type == 1
				end,
			},
			{
				icon = "trash",
				text = "Delete Object",
				event = "Objects:Client:DeleteObject",
				data = {
					id = id,
					type = type,
					creator = creator,
					entity = obj,
					model = model,
					coords = coords,
					heading = heading,
					rotation = rotation,
					isFrozen = isFrozen,
					nameOverride = nameOverride,
				},
				isEnabled = function(data, entity)
					local eState = Entity(entity.entity).state
					return eState.isPlacedProp
						and (plsr.State.flags.isStaff or plsr.State.flags.isAdmin or plsr.State.character.SID == _placedProps[entState.objectId].creator)
						and _placedProps[entState.objectId].type ~= 2
				end,
			},
			{
				icon = "info",
				text = "View Object Details",
				event = "Objects:Client:ViewData",
				data = {
					id = id,
					type = type,
					creator = creator,
					entity = obj,
					model = model,
					coords = coords,
					heading = heading,
					rotation = rotation,
					isFrozen = isFrozen,
					nameOverride = nameOverride,
				},
				isEnabled = function(data, entity)
					local eState = Entity(entity.entity).state
					return eState.isPlacedProp
						and (plsr.State.flags.isStaff or plsr.State.flags.isAdmin)
						and _placedProps[entState.objectId].type ~= 2
				end,
			},
		}, 3.0, true)
	end,
	Delete = function(self, id)
		if _placedProps[id] ~= nil then
			DeleteEntity(_placedProps[id].entity)
			_placedProps[id] = nil
		else
			return false
		end
	end,
}

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["pulsar_core"]:RegisterComponent("Objects", _OBJECTS)
end)

AddEventHandler("Objects:Client:DeleteObject", function(entity, data)
	if Entity(entity.entity).state.isPlacedProp then
		TriggerServerEvent("Objects:Server:Delete", Entity(entity.entity).state.objectId)
	end
end)

AddEventHandler("Objects:Client:ViewData", function(entity, data)
	TriggerServerEvent("Objects:Server:View", Entity(entity.entity).state.objectId)
end)

AddEventHandler("Objects:Client:OpenInventory", function(entity, data)
	plsr.Inventory.Dumbfuck:Open({
		invType = 138,
		owner = Entity(entity.entity).state.objectId,
	})
end)
