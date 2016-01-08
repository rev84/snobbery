window.BASE_TIME = false
window.TIME_JSON = []

$().ready(->
  $('#clear').on('click',->
    window.BASE_TIME = false
    window.TIME_JSON = []
    $('textarea').html('')
  )

  $(window).on('keydown', (e)->
    return if e.keyCode isnt 32
    now = +new Date()
    record = 0

    if window.BASE_TIME is false
      window.BASE_TIME = now
    else
      record = now - window.BASE_TIME

    window.TIME_JSON.push record
    $('textarea').html JSON.stringify(window.TIME_JSON, null, 2)
  )
)
