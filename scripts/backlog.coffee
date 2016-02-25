# Description:
#  backlog api
#
# Commands:
#   hubot backlog <ProjectKey> <Title> <Description>
#   hubot backlog-putenv <ProjectKey> <EnvKey> <EnvValue>
#   hubot backlog-getenv <ProjectKey>
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  keyPrefix = "BACKLOG-"
  keySuffixes = ["PROJECT-ID", "ISSUE-TYPE-ID", "CATEGORY-ID", "BOT-RESPONSE"]

  robot.respond /backlog (.+?)\s+(.+?)\s+([\s\S]*)/i, (msg) ->
    arg1 = msg.match[1].toUpperCase()
    arg2 = msg.match[2]
    arg3 = msg.match[3]
    options =
      url: "https://#{process.env.HUBOT_BACKLOG_SPACE_ID}.backlog.jp/api/v2/issues?apiKey=#{process.env.HUBOT_BACKLOG_API_KEY}"
      form:
        summary: arg2
        description: arg3
        priorityId: 3
        projectId: robot.brain.get(keyPrefix + arg1 + "-" + keySuffixes[0])
        issueTypeId: robot.brain.get(keyPrefix + arg1 + "-" + keySuffixes[1])
        categoryId: [robot.brain.get(keyPrefix + arg1 + "-" + keySuffixes[2])] ? []
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request.post options,  (error,  response,  body) ->
      text = "https://#{process.env.HUBOT_BACKLOG_SPACE_ID}.backlog.jp/view/"
      text += (JSON.parse(body)["issueKey"])
      text += "\n"
      text += robot.brain.get(keyPrefix + arg1 + keySuffixes[3]) ? ""
      msg.send("Subject:#{msg.match[2]}\nURL:#{text}")

  robot.respond /backlog-putenv (.+?)\s+(.+?)\s+([\s\S]*)/i, (msg) ->
    arg1 = msg.match[1].toUpperCase()
    arg2 = msg.match[2].toUpperCase()
    arg3 = msg.match[3]
    robot.brain.set(keyPrefix + arg1 + "-" + arg2, arg3)

  robot.respond /backlog-getenv (.+)/i, (msg) ->
    arg1 = msg.match[1].toUpperCase()
    for keySuffix in keySuffixes
      key = keyPrefix + arg1 + "-" + keySuffix
      val = robot.brain.get(key) ? []
      msg.send(key + ":" + val)
