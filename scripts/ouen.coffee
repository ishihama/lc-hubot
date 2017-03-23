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
    get_ouen NEKKETSU_OUEN, (messages) ->
      rnd = Math.floor(Math.random() * (Object.keys(kanojos).length))
      ouen = Object.keys(messages)[rnd];
      msg.send(ouen)

get_ouen = (url, callback) ->
  client.fetch url, {}, (error, $, response, body) ->
    messages = []
    for line, i in body.split('\n')
      line = line.trim()
      if line.length > 1
        messages[i] = line
    callback(messages)
