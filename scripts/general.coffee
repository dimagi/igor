module.exports = (robot) ->

  robot.hear /.*thank.*igor/i, (res) ->
    res.send "No problem #{res.message.user.real_name || res.message.user.name}. You're pretty clever yourself."


  robot.respond /whosthebestteam/i, (res) ->
    res.send "Why it's the Field team of course!!"
