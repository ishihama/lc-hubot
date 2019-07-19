# Description:
#   おすすめランチをランダムで1件表示
#
# Commands:
#   hubot lunch
#   hubot lunch yaesu
#   hubot lunch 八重洲 寿司 1000
#   hubot nomu 八重洲
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'
http = require 'http'

AREA_MERGE_LIST = 'https://docs.google.com/spreadsheets/d/1hbSj0_KfZvXTRjs9hFCS08IWCYi1swXmAh_9QLNZNaw/pub?gid=398199746&single=true&output=tsv'
GENLE_LIST = 'https://docs.google.com/spreadsheets/d/1kO3UP31D6jsZ0obE3Lem-Ex7IpA11ovWzO2EVjJdPKM/pub?gid=907489459&single=true&output=tsv'
STATION_LIST = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSJlV3SYxHdutZdL0WXeEjJvOoIvG75kDWhpiV4fPkQTqoX8EckuauKuxnB15m74499SHaeUwyzRKUP/pub?gid=0&single=true&output=tsv'

class Conf
  help_list: ->
    rtn_str = "〜使い方〜"
    rtn_str = rtn_str + "\n" + "後ろに食べたいジャンルを入れたら、エリア近辺の料理を表示するよ"
    rtn_str = rtn_str + "\n" + "shibazo lunch yaesu 寿司"
    rtn_str = rtn_str + "\n" + "shibazo lunch 八重洲 寿司"
    rtn_str = rtn_str + "\n" + "さらに後ろに予算を入力すると、予算内のお店を検索するよ"
    rtn_str = rtn_str + "\n" + "shibazo lunch 八重洲 寿司 1000"

    return rtn_str

  shop_list: (msg, area_text, genre_name) ->
    rec_list_url = "https://retty.me/API/OUT/slcRestaurantBySearchConditionForWeb/?p=%2C%2C%2Call%2C%2C%2C%2C%2C%2C#{area_text}#{genre_name }%2C0%2C11%2C%2C"
    rec_list_url = encodeURI(rec_list_url)
    request rec_list_url, (err, res, body) ->
      results = JSON.parse(body).results
      if results == undefined
        msg.send "残念ながら条件に一致するお店は見つけられませんでした。"
      else
        result = results[Math.floor(Math.random() * results.length)]
        rec_url = result.restaurant_url
        msg.send "おすすめはこちら！\n#{rec_url}"

module.exports = (robot) ->
  # 飲むコマンド用
  robot.respond /nomu(.*)/i, (msg) ->
    main msg, 2, robot

  # ランチコマンド用
  robot.respond /lunch(.*)/i, (msg) ->
    main msg, 1, robot

  # メイン処理
  main = (msg, type, robot) ->
    genle_list = []
    area_merge_list = []
    station_list = []
    client.fetch AREA_MERGE_LIST, {}, (error, $, response, body) ->
      for line in body.split('\n')
        line = line.trim()
        line_splited = line.split('\t')
        if line_splited[0].length > 0
          if line_splited.length > 1
            area_merge_list[line_splited[1].trim()] = line_splited[0].trim()
          else
            area_merge_list[line_splited[1].trim()] = true
      setTimeout ->
        # 引数チェック
        arg = msg.match[1].split(' ')
        conf = new Conf()
        if arg.length < 2
          msg.send conf.help_list()
        else if arg.length <= 4
          yosan_kbn = 13
          area_text = arg[1].trim()
          if arg.length == 3
            genre_name = arg[2].trim()
          else if arg.length == 4
            genre_name = arg[2].trim()
            yosan = arg[3].trim()
            pattern = /^([1-9]\d*|0)$/
            if pattern.test(yosan) == false
              msg.send "金額指定の箇所に0以下の値、もしくは数値以外のものが選択されているよ"
              msg.send conf.help_list() 
              return
            else
              if yosan <= 1000
                yosan_kbn = 2
              else if yosan <= 2000
                yosan_kbn = 3
              else if yosan <= 3000
                yosan_kbn = 4
              else if yosan <= 4000
                yosan_kbn = 5
              else if yosan <= 5000
                yosan_kbn = 6
              else if yosan <= 6000
                yosan_kbn = 7
              else if yosan <= 8000
                yosan_kbn = 8
              else if yosan <= 10000
                yosan_kbn = 9
              else if yosan <= 15000
                yosan_kbn = 10
              else if yosan <= 20000
                yosan_kbn = 11
              else if yosan <= 30000
                yosan_kbn = 12
              else if yosan > 30000
                yosan_kbn = 13
          else
            genre_name = ''
          station_cond = ''

          if area_text != undefined
            # エリアマージマスタ読み込み
            if (area_text of area_merge_list)
              area_text = area_merge_list[area_text]

            # 駅マスタ読み込み            
            client.fetch STATION_LIST, {}, (error, $, response, body) ->
              if error != null && body != undefined
                for line, i in body.split('\n')
                  line = line.trim()
                  line_splited = line.split('\t')

                  if line_splited[2] == area_text
                    if line_splited[0] == "1"
                      station_cond = "prefecture_code=" + line_splited[1]
                    else
                      station_cond = "station_id=" + line_splited[1]

          # 緯度経度検索
          area_url = "http://www.geocoding.jp/api/?v=1.1&q=#{area_text}"
          area_url = encodeURI(area_url)
          request area_url, (err, res, body) ->
            if err == null
              $ = cheerio.load(body,{ignoreWhitespace: true,xmlMode: true})
              lat = $($('coordinate').children "lat").text()
              lng = $($('coordinate').children "lng").text()
            else
              lag = ''
              lng = ''
            setTimeout ->
              if !lat && !lng
                conf.shop_list(msg, area_text, genre_name)
                return
              else
                # ご飯タイプ :budget_meal_type:1(lunch)/2(dinner) 
                # 予算       :max_budget
                rec_list_url = "https://retty.me/restaurant-search/search-result/?budget_meal_type=#{type}&max_budget=#{yosan_kbn}&free_word_area=#{area_text}&free_word_category=#{genre_name}&latlng=#{lat},#{lng}"
                rec_list_url = encodeURI(rec_list_url)
                if station_cond.length > 0
                  rec_list_url = rec_list_url + "&#{station_cond}"
              
              if rec_list_url.length > 0
                request rec_list_url, (err, res, body) ->
                  setTimeout ->
                    if err == null
                      if body == null
                        msg.send "残念ながら条件に一致するお店は見つけられませんでした。"
                      else
                        $ = cheerio.load body
                        body_json = $("div[is=\"restaurant-list\"]").attr(':restaurants')
                        if body_json != undefined
                          body_json = body_json.replace(/\'/g, '\"')
                          body_json = JSON.parse(body_json)
                          x = Math.floor(Math.random() * body_json.length)
                          rec_url = body_json[x].url
                        
                          msg.send "#{area_text}のおすすめ#{genre_name}はここだよ〜！\n#{rec_url}"
                        else
                          conf.shop_list(msg, area_text, genre_name)
                  , 1000
            , 1000
      ,1000
