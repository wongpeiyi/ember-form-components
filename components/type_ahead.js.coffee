App.TypeAheadComponent = Ember.TextField.extend
  limit: 5

  setupOnInsert: ( ->
    @setupBloodhound()
    @setupTypeahead()
    @setupBindings()
  ).on('didInsertElement')

  setupBloodhound: ->
    opts =
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: []
      limit: @get('limit')
      dupDetector: @_dupDetector
    if @get('remote')
      opts.remote =
        url:    @_remoteURL()
        filter: @_transformData.bind(this)
        ajax: success: @_pushRemoteToStore.bind(this)
    @set('blood', new Bloodhound(opts))
    @get('blood').initialize()

  setupTypeahead: ->
    @typeahead = @$().typeahead
      hint:      true
      highlight: true
      minLength: 1
    ,
      source: @get('blood').ttAdapter()
      displayKey: "value"

  # Bind `selection`

  setupBindings: ->
    @typeahead.on 'typeahead:selected',      @_setSelection.bind(this)
    @typeahead.on 'typeahead:autocompleted', @_setSelection.bind(this)
    @selectionDidChange()

  selectionDidChange: ( ->
    if @get('selection')
      @typeahead.val(@get('selection').get(@get('property')))
    else
      @typeahead.val("")
  ).observes('selection')

  _setSelection: (event, item) ->
    @set('selection', item.object)

  # Load data from store based on `collectionModel`

  store: ( ->
    App.__container__.lookup('store:main')
  ).property()

  data: ( ->
    @get('store').all(@get('collectionModel'))
  ).property().volatile()

  # Update bloodhound datums

  dataDidChange: ( ->
    Ember.run.once(this, @_updateData)
  ).observes('data.[]').on('didInsertElement')

  _updateData: ->
    @get('blood').clear()
    @get('blood').add @_transformData(@get('data'))
    App._.log "typeahead: Loaded #{@get('data.length')} items"

  _transformData: (data) ->
    unless Ember.isArray(data)
      data = data[@get('collectionModel').pluralize()]
    data.map (obj) =>
      value:  Ember.get(obj, @get('property'))
      object: obj

  # Remote handling

  _remoteURL: ->
    url = @get('store').adapterFor(@get('collectionModel'))
                       .buildURL(@get('collectionModel'))
    url + "?q=%QUERY"

  _pushRemoteToStore: (data) ->
    @get('store').pushPayload(data)

  _dupDetector: (remote, local) ->
    +remote.object.id == +local.object.id
