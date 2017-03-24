# Description:
#  占い
# 
# Commands:
#  hubotname fortune 星座
#
# Notes:
#  

cronJob = require('cron').CronJob
cheerio = require 'cheerio-httpcli'
dateformat = require 'dateformat'

fortune =
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
#  cronJob = new cronJob(
#    cronTime: "0 0 10 * * 1"
#    start: true
#    timezone: "Asia/Tokyo"
#    onTick: ->
#      cron_game_release_titles()
#  )

  robot.respond /fortune (.+)$/i, (msg) ->
    keyword = msg.match[1]
    request_url = "http://info.felissimo.co.jp/contents/feature/hoshimoyo/"
    options =
      encoding: "SJIS"
      timeout: 5000
      headers: {'user-agent': 'node fetcher'}

    search_zodiac = ""
    for key, value of fortune
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

