# Description:
#  force nomu.
#
# Notes:
#  when you leave 'lets_today_nomu' ch, you can't do it.
#

request = require 'request'

LEAVE_MESSAGES = [
  "<@{member_id}> は逃げ出した",
]

FORCE_ENTER_MESSAGES = [
  "逃げられると思ったか？",
  "逃がさない",
  "おかえりなさい！みんなで仲良く楽しくやっていきましょう！",
  "し か し ま わ り こ ま れ て し ま っ た 。",
  "ごめんね、ここからは出られないんだ。",
]

module.exports = (robot) ->
  robot.leave (msg) ->
    member_id = msg.message.user.id
    room_id = msg.channel.id
    msg.send(room_id)
    if room_id == "C4TUT57K2"
      # 一応、botのidには動作しないようにしておく
      if (member_id != robot.adapter.self.id)
        msg.send(msg.random(LEAVE_MESSAGES).replace("{member_id}", member_id))
        url = "https://slack.com/api/channels.invite?token=#{process.env.HUBOT_SLACK_FORCE_NOMU_TOKEN}&channel=#{room_id}&user=#{member_id}"
        request url, (err, res, body) ->
          msg.send(body)
          msg.send(msg.random(FORCE_ENTER_MESSAGES))

