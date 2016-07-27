# Description:
#   lets today kanojo.
#
# Commands:
#   hubot lets_today_kanojo
#   hubot lets_random_kanojo
#   hubot lets_konohi_kanojo 2012.10.04
#

cronJob = require('cron').CronJob
client  = require 'cheerio-httpcli'

module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 0 10 * * *"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      cron_today_kanojo()
  )
  cron_today_kanojo = ->
    get_kanojos (kanojos) ->
      now = new Date()
      ymd = now.getFullYear() + "." + ('0' + (now.getMonth() + 1)).slice(-2) + "." + ('0' + now.getDate()).slice(-2)
      if (ymd of kanojos)
        robot.send {room: "lets_today_kanojo"}, '今日の彼女です。\r\n' + 'http://r25.jp/entertainment/' + kanojos[ymd] + '/'

  robot.respond /lets_today_kanojo$/i, (msg) ->
    get_kanojos (kanojos) ->
      now = new Date()
      ymd = now.getFullYear() + "." + ('0' + (now.getMonth() + 1)).slice(-2) + "." + ('0' + now.getDate()).slice(-2)
      if (ymd of kanojos)
        msg.send('http://r25.jp/entertainment/' + kanojos[ymd] + '/')
      else
        msg.send("今日はまだ彼女いないよ。")

  robot.respond /lets_random_kanojo/i, (msg) ->
    get_kanojos (kanojos) ->
      rnd = Math.floor(Math.random() * (Object.keys(kanojos).length + 1))
      kanojo = kanojos[Object.keys(kanojos)[rnd]];
      msg.send('http://r25.jp/entertainment/' + kanojo + '/')

  robot.respond /lets_konohi_kanojo (\d{4}\.\d{2}\.\d{2})/i, (msg) ->
    get_kanojos (kanojos) ->
      if (msg.match[1] of kanojos)
        msg.send('http://r25.jp/entertainment/' + kanojos[msg.match[1]] + '/')
      else
        msg.send('その日に彼女はいないよ。')

get_kanojos = (callback) ->
  client.fetch 'https://docs.google.com/spreadsheets/d/1uXHdgQjCaEyN2eIX-GNRZ_qAo298yXk1tGueTkY5qsQ/pub?gid=0&single=true&output=tsv', {}, (error, $, response, body) ->
    kanojos = {}
    for line, i in body.split('\n')
      line = line.trim()
      line_splited = line.split('\t')
      kanojos[line_splited[0].trim()] = line_splited[1].trim()
    callback(kanojos)

