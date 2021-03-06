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
//= require moment
//= require bootstrap-datetimepicker
//= require tinymce-jquery
//= require_tree .

$(document).ready(function() {
    
    $(".editable").editable();
    $('[data-toggle="tooltip"]').tooltip({container: 'body'});
    $('[data-toggle="popover"]').popover({
        html : true,
        container: "body",
        content: function() {
          var content = $(this).attr("data-popover-content");
          return $(content).children(".popover-body").html();
        },
        title: function() {
          var title = $(this).attr("data-popover-content");
          return $(title).children(".popover-heading").html();
        }
    });
    TinyMCERails.configuration.default = {
        selector: "textarea.tinymce",
        cache_suffix: "?v=5.0.16",
        toolbar: ["styleselect | bold italic | undo redo","image | link"],
        plugins: [
            "advlist autolink lists link image charmap print preview hr anchor pagebreak",
            "searchreplace wordcount visualblocks visualchars code fullscreen",
            "insertdatetime media nonbreaking save table directionality",
            "emoticons template paste textpattern determinemimetype imagetools save"
          ],
         toolbar1: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
         toolbar2: "print preview save media | forecolor backcolor emoticons",
         relative_urls : false,
         remove_script_host : true,
         image_advtab: true,
          images_upload_handler: function (blobInfo, success, failure) {
            var xhr, formData;
            xhr = new XMLHttpRequest();
            xhr.withCredentials = false;
            var csrfToken = $('meta[name="csrf-token"]').attr('content');
            xhr.open('POST', '/images');
            xhr.setRequestHeader("X-CSRF-Token", csrfToken);
            xhr.onload = function() {
              var json;

              if (xhr.status != 200) {
              failure('HTTP Error: ' + xhr.status);
              return;
              }
              json = JSON.parse(xhr.responseText);

              if (!json || typeof json.location != 'string') {
              failure('Invalid JSON: ' + xhr.responseText);
              return;
              }
              success(json.location);
            };
            formData = new FormData();
            // form.append("Content-Type", file.type);
            // form.append("image[image]", file);
            // formData.append('file', blobInfo.blob(), blobInfo.filename());

            formData.append('image[image]', blobInfo.blob());
            xhr.send(formData);
          }





    };
    TinyMCERails.initialize('default', {
      
    });




    



    $('.faxselect').change(function () {
         var faxNumber  = $(this).children("option:selected").val();
         var faxPick = $(this).attr('datafax');
         $("[name='"+faxPick+"']").val(faxNumber);


      });


        $('#docselect').change(function(e){
            var fileName = e.target.files[0].name;
            fileName = fileName.replace(/\.[^/.]+$/, "");
            fileName = fileName.replace(/_/g, ' ');
            fileName = fileName.replace(/-/g, ' ');
            fileName = fileName.replace( /([A-Z])/g, " $1" );
            fileName = fileName.charAt(0).toUpperCase() + fileName.slice(1);
            $('#docname').val(fileName);
        });
  

    $('.faxpick').click(function () {
        var url = "/fax/"+$(this).attr('data-url');
        var faxindex = $(this).attr('faxindex');
        image = new Image();
        image.src = url;
        image.onload = function () {
            $('#fax-holder').empty().append(image);
        };
        image.onerror = function () {
            $('#fax-holder').empty().html('That image is not available.');
        }

        $('#fax-holder').empty().html('Loading...');

         $('.fax-arrow').hide();
         $('#fax-arrow-'+faxindex).show();

          $('.faxpick').removeClass('table-selected');
         $('#tr-'+faxindex).addClass('table-selected');





        return false;
    });


     $(".chart").each(function(){
            drawChart($(this));
    });
     $(".apptreason").hide();
     $('.datepicker').datetimepicker({format: "ll", keepInvalid: true, useStrict: true});





    if ($("#appointments").length && window.location.pathname.indexOf('examen') > 0 ){
    // Your specific controller code here
                


                  var day=getQueryVariable("date%5Bday%5D");
                  var month=getQueryVariable("date%5Bmonth%5D");
                  var year=getQueryVariable("date%5Byear%5D")

                  $.ajax({
                  url: "/appointments/patient_audit",
                  data: { day: day, year: year, month: month},
                  cache: false,
                  success: function(html){
                    $("#patient_audit_placeholder").html(html);
                  }

                  });

         };         


    if ($("#book").length && window.location.pathname.indexOf('confirm') == -1 && window.location.pathname.indexOf('slots') == -1){
    // Your specific controller code here
                


                  var day=getQueryVariable("date%5Bday%5D");
                  var month=getQueryVariable("date%5Bmonth%5D");
                  var year=getQueryVariable("date%5Byear%5D")

                 // $.ajax({
                   // url: "/book/show_appt",
                    //data: { day: day, year: year, month: month},
                   // cache: false,
                   // success: function(html){
                   //   $("#show_appts_placeholder").html(html);
                    //}

                 // });




              
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




  }




});

var request = {
  queryString: function(item){
    var value = location.search.match(new RegExp("[\?\&]" + item + "=([^\&]*)(\&?)","i"));
    return value ? value[1] : value;
  }
}



function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}

$('.editableUpdate').on('save', function() {
    
    var theId = $(this).data('touch');

    $('#' + theId).html("Updated Today");

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
   $('#showurgenttasks').click( function() {
            $('.nonurgent').toggle();
    });
    $('#showwarnings').click( function() {
            $('.noitemwarning').toggle();
    });
    $('#patient_audit_placeholder').on( "click", "#showincomplete", function(){
            $('.complete').toggle();
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
    $('#noDays').change( function() {
      

        var noDays = $('#noDays').val()
        


        var key = 'noDays';
  


        var s = document.location.search;
        var kvp = key +"="+ noDays;

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

  // This is to allow editing of monitoring function
  $(document).on("click", '.monitor-every', function(event) { 
  //. $(".monitor-every").click(function(){ 
      // alert($(this).data('member'));
      // alert($(this).text());
      theMember = $(this).data('member')
      $("#monitor_every_" + theMember).hide();
      $("#monitor_next_" + theMember).hide();
      $("#monitor_form_" + theMember).show();
      $("#everyUnit-" + theMember).focus();
      $("#monitor_delete_" + theMember).hide();
      // $(this).data('DateTimePicker').date("01/08/2023");
   });
    $(document).on("click", '.clear-member', function(event) { 
   // $(".clear-member").click(function(){ 
      //alert($(this).data('member'));
      theMember = $(this).data('member');
      $("#everyUnit-" + theMember).val("");
      $("#nextDay-" + theMember).val("");
   });
    $(document).on("click", '.cancel-member', function(event) { 
   // $(".cancel-member").click(function(){ 
      //alert($(this).data('member'));
      // alert($(this).text());
      theMember = $(this).data('member');
      $("#monitor_form_" + theMember).hide();
      $("#monitor_every_" + theMember).show();
      $("#monitor_next_" + theMember).show();
      $("#monitor_delete_" + theMember).show();
   });
    $(document).on("click", '.destroy-member', function(event) { 
   // $(".cancel-member").click(function(){ 
      //alert($(this).data('member'));
      // alert($(this).text());
      if (confirm("Are you sure?")){
        theMember = $(this).data('member');
        $.ajax({
                  url: "/members/"+theMember,
                  cache: false,
                  type: 'DELETE',
                  success: function(html){
                    $("#member-" + theMember).hide('puff');
                  }

        });



      }

   });













  // This is to load condiiton id into hidden field in New Goal modal
  $('#show_appts_placeholder').on( "click", ".date-scroller", function(){
  //$(".date-scroller").click(function(){ 

       
        
        
        
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

  $('#show_appts_placeholder').on( "click", ".apptTime", function(){
  // $(".apptTime").click(function(){ 
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
        if (appttime >=1200){
           var morning = "pm"
           if (appttime >=1300){
              appttime = appttime - 1200;
           }
        };
        appttime=appttime.toString();
        if (appttime == "0"){
          appttime = '1200';
        }
        len=appttime.length
        appttime = appttime.substring(0, len-2) + ":" + appttime.substring(len-2);
        $("#appttime").val(appttime + morning);

        // convert date format
        var parts =$(this).data('date').split('-');
        var apptdate = new Date(parts[0], parts[1] - 1, parts[2]); 

        $("#appttime").val(doctor_name + " at " + appttime + morning+ " on " + apptdate.toDateString());
        $( "#appttime" ).valid();
        
        // new bit - then scroll to form

    $([document.documentElement, document.body]).animate({
        scrollTop: $("#topofapptform").offset().top
    }, 2000);


       
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

  function getJsonFromUrl(url) {
      if(!url) url = location.href;
      var question = url.indexOf("?");
      var hash = url.indexOf("#");
      if(hash==-1 && question==-1) return {};
      if(hash==-1) hash = url.length;
      var query = question==-1 || hash==question+1 ? url.substring(hash) : 
      url.substring(question+1,hash);
      var result = {};
      query.split("&").forEach(function(part) {
        if(!part) return;
        part = part.split("+").join(" "); // replace every + with space, regexp-free version
        var eq = part.indexOf("=");
        var key = eq>-1 ? part.substr(0,eq) : part;
        var val = eq>-1 ? decodeURIComponent(part.substr(eq+1)) : "";
        var from = key.indexOf("[");
        if(from==-1) result[decodeURIComponent(key)] = val;
        else {
          var to = key.indexOf("]",from);
          var index = decodeURIComponent(key.substring(from+1,to));
          key = decodeURIComponent(key.substring(0,from));
          if(!result[key]) result[key] = [];
          if(!index) result[key].push(val);
          else result[key][index] = val;
        }
      });
      return result;
}

// -- Chat panel -- 
function sleep(milliseconds) {
  const date = Date.now();
  let currentDate = null;
  do {
    currentDate = Date.now();
  } while (currentDate - date < milliseconds);
}








