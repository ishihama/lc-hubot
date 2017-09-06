# Description:
#   今週公開の映画を表示
#
# Commands:
#   hubot movie
#
# Notes:
#

cronJob = require('cron').CronJob
request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 0 10 * * 1"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      get_movie_list()
  )

  robot.respond /movie$/i, (msg) ->
    get_movie_list()

  get_movie_list = ->
    text = ""
    options =
      url: 'http://feeds.eiga.com/eiga_comingsoon?format=xml'
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      $ = cheerio.load body

      #desc = $('rss').children('channel').children('title').text()
      #text = desc

      for item in $('item')
        title = item['children'][0]['children'][0]['data']
        url = item['children'][4]['children'][0]['data']
        text = text + "\n" + title + ": <" + url + ">"

      data =
        content:
          color: "00ff00"
          fallback: "Sumally ....."
          title: "今週公開の映画"
          title_link: "http://eiga.com/upcoming/"
          text: text
          mrkdwn_in: ["text"]
        #channel: msg.envelope.room
        channel: "test"
        #username: "bot_name"
        #icon_emoji: ":emoji:"

      #robot.send {room: "movie"}, text
      #robot.send {room: "test"}, text
      robot.emit "slack.attachment",  data

