# Description:
#  backlog api
#
# Commands:
#   hubot backlog <ProjectId> <Title> <Description>
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  robot.respond /backlog (.+)\s(.+)\s(.+)/i, (msg) ->
    options =
      url: "https://#{process.env.HUBOT_BACKLOG_SPACE_ID}.backlog.jp/api/v2/issues?apiKey=#{process.env.HUBOT_BACKLOG_API_KEY}"
      form:
        projectId: msg.match[1]
        summary: msg.match[2]
        description: msg.match[3]
        priorityId: 3
        issueTypeId: process.env.HUBOT_BACKLOG_ISSUE_TYPE_ID
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request.post options,  (error,  response,  body) ->
      text = "https://#{process.env.HUBOT_BACKLOG_SPACE_ID}.backlog.jp/view/"
      text += (JSON.parse(body)["issueKey"])
      msg.send("Subject:#{msg.match[2]}\nURL:#{text}")

