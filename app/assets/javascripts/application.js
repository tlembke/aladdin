// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dresssed
// require turbolinks
//= require bootstrap-editable
//= require bootstrap-editable-rails
//= require_tree .

$(document).ready(function() {
    $(".editable").editable();


    $('.panel').on('shown.bs.collapse', function (e) {
    $(".chart").each(function(){
        $(this).empty();
        drawChart($(this));
    });





})



  




// This is to load condiiton id into hidden field in New Goal modal
     $(".new_goal_link").click(function(){ 
     	$("#goal_condition_id").val($(this).data('condition'));
     	$('#new-goal-modal').modal('show');
   	 });
// an external submit button for import goals
     $('#submit-import-goals').click( function() {
     		$('form#import-goals').submit();
	});
// select / unselect all

     $(".master-select-all").click( function() {
     		master=".goal_master_"+$(this).data('master');
			$(master).prop("checked",$(this).prop("checked"))
	});

// new goal saved via ajax




});

    function drawChart(chart){
         //alert(chart.data('values'));
        // jsn=JSON.parse(chart.data('values'));


        Morris.Line({
            element: chart.attr('id'),
            data: chart.data('values'),
            xkey: chart.data('xkey'),
              xLabelFormat: function(date) {
                      return date.getDate()+'/'+   (date.getMonth()+1)+'/'+date.getFullYear(); 
                      },
            parseTime: 'true',
            goals: chart.data('goals'),
            postUnits: chart.data('units'),
            ykeys: chart.data('ykeys'),
            goalLineColors: ['red'],
            labels: chart.data('labels'),
            dateFormat: function(date) {
                      d = new Date(date);
                      return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear(); 
            },
         });
    }

    function drawChart1(chart){
        // alert(chart.data('values'));
        // jsn=JSON.parse(chart.data('values'));
        alert(chart.data('values'));
        ykeys=["a"];
        if (chart.data('labels').length == 2) {
            ykeys.push("b"); 
        }
        Morris.Line({
            element: chart.attr('id'),
            data: chart.data('values'),
            xkey: 'date',
              xLabelFormat: function(date) {
                      return date.getDate()+'/'+   (date.getMonth()+1)+'/'+date.getFullYear(); 
                      },
            parseTime: 'true',
            goals: chart.data('goals'),
            ykeys: ykeys,
            goalLineColors: ['red'],
            labels: chart.data('labels'),
            dateFormat: function(date) {
                      d = new Date(date);
                      return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear(); 
            },
         });
    }

    function drawChart2(){
         // using Morris Charts
        Morris.Line({
            element: 'measure_example',
            data: [
                { date: '2016-04-03', a: 170, b: 80 },
                { date: '2016-04-01', a: 175,  b: 65 },
                { date: '2016-03-03', a: 150,  b: 40 },
                { date: '2016-02-03', a: 170,  b: 65 },
                { date: '2015-04-03', a: 130,  b: 80 },
                { date: '2015-12-10', a: 195,  b: 65 },
                { date: '2016-01-03', a: 100, b: 40 }
              ],
              xkey: 'date',
              xLabelFormat: function(date) {
                      return date.getDate()+'/'+   (date.getMonth()+1)+'/'+date.getFullYear(); 
                      },
              parseTime: 'true',
              goals: ['130','80'],
              ykeys: ['a', 'b'],
              goalLineColors: ['red'],
              labels: ['Systolic', 'Diastolic'],
              dateFormat: function(date) {
                      d = new Date(date);
                      return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear(); 
              },
            });

      };






