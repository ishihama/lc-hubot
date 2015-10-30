# Description:
#  backlog api
#
# Commands:
#   hubot backlog 課題件名
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  robot.respond /backlog (.+)$/i, (msg) ->
    options =
      url: "https://#{process.env.HUBOT_BACKLOG_SPACE_ID}.backlog.jp/api/v2/issues?apiKey=#{process.env.HUBOT_BACKLOG_API_KEY}"
      form:
        projectId: process.env.HUBOT_BACKLOG_PROJECT_ID
        summary: msg.match[1]
        priorityId: 3
        issueTypeId: process.env.HUBOT_BACKLOG_ISSUE_TYPE_ID
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request.post options,  (error,  response,  body) ->
      text = "https://#{process.env.HUBOT_BACKLOG_SPACE_ID}.backlog.jp/view/"
      text += (JSON.parse(body)["issueKey"])
      msg.send("#{text} を登録しました")

