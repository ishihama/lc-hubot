# Description:
#  force nomu.
#
# Notes:
#  when you leave 'lets_today_nomu' ch, you can't do it.
#

request = require 'request'
Slack = require 'slack-node'

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

RUN_AWAY_BRAIN_KEY = 'force_today_nomu_run_away'

module.exports = (robot) ->
  robot.leave (msg) ->
    member_id = msg.message.user.id
    room_name = msg.message.user.room
    if room_name in ROOM_NAME
      # 一応、botのidには動作しないようにしておく
      if (member_id != robot.adapter.self.id)
        members = robot.brain.get(RUN_AWAY_BRAIN_KEY) ? []
        new_members = []
        if member_id in members
          for m in members
            if member_id != m
              new_members.append(m)
          robot.brain.set(RUN_AWAY_BRAIN_KEY, new_members)
          return
        msg.send(msg.random(LEAVE_MESSAGES).replace("{member_id}", member_id))
        url = "https://slack.com/api/channels.invite?token=#{process.env.HUBOT_SLACK_FORCE_NOMU_TOKEN}&channel=#{ROOM_ID}&user=#{member_id}"
        request url, (err, res, body) ->
          msg.send(msg.random(FORCE_ENTER_MESSAGES).replace("{member_id}", member_id))
    if room_name in SILENT_LEAVE_ROOM_NAME
      slack = new Slack process.env.HUBOT_SLACK_TOKEN
      slack.api "channels.list", {}, (err, res) ->
        if res.ok
          msg.send JSON.stringify(res.channels)
          for channel in res.channels
            if channel.name == room_name
              slack.api "channels.history", {"channel": channel.id}, (err, res) ->
                if res.ok
                  msg.send JSON.stringify(res.histories)
                  for his_msg in res.histories
                    if his_msg.subtype == 'channel_leave' && his_msg.user == member_id
                      slack.api "chat.delete", {"channel": channel.id, "ts": his_msg.ts}, (err, res) ->
                        console.log(JSON.stringify(res))
                else
                  console.log(JSON.stringify(res))
        else
          console.log(JSON.stringify(res))

  robot.respond /remove me/i, (msg) ->
    member_id = msg.message.user.id
    room_name = msg.message.user.room
    if room_name not in ROOM_NAME
      return
    members = robot.brain.get(RUN_AWAY_BRAIN_KEY) ? []
    if member_id not in members
      members.push member_id
    robot.brain.set(RUN_AWAY_BRAIN_KEY, members)
    slack = new Slack process.env.HUBOT_SLACK_FORCE_NOMU_TOKEN
    slack.api "channels.kick", {"channel", ROOM_ID, "user": member_id}, (err, res) ->
      if res.ok
        return
  
