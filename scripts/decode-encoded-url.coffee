# Description:
#   encodeされたURLを日本語に戻す
#
# Commands:
#   hubot decode ENCODED_URL
#
# Author:
#

module.exports = (robot) ->

  robot.respond /decode (.+)$/i, (msg) ->
    url = msg.match[1]
    return if url is decodeURI url
    url = decodeURI(url).replace /[ <>]/g,  (c) -> encodeURI c
    msg.send "日本語でおｋ\n#{url}"

    return
