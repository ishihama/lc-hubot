# Description:
#  aipo
#
# Commands:
#   hubot aipo
#   hubot aipo <entityid>
#
# Notes:
#

request = require 'request'
client  = require 'cheerio-httpcli'

permitted_rooms = process.env.HUBOT_PERMITTED_ROOMS?.split(',') || []
# permitted_users = process.env.HUBOT_PERMITTED_USERS?.split(',') || []

permitted = (msg) ->
  msg.room?.trim().toLowerCase() in permitted_rooms

module.exports = (robot) ->
  robot.respond /aipo$/i, (msg) ->
    if !permitted msg
      return
    client.fetch 'https://vps.lightcafe.co.jp/aipo/portal', {}, (error, $, response) ->
      loginInfo = {
        'username': process.env.AIPO_USER_ID,
        'member_username': process.env.AIPO_USER_ID,
        'password': process.env.AIPO_USER_PW
      }
      $('form[name=frm]').submit loginInfo, (error, $, response, body) -> 
        message = ''
        $('#formP-14bcbf50e94-100e1 tr').each () -> 
          a = $('td a', this)
          entityid = $('td a', this).attr('onclick').match(/entityid=(\d+)/i)[1]
          message += "#{$('td.right', this).text()}: #{a.text()}(#{entityid})\n"
        msg.send message.trim()
        client.fetch "https://vps.lightcafe.co.jp/aipo/portal/media-type/html/user/#{process.env.AIPO_USER_ID}/page/default.psml?action=ALJLogoutUser", {}, (error, $, response) ->
          

  robot.respond /aipo (\d+)$/i, (msg) ->
    if !permitted msg
      return
    client.fetch 'https://vps.lightcafe.co.jp/aipo/portal', {}, (error, $, response) ->
      loginInfo = {
        'username': process.env.AIPO_USER_ID,
        'member_username': process.env.AIPO_USER_ID,
        'password': process.env.AIPO_USER_PW
      }
      $('form[name=frm]').submit loginInfo, (error2, $, response, body) -> 
        client.fetch "https://vps.lightcafe.co.jp/aipo/portal/media-type/html/user/#{process.env.AIPO_USER_ID}/page/default.psml/js_peid/P-14bcbf50e94-100e1?template=MsgboardTopicDetailScreen&entityid=#{msg.match[1]}", {}, (error, $, response) ->
          $('caption span').remove()
          captionelm = $('caption')
          contentelm = $("td[style='border-bottom:none;']")
          contentelm.html(contentelm.html().replace(/<br>/g, "\n"))
          caption = captionelm.text().trim()
          content = contentelm.text().trim()
          msg.send "#{caption}\n\n#{content}"
          client.fetch "https://vps.lightcafe.co.jp/aipo/portal/media-type/html/user/#{process.env.AIPO_USER_ID}/page/default.psml?action=ALJLogoutUser", {}, (error, $, response) ->

