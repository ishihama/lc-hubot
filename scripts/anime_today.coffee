# Description:
#  today_anime list
#
# Commands:
#   hubot today_anime
#   hubot today_anime <yyyymmdd>
#
# Notes:
#

cronJob = require('cron').CronJob
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'

module.exports = (robot) ->
  cronJob = new cronJob(
    cronTime: "0 0 10 * * 1"
    start: true
    timezone: "Asia/Tokyo"
    onTick: ->
      cron_anime_list()
  )
  cron_anime_list = ->
    dt = new Date
    today = dt.getFullYear() + ('0' + (dt.getMonth() + 1)).slice(-2) + ('0' + dt.getDate()).slice(-2)
    url = "http://www.tsundere.com/tokyo/table/#{today}-23"

    get_anime_list url, (animelist) ->
      msg.send "```#{today}のアニメ情報\n#{animelist}\n```"


  robot.respond /today_anime(.*)/i, (msg) ->
    arg = msg.match[1].split(' ')
    intFlg = 0
    if arg.length > 1
      if arg[1].match(/^-?[0-9]+$/)
        intFlg = 1
      if arg[1].length == 8 && intFlg == 1
        today = arg[1]
      else
        msg.send "１週間以内の日付(YYYYMMDD)で入力してね"

    if intFlg == 0
      dt = new Date
      today = dt.getFullYear() + ('0' + (dt.getMonth() + 1)).slice(-2) + ('0' + dt.getDate()).slice(-2)

    url = "http://www.tsundere.com/tokyo/table/#{today}-23"

    get_anime_list url, (animelist) ->
      msg.send "```#{today}のアニメ情報\n#{animelist}\n```"

  get_anime_list = (url, callback) ->
    client.fetch url, {'user-agent': 'node fetcher'}, (error, $ ,response, body) ->
      $ = cheerio.load body
      if body.match(/情報はありません/)
        body_re = "\nまだ作成されてないよ"
      else
        # 今日のアニメ欄整形
        body_re = body.replace(/<img src=\"\.\.\/img\/i4_special\.png\" width=\"175\" height=\"35\" alt=\"放送時間変更／特別番組\"><br>/g, '')
        body_re = body_re.replace(/<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" id=\"anime_table_special\">/g, '')
        body_re = body_re.replace(/<tr class=\"program\"><td class=\"time\">/g, '')
        body_re = body_re.replace(/<span class=\"notice_lite\">★<\/span>/g, '')
        body_re = body_re.replace(/<img src=\"\/img\/i_hl_new\.png\" width=\"12\" height=\"12\" alt=\"新番組\" class=\"expr_icon\">/g, '')
        body_re = body_re.replace(/<\/td><td class=\"station\">/g, '\/')
        body_re = body_re.replace(/<img src=\"\/img\/i_hl_move\.png\" width=\"12\" height=\"12\" alt=\"時間変更\" class=\"expr_icon\">/g, '')
        body_re = body_re.replace(/<img src=\"\/img\/i_hl_sp\.png\" width=\"12\" height=\"12\" alt=\"特番\" class=\"expr_icon\">/g, '')
        body_re = body_re.replace(/<img src=\"\/img\/iepg\.png" width=\"25\" height=\"11\" alt=\"iEPG 録画予約\" class=\"iepg_icon\">/g, '')
        body_re = body_re.replace(/<\/a> <span class=\"notice\">/g, '')
        body_re = body_re.replace(/<\/td><td class=\"title\"><a href=\"\/tokyo\/info\/[0-9]+\">/g, '\/')
        body_re = body_re.replace(/<\/a> <a href=\"\/common\/iepg\.tvpi\?(.*)<\/a><\/td><\/tr>/g, 'br')

        body_re = body_re.replace(/<\/a><\/td><\/tr>/g, '')
        body_re = body_re.replace(/<\/span> <a href=(.*)/g, 'br')
        # 改行削除
        body_re = body_re.replace(/\r?\n/g, '')

        # 不必要な項目を除去
        body_re = body_re.replace(/(.*)<div class=\"container_special\">/g, '')
        body_re = body_re.replace(/<div class=\"container_content\">(.*)/g,'')
        body_re = body_re.replace(/<\/table><\/div><\/div>/g, '')
        body_re = body_re.replace(/<span class=\"warning\">(.*)<\/span>/g, '')
        body_re = body_re.replace(/br/g, '\n')
        body_re = body_re.replace(/リピート[0-9]\/[0-9]/g, 'リピート放送')

        # インデント処理
        body_re = body_re.replace(/\//g, ' \/ ')

      callback(body_re)
