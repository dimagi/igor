_ = require 'lodash'

USER_PARAM = 'user'
ROOM_PARAM = 'room'

extractParam = (param, query) ->
  result = _.filter(query.split(' '), (word) -> _.startsWith(word, "#{param}="))

  extracted = null
  if result.length >= 1
    extracted = result[0].slice "#{param}=".length

  extracted

exports.extractUser = (query) ->
  extractParam 'user', query

exports.extractRoom = (query) ->
  extractParam 'room', query

exports.USER_PARAM = USER_PARAM
exports.ROOM_PARAM = ROOM_PARAM
