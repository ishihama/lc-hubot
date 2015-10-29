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
      url: "https://#{process.env.spaceId}.backlog.jp/api/v2/issues?apiKey=#{process.env.apiKey}"
      form:
        projectId: process.env.projectId
        summary: msg.match[1]
        priorityId: 3
        issueTypeId: process.env.issueTypeId
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request.post options,  (error,  response,  body) ->
      text = "https://#{process.env.spaceId}.backlog.jp/view/"
      text += (JSON.parse(body)["issueKey"])
      msg.send("#{text} を登録しました")

