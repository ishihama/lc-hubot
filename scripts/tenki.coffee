# Description:
#  天気情報を表示
#
# Commands:
#   hubot tenki
#
# Notes:
#

request = require 'request'

module.exports = (robot) ->
  robot.respond /tenki/i, (msg) ->
    options =
      url: "http://map.olp.yahooapis.jp/OpenLocalPlatform/V1/static?appid=#{process.env.HUBOT_YAHOO_TENKI_APP_ID}&lat=#{process.env.HUBOT_YAHOO_TENKI_LAT}&lon=#{process.env.HUBOT_YAHOO_TENKI_LON}&z=#{process.env.HUBOT_YAHOO_TENKI_ZOOM}&width=500&height=500&overlay=type:rainfall"
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      text = "現在の雨雲の様子です\n"
      text += body
      msg.send(text)

