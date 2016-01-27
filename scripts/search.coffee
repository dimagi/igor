# Description
#   Runs Fogbugz utilities
#
# Dependencies:
#
# Configuration:
#   NODE_ENV=(local|production)
#
# Commands:
#   hubot search <all> <@mention> <#room> <query> - searches for a message
#   hubot context <messageId> - gets messages that before and after the specified message
#
# Notes:
#
# Author:
#   benrudolph

elasticsearch = require 'elasticsearch'
_ = require 'lodash'
moment = require 'moment'
utils = require '../utils/utils'

INDEX = 'slack_messages'
MESSAGE_TYPE = 'message'

client = new elasticsearch.Client
  host: 'localhost:9200'

module.exports = (robot) ->
  robot.hear /.*/i, (res) ->
    if not _.startsWith res.message.text, 'igor'
      client.index
        index: INDEX
        type: MESSAGE_TYPE
        body:
          message: res.message.text
          user: res.message.user.name
          room: res.message.room
          channelId: res.message.rawMessage.channel
          userId: res.message.user.id
          messageId: res.message.id.split('.')[0]  # Ensure the id is just a number. Seems to be gobally unique
          roomMessageId: +res.message.id.split('.')[1]  # Id for the message in just the room
          date: new Date()
        , (err, resp) ->
          if err
            res.send err.toString()

  robot.respond /context (.+)/i, (res) ->
    messageId = +res.match[1]

    contextIds = _.map [-3, -2, -1, 0, 1, 2, 3], (increment) -> messageId + increment
    query =
      bool:
        must: [
          { match: { messageId: contextIds.join ' ' } }
        ]

    client.search
      index: INDEX
      type: MESSAGE_TYPE
      body:
        query: query
        sort: { date: { order: 'asc' } }
      , (err, resp) ->
        if err
          res.send err.toString()
          return
        res.send formatResults resp

  robot.respond /search (all )?(.+)/i, (res) ->
    query = res.match[2]
    mentions = utils.extractMentions res.message.rawText
    allRooms = res.match[1]?

    # Ensure we do not channels in the query
    query = utils.removeChannelsFromQuery query
    query = query.replace "/\b@[^ ]/", ' '

    musts = _.map query.split(' '), (word) -> { match: { message: word } }

    query =
      bool:
        must: musts

    if not allRooms
      if mentions.channels.length
        query.bool.must.push { match: { channelId: mentions.channels.join(' ') } }
      else
        query.bool.must.push { match: { channelId: res.message.rawMessage.channel } }

    if mentions.users.length
      query.bool.must.push { match: { userId: mentions.users.join(' ') } }

    client.search
      index: INDEX
      type: MESSAGE_TYPE
      body:
        query: query
        highlight:
          pre_tags: ['*']
          post_tags: ['*']
          fields:
            message: {}
      , (err, resp) ->
        if err
          res.send err.toString()
          return

        res.send formatResults(resp)

formatResults = (resp) ->
  hits = resp.hits.hits
  out = ''

  _.each resp.hits.hits, (hit) ->
    date = new Date hit._source.date
    formattedDate = moment(date).format('YYYY-M-D')
    room = hit._source.room
    messageId = hit._source.messageId or 'None'
    message = hit.highlight?.message[0] or hit._source.message

    out += "[#{messageId}][##{room}][#{formattedDate}] #{hit._source.user}: #{message}\n"

  if not out
    out = 'Found nothing!'
  return out
