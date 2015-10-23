$().ready(->
  # ボリューム
  $('#volume').val(if $.cookie('volume')? then $.cookie('volume') else 0.1)
  $('#volume').on 'change', ->
    vol = $(this).val()
    $.cookie 'volume', vol, {expires:100*365}
    window.mysound.setVolume vol

  $('#volumeForm').on(
    mouseenter:->
      $(this).fadeTo 500, 1
    mouseleave:->
      $(this).fadeTo 1000, 0.01
  )

  # スタートボタン
  $('#play').on 'click', ->
    $('#playForm').addClass 'noDisplay'
    # 開始
    window.mysound = new MySound()

  # デバッグ
  window.onerror = (e)->
    alert e
)

