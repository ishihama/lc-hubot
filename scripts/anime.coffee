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

      $ = cheerio.load body
      # 改行削除
      body_re = body.replace(/\r?\n/g, '')
      ##TODO:月によって参照する期を変える
      dt = new Date
      year = dt.getFullYear()
      month = dt.getMonth() + 1
      if month < 10
        month = '0' + month
      switch (month)
        when '01'
          year = dt.getFullYear() - 1
          month = '11'
        when '02'
          month = '03'
        when '03'
          month = '03'
        when '04'
          month = '03'
        when '05'
          month = '07'
        when '06'
          month = '07'
        when '07'
          month = '07'
        when '08'
          month = '09'
        when '09'
          month = '09'
        when '10'
          month = '09'
        when '11'
          month = '11'
        when '12'
          month = '11'
        else
          msg.send '不正な値が取得されたよ'

      dd_str = "/(.*)s#{year}#{month}/g"
      #console.log body_re.replace(/\(.*)s\"#{year}#{month}\"/g, '')
      #body_re = body_re.replace(/(.*)'放送開始予定作品'/g, '')
      # body_re = body_re.replace(dd_str, '')
      body_re = body_re.replace(/(.*)<h2 id=\"s201703\">/g, '')
      body_re = body_re.replace(/<\/table>(.*)/g,'')

      body_re = body_re.replace(/<td align=\"center\">/g, '')
      body_re = body_re.replace(/<\/td><td>|<\/td><td align=\"center\">|<\/td>|<\/td><\/tr>|<\/td><td>/g, '|')
      body_re = body_re.replace(/<br \/>|<\/a>/g,'')

      output = ""
      i = 0
      for line in body_re.split('<tr>')
        if ++i > 30
          break

        # タイトル除去
        line_str = line.replace(/<\/h2>(.*)>/g, '')
        line_str = line_str.replace(/<th (.*)<\/tr>/g, '')

        # 文字整形
        #line_str = line_str.replace(/<(.*)>/g,'')
        line_str = line_str.replace(/<a href=\"https?:\/\/[a-zA-Z0-9\-_\.\:\@\!\~\*\'(\\)\;\/\?\&=\+$,%#]+\/?\" target=\"_blank\">/g, '')

        # 放送局絞り込み
        line_str = line_str.replace(/□(.*)/, '-|')

        # 広告除去
        line_str = line_str.replace(/\-\-/g, '')
        line_str = line_str.replace(/amazon(.*)/g, '')

        # 出力用文字列
        output = output + "\n" + line_str

      msg.send "```#{output}\n```"
