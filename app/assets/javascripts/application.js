//= require jquery
//= require jquery-ui-1.8.16.custom.min
//= require jquery.form
//= require pusher.min.js

window.pusher = new Pusher(window.pusherKey)
userChannel = pusher.subscribe(window.currentUser)

userChannel.bind('tagged',
  function(data) {
    tagName = data.name;

    var a = $("<a>").attr({href: '/comments#person_'+window.currentUser})
    var el = $("<div class=notification>").css({display: 'none'})
    
    el.html("Zu dir wurde ein neuer Kommentar geschrieben!<br><br>&nbsp;&nbsp;&nbsp;<em><strong>"+tagName+"</strong></em><br><br>Klick hier, um auf die Kommentarseite zu gelangen.")
    a.click(function() {
      el.remove()
    })
    a.append(el)
    $("body").append(a)
    $(el).fadeIn()
  }
);