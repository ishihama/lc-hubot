# Description:
#  random
#
# Commands:
#   hubot random
#   hubot random <phrases>
#
# Notes:
#

request = require 'request'

MESSAGE_TEMPLATE = [
  ":shibazo: <@{member}> おねがいねー。",
  ":pray: <@{member}> さん、おねがいします！",
  "<@{member}> :yoro:",
]


module.exports = (robot) ->
  robot.respond /(random|抽選|選ぶ)(.*)$/i, (msg) ->
    url = 'https://slack.com/api/channels.list?token=' + process.env.HUBOT_SLACK_TOKEN
    request url, (err, res, body) ->
      main msg, JSON.parse(body).channels, robot
    url = 'https://slack.com/api/groups.list?token=' + process.env.HUBOT_SLACK_TOKEN
    request url, (err, res, body) ->
      main msg, JSON.parse(body).groups, robot


main = (msg, list, robot) ->
  channel = (c for c in list when c.name == msg.message.room)
#  channel = (c for c in list when c.name == 'lets_today_nomu')

  if channel.length > 0
    members = (m for m in channel[0].members when m != robot.adapter.self.id)
#    members = (m for m in channel[0].members when m != '')
    member = msg.random members

    message = "<@#{member}>"

    if msg.match[2]
      message += msg.match[2]
    else
      message = msg.random(MESSAGE_TEMPLATE).replace("{member}", member)
        
     msg.send message


