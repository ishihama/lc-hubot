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

R25_KANOJO      = 'https://docs.google.com/spreadsheets/d/1uXHdgQjCaEyN2eIX-GNRZ_qAo298yXk1tGueTkY5qsQ/pub?gid=0&single=true&output=tsv'
DENDOU_KANOJO   = 'https://docs.google.com/spreadsheets/d/1uXHdgQjCaEyN2eIX-GNRZ_qAo298yXk1tGueTkY5qsQ/pub?gid=1858677384&single=true&output=tsv'
ENGINEER_KANOJO = 'https://docs.google.com/spreadsheets/d/1uXHdgQjCaEyN2eIX-GNRZ_qAo298yXk1tGueTkY5qsQ/pub?gid=974414959&single=true&output=tsv'
NET_KANOJO      = 'https://docs.google.com/spreadsheets/d/1uXHdgQjCaEyN2eIX-GNRZ_qAo298yXk1tGueTkY5qsQ/pub?gid=1678189143&single=true&output=tsv'
DENDOU_SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbxFpry4gw0x05uglzrlcUIzl1dNnPLS8aYrC66EoO-VthisG4w/exec'

module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 0 10 * * *"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      cron_today_kanojo()
  )
  cron_today_kanojo = ->
    get_kanojos R25_KANOJO, (kanojos) ->
      now = new Date()
      ymd = now.getFullYear() + "." + ('0' + (now.getMonth() + 1)).slice(-2) + "." + ('0' + now.getDate()).slice(-2)
      if (ymd of kanojos)
        robot.send {room: "lets_today_kanojo"}, '今日の彼女です。\r\n' + 'http://r25.jp/entertainment/' + kanojos[ymd] + '/'

  robot.respond /lets_today_kanojo$/i, (msg) ->
    get_kanojos R25_KANOJO, (kanojos) ->
      now = new Date()
      ymd = now.getFullYear() + "." + ('0' + (now.getMonth() + 1)).slice(-2) + "." + ('0' + now.getDate()).slice(-2)
      if (ymd of kanojos)
        msg.send('http://r25.jp/entertainment/' + kanojos[ymd] + '/')
      else
        msg.send("今日はまだ彼女いないよ。")

  robot.respond /lets_random_kanojo/i, (msg) ->
    get_kanojos R25_KANOJO, (kanojos) ->
      rnd = Math.floor(Math.random() * (Object.keys(kanojos).length))
      kanojo = kanojos[Object.keys(kanojos)[rnd]];
      msg.send('http://r25.jp/entertainment/' + kanojo + '/')

  robot.respond /lets_konohi_kanojo (\d{4}\.\d{2}\.\d{2})/i, (msg) ->
    get_kanojos R25_KANOJO, (kanojos) ->
      if (msg.match[1] of kanojos)
        msg.send('http://r25.jp/entertainment/' + kanojos[msg.match[1]] + '/')
      else
        msg.send('その日に彼女はいないよ。')

  robot.respond /lets_dendou_kanojo add (.*)/i, (msg) ->
    url = msg.match[1]
    client.fetch DENDOU_SCRIPT_URL + '?add=' + url, {}, (error, $, response, body) ->
      obj = JSON.parse body
      msg.send(obj.msg)

  robot.respond /lets_dendou_kanojo del (.*)/i, (msg) ->
    url = msg.match[1]
    client.fetch DENDOU_SCRIPT_URL + '?del=' + url, {}, (error, $, response, body) ->
      obj = JSON.parse body
      msg.send(obj.msg)

  robot.respond /lets_dendou_kanojo$/i, (msg) ->
    get_kanojos DENDOU_KANOJO, (kanojos) ->
      rnd = Math.floor(Math.random() * (Object.keys(kanojos).length))
      kanojo = Object.keys(kanojos)[rnd];
      msg.send(kanojo)

  robot.respond /lets_it_kanojo/i, (msg) ->
    get_kanojos ENGINEER_KANOJO, (kanojos) ->
      rnd = Math.floor(Math.random() * (Object.keys(kanojos).length))
      kanojo = Object.keys(kanojos)[rnd];
      msg.send(kanojo)

# get kanojos from tsv on network.
get_kanojos = (url, callback) ->
  client.fetch url, {}, (error, $, response, body) ->
    kanojos = {}
    for line, i in body.split('\n')
      line = line.trim()
      line_splited = line.split('\t')
      if line_splited[0].length > 0
        if line_splited.length > 1
          kanojos[line_splited[0].trim()] = line_splited[1].trim()
        else
          kanojos[line_splited[0].trim()] = true
    callback(kanojos)


