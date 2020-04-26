!function( $ ) {

  $(function () {

    // FORM SHEET
    // ----------
    //

    // This is the fix for when Webkit decides to autofill a field,
    // and it causes the label being used as a placeholder to be seen underneath
    // the autofilled text.
    var attemptCount = 0;
    var intervalId = window.setInterval(function(){
      try {
        $('.form-sheet').find('input:-webkit-autofill').each(function(){
          hideLabel(this);
          attemptCount++;

          if(attemptCount > 3) {
            clearInterval(intervalId);
          }
        });
      } catch( e ) { /* Do Nothing */ }
    }, 300);

    // Use label as placeholder in sheet forms, as placeholder can't be styled fully in most browsers.

    $(".form-sheet").find("input, textarea")

      .bind("keydown.formsheet", function(e) {
        checkForChange(e)
      })

      .change(function() {
        if (this.value == "") {
          showLabel(this)
        } else {
          hideLabel(this)
        }
      })

      .focus(function() {
        findLabel(this).addClass("focused")
      })

      .blur(function() {
        if (this.value == "") {
          showLabel(this)
        } else {
          hideLabel(this)
        }

        findLabel(this).removeClass("focused")
      })

      // Ensure inputs with some values on load have their label hidden.
      .each(function() {
        $(this).triggerHandler("blur")
      })

      // Apply .focused class to inputs already focused on page load.
      .filter(":focus")
        .each(function() {
          findLabel(this).addClass("focused")
        })
      .end()

    function checkForChange(e) {
      if(	e.keyCode == 9  || // Skip Tab
          e.keyCode == 16 || // Skip Shift
          e.keyCode == 17 || // Skip Control
          e.keyCode == 18 || // Skip Option
      		e.keyCode == 91 || // Skip LCommand
      		e.keyCode == 93    // Skip RCommand
      	  ) return;

      hideLabel(e.target)
    }

    function hideLabel(input) {
      findLabel(input).hide()
      $(input).unbind("keydown.formsheet")
    }

    function showLabel(input) {
      findLabel(input).show()
      $(input).bind("keydown.form-sheet", function(e) {
        checkForChange(e)
      })
    }

    function findLabel(input) {
      return $(input).parents(".form-group").find("label.form-label")
    }

  })

}( window.jQuery )
