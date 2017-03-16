# Description:
#  ゲームのリリース情報を表示
# 
# Commands:
#  hubot game {query}
#
# Notes:
#  

cronJob = require('cron').CronJob
cheerio = require 'cheerio-httpcli'
dateformat = require 'dateformat'


add_date = (date, num) ->
  date.setDate(date.getDate() + num)
  return date


fetch_site = (request_month, callback) ->
  request_url = "http://kakaku.com/game/release/Date=" + request_month + "/"
  options =
    encoding: "SJIS"
    timeout: 5000
    headers: {'user-agent': 'node fetcher'}
  cheerio.fetch request_url, options, (error, $, response) ->
    all_release_titles = []
    current_date = undefined
    $("#titleSche tr").each () ->
      if ($(".weekly, .sat, .sun", this).length)
        current_date = $(".weekly, .sat, .sun", this).text()
      if ($(".gameTitle a", this).length)
        all_release_titles.push({
          release_date: current_date.replace(/（.*）/, ''),
          release_date_full: current_date,
          title: $(".gameTitle a", this).text(),
          price: $(".gamePrice", this).text()
        })
    callback(all_release_titles)


module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 0 10 * * 1"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      cron_game_release_titles()
  )

  robot.respond /game (.+)$/i, (msg) ->
    now = new Date()
    request_month = dateformat(now, 'yyyymm')
    request_title = msg.match[1]

    fetch_site request_month, (all_release_titles) ->
      matched = (t for t in all_release_titles when t.title.match(request_title))
      if !matched
        msg.send("また発売はだいぶ先みたいっす")
      for title in matched
        msg.send("#{title.title} の発売日は #{title.release_date_full}")


  cron_game_release_titles = ->
    now = new Date();
    request_month = dateformat(now, 'yyyymm')
    fetch_site request_month, (all_release_titles) ->
      target_dates = (dateformat(add_date(new Date(), i), 'yyyy年m月d日') for i in [0..6])

      output_titles = ("#{title.release_date_full}: #{title.title} (#{title.price})" for title in all_release_titles when title.release_date in target_dates)

      robot.send {room: "game"}, "```\n" + output_titles.join("\n") + "\n```"
