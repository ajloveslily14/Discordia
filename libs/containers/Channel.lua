local Snowflake = require('./Snowflake')

local json = require('json')
local class = require('../class')

local format = string.format

local Channel, get = class('Channel', Snowflake)

--[[
Guild Text     = 0
Private        = 1
Guild Voice    = 2
Group          = 3
Guild Category = 4
Guild News     = 5
Guild Store    = 6
]]

function Channel:__init(data, client)
	Snowflake.__init(self, data, client)
	self._guild_id = data.guild_id -- text, voice, category, news, store (excludes private and group)
	return self:_load(data)
end

function Channel:_load(data)
	self._type = data.type -- all types
	self._name = data.name -- text, voice, group, category, news, store (excludes private)
	self._topic = data.topic -- text, news
	self._nsfw = data.nsfw -- text, news, store
	self._position = data.position -- text, voice, category, news, store (excludes private and group)
	self._icon = data.icon -- group
	self._owner_id = data.owner_id -- group
	self._application_id = data.application_id -- group
	self._parent_id = data.parent_id -- text, voice, news, store (excludes private, group, category)
	self._last_pin_timestamp = data.last_pin_timestamp -- text, news, private
	self._bitrate = data.bitrate -- voice
	self._user_limit = data.user_limit -- voice
	self._rate_limit_per_user = data.rate_limit_per_user -- text
	-- TODO: permission overwrites -- text, voice, category, news, store (excludes private and group)
	-- TODO: recipients -- private, group
end

-- TODO: sorting
-- TODO: join/leave voice channel

function Channel:delete()
	return self.client:deleteChannel(self.id)
end

function Channel:createInvite(payload)
	return self.client:createChannelInvite(self.id, payload)
end

function Channel:getInvites()
	return self.client:getChannelInvites(self.id)
end

function Channel:getMessage(id)
	return self.client:getChannelMessage(self.id, id)
end

function Channel:getFirstMessage()
	local messages, err = self.client:getChannelMessages(self.id, 1, 'after', self.id)
	if messages then
		if messages[1] then -- NOTE: this might not always be an array
			return messages[1]
		else
			return nil, 'Channel has no messages'
		end
	else
		return nil, err
	end
end

function Channel:getLastMessage()
	local messages, err = self.client:getChannelMessages(self.id, 1)
	if messages then
		if messages[1] then -- NOTE: this might not always be an array
			return messages[1]
		else
			return nil, 'Channel has no messages'
		end
	else
		return nil, err
	end
end

function Channel:getMessages(limit, whence, messageId)
	return self.client:getChannelMessages(self.id, limit, whence, messageId)
end

function Channel:getPinnedMessages()
	return self.client:getPinnedMessages(self.id)
end

function Channel:bulkDelete(messages)
	return self.client:bulkDeleteMessages(self.id, messages)
end

function Channel:triggerTyping()
	return self.client:triggerTypingIndicator(self.id)
end

function Channel:send(payload)
	return self.client:createMessage(self.id, payload)
end

function Channel:createWebhook(name)
	return self.client:createWebhook(self.id, name)
end

function Channel:getWebhooks()
	return self.client:getChannelWebhooks(self.id)
end

function Channel:setName(name)
	return self.client:modifyChannel(self.id, {name = name or json.null})
end

function Channel:setCategory(parentId)
	return self.client:modifyChannel(self.id, {parent_id = parentId or json.null})
end

function Channel:setTopic(topic)
	return self.client:modifyChannel(self.id, {topic = topic or json.null})
end

function Channel:enableNSFW()
	return self.client:modifyChannel(self.id, {nsfw = true})
end

function Channel:disableNSFW()
	return self.client:modifyChannel(self.id, {nsfw = false})
end

function Channel:setRateLimit(limit)
	return self.client:modifyChannel(self.id, {rate_limit_per_user = limit or json.null})
end

function Channel:setBitrate(bitrate)
	return self.client:modifyChannel(self.id, {bitrate = bitrate or json.null})
end

function Channel:setUserLimit(userLimit)
	return self.client:modifyChannel(self.id, {user_limit = userLimit or json.null})
end

----

function get:type()
	return self._type
end

function get:mentionString()
	return format('<#%s>', self.id)
end

function get:name()
	return self._name
end

function get:position()
	return self._position
end

function get:guildId()
	return self._guild_id
end

function get:parentId()
	return self._parent_id
end

function get:topic()
	return self._topic
end

function get:nsfw()
	return self._nsfw
end

function get:rateLimit()
	return self._rate_limit_per_user or 0
end

function get:bitrate()
	return self._bitrate
end

function get:userLimit()
	return self._user_limit
end

return Channel
