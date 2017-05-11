# Description:
#   おすすめディナーをランダムで1件表示
#
# Commands:
#   hubot nomu
#   hubot nomu yaesu
#   hubot nomu list
#   hubot nomu yaesu 寿司
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'

AREA_LIST = 'https://docs.google.com/spreadsheets/d/1dPZhmmyqESVHPwdCaU4yzKfqWeivV_fC0wW9MgRQZZo/pub?gid=1681493928&single=true&output=tsv'
AREA_MERGE_LIST = 'https://docs.google.com/spreadsheets/d/1hbSj0_KfZvXTRjs9hFCS08IWCYi1swXmAh_9QLNZNaw/pub?gid=398199746&single=true&output=tsv'
GENLE_LIST = 'https://docs.google.com/spreadsheets/d/1kO3UP31D6jsZ0obE3Lem-Ex7IpA11ovWzO2EVjJdPKM/pub?gid=907489459&single=true&output=tsv'

class Conf
  help_list: ->
    rtn_str = "〜使い方〜"
    rtn_str = rtn_str + "\n" + "後ろに食べたいジャンルを入れたら、エリア近辺の料理を表示するよ"
    rtn_str = rtn_str + "\n" + "shibazo nomu yaesu 寿司"
    rtn_str = rtn_str + "\n" + "shibazo nomu 八重洲 寿司"

    return rtn_str

module.exports = (robot) ->
  # メイン処理
  robot.respond /nomu(.*)/i, (msg) ->
    genle_list = []
    area_merge_list = []
    area_list = []
    client.fetch GENLE_LIST, {}, (error, $, response, body) ->
      rtn_str = ''
      for line, i in body.split('\n')
        line = line.trim()
        line_splited = line.split('\t')
        if line_splited[0].length > 0
          if line_splited.length > 1
            genle_list[line_splited[1].trim()] = line_splited[0].trim()
          else
            genle_list[line_splited[1].trim()] = true
      setTimeout ->
        client.fetch AREA_MERGE_LIST, {}, (error, $, response, body) ->
          rtn_str = ''
          for line, i in body.split('\n')
            line = line.trim()
            line_splited = line.split('\t')
            if line_splited[0].length > 0
              if line_splited.length > 1
                area_merge_list[line_splited[1].trim()] = line_splited[0].trim()
              else
                area_merge_list[line_splited[1].trim()] = true
          setTimeout ->
            client.fetch AREA_LIST, {}, (error, $, response, body) ->
              rtn_str = ''
              for line, i in body.split('\n')
                line = line.trim()
                line_splited = line.split('\t')
                if line_splited[0].length > 0
                  if line_splited.length > 2
                    area_list[line_splited[2].trim()] = line_splited[0].trim() + ',' + line_splited[1].trim()
                  else
                    area_list[line_splited[2].trim()] = true
              setTimeout ->
                arg = msg.match[1].split(' ')
                conf = new Conf()
                if arg[1] == 'list'
                  msg.send conf.help_list()
                else if arg.length == 2 || arg.length == 3
                  # ジャンル指定
                  if arg.length == 3
                    genre = arg[2].trim()
                    genre_cd = ''
                    if (genre of genle_list)
                      genre_cd = genle_list[genre]
                    if genre_cd.length == 0
                      msg.send "ジャンル名が存在しないよ。他の単語で検索してみてね。"
                      genre = ''
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
                    if (area_text_w of area_merge_list)
                      area_text = area_merge_list[area_text_w]
                    if area_text.length == 0
                      area_text = area_text_w

                    # エリアマスタ読み込み
                    if (area_text of area_list)
                      text_w = area_list[area_text].split('\t')[0]
                      area_cd = text_w.split(',')[0]
                      if text_w.split(',')[1] != undefined
                        stan_cd = text_w.split(',')[1]
                      area = area_text

                  if area_cd && area
                    rec_url_w = "https://retty.me/area/#{area_cd}#{stan_cd}#{genre_cd}PUR8/"
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

                            msg.send "#{area}のおすすめ#{genre}はここだよ〜！\n#{rec_url}"
                      , 1000
                else
                  msg.send conf.help_list()
              , 100
          , 100
      , 100
