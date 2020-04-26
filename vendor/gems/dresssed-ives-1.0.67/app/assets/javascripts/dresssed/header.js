!function( $ ) {

  $(function () {
    
    // fix sub nav on scroll
    var $win = $(window)
      , $bar = $('header hr')
      , barTop = $('header hr').length && $('header hr').offset().top - 58
      , isFixed = 0

    function processScroll() {
      var i, scrollTop = $win.scrollTop()
      if (scrollTop >= barTop && !isFixed) {
        isFixed = 1
        $bar.addClass('bar-fixed')
      } else if (scrollTop <= barTop && isFixed) {
        isFixed = 0
        $bar.removeClass('bar-fixed')
      }
    }
    
    if (!$("header .navbar").hasClass("navbar-fixed-top")) {
      // Navbar is static, bar should be too
    } else if ($("header #featured")[0]) {
      processScroll()
      $win.on('scroll', processScroll)
    } else {
      $bar.addClass('bar-fixed')
    }

  })

}( window.jQuery )
