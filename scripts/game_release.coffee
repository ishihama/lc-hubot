cronJob = require('cron').CronJob
request = require 'request'
cheerio = require 'cheerio'
dateformat = require 'dateformat'
iconv = require "iconv"
buffer = require "buffer"

module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 * * * * *"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      cron_game_release_titles()
  )

  robot.respond /game (.+)$/i, (msg) ->
    now = new Date()
    request_month = dateformat(now, 'yyyymm')
    request_url = "http://kakaku.com/game/release/Date=" + request_month + "/"
    options =
      url: request_url
      encoding:"binary"
      timeout: 5000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      request_title = msg.match[1]
      conv = new iconv.Iconv('SJIS', 'UTF-8//TRANSLIT//IGNORE')
      body = new Buffer(body, 'binary')
      body = conv.convert(body).toString()
      $ = cheerio.load body
      release_day = ""
      flag = 0
      $("#titleSche tr").each () ->
        if ($('.weekly', this).length)
          release_day = $('.weekly', this).text()

        title = $('.gameTitle a', this).text()
        if (title.match(request_title))
          flag = 1
          msg.send(title + "  の発売日は " + release_day)

      if (!flag)
        msg.send("また発売はだいぶ先みたいっす")

      msg.send("とりあえず3月の分しか対応してませんヽ(=´▽`=)ﾉ")
      robot.send("とりあえず3月の分しか対応してませんヽ(=´▽`=)ﾉ")

  cron_game_release_titles = ->
    now = new Date();
    request_month = dateformat(now, 'yyyymm')
    request_url = "http://kakaku.com/game/release/Date=" + request_month + "/"
    options =
      url: request_url
      encoding:"binary"
      timeout: 5000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      conv = new iconv.Iconv('SJIS', 'UTF-8//TRANSLIT//IGNORE')
      body = new Buffer(body, 'binary')
      body = conv.convert(body).toString()
      $ = cheerio.load body
      all_release_titles = []
      target_date = ""
      $("#titleSche tr").each () ->
        if ($('.weekly, .sat, .sun', this).length)
          target_date = $('.weekly, .sat, .sun', this).text()

        if ($('.gameTitle a', this).length)
          all_release_titles.push(target_date + ":" + $('.gameTitle a', this).text())

      search_dates = []
      for i in [0..6]
        search_dates.push(dateformat(now, 'yyyy年m月d日'))
        now.setDate(now.getDate() + 1)

      output_titles = []
      for i, search_date of search_dates
        for i, release_title of all_release_titles
          if (release_title.match(search_date))
            output_titles.push(release_title)

      robot.send ("```\n" + output_titles.join("\n") + "\n```")

