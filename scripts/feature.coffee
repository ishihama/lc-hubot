# Description:
#  占い
# 
# Commands:
#  hubot feature 
#
# Notes:
#  

cronJob = require('cron').CronJob
cheerio = require 'cheerio-httpcli'
dateformat = require 'dateformat'

feature =
  "おひつじ座": "aries"
  "おうし座": "taurus"
  "ふたご座": "gemini"
  "かに座": "cancer"
  "しし座": "leo"
  "おとめ座": "virgo"
  "てんびん座": "libra"
  "さそり座": "scorpio"
  "いて座": "sagittarius"
  "やぎ座": "capricorn"
  "みずがめ座": "aquarius"
  "うお座": "pisces"

module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 0 10 * * 1"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      cron_game_release_titles()
  )

  robot.respond /feature (.+)$/i, (msg) ->
    keyword = msg.match[1]
    request_url = "http://info.felissimo.co.jp/contents/feature/hoshimoyo/"
    options =
      encoding: "SJIS"
      timeout: 5000
      headers: {'user-agent': 'node fetcher'}

    search_zodiac = ""
    for key, value of feature
      if (key.match(keyword))
        search_zodiac = value
        break

    cheerio.fetch request_url, options, (error, $, response) ->
      $("#sign_block dl dt a").each () ->
        url = $(this).attr("href")
        if (url.match(search_zodiac))
          request_url2 = url
          cheerio.fetch request_url2, options, (error, $, response) ->
            result = $("#page_body p").text()
            msg.send (result)
            return false


#  cron_game_release_titles = ->
#    now = new Date();
#    request_month = dateformat(now, 'yyyymm')
#    fetch_site request_month, (all_release_titles) ->
#      target_dates = (dateformat(add_date(new Date(), i), 'yyyy年m月d日') for i in [0..6])
#
#      output_titles = ("#{title.release_date_full}: #{title.title} (#{title.price})" for title in all_release_titles when title.release_date in target_dates)
#
#      robot.send {room: "game"}, "```\n" + output_titles.join("\n") + "\n```"
