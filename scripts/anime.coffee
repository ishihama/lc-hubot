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
      body_re = body_re.replace(/(.*)<h2 id=\"s201703\">/g, '')
      body_re = body_re.replace(/<\/table>(.*)/g,'')
#http\:\/\/[\\w\/:\%\#\$\&\?\(\)\~\.\=\+\-\]\+\/\"

      body_re = body_re.replace(/<\/td><td align=\"center\">|<td align=\"center\">|<\/td><\/tr>|<\/td><td>/g, '|')
      body_re = body_re.replace(/<br \/>|<\/a>/g,'')

      output = "```"
      for line in body_re.split('<tr>')
        # タイトル除去
        line_str = line.replace(/<th>(.*)/g, '')

        # 文字整形
        line_str = line_str.replace(/<(.*)>/g,'')
        #line_str = line.replace(/<a href=\"http:\/\/[a-zA-Z0-9\-_\.\:\@\!\~\*\'(\\)\;\/\?\&=\+$,%#]+\/\" target=\"_blank\">/g, '')

        # 広告除去
        line_str = line_str.replace(/\-\-/g, '')
        line_str = line_str.replace(/amazon(.*)/g, '')

        # 出力用文字列
        output = output + "\n" + line_str

      output = output + "```"
      msg.send output
