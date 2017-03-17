# Description:
#   おすすめランチをランダムで1件表示
#
# Commands:
#   hubot lunch
#   hubot lunch yaesu
#   hubot lunch list
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'
Bluebird = require 'bluebird'

module.exports = (robot) ->
  robot.respond /lunch list$/i, (msg) ->
    msg.send "八重洲 ->yaesu"
    msg.send "銀座 -> ginza"
    msg.send "有楽町 -> yurakucho"
    msg.send "日本橋 -> nihonbashi"
    msg.send "丸の内 -> marunouchi"
    msg.send "渋谷 -> shibuya"
    msg.send "原宿 -> harajuku"
    msg.send "博多 -> hakata"
    msg.send "天神 -> tenjin"
    msg.send "福岡 -> fukuoka"
    msg.send "沖縄 -> okinawa"

  robot.respond /lunch(.*)/i, (msg) ->

    # エリア指定
    area_text = msg.match[1].split(' ')[1]
    if area_text != undefined
      area_size = area_text.length
      switch (area_text)
        when '八重洲', 'yaesu', 'tokyo'
          area_cd = 'PRE13/ARE15/SUB1501/'
          area = '八重洲'
        when '銀座', 'ginza'
          area_cd = 'PRE13/ARE2/SUB201/'
          area = '銀座'
        when '有楽町', 'yurakucho'
          area_cd = 'PRE13/ARE2/SUB202/'
          area = '有楽町'
        when '日本橋', 'nihonbashi', 'nihonbasi'
          area_cd = 'PRE13/ARE15/SUB1503/'
          area = '日本橋'
        when '丸の内', 'marunouchi'
          area_cd = 'PRE13/ARE15/SUB1504/'
          area = '丸の内'
        when '渋谷', 'shibuya', 'sibuya'
          area_cd = 'PRE13/ARE8/'
          area = '渋谷'
        when '原宿', 'harajuku'
          area_cd = 'PRE13/ARE23/SUB2301/'
          area = '原宿'
        when '博多', 'hakata'
          area_cd = 'PRE40/ARE126/'
          area = '博多'
        when '天神', 'tenjin'
          area_cd = 'PRE40/ARE122/'
          area = '天神'
        when '福岡', 'fukuoka', 'hukuoka'
          area_cd = 'PRE40/ARE126/'
          area = '福岡'
        when '沖縄', 'okinawa'
          area_cd = 'PRE47/ARE144/SUB14402/'
          area = '沖縄'
        when 'list'
          return false
        else
          msg.send "登録されてないエリアです"
          return false
    else
      area_cd = 'PRE13/ARE15/'
      area = '東京駅'
      msg.send "東京駅近辺で出してみたよ。エリア指定してみてね！\nshibazo lunch [ yaesu | shibuya | tenjin]\nリスト一覧 : shibazo lunch list"

    rec_url_w = "https://retty.me/area/#{area_cd}PUR1/"

    if rec_url_w.length > 0
      request rec_url_w, (err, res, body) ->
        setTimeout ->
          if err == null
            body_re = /var restaurantIds\=(.*)/.exec(body)
            body_re = body_re[0].replace(/var restaurantIds=\[/g,'')
            body_re = body_re.replace(/\]\;getEbisuReservationBtnByMultipleValues(.*)/g, '')
            selected_shop = msg.random body_re.split(',')
            rec_url = "https://retty.me/area/#{area_cd}#{selected_shop}/"

            msg.send "#{area}のおすすめランチはここだよ〜！\n#{rec_url}"
        , 1000
