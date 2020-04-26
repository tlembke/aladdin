function rickshawBars() {
  if ($('#rickshaw-bars')[0] === undefined) {
    return;
  }

  var seriesData = [[], []];
  var random = new Rickshaw.Fixtures.RandomData(50);

  for (var i = 0; i < 50; i++) {
    random.addData(seriesData);
  }

  var graph = new Rickshaw.Graph({
    element: document.getElementById('rickshaw-bars'),
    height: 200,
    renderer: 'bar',
    series: [
      {
        color: '#D13B47',
        data: seriesData[0]
      },
      {
        color: '#90caf9',
        data: seriesData[1]
      }
    ]
  });

  graph.render();

  $(window).on('resize', function() {
    graph.configure({
      width: $('#rickshaw-bars').parent('.panel-body').width(),
      height: 200
    });
    graph.render();
  });

  var hoverDetail = new Rickshaw.Graph.HoverDetail({ graph: graph });
}
