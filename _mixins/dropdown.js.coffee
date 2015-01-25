#= require views/_mixins/click_outside

App.DropdownMixin = Ember.Mixin.create App.ClickOutsideMixin,
  classNames: "dropdown"
  classNameBindings: "showDropdown:active"

  setupClickOutsideOnInsert: false
  showErrorsOnBlur: false

  openOnFocus: ( (event) ->
    return @$('a, input').blur() if @get('disabled')
    @set('showDropdown', true)
  ).on('focusIn')

  closeOnClick: ( (event) ->
    return if $(event.target).parents('.dropdown-menu').length
    return unless @get('showDropdown')
    Ember.run.next(this, @blurDropdown)
  ).on('mouseDown')

  closeOnDisable: ( ->
    @blurDropdown() if @get('disabled')
  ).observes('disabled')

  closeOnTabAway: ( (event) ->
    if event.which == 9
      @set('showDropdown', false)
  ).on('keyDown')

  didClickOutside: ->
    @blurDropdown()

  didToggleDropdown: ( ->
    if @get('showDropdown')
      @_setupClickOutside()
    else
      @_teardownClickOutside()
  ).observes('showDropdown')

  blurDropdown: ->
    @set('showDropdown', false)
    @$('a, input').blur() if @inDOM()

  actions:
    select: (value) ->
      @set('value', value)
      @blurDropdown()
