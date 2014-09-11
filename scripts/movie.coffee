# Description:
#   今週公開の映画を表示
#
# Commands:
#   hubot movie
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.respond /movie/i,  (msg) ->
    options =
      url: 'http://feeds.eiga.com/eiga_comingsoon?format=xml'
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      $ = cheerio.load body

      desc = $('rss').children('channel').children('title').text()
      text = desc

      for item in $('item')
        title = item['children'][0]['children'][0]['data']
        url = item['children'][4]['children'][0]['data']
        text = text + "\n" + title + " / " + url

      msg.send(text)

