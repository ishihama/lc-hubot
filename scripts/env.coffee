# Description:
#   check env.
#
# Commands:
#   hubot env {key}
#


module.exports = (robot) ->
  robot.respond /env(.*)$/i, (msg) ->
    env_keys = msg.match[1].toUpperCase().trim().split(" ")
    if msg.envelope.room?.trim().toLowerCase() != 'hubot'
      return
    for key in env_keys
      if key of process.env
        msg.send "process.env.#{key}=#{process.env[key]}"
      else
        msg.send "no key [#{key}] in env"
    
