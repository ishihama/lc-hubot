# Description:
#  雨雲情報を表示
#
# Commands:
#   hubot rain
#
# Notes:
#

#request = require 'request'

module.exports = (robot) ->
  robot.respond /rain/i, (msg) ->
    url = "http://map.olp.yahooapis.jp/OpenLocalPlatform/V1/static?appid=#{process.env.HUBOT_YAHOO_TENKI_APP_ID}&lat=#{process.env.HUBOT_YAHOO_TENKI_LAT}&lon=#{process.env.HUBOT_YAHOO_TENKI_LON}&z=#{process.env.HUBOT_YAHOO_TENKI_ZOOM}&width=500&height=500&overlay=type:rainfall"
    msg.send(url)
    msg.send("現在の雨雲の様子です")

