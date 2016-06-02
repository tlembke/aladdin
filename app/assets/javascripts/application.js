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
// require turbolinks
// require jquery
// require jquery_ujs
// require modernizr
//  require dresssed
//  require bootstrap-editable
//  require bootstrap-editable-rails
//= require_tree .

$(document).ready(function() {
    $(".editable").editable();
     $(".chart").each(function(){
            drawChart($(this));
    });
     $(".apptname").hide();
     

});
    $('.panel').on('shown.bs.collapse', function (e) {
        $(".chart").each(function(){
            $(this).empty();
            drawChart($(this));
        });
    });

    // Add parameter to epclink
    $(".epclink").click(function(e) {

        var theLink=$(this).data('member');

        theText=$("#"+theLink).text();

        e.preventDefault();

        newLink= $(this).attr("href") + '&noVisits=' + theText;

        window.open(newLink, '_blank'); // <- This is what makes it open in a new window.


        // window.location.href = $(this).attr("href") + '&noVisits=' + theText;
    });

    // Show Appt Details

   $('#apptdetails').click( function() {

            $('.apptname').toggle();
            $('.apptreason').toggle();
    });

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
			$(master).prop("checked",$(this).prop("checked"));
	});

// new goal saved via ajax





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









