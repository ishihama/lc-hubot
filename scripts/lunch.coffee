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

class Conf

  help_list: ->
    rtn_str = "実装されてるエリアだよ〜"
    rtn_str = rtn_str + "\n" + "八重洲 -> shibazo lunch yaesu"
    rtn_str = rtn_str + "\n" + "銀座 -> shibazo lunch ginza"
    rtn_str = rtn_str + "\n" + "有楽町 -> shibazo lunch yurakucho"
    rtn_str = rtn_str + "\n" + "日本橋 -> shibazo lunch nihonbashi"
    rtn_str = rtn_str + "\n" + "丸の内 -> shibazo lunch marunouchi"
    rtn_str = rtn_str + "\n" + "渋谷 -> shibazo lunch shibuya"
    rtn_str = rtn_str + "\n" + "原宿 -> shibazo lunch harajuku"
    rtn_str = rtn_str + "\n" + "博多 -> shibazo lunch hakata"
    rtn_str = rtn_str + "\n" + "天神 -> shibazo lunch tenjin"
    rtn_str = rtn_str + "\n" + "福岡 -> shibazo lunch fukuoka"
    rtn_str = rtn_str + "\n" + "沖縄 -> shibazo lunch okinawa"
    rtn_str = rtn_str + "\n" + "沖縄空港 -> shibazo lunch okinawaKuko"
    rtn_str = rtn_str + "\n" + "おもろまち -> shibazo lunch omoromachi"
    rtn_str = rtn_str + "\n" + ""
    rtn_str = rtn_str + "\n" + "後ろに食べたいジャンルを入れたら、エリア近辺の料理を表示するよ"
    rtn_str = rtn_str + "\n" + "shibazo lunch yaesu 寿司"

    return rtn_str

  genle_search: (param) ->
    switch (param)
      when 'パスタ'
        rtn = 'LCAT6/CAT200/'
      when 'ピザ'
        rtn = 'LCAT6/CAT210/'
      when '魚料理', '魚'
        rtn = 'LCAT2/'
      when '寿司'
        rtn = 'LCAT2/CAT30/'
      when '海鮮', '海鮮料理', '魚介', '魚介料理'
        rtn = 'LCAT2/CAT40/'
      when '回転ずし', '回転寿司'
        rtn = 'LCAT2/CAT41/'
      when '海鮮丼'
        rtn = 'LCAT2/CAT42/'
      when 'うなぎ'
        rtn = 'LCAT2/CAT70/'
      when '和食'
        rtn = 'LCAT4/'
      when 'とんかつ'
        rtn = 'LCAT4/CAT90/'
      when '唐揚げ', 'からあげ'
        rtn = 'LCAT4/CAT93/'
      when 'おでん'
        rtn = 'LCAT4/CAT15/'
      when '親子丼'
        rtn = 'LCAT4/CAT11/'
      when '牛丼', '牛どん'
        rtn = 'LCAT4/CAT12/'
      when '天丼', '天どん'
        rtn = 'LCAT4/CAT13/'
      when '天ぷら', 'てんぷら'
        rtn = 'LCAT4/CAT110/'
      when '麺', '麺類'
        rtn = 'LCAT5/'
      when '担々麺'
        rtn = 'LCAT5/CAT111/'
      when 'そば', '蕎麦'
        rtn = 'LCAT5/CAT50/'
      when 'うどん'
        rtn = 'LCAT5/CAT60/'
      when '讃岐うどん'
        rtn = 'LCAT5/CAT113/'
      when 'カレーうどん'
        rtn = 'LCAT5/CAT114/'
      when '刀削麺'
        rtn = 'LCAT5/CAT112/'
      when 'ちゃんぽん'
        rtn = 'LCAT5/CAT115/'
      when '冷麺'
        rtn = 'LCAT5/CAT116/'
      when '油そば'
        rtn = 'LCAT5/CAT117/'
      when 'B級麺料理', 'B級麺'
        rtn = 'LCAT5/CAT118/'
      when '焼きそば', 'やきそば'
        rtn = 'LCAT5/CAT119/'
      when 'ラーメン'
        rtn = 'LCAT5/CAT290/'
      when 'つけ麺', 'つけめん'
        rtn = 'LCAT5/CAT295/'
      when 'お好み焼き', '粉', '粉もの'
        rtn = 'LCAT13/'
      when 'たこ焼き', 'たこやき'
        rtn = 'LCAT13/CAT91/'
      when '明石焼', '明石焼き'
        rtn = 'LCAT13/CAT92/'
      when 'もんじゃ焼き', 'もんじゃ'
        rtn = 'LCAT13/CAT130/'
      when '日本料理', '郷土料理'
        rtn = 'LCAT17/'
      when '沖縄', '沖縄料理'
        rtn = 'LCAT17/CAT150/'
      when 'アメリカ', 'usa', 'america'
        rtn = 'LCAT22/'
      when 'アフリカ', 'アフリカ料理'
        rtn = 'LCAT23/'
      when 'アジア', 'エスニック'
        rtn = 'LCAT7/'
      when 'インドネシア', 'インドネシア料理'
        rtn = 'LCAT7/CAT151/'
      when 'ベトナム', 'ベトナム料理'
        rtn = 'LCAT7/CAT152/'
      when 'インド', 'インド料理'
        rtn = 'LCAT7/CAT153/'
      when 'ネパール', 'ネパール料理'
        rtn = 'LCAT7/CAT154/'
      when 'トルコ', 'トルコ料理'
        rtn = 'LCAT7/CAT155/'
      when 'メキシコ', 'メキシコ料理'
        rtn = 'LCAT7/CAT156/'
      when 'シュラスコ', 'シュラスコ料理'
        rtn = 'LCAT7/CAT157/'
      when 'シンガポール', 'シンガポール料理'
        rtn = 'LCAT7/CAT158/'
      when 'マレーシア', 'マレーシア料理'
        rtn = 'LCAT7/CAT159/'
      when '韓国', 'korea', '韓国料理'
        rtn = 'LCAT7/CAT270/'
      when 'タイ', 'タイ料理'
        rtn = 'LCAT7/CAT280/'
      when 'インドカレー'
        rtn = 'LCAT7/CAT301/'
      when '中華', '中華料理'
        rtn = 'LCAT14/'
      when '広東', '広東料理'
        rtn = 'LCAT14/CAT122/'
      when '上海', '上海料理', '上海蟹'
        rtn = 'LCAT14/CAT124/'
      when '四川', '四川料理'
        rtn = 'LCAT14/CAT121/'
      when '北京', '北京料理'
        rtn = 'LCAT14/CAT123/'
      when '台湾', '台湾料理'
        rtn = 'LCAT14/CAT125/'
      when '飲茶', '点心'
        rtn = 'LCAT14/CAT128/'
      when 'チャーハン', '炒飯'
        rtn = 'LCAT14/CAT126/'
      when '餃子'
        rtn = 'LCAT14/CAT260/'
      when 'イタリアン', 'イタリア', 'イタリア料理'
        rtn = 'LCAT6/'
      when '洋食', '西洋', '洋食料理', '西洋料理'
        rtn = 'LCAT15/'
      when 'スープカレー'
        rtn = 'LCAT15/CAT141/'
      when 'オムライス'
        rtn = 'LCAT15/CAT143/'
      when 'ドイツ', 'ドイツ料理'
        rtn = 'LCAT15/CAT147/'
      when 'スペイン', 'スペイン料理'
        rtn = 'LCAT15/CAT190/'
      when 'ハンバーグ'
        rtn = 'LCAT15/CAT230/'
      when 'ハンバーガー'
        rtn = 'LCAT15/CAT240/'
      when 'カレー'
        rtn = 'LCAT15/CAT300/'
      when 'フレンチ', 'フレンチ料理', 'フランス'
        rtn = 'LCAT19/'
      when '肉', '肉料理'
        rtn = 'LCAT3/'
      when '牛タン'
        rtn = 'LCAT3/CAT33/'
      when 'ステーキ'
        rtn = 'LCAT3/CAT220/'
      when '焼肉'
        rtn = 'LCAT3/CAT310/'
      when '鍋'
        rtn = 'LCAT11/'
      when 'しゃぶしゃぶ'
        rtn = 'LCAT18/CAT81/'
      when 'すきやき', 'すき焼き'
        rtn = 'LCAT18/CAT40/'
      when '串', '串料理'
        rtn = 'LCAT12/'
      when 'やきとり', '焼き鳥', '焼鳥'
        rtn = 'LCAT12/CAT80/'
      when '炉端焼き', '炉ばた焼き'
        rtn = 'LCAT12/CAT61/'
      when '串カツ'
        rtn = 'LCAT12/CAT62/'
      when '串揚げ'
        rtn = 'LCAT12/CAT100/'
      when '串焼き', '串焼'
        rtn = 'LCAT25/CAT500/'
      when 'もつ'
        rtn = 'LCAT25/CAT495/'
      when 'ベジタリアン', 'ベジタブル', '野菜料理'
        rtn = 'LCAT99/CAT907/'
      else
        rtn = ''

    return rtn

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
          genre = ''
          msg.send "ジャンル名が存在しないよ。他の単語で検索してみてね。"
      else
        genre = ''
        genre_cd = ''

      # エリア指定
      area_text = arg[1]
      if area_text != undefined
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
            area = '沖縄(国際通り)'
          when '沖縄空港', 'okinawaKuko'
            area_cd = 'PRE47/ARE144/SUB14404/'
            area = '沖縄空港近辺'
          when 'おもろまち', 'omoromachi'
            area_cd = 'PRE47/ARE144/SUB14403/'
            area = 'おもろまち近辺'
          else
            msg.send "登録されてないエリアです"
            return false
      else
        area_cd = 'PRE13/ARE15/'
        area = '東京駅'
        msg.send "東京駅近辺で出してみたよ。エリア指定してみてね！\nshibazo lunch [ yaesu | shibuya | tenjin]\nリスト一覧 : shibazo lunch list"

      rec_url_w = "https://retty.me/area/#{area_cd}#{genre_cd}PUR1/"

      if rec_url_w.length > 0
        request rec_url_w, (err, res, body) ->
          setTimeout ->
            if err == null
              body_re = /var restaurantIds\=(.*)/.exec(body)
              body_re = body_re[0].replace(/var restaurantIds=\[/g,'')
              body_re = body_re.replace(/\]\;getEbisuReservationBtnByMultipleValues(.*)/g, '')
              selected_shop = msg.random body_re.split(',')
              rec_url = "https://retty.me/area/#{area_cd}#{selected_shop}/"

              msg.send "#{area}のおすすめ#{genre}ランチはここだよ〜！\n#{rec_url}"
          , 1000
    else
      conf = new Conf()
      msg.send conf.help_list()
