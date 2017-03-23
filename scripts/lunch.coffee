# Description:
#   おすすめランチをランダムで1件表示
#
# Commands:
#   hubot lunch
#   hubot lunch yaesu
#   hubot lunch list
#   hubot lunch yaesu 寿司
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'
Bluebird = require 'bluebird'

fs = require 'fs'

AREA_LIST = '/Users/uu039499/lc-hubot/scripts/list/area_list.tsv'
AREA_MERGE_LIST = '/Users/uu039499/lc-hubot/scripts/list/area_merge_list.tsv'
GENLE_LIST = '/Users/uu039499/lc-hubot/scripts/list/genle_list.tsv'

class Conf
  help_list: ->
    rtn_str = "〜使い方〜"
    rtn_str = rtn_str + "\n" + "後ろに食べたいジャンルを入れたら、エリア近辺の料理を表示するよ"
    rtn_str = rtn_str + "\n" + "shibazo lunch yaesu 寿司"
    rtn_str = rtn_str + "\n" + "shibazo lunch 八重洲 寿司"

    return rtn_str

  genle_search: (param) ->
    data = fs.readFileSync GENLE_LIST, 'utf8'
    rtn_str = ''
    for line in data.split('\n')
      if line.split('\t')[1] == param
        rtn_str = line.split('\t')[0]

    return rtn_str

module.exports = (robot) ->
  # メイン処理
  robot.respond /lunch(.*)/i, (msg) ->
    arg = msg.match[1].split(' ')
    if arg[1] == 'list'
      conf = new Conf()
      msg.send conf.help_list()
    else if arg.length == 2 || arg.length == 3
      # ジャンル指定
      if arg.length == 3
        conf = new Conf()
        genre = arg[2]
        genre_cd = conf.genle_search genre
        if genre_cd.length == 0
          msg.send "ジャンル名が存在しないよ。他の単語で検索してみてね。"
          genre = ''
          genre_cd = ''
      else
        genre = ''
        genre_cd = ''

      # エリア指定
      area_text_w = arg[1]
      area_text = ''
      area_cd = ''
      area = ''
      stan_cd = ''

      if area_text_w != undefined
        # エリアマージマスタ読み込み
        merge = fs.readFileSync AREA_MERGE_LIST, 'utf8'
        for line in merge.split('\n')
          if line.split('\t')[1] == area_text_w
            area_text = line.split('\t')[0]
            break
        if area_text.length == 0
          area_text = area_text_w

        # エリアマスタ読み込み
        data = fs.readFileSync AREA_LIST, 'utf8'
        for line in data.split('\n')
          if line.split('\t')[2] == area_text
            area_cd = line.split('\t')[0]
            stan_cd = line.split('\t')[1]
            area = area_text
      else
        area_cd = 'PRE13/'
        area = '東京'
        msg.send "東京でオススメを出してみたよ。エリア指定してみてね！\nshibazo lunch [ yaesu | shibuya | tenjin]\nリスト一覧 : shibazo lunch list"

      if area_cd && area
        rec_url_w = "https://retty.me/area/#{area_cd}#{stan_cd}#{genre_cd}"
        #rec_url_w = "https://retty.me/area/#{area_cd}#{stan_cd}#{genre_cd}PUR1/"
      else
        if genre
          genre = "+" + encodeURI(genre)
        area_text = encodeURI(area_text)
        rec_url_w = "https://retty.me/API/OUT/slcRestaurantBySearchConditionForWeb/?p=%2C%2C%2Call%2C%2C%2C%2C%2C%2C#{area_text}#{genre }%2C0%2C11%2C%2C"
        request rec_url_w, (err, res, body) ->
          results = JSON.parse(body).results
          if results.length == 0
            msg.send "残念ながら条件に一致するお店は見つけられませんでした。。"
            return
          result = msg.random results
          rec_url = result.restaurant_url
          msg.send "おすすめはこちら！\n#{rec_url}"
        return

      if rec_url_w.length > 0
        request rec_url_w, (err, res, body) ->
          setTimeout ->
            if err == null
              body_re = /var restaurantIds\=(.*)/.exec(body)
              if body_re == null
                msg.send "残念ながら条件に一致するお店は見つけられませんでした。。"
              else
                body_re = body_re[0].replace(/var restaurantIds=\[/g,'')
                body_re = body_re.replace(/\]\;getEbisuReservationBtnByMultipleValues(.*)/g, '')
                selected_shop = msg.random body_re.split(',')
                rec_url = "https://retty.me/area/#{area_cd}#{selected_shop}/"

                msg.send "#{area}のおすすめ#{genre}ランチはここだよ〜！\n#{rec_url}"
          , 1000
    else
      conf = new Conf()
      msg.send conf.help_list()
