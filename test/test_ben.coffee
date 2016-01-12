HubotHelper = require('hubot-test-helper')
expect = require('chai').expect
co = require('co')


helper = new HubotHelper '../scripts/ben.coffee'

describe 'Ben', ->

  beforeEach ->
    @room = helper.createRoom()
    co =>
      yield @room.user.say 'george', '@hubot whostheman'

  afterEach ->
    @room.destroy()

  it 'should say who the man is', ->
    expect(@room.messages).to.eql [
        ['george', '@hubot whostheman']
        ['hubot', "Ben! Ben! You're the man! If you can't do it no one can!"]
    ]
