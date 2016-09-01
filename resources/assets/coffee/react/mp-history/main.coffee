###
# Copyright 2016 ppy Pty. Ltd.
#
# This file is part of osu!web. osu!web is distributed with the hope of
# attracting more community contributions to the core ecosystem of osu!.
#
# osu!web is free software: you can redistribute it and/or modify
# it under the terms of the Affero GNU General Public License version 3
# as published by the Free Software Foundation.
#
# osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
###
{div} = React.DOM
el = React.createElement

class MPHistory.Main extends React.Component
  refreshTimeout: 10000

  constructor: (props) ->
    super props

    @timeout = null

    @state =
      events: []
      allEventsCount: 0 # amount of all events in the database (including ones that aren't currently shown)
      users: {}
      since: 0
      lastGameId: 0
      teamType: ''
      initialLoaded: false

    @loadHistory @state.since

  componentDidUpdate: (props, state) ->
    if !@state.initialLoaded
      target = $('.js-mp-history--event-box')[0]
      $(window).stop().scrollTo target.scrollHeight, 500

      @setState initialLoaded: true

  componentWillUnmount: ->
    clearTimeout @timeout

  loadHistory: =>
    return if _.last(@state.events)?.detail.type == 'match-disbanded'

    $.ajax laroute.route('matches.history', matches: @props.match.id, full: @props.full),
      method: 'GET'
      dataType: 'JSON'
      data:
        since: @state.since

    .done (data) =>
      return if _.isEmpty data.events.data

      lastIndex = _.findLastIndex @state.events, (e) -> e.id < data.events.data[0].id
      newEvents = _.concat @state.events[..lastIndex], data.events.data

      newUsers = _(data.users.data)
        .keyBy (o) -> o.id
        .assign @state.users
        .value()

      @setState
        events: newEvents
        allEventsCount: data.all_events_count
        users: newUsers
        since: @minNextEventId
        lastGameId: _.findLast(newEvents, (e) -> e.game?)?.id ? 0

    .always =>
      @timeout = setTimeout @loadHistory, @refreshTimeout

  minNextEventId: =>
    lastGame = _.findLast @state.events, (o) -> o.game?

    if lastGame? && !lastGame.game.data.end_time?
      lastGame.id - 1
    else
      _.last(@state.events)?.id ? 0

  lookupUser: (id) =>
    @state.users[id]

  render: ->
    div className: 'osu-layout__section',
      el MPHistory.Header,
        name: @props.match.name

      el MPHistory.Content,
        id: @props.match.id
        events: @state.events
        lastGameId: @state.lastGameId
        allEventsCount: @state.allEventsCount
        full: @props.full
        lookupUser: @lookupUser
