# Description
#   Runs Fogbugz utilities
#
# Dependencies:
#
# Configuration:
#
# Commands:
#   hubot bookmark <url> <desc> - Saves url with description
#   hubot bookmark list - Lists all saved bookmarks
#   hubot bookmark delete <url> - Removes specified url
#   hubot bookmark delete all - Removes all saved bookmarks
#
# Notes:
#
# Author:
#   benrudolph

fs = require 'fs'
config = require 'config'
os = require 'os'
_ = require 'lodash'

DELIMITER = '|'


module.exports = (robot) ->

  robot.respond /bookmark (http[^ ]+) (.+)/, (res) ->
    url = res.match[1]
    desc = res.match[2]
    basePath = config.get 'Bookmarks.path'
    filePath = "#{basePath}/#{res.message.user.id}"

    saveBookmark filePath, url, desc, (out) -> 
      res.send "#{res.message.user.name}, #{out}"

  robot.respond /bookmark (http[^ ]+)/, (res) ->
    url = res.match[1]
    basePath = config.get 'Bookmarks.path'
    filePath = "#{basePath}/#{res.message.user.id}"

    saveBookmark filePath, url, null, (out) ->
      res.send "#{res.message.user.name}, #{out}"

  robot.respond /bookmark delete (http[^ ]+)/, (res) ->
    url = res.match[1]
    basePath = config.get 'Bookmarks.path'
    filePath = "#{basePath}/#{res.message.user.id}"

    fs.readFile filePath, 'utf-8', (err, contents) ->
      if err
        res.send "Unable to read file: #{err}. This probably means you haven't saved any bookmarks."
        return

      lines = contents.split os.EOL
      lines = _.filter lines, (line) -> line.split(DELIMITER)[0] != url
      newContents = lines.join os.EOL

      fs.writeFile filePath, newContents, (err) ->
        if err
          res.send "Unable to save: #{err}"
        else
          res.send "Successfully deleted #{url}"

  robot.respond /bookmark delete all/, (res) ->
    basePath = config.get 'Bookmarks.path'
    filePath = "#{basePath}/#{res.message.user.id}"

    fs.writeFile filePath, '', (err) ->
      if err
        res.send "Unable to save: #{err}"
      else
        res.send "Successfully deleted all bookmarks"

  robot.respond /bookmark list/, (res) ->
    filePath = config.get 'Bookmarks.path'

    fs.readFile "#{filePath}/#{res.message.user.id}", 'utf-8', (err, contents) ->
      if err
        res.send "Unable to read file: #{err}. This probably means you haven't saved any bookmarks."
        return

      lines = contents.split os.EOL
      out = ''
      _.each lines, (line) ->
        parts = line.split DELIMITER
        out += "#{parts[0]}"
        if parts[1]
          out += ": #{parts[1]}"
        out += '\n'

      res.send out


saveBookmark = (filePath, url, desc, callback) ->
  fs.readFile filePath, 'utf-8', (err, contents) ->
    # No error reading file, check to make sure url hasn't been saved
    if !err
      lines = contents.split os.EOL

      if _.any(lines, (line) -> line.split(DELIMITER)[0] == url)
        callback "#{url} already is already saved"
        return

    # Save the bookmark
    fs.appendFile filePath, "#{url}#{DELIMITER}#{desc || ''}#{os.EOL}", (err) ->
      if err
        callback "I was unable to save: #{err}"
      else
        callback "I successfully saved #{url}"
