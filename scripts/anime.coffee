# Description:
#   今期、または来期アニメの情報を表示
#
# Commands:
#   hubot anime
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'
client  = require 'cheerio-httpcli'

module.exports = (robot) ->
  robot.respond /anime(.*)$/i, (msg) ->
    client.fetch 'http://www.kansou.me', {'user-agent': 'node fetcher'}, (error, $ ,response, body) ->

      month_list = ['01','02','03','04','05','06','07','08','09','10','11','12']

      $ = cheerio.load body
      # 放送局除外
      # 北海道
      body_re = body.replace(/□ (.*)北海道(.*)|□ (.*)札幌(.*)|□ (.*)HTB(.*)/g, '')
      # 東北
      body_re = body_re.replace(/□ (.*)岩手(.*)|□ (.*)福島(.*)|□ (.*)秋田(.*)|□ (.*)仙台(.*)|□ (.*)青森(.*)|□ (.*)岩手(.*)/g, '')
      body_re = body_re.replace(/□ (.*)東北(.*)|□ (.*)北陸(.*)|□ (.*)ミヤギ(.*)|□ さくらんぼテレビ(.*)|□ ATV(.*)/g, '')
      # 関東
      body_re = body_re.replace(/□ (.*)群馬(.*)|□ (.*)千葉(.*)|□ (.*)栃木(.*)|□ (.*)茨城(.*)|□ (.*)神奈川(.*)|□ (.*)埼玉(.*)/g,'')
      body_re = body_re.replace(/□ (.*)とちぎ(.*)|□ (.*)チバ(.*)/g, '')
      # 東海
      body_re = body_re.replace(/□ (.*)愛知(.*)|□ (.*)静岡(.*)|□ (.*)長野(.*)|□ (.*)新潟(.*)/g, '')
      body_re = body_re.replace(/□ (.*)東海(.*)/g, '')
      body_re = body_re.replace(/□ CBC(.*)|□ 中京(.*)/g, '')
      # 近畿
      body_re = body_re.replace(/□ (.*)関西(.*)|□ (.*)京都(.*)|□ (.*)大阪(.*)|□ (.*)和歌山(.*)/g, '')
      body_re = body_re.replace(/□ (.*)兵庫(.*)|□ (.*)三重(.*)|□ (.*)滋賀(.*)|□ (.*)奈良(.*)/g, '')
      body_re = body_re.replace(/□ (.*)読売(.*)|□ サンテレビ(.*)/g, '')
      body_re = body_re.replace(/□ (.*)西日本(.*)|□ (.*)ABC(.*)/g, '')
      # 中国
      body_re = body_re.replace(/□ (.*)広島(.*)|□ (.*)鳥取(.*)|□ (.*)島根(.*)|□ (.*)岡山(.*)|□ (.*)山口(.*)/g, '')
      body_re = body_re.replace(/□ びわ湖放送(.*)|□ (.*)中国(.*)/g, '')
      # 四国
      body_re = body_re.replace(/□ (.*)愛媛(.*)|□ (.*)香川(.*)|□ (.*)徳島(.*)|□ (.*)高知(.*)|□ (.*)四国(.*)/g, '')
      # 九州
      body_re = body_re.replace(/□ (.*)福岡(.*)|□ (.*)佐賀(.*)|□ (.*)熊本(.*)/g, '')
      body_re = body_re.replace(/□ (.*)長崎(.*)|□ (.*)大分(.*)|□ (.*)宮崎(.*)|□ (.*)鹿児島(.*)/g, '')
      body_re = body_re.replace(/□ TVQ(.*)|□ (.*)九州(.*)|□ RKB(.*)|□ サガ(.*)|□ KBC(.*)/g, '')
      # 沖縄
      
      # その他除外
      body_re = body_re.replace(/□ AT-X(.*)|□ WOWOW(.*)|□ BS(.*)|□ (.*)Netflix(.*)/g, '')
      body_re = body_re.replace(/□ J:COM(.*)|□ 時代劇専門チャンネル(.*)/g, '')
      body_re = body_re.replace(/□ NHK BS(.*)/g, '')
      body_re = body_re.replace(/□ <a href=\"https:\/\/anime.iowl.jp\/\" target=\"_blank\">ComicFestaアニメZone(.*)/g, '')
      body_re = body_re.replace(/□ 他(.*)/g, '他')
      body_re = body_re.replace(/□ <a href=\"http:\/\/www.b-ch.com\/\" target=\"_blank\">バンダイ(.*)/g, '')
      body_re = body_re.replace(/□ <a href=\"http:\/\/gundam-tb.net\/\" target=\"_blank\">ネット配信(.*)/g, '')
      body_re = body_re.replace(/他複数/g, '')
      body_re = body_re.replace(/<!--/g, '')
      body_re = body_re.replace(/-->/g, '')
      body_re = body_re.replace(/\s\～|\～/g, '')

      # 改行削除
      body_re = body_re.replace(/\r?\n/g, '')
      dt = new Date
      # 今期の年月取得
      year = dt.getFullYear()
      month = dt.getMonth() + 1
      switch (month)
        when 1
          month = '01'
        when 2, 3, 4
          month = '03'
        when 5, 6, 7
          month = '06'
        when 8, 9, 10
          month = '09'
        when 11, 12
          year = dt.getFullYear() + 1
          month = '01'

      dd_str = "<h2 id=\"s#{year}#{month}\">"
      pattern = ///(.*)#{dd_str}///g
      body_re = body_re.replace(pattern, '')
      body_re = body_re.replace(/<\/table>(.*)/g,'')

      body_re = body_re.replace(/<td align=\"center\">/g, '')
      body_re = body_re.replace(/<\/td><td>|<\/td><td align=\"center\">|<\/td>|<\/td><\/tr>|<\/td><td>/g, '|')
      body_re = body_re.replace(/<br \/>|<\/a>/g,'')

      output = ""
      i = 0
      for line in body_re.split('<tr>')
        # タイトル除去
        line_str = line.replace(/<\/h2>(.*)>/g, '')
        line_str = line_str.replace(/<th (.*)<\/tr>/g, '')

        # 文字整形
        line_str = line_str.replace(/<a href=\"https?:\/\/[a-zA-Z0-9\-_\.\:\@\!\~\*\'(\\)\;\/\?\&=\+$,%#]+\/?\" target=\"_blank\">/g, '')
        line_str = line_str.replace(/<\/tr>/g,'')
        # 日付未定文字除去
        for value,key in month_list
          line_str = line_str.replace(///：#{value}\/\-\-\(\-\)///g, '')
        line_str = line_str.replace(/\-\-\/\-\-\(\-\)/g, '')
        line_str = line_str.replace(/\/\-\-\(\-\)/g, '')

        # 広告除去
        line_str = line_str.replace(/amazon(.*)/g, '')

        # 出力用文字列
        output = output + "\n" + line_str

      msg.send "#{output}\n"
