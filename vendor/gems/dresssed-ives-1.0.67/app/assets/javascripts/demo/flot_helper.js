function flotMetric(el, data, yaxis, options) {
  if (el[0] === undefined) {
    return;
  }

  options = $.extend(
    {
      type: 'area',
      lineWidth: 1
    },
    options
  );

  var series = {
    shadowSize: 0
  };

  series.lines = {
    lineWidth: 3,
    show: true,
    fill: true
  };

  $.plot(
    el,
    [
      {
        label: 'Data 1',
        data: data,
        color: '#C9E3F5'
      }
    ],
    {
      series: series,
      grid: {
        show: false,
        borderWidth: 0
      },
      yaxis: yaxis,
      xaxis: {
        tickDecimals: 0
      },
      legend: {
        show: false
      }
    }
  );
}

function flotRealtime() {
  if ($('#realtime')[0] === undefined) {
    return;
  }

  var dataGenerator = new DataGenerator(200);
  var plot = $.plot('#realtime', [dataGenerator.getRandomizedData()], {
    series: {
      shadowSize: 0
    },
    yaxis: {
      min: 0,
      max: 100
    },
    xaxis: {
      show: false
    }
  });

  function update() {
    plot.setData([dataGenerator.getRandomizedData()]);
    plot.draw();

    if (!Modernizr.touch) {
      setTimeout(update, 24);
    } else {
      setTimeout(update, 1000);
    }
  }

  update();
}
