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
Q = require('q')
Bluebird = require 'bluebird'

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

    rec_lunch = ""
    rec_lunch_w = ""

    new Bluebird (resolve) ->
      resolve area_cd
    .then (area_cd) =>
      randam_su = Math.floor(Math.random() * 30) + 1
      randam_su2 = Math.floor(Math.random() * 30) + 1
      rec_url_w = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=f83e9b6f731b0871&small_area=#{area_cd}&lunch=1&budget=B001&start=#{randam_su}&count=1&format=json"

      request rec_url_w, (err, res, body) ->
        article = (JSON.parse(body)['results']['shop'])
        for id of article
          text = (JSON.parse(body)['results']['shop'][id]['id'])
          rec_lunch_w = "https://www.hotpepper.jp/str#{text}/lunch/"
        setTimeout ->
          if err == null
            request rec_lunch_w, (err2, res2, body2) ->
              if err2 == null
                setTimeout ->
                  if rec_lunch_w.length > 0
                	   msg.send "今日のオススメランチはここだよ〜！\n#{rec_lunch_w}"
                  else
                    msg.send "データが存在しないよ。もう一回コマンド打って〜！"
                , 1500
              else
                msg.send "データが存在しないよ。もう一回コマンド打って〜！"
          else
            msg.send "データが存在しないよ。もう一回コマンド打って〜！"
        , 800
