# Description:
#  tiqav
#
# Commands:
#   hubot tiqav ちくわ
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  robot.respond /tiqav (.+)$/i, (msg) ->
    options =
      url: "http://api.tiqav.com/search.json?q=#{msg.match[1]}"
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      index = Math.floor(Math.random() * JSON.parse(body).length)
      text = "http://img.tiqav.com/"
      text += (JSON.parse(body)[index]["id"])
      text += "."
      text += (JSON.parse(body)[index]["ext"])
      msg.send("#{text}")

