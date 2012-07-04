class Options
  constructor: (analyzer) ->
    @analyzer = analyzer
    @nextStreamId = 0

    @init()

  init: () ->
    $(OPTIONS_CONTAINER).modal({
      backdrop: 'static',
      keyboard: false,
      show: true
    })
    $(OPTIONS_ADD_BTN).click () => @addColumn()
    $(OPTIONS_DONE_BTN).click () => @done()

    @addColumn()

  show: () ->
    $(OPTIONS_CONTAINER).modal("show")

  hide: () ->
    $(OPTIONS_CONTAINER).modal("hide")

  addColumn: () ->
    count = $(OPTIONS_COLUMN).length
    if count == MAX_COLUMNS
      @addError('There is a maximum of ' + MAX_COLUMNS + ' columns.')
    else
      $(OPTIONS_COLUMNS).append(
        '<div class="form-inline options-column">
          <div class="control-group search-term-holder">
            <input type="text" placeholder="Search term" class="input-medium search-term"> 
          </div>
          <div class="control-group">
              <div class="input-append">
                <input type="text" placeholder="Refresh rate" class="input-small refresh-rate"><span class="add-on">seconds</span>
              </div>
          </div>
          <i class="remove-column icon-remove"></i>
        </div>'
      )
      $(OPTIONS_REMOVE_COLUMN).click (e) => 
        @removeColumn(e.target)

  removeColumn: (element) ->
    console.log element
    console.log $(element).parent()
    stream = $(element).parent().data('stream')
    console.log stream
    if stream != undefined
      stream.destroy()
    $(element).parent().remove()

  done: () ->
    $(OPTIONS_ERRORS).html('')
    error = false
    $(OPTIONS_COLUMN).each (i, element) => 
      stream = $(element).data('stream')
      if stream == undefined
        stream = @createNewStream(element)
        if !stream
          @addError("All fields are required.")
          error = true

    if !error
      @hide()
      count = $(OPTIONS_COLUMN).length
      $(STREAM).each (i, element) ->
        $(element).removeClass("column-count1 column-count2 column-count3 column-count4 column-count5 column-count6")
        $(element).addClass("column-count#{ count }")
      

  addError: (message) ->
    $(OPTIONS_ERRORS).append(
        "<div class='alert alert-error'>
        <a class='close' data-dismiss='alert' href='#''>×</a>
        #{ message }
        </div>"
      )

  createNewStream: (element) ->
    $(element).find('.error').each((i,element)->
      $(element).removeClass('error')
    )
    error = false
    
    searchTerm = $(element).find(OPTIONS_SEARCH_TERM).val()
    if searchTerm == ''
      error = true
      $(element).find(OPTIONS_SEARCH_TERM).parent().addClass('error')
    else if $(element).find(OPTIONS_SEARCH_TERM_HOLDER).find('.uneditable-input').length < 1
        $(element).find(OPTIONS_SEARCH_TERM_HOLDER).append(
            "<span class='input-medium uneditable-input'>#{ searchTerm }</span>"
        )
        $(element).find(OPTIONS_SEARCH_TERM).hide()
    
    refreshRate = $(element).find(OPTIONS_REFRESH_RATE).val()
    if refreshRate == ''
      error = true
      $(element).find(OPTIONS_REFRESH_RATE).parent().parent().addClass('error')

    refreshRate = parseInt(refreshRate) * 1000

    if error
      return false

    $(STREAM_HOLDER).append(
      "<div class='stream' id='stream-#{ @nextStreamId }'>
        <h3><i class='icon-search'></i> #{ searchTerm }</h3>
        <ul class='tweets'>
        </ul>
      </div>"
    )

    stream = new Stream(@analyzer, searchTerm, refreshRate, "#stream-#{ @nextStreamId }")
    $(element).data('stream', stream)
    @nextStreamId++

    return stream


