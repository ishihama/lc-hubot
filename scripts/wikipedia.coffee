# Description:
#  wikipedia
#
# Commands:
#   hubot wiki <query>
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  robot.respond /wikipedia (.+)$/i, (msg) ->
    options =
      url: "http://ja.wikipedia.org/w/api.php?action=query&format=json&titles=#{msg.match[1]}&prop=extracts&redirects=1&exchars=130&explaintext=1"
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      article = (JSON.parse(body)['query']['pages'])
      for id of article
        console.log(JSON.parse(body)['query']['pages'][id]['extract'])
        text = (JSON.parse(body)['query']['pages'][id]['extract'])
        msg.send("#{text}")

