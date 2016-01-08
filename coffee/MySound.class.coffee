class MySound
  CONFIG:
    filename : './snobbery.mp3'
    fps : 60
    fftSize : 128
    startSec : 2

  isLoaded  : false
  isReady   : false
  isPlaying : false
  canvas    : null
  manager   : null
  startTime : null
  widthArray : null
  resizeTimer : false

  constructor:()->
    @createCanvas()
    @createManager()
    @manager.load(
      bgm:
        path : @CONFIG.filename
        loop : false
        fftSize: @CONFIG.size
        gain : 'bgm'
        volume : $('#volume').val()
    )
    $(window).resize @onResize

  onResize:()=>
    clearTimeout @resizeTimer if @resizeTimer isnt false
    @resizeTimer = setTimeout(
      =>
        @widthArray = null
        @resizeTimer = false
      100
    )
  createCanvas:()->
    @canvas = document.getElementById('canvas')
    @canvas.width = $(window).width()
    @canvas.height = $(window).height()
    ctx = @getCanvasContext()
    @fillRect 0, 0, null, null, '#000000'

  createManager:()->
    @manager = new AudioManager(
      fps             : @CONFIG.fps
      fftSize         : @CONFIG.fftSize
      autoLoop        : true
      onLoaded        : => @onLoaded()
      onEnterFrame    : => @onEnterFrame()
    ).init()

  onLoaded:()=>
    @isLoaded = true
  onEnterFrame:()=>
    if not @isLoaded
      return
    if not @isReady
      @isReady = true
      # ボリューム
      @setVolume $('#volume').val()

      setTimeout(
        =>
          @startTime = +new Date()
          @isPlaying = true
          @manager.play 'bgm'
        @CONFIG.startSec * 1000
      )
      return
    if not @isPlaying
      return

    # 歌詞を置く
    @putLyric()

    dat = @manager.analysers.bgm.getByteFrequencyData()
    @canvas.width = $(window).width()
    @canvas.height = $(window).height()
    
    w = canvas.width
    h = canvas.height

    @fillRect 0, 0, null, null, '#000000'

    widthArray = @getWidthArray(dat.length, w)
    widthCount = 0
    for i in [0...dat.length]
      myHeight = h*dat[i]/255
      @fillRect widthCount, h-myHeight, widthArray[i], myHeight, '#ffffff'
      widthCount += widthArray[i]

  fillRect:(x, y, w, h, color)->
    w = @canvas.width if w is null
    h = @canvas.height if h is null

    ctx = @getCanvasContext()
    ctx.strokeStyle = color
    ctx.fillStyle = color
    ctx.fillRect x, y, w, h

  getCanvasContext:()->
    @canvas.getContext('2d')

  getWidthArray:(noteCount, canvasWidth)->
    return @widthArray if @widthArray isnt null

    baseW = canvasWidth // noteCount
    restW = canvasWidth - baseW * noteCount
    
    plus1 = []
    plus1.push 1 for i in [0...restW]
    plus1.push 0 for i in [restW...canvasWidth]
    shuffle = (array)->
      n = array.length
      while n
        i = Math.floor(Math.random() * n--)
        [array[n], array[i]] = [array[i], array[n]]
      array
    plus1 = shuffle plus1

    res = []
    res.push(baseW+plus1[i]) for i in [0...canvasWidth]
    @widthArray = res

  putLyric:()->
    return if window.LYRICS.length is 0
    [time, lyric] = window.LYRICS[0]
    nowTime = +new Date()
    if nowTime - @startTime > time
      window.LYRICS.shift()
      #lyric = lyric.replace(/\s/g, '&nbsp;')
      lyricSpan = $('<div>').addClass('lyric').html(lyric)
      lyricSpan.appendTo("#lyrics").hide().fadeIn(1000)

  setVolume:(volume)->
    @manager.setVolume 'bgm', volume