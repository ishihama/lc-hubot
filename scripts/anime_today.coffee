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

    get_day today, (animelist) ->
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

    get_day today, (animelist) ->
      msg.send "```#{today}のアニメ情報\n#{animelist}\n```"

  get_day = (today, callback) ->
    url_06 = "http://www.tsundere.com/tokyo/table/#{today}-06"
    url_17 = "http://www.tsundere.com/tokyo/table/#{today}-17"
    url_23 = "http://www.tsundere.com/tokyo/table/#{today}-23"

    get_anime_list url_06, (animeList_06) ->
      animeList = ""
      if ! animeList_06.match(/この時間の番組表は表示できません/)
        animeList = animeList_06
      get_anime_list url_17, (animeList_17) ->
        animeList = animeList + animeList_17
        get_anime_list url_23, (animeList_23) ->
          animeList = animeList + animeList_23
          callback(animeList)

  get_anime_list = (url, callback) ->
    original_proxy = process.env.HTTP_PROXY
    process.env.HTTP_PROXY = process.env.HUBOT_JP_HTTP_PROXY
    client.fetch url, {'user-agent': 'node fetcher'}, (error, $ ,response, body) ->
      $ = cheerio.load body

      # 今日のアニメ欄整形
      body_re = body.replace(/<td rowspan=\"[0-9]+\" class=\"program[A-Z]?\">/g, '')
      body_re = body_re.replace(/<td rowspan=\"[0-9]+\" class=\"program[A-Z]?\">/g, '')
      body_re = body_re.replace(/<td rowspan=\"[0-9]+\" class=\"program[A-Z]?_b\">/g, '')
      body_re = body_re.replace(/<div class=\"time[A-Z]?\">/g, '')
      body_re = body_re.replace(/<td rowspan=\"[0-9]+\" class=\"hour\">[0-9]+/g, '')
      body_re = body_re.replace(/<td class=\"b[0-9]+\">(.*)|<td class=\"b[0-9]+b\">(.*)|<td class=\"b[0-9]+b_b\">(.*)|<td class=\"b[0-9]+_b\">(.*)/g, '')
      body_re = body_re.replace(/<td class=\"b[0-9]+bs\">(.*)|<td class=\"b[0-9]+bs_b\">(.*)/g, '')
      body_re = body_re.replace(/<div class=\"notice\">/g, '')
      body_re = body_re.replace(/<a href=\"\/tokyo\/info\/[0-9]+\">/g, '\/')
      # アニメ再放送系削除
      body_re = body_re.replace(/(.*)再放送(.*)/g, '')
      # 有料テレビ放送削除
      body_re = body_re.replace(/(.*)BS(.*)/g, '')
      body_re = body_re.replace(/(.*)ANIMAX(.*)/g, '')
      body_re = body_re.replace(/(.*)AT-X(.*)/g, '')
      body_re = body_re.replace(/(.*)KIDS(.*)/g, '')
      body_re = body_re.replace(/(.*)CTC(.*)/g, '') # チバテレビ
      body_re = body_re.replace(/(.*)GTV(.*)/g, '') # 群馬テレビ
      body_re = body_re.replace(/(.*)GYT(.*)/g, '') # 栃木テレビ
      body_re = body_re.replace(/(.*)SSTV(.*)/g, '') # スペースシャワーTVプラス
      body_re = body_re.replace(/(.*)Disney(.*)/g, '') # Disneyチャンネル
      # 画像系削除
      body_re = body_re.replace(/<img src=\"\/img\/i_hl_sp\.png\" width=\"12\" height=\"12\" alt=\"特番\" class=\"status_icon\">/g, '')
      body_re = body_re.replace(/<img src="\/img\/i_hl_new\.png\" width=\"12\" height=\"12\" alt=\"新番組\" class=\"status_icon\">/g, '')
      body_re = body_re.replace(/<img src=\"\/img\/i_hl_move\.png\" width=\"12\" height=\"12\" alt=\"時間変更\" class=\"status_icon\">/g, '')

      body_re = body_re.replace(/<td class=\"hour\" rowspan=\"2\"><td class=\"station\">/g, '')
      # 行ごと削除
      body_re = body_re.replace(/<td class=\"station\">(.*)/g, '')
      body_re = body_re.replace(/<td class=\"station_[a-z]\">(.*)/g, '')
      body_re = body_re.replace(/<td class=\"time\">(.*)/g, '')
      body_re = body_re.replace(/<td class=\"date\">(.*)/g, '')
      body_re = body_re.replace(/<td class=\"date_[a-z]\">(.*)/g, '')
      body_re = body_re.replace(/<div class=\"fr\"><a href=\"\/common\/iepg\.tvpi(.*)&amp;/g, '')
      body_re = body_re.replace(/station=/g, ' : ')
      body_re = body_re.replace(/\"><img src=\"\/img\/iepg\.png(.*)<\/a>/g, 'br')
      # 改行削除
      body_re = body_re.replace(/\r?\n/g, '')

      # 不必要な項目を除去
      body_re = body_re.replace(/<div class=\"title\">/g, '')
      body_re = body_re.replace(/<\/div>/g, '')
      body_re = body_re.replace(/<span class=\"warning\">/g, '')
      body_re = body_re.replace(/<\/span>/g, '')
      body_re = body_re.replace(/<\/a>/g, '')
      body_re = body_re.replace(/<br>/g, '')
      body_re = body_re.replace(/<td>/g, '')
      body_re = body_re.replace(/<\/td>/g, '')
      body_re = body_re.replace(/<\/tr><tr>/g, '')
      body_re = body_re.replace(/(.*)<div class=\"container_table">/g, '')
      body_re = body_re.replace(/<div class=\"container_footer\">(.*)/g,'')
      body_re = body_re.replace(/br/g, '\n')
      body_re = body_re.replace(/<td class=\"hour\" rowspan=\"2\">(.*)/g, '')
      body_re = body_re.replace(/<table border=\"1\" cellspacing=\"0\" cellpadding=\"0\" id=\"daily_table\">(.*)/g, '')
      body_re = body_re.replace(/リピート[0-9]\/[0-9]/g, 'リピート放送')

      # インデント処理
      body_re = body_re.replace(/\//g, ' \/ ')

      callback(body_re)
    # proxy戻し
    if (original_proxy)
      process.env.HTTP_PROXY = original_proxy
    else
      delete process.env['HTTP_PROXY']
