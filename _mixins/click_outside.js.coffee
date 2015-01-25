App.ClickOutsideMixin = Ember.Mixin.create
  didClickOutside: Ember.K

  setupClickOutsideOnInsert: ( ->
    @_setupClickOutside()
  ).on('didInsertElement')

  teardownClickOutsideOnDestroy: ( ->
    @_teardownClickOutside()
  ).on('willDestroyElement')

  _clickOutsideHandler: (event) ->
    unless $(event.target).closest(@get('element')).length > 0
      @didClickOutside(event)

  _setupClickOutside: ->
    Ember.run.scheduleOnce "afterRender", this, ->
      $(window).on("click.#{@_uuid}", @_clickOutsideHandler.bind(this))

  _teardownClickOutside: ->
    $(window).off("click.#{@_uuid}")
