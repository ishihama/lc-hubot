# Description:
#  chousei
#
# Commands:
#   hubot chousei <weekday/weekend> title=タイトル range=範囲(n日後まで) kouho=候補日(weekday,weekendを指定しない場合のみ。カンマ区切り)
# 
# Notes:
#   hubot chousei weekend title=タイトル range=30
#   hubot chousei weekday title=タイトル range=30
#   hubot chousei title=タイトル kouho=7/9(土),7/10(日),7/16(土),7/17(日),7/18(月祝)
#

request = require 'request'
client  = require 'cheerio-httpcli'

CHOUSEI_BASE_URL = 'https://chouseisan.com/'
CHOUSEI_PERM_BASE_URL = CHOUSEI_BASE_URL + 's?h='
jw = ["(日)", "(月)", "(火)", "(水)", "(木)", "(金)", "(土)"]

get_args = (arg_str) -> 
  args = {}
  for s in arg_str.split(' ')
    args[s.split('=')[0]] = s.split('=')[1]
  return args

get_kouho_days = (range, days_of_week) -> 
  now = new Date()
  return [0..range]
      .map(
        (n) ->
          new Date(now.getFullYear(), now.getMonth(), now.getDate()+n)
      ).filter(
        (d) ->
          d.getDay() in days_of_week
      ).map(
        (d) ->
          "#{d.getMonth()+1}/#{d.getDate()}#{jw[d.getDay()]}"
      )

post_to_chousei_create = (msg, title, kouho) ->
  client.fetch CHOUSEI_BASE_URL, {}, (error, $, response) ->
    create_info = {
      'name': title,
      'kouho': kouho.join("\n"),
    }
    $('form#newEventForm').submit create_info, (error, $, response, body) ->
      if error and "#{error}"[..."Error: Invalid URI".length] is "Error: Invalid URI"
        url = CHOUSEI_PERM_BASE_URL + error["url"].split('\?h=')[1]
      else
        url = $('#listUrl').val()
      msg.send url

module.exports = (robot) ->
  robot.respond /chousei (.*)$/i, (msg) ->
    args = get_args(msg.match[1])

    arg_error = false
    if !("title" of args)
      msg.send "titleは必須です"
      arg_error = true
    if !("weekday" of args or "weekend" of args or "kouho" of args) or ("weekday" of args and "weekend" of args)
      msg.send "weekday, weekendまたはkouhoパラメータを指定してください"
      arg_error = true

    if arg_error
      return

    if !("weekday" of args or "weekend" of args)
      kouho = args["kouho"].split(",")
    else
      days_of_week = if "weekday" of args then [1,2,3,4,5] else [0,6]
      kouho = get_kouho_days(args["range"], days_of_week)

    post_to_chousei_create(msg, args["title"], kouho)

