# Description:
#   おすすめランチをランダムで1件表示
#
# Commands:
#   hubot lunch
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'
Bluebird = require 'bluebird'

lunch_key = process.env.LUNCH_KEY

module.exports = (robot) ->
  robot.respond /lunch(.*)$/i, (msg) ->
    # エリア指定
    area_text = msg.match[1].split(' ')[1]
    if area_text != undefined
      area_size = area_text.length
      switch (area_text)
        when '八重洲', 'yaesu', 'tokyo'
          area_cd = 'X040'
        when '銀座', 'ginza'
          area_cd = 'Y005'
        when '日本橋', 'nihonbashi', 'nihonbasi'
          area_cd = 'X035'
        when '渋谷', 'shibuya', 'sibuya'
          area_cd = 'XA0T'
        when '原宿', 'harajuku'
          area_cd = 'X100'
        else
          msg.send "登録されてないエリアです"
          return false
    else
      area_cd = 'X040'
      msg.send "エリア指定も出来るよ shibazo lunch [ yaesu | shibuya | harajuku]"

    rec_lunch_w = ""

    new Bluebird (resolve) ->
      resolve area_cd
    .then (area_cd) =>
      randam_su = Math.floor(Math.random() * 30) + 1
      rec_url_w = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=#{lunch_key}&small_area=#{area_cd}&lunch=1&budget=B001&start=1&count=100&format=json"

      if rec_url_w.length > 0
        request rec_url_w, (err, res, body) ->

          article = (JSON.parse(body)['results']['shop'])

          lunch_list = []
          for id of article
            text = (JSON.parse(body)['results']['shop'][id]['id'])
            lunch_list.push("https://www.hotpepper.jp/str#{text}/lunch/")
          rec_url = msg.random lunch_list
          setTimeout ->
            if err == null
              request rec_url, (err2, res2, body2) ->
                if err2 == null
                  setTimeout ->
                    if rec_url.length > 0
                  	   msg.send "今日のオススメランチはここだよ〜！\n#{rec_url}"
                    else
                      msg.send "データが存在しないよ。もう一回コマンド打って〜！"
                  , 1500
                else
                  msg.send "データが存在しないよ。もう一回コマンド打って〜！"
            else
              msg.send "データが存在しないよ。もう一回コマンド打って〜！"
          , 800
