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
      body_re = body.replace(/□ サンテレビ(.*)|□ KBS京都(.*)|□ テレビ愛知(.*)/g, '')
      body_re = body_re.replace(/□ 群馬テレビ(.*)|□ とちぎテレビ(.*)/g, '')
      body_re = body_re.replace(/□ 東海テレビ(.*)/g, '')
      body_re = body_re.replace(/□ サンテレビ(.*)/g, '')
      body_re = body_re.replace(/□ 関西テレビ(.*)|□ BS(.*)|□ (.*)Netflix(.*)/g, '')
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
      year = dt.getFullYear()
      month = dt.getMonth() + 1
      switch (month)
        when 1
          year = dt.getFullYear() - 1
          month = '11'
        when 2, 3, 4
          month = '03'
        when 5, 6, 7
          month = '06'
        when 8, 9, 10
          month = '09'
        when 11, 12
          month = '11'

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
