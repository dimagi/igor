config = require('config')
exec = require('child_process').exec
moment = require('moment');
_ = require('lodash')

module.exports = (robot) ->

  robot.respond /(.*) exists on (.*)/i, (res) ->
    sha = res.match[1]
    env = res.match[2]
    refreshedRepo = false

    # First searches if the commit exists on the repo, then if it cannot find it,
    # it will pull the repo and see if it exists on the updated repo

    foundCallback = (err, tag) ->
      if err and err.toString().indexOf('no such commit') == -1
        # Unexpected error
        res.send err
      else if err
        # Could not find it
        res.send "Sorry hun, I couldn't find #{sha} on #{env} for ya"
      else
        # Success
        date = extractDateFromTag tag

        res.send "#{sha} certainly exists on #{env}"
        res.send "In fact it was deployed #{moment(date).fromNow()} on #{moment(date).format("dddd, MMMM Do YYYY, h:mm:ss a")}"

    callback = (err, tag) ->
      if err and not refreshedRepo
        res.send "Pulling latest code..."
        refreshRepo(->
          refreshedRepo = true
          findCommit sha, env, foundCallback
        )
      else
        foundCallback null, tag


    findCommit sha, env, callback


    res.send "Crunching some numbers..."


refreshRepo = (callback) ->
  cchqPath = config.get 'CommCareHQ.path'

  exec "git pull origin master", { cwd: cchqPath }, (err, stdout, stderr) ->
    if err
      res.send 'Trouble pulling repo...'
      res.send stderr
    callback(err)


findCommit = (sha, env, callback) ->
  cchqPath = config.get 'CommCareHQ.path'

  exec "git tag --contains #{sha}", { cwd: cchqPath }, (err, stdout, stderr) ->
    lines = stdout.split('\n').reverse()
    tag = _.find lines, (line) -> line.indexOf(env) != -1

    callback err, tag



extractDateFromTag = (tag) ->
  # Date is the first 16 characters of the tag
  raw = tag.slice 0, 16

  return moment raw, 'YYYY-MM-DD_HH.mm'
