expect = require('chai').expect
utils = require('../utils/utils')

describe 'Igor Search', ->
  describe 'Utils', ->
    it 'should correctly parse user', ->
      user = utils.extractUser 'igor search user=ben woah'
      expect(user).to.eql 'ben'

    it 'should correctly parse room', ->
      room = utils.extractRoom 'igor search room=requirement woah'
      expect(room).to.eql 'requirement'

    it 'should parse multiple params', ->
      query = 'igor search room=requirement user=ben woah'
      room = utils.extractRoom query
      user = utils.extractUser query

      expect(user).to.eql 'ben'
      expect(room).to.eql 'requirement'
