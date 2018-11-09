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
// require jquer
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



        $("#appt_form").validate({
          rules: {
            Surname: {
              required: true
            },
            FirstName: {
              required: true
            },
            mobile: {
              required: true,
              digits: true,
              normalizer: function( value ) {
                  // Trim the value of the `field` element before
                  // validating. this trims only the value passed
                  // to the attached validators, not the value of
                  // the element itself.
                  return value.replace(/ /g,'');
              },
              minlength: 10,
              maxlength: 10,
              phonemobileAU: true
            },

            



            appttime: {
              required: true
            }

          },
          messages: {
              appttime: {
                required: "Please click on a green appointment time in the calendar above",
              },
              Surname: {
                required: "A surname is required",
              },
              FirstName: {
                required: "A first name is required",
              },             
              mobile: {
                required: "A mobile number is required",
              }, 
          }
        });
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

        theProvider = $("#provider").val();


        e.preventDefault();

        newLink= $(this).attr("href") + '&noVisits=' + theText + '&provider=' + theProvider;

        window.open(newLink, '_blank'); // <- This is what makes it open in a new window.


        // window.location.href = $(this).attr("href") + '&noVisits=' + theText;
    });

    // Show Appt Details

   $('#apptdetails').click( function() {

            $('.apptname').toggle();
            $('.apptreason').toggle();
    });


    $('#bookMode').change( function() {
      

        var mode = "h"
        if($(this).is(":checked")){
          var mode = "v"
        }
        


        var key = 'mode';
  


        var s = document.location.search;
        var kvp = key +"="+mode;

        var r = new RegExp("(&|\\?)"+key+"=[^\&]*");

        s = s.replace(r,"$1"+kvp);

        if(!RegExp.$1) {s += (s.length>0 ? '&' : '?') + kvp;};

        //again, do what you will here
        document.location.search = s;
  
    });









// This is to load condiiton id into hidden field in New Goal modal
  $(".new_goal_link").click(function(){ 
     	$("#goal_condition_id").val($(this).data('condition'));
     	$('#new-goal-modal').modal('show');
   });


  // This is to load condiiton id into hidden field in New Goal modal
  $(".date-scroller").click(function(){ 
       // alert("Show " + $(this).data('show'));
        //alert("Hide " + $(this).data('hide'));
       
        
        
        
        theString = "-" + $(this).data('doctor') + "-" + $(this).data('code');
        $("#" + $(this).data('hide') + theString).hide();
        $("#" + $(this).data('show') + theString).show();
        if ($(this).data('uparrowhide') != -1 ){
           //alert("UAH " + $(this).data('uparrowhide') + "-up" + theString);
          $("#" + $(this).data('uparrowhide') + "-up" + theString).hide();
        }
        if ($(this).data('uparrowshow') != -1 ){
          // alert("UAS " + $(this).data('uparrowshow') + "-up" + theString);
          $("#" + $(this).data('uparrowshow') + "-up" + theString).show();
        }
        if ($(this).data('downarrowhide') != -1 ){
          //alert("DAH " + "#" + $(this).data('downarrowhide') + "-down" +theString);
          $("#" + $(this).data('downarrowhide') + "-down" +theString).hide();
        }
        if ($(this).data('downarrowshow') != -1 ){
          // alert("DAS " + $(this).data('downarrowshow') + "-down" + theString);
          $("#" + $(this).data('downarrowshow') + "-down" + theString).show();
        }
  

      

      //$("#goal_condition_id").val($(this).data('condition'));
      //$('#new-goal-modal').modal('show');

   });

  // This is to load condiiton id into hidden field in New Goal modal
  $(".apptTime").click(function(){ 
       // alert("Show " + $(this).data('show'));
        //alert("Hide " + $(this).data('hide'));
       
        // alert($(this).data('id'));
        $("#doctor_id").val($(this).data('doctor'));
        $("#date").val($(this).data('date'));
        $("#time").val($(this).data('time'));
        $("#appt_id").val($(this).data('appt_id'));
        if ($(this).hasClass( "single" )){        
             $("#single").val(1);
        }
        else{
            $("#single").val(0);
        }
        // $("#doctor_name").val($(this).data('doctor_name'));
        var doctor_name = $(this).data('doctor_name');
        var appttime = $(this).data('time');

         var morning = "am";
        if (appttime >1200){
           var morning = "pm"
           appttime = appttime - 1200
        };
        appttime=appttime.toString();
        len=appttime.length
        appttime = appttime.substring(0, len-2) + ":" + appttime.substring(len-2);
        $("#appttime").val(appttime + morning);

        // convert date format
        var parts =$(this).data('date').split('-');
        var apptdate = new Date(parts[0], parts[1] - 1, parts[2]); 

        $("#appttime").val(doctor_name + " at " + appttime + morning+ " on " + apptdate.toDateString());
        $( "#appttime" ).valid();
        

       
        // var morning = "am";


        // $("#appt_time").val(appt_time);


   });


  // This is for when single or double appt selected
  $("#apptduration_single").click(function(){ 
       $(".single").removeClass('disabled');
       $(".single").addClass("btn-success");
  });

    $("#apptduration_double,#apptduration_annual").click(function(){ 
      $(".single").removeClass("btn-success");
      $(".single").addClass('disabled');
      // and clear currently selected appointment if it is a single
      // alert($("#single").val());
      if ($("#single").val() == 1){
        // alert ("Single found");
        $('#appttime').val("");
        $('#date').val(0);
        $('#time').val(0);
        $('#doctor_id').val(0);
        $('#single').val(0);
      }
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
         //alert(chart.data('xkey'));
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
            preUnits: chart.data('preunits'),
            ykeys: chart.data('ykeys'),
            goalLineColors: ['red'],
            labels: chart.data('labels'),
            dateFormat: function(date) {
                      d = new Date(date);
                      return d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear(); 
            },
         });
    }









