# Description:
#  force nomu.
#
# Notes:
#  when you leave 'lets_today_nomu' ch, you can't do it.
#

request = require 'request'

LEAVE_MESSAGES = [
  "<@{member_id}> は逃げ出した",
  "「こんなところにはもういられない！」そう言い残して <@{member_id}> は去っていった",
  "<@{member_id}> の・・・・霊圧が・・・消えた・・・・・",
  "ハゴー、マーヤガイッタン",
  "やっけー、<@{member_id}> がひんぎた",
  "ちょ、待てよ",
  "ぬかしよる",
]

FORCE_ENTER_MESSAGES = [
  "逃げられると思ったか？",
  "逃がさない",
  "おかえりなさい！みんなで仲良く楽しくやっていきましょう！",
  "し か し ま わ り こ ま れ て し ま っ た 。",
  "ごめんね、ここからは出られないんだ。",
  "くっ! ガッツが足りない",
  "唯一神shibazo が <@{member_id}> はレッツトゥデイ飲むに投げ込む者である",
  "大抵の物事は飲めば解決する。",
  "後悔なんて時間の無駄だ！飲んで忘れろ！",
  "おかえりなさい。おくまんにする？ちばちゃん？それとも、天・下・一？ BLメンバーはスナックおでん未亡人集合。",
  "ヤー、バッペータル。クマンカイ メンソーレ",
  "ヤーハエーサンケ、ワッタート サキヌマンカイサビラ",
  "わったーくびちりどぅーしーやんに？",
  "<@{member_id}> を連れてきたよ",
]

ROOM_ID = "C0DBB44QP"
ROOM_NAME = ["レッツトゥデイ飲む"]
SILENT_LEAVE_ROOM_NAME = ["test_leave"]

module.exports = (robot) ->
  robot.leave (msg) ->
    member_id = msg.message.user.id
    room_name = msg.message.user.room
    if room_name in ROOM_NAME
      # 一応、botのidには動作しないようにしておく
      if (member_id != robot.adapter.self.id)
        msg.send(msg.random(LEAVE_MESSAGES).replace("{member_id}", member_id))
        url = "https://slack.com/api/channels.invite?token=#{process.env.HUBOT_SLACK_FORCE_NOMU_TOKEN}&channel=#{ROOM_ID}&user=#{member_id}"
        request url, (err, res, body) ->
          msg.send(msg.random(FORCE_ENTER_MESSAGES).replace("{member_id}", member_id))
    if room_name in SILENT_LEAVE_ROOM_NAME
      msg.send(JSON.stringify(msg))
      ts = msg.message.item.ts
      ch = msg.message.item.channel
      robot.adapter.client.web.chat.delete(ts, ch, true)

  robot.respond /remove me/, (msg) ->
    msg.send "test"

