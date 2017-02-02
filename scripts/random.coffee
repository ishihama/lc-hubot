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
    url = 'https://slack.com/api/channels.list?token=' + process.env.HUBOT_SLACK_TOKEN
    request url, (err, res, body) ->
      channel = (c for c in JSON.parse(body).channels when c.name == msg.message.room)

      if channel.length > 0
        members = (m for m in channel[0].members when m != robot.adapter.self.id)
        member = msg.random members
        
        msg.send "<@#{member}>"

