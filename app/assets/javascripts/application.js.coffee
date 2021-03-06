# Main application file
# = require jquery
# = require jquery_ujs
# = require jquery.mixitup
# = require bootstrap
# = require highcharts
# = require highcharts_fr
# = require js-routes
# = require URI

(($) ->
  $ ->
    # Initialize chart
    $chart = $('#chart-container')
    if $chart.get 0
      # We are on the homepage, start listening for events

      # Build the event source path
      uri = URI(window.location).scheme("ws").pathname("/inte/events").toString()
      ws = new WebSocket(uri)
      ws.onmessage = (e) ->
        if e.data == "teams_changed"
          window.reloadChart()
          window.reloadTeams()
          window.reloadRewards()
        else
          console.log "Unknown event data " + e.data

      # Initialize teams
      $('#teams-container').mixItUp
        selectors:
          target: '.team'

      #  Show a throbber icon
      $chart.addClass('loading').parents('.row').removeClass('hidden')

      #  Load data via AJAX
      $.get Routes.stats_path(format: 'json'), null, (data) ->
        # Remove throbber and initialize highcharts
        $chart.removeClass('loading').highcharts
          series: data.series
          title:
            text: ''
          xAxis:
            type: 'datetime'
            title:
              text: 'Date'
          yAxis:
            min: 0
            title:
              text: 'Points'
          legend:
            itemStyle:
              fontFamily: 'sf_ironsides'
              fontWeight: 'normal'
              fontSize: '25pt'
              textTransform: 'uppercase'

  window.reloadTeams = ->
    $.get Routes.teams_path(format: 'json'), null, (data) ->
      $('.team').each ->
        $this = $(this)
        team = data[$this.data('team-id')]
        $this.attr({ 'data-team-score': team.score.value, 'data-team-rank': team.rank.value })
        $this.find('.position').text team.rank.text
        $this.find('.score').text team.score.text
      $('#teams-container').mixItUp('sort', 'team-rank:asc')

  window.reloadChart = ->
    chart = $('#chart-container').highcharts()
    chart.showLoading()
    $.get Routes.stats_path(format: 'json'), null, (data) ->
      for series, i in data.series
        chart.series[i].update(series, false)
      chart.hideLoading()
      chart.redraw()

  window.reloadRewards = ->
    $.get Routes.rewards_path(), null, (code) ->
      $('#last-rewards').html(code)

)(jQuery)