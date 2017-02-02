# Description:
#  random
#
# Connamds:
#   hubot random
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  robot.respond /(random|抽選|選ぶ)/i, (msg) ->
    msg.send robot.adapterName
    url = 'https://slack.com/api/channels.list?token=' + process.env.HUBOT_SLACK_TOKEN
    request url, (err, res, body) ->
      channel = JSON.parse(body).channels.filter (channel) ->
        return channel.name === msg.message.room

      if channel.length > 0
        members = channel[0].members.filter (member) ->
          return member !== robot.adapter.self.id
        member = msg.random channel[0].members
        
        msg.send "<@#{member}>"

