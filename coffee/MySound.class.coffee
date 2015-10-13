class MySound
  CONFIG:
    filename : './snoberry.ogg'
    fps : 60
    fftSize : 128

  isLoaded  : false
  isPlaying : false
  canvas    : null
  manager   : null
  startTime : null
  widthArray : null

  constructor:()->
    @createCanvas()
    @createManager()
    @manager.load(
      bgm:
        path : @CONFIG.filename
        loop : false
        fftSize: @CONFIG.size
    )
  createCanvas:()->
    @canvas = document.getElementById('canvas')
    ctx = @getCanvasContext()
    @fillRect 0, 0, 

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
    return unless @isLoaded
    if @isPlaying
      # 歌詞を置く
      @putLyric()

      dat = @manager.analysers.bgm.getByteFrequencyData()
      @canvas.width = $(window).width();
      @canvas.height = $(window).height();
      
      w = canvas.width
      h = canvas.height

      @fillRect 0, 0, null, null, '#000000'

      widthArray = @getWidthArray(dat.length, w)
      widthCount = 0
      for i in [0...dat.length]
        myHeight = h*dat[i]/255
        @fillRect widthCount, h-myHeight, widthArray[i], myHeight, '#ffffff'
        widthCount += widthArray[i]
    else
      @isPlaying = true
      @manager.play 'bgm'
      @startTime = +new Date()
    return true

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
        i = Math.floor(Math.random() * n--);
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
      lyricSpan = $('<div>').addClass('lyrics').html(lyric.replace(/\s/g, '&nbsp;'))
      lyricSpan.appendTo("#lyrics").hide().fadeIn(1000)   
