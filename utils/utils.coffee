_ = require 'lodash'

extractParam = (param, query) ->
  result = _.filter(query.split(' '), (word) -> _.startsWith(word, "#{param}="))

  extracted = null
  if result.length >= 1
    extracted = result[0].slice "#{param}=".length

  extracted

exports.extractMentions = (text) ->
  mentions = _.filter(text.split(' '), (word) -> _.startsWith(word, "<") and _.endsWith(word, ">"))

  results = {
    channels: []
    users: []
  }
  _.each mentions, (mention) ->
    stripped = _.trim mention, '<>'
    if _.startsWith stripped, '#'
      results.channels.push stripped.slice(1)
    else if _.startsWith stripped, '@'
      results.users.push stripped.slice(1)

  results
