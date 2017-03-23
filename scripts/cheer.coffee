# Description:
#   頑張るあなたを応援します
#
# Commands:
#   hubot (応援|疲れた)
#
# Notes:
#

client  = require 'cheerio-httpcli'

NEKKETSU_OUEN = 'https://docs.google.com/spreadsheets/d/14FUQMxDSwJxujfjAZNpPbhhQroegMcPUitbGb88R2pU/export?format=tsv'

module.exports = (robot) ->
  robot.respond /(応援｜疲れた)(.*)$/i, (msg) ->
    get_cheer_messages NEKKETSU_OUEN, (messages) ->
      cheer = msg.random(messages);
      msg.send(cheer)

get_cheer_messages = (url, callback) ->
  client.fetch url, {}, (error, $, response, body) ->
    messages = []
    for line, i in body.split('\n')
      line = line.trim()
      if line.length > 1
        messages[i] = line
    callback(messages)
