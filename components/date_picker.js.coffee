App.DatePickerComponent = Ember.Component.extend App.DropdownMixin,
  classNames: "datepicker"

  currentMonth: Ember.computed.momentFormat('monthStart', 'MMM YYYY')

  days: ( ->
    [0..@get('daysCount')].map (index) =>
      DatePickerDay.create
        datePicker: this
        date: moment(@get('firstIsoDay')).add(index, 'days').toDate()
  ).property('firstIsoDay', 'weeksInMonth')

  weeks: ( ->
    [0..(@get('daysCount') + 1) / 7 - 1].map (index) =>
      days: @get('days').slice(index * 7, index * 7 + 7)
  ).property('days.[]')

  setMonthStart: ( ->
    @set('monthStart', moment(@get('value')).startOf('month').toDate())
  ).observes('value', 'showDropdown').on('init')

  actions:
    nextMonth: ->
      @set('monthStart', moment(@get('monthStart')).add(1, 'month').toDate())

    prevMonth: ->
      @set('monthStart', moment(@get('monthStart')).subtract(1, 'month').toDate())

    setDay: (day) ->
      @setProperties
        value: day.get('date')
        showDropdown: false

  firstIsoDay:  Ember.computed.momentStartOf('monthStart', 'isoWeek')
  monthEnd:     Ember.computed.momentEndOf('monthStart', 'month')
  lastIsoDay:   Ember.computed.momentEndOf('monthEnd', 'isoWeek')

  daysCount: ( ->
    moment(@get('lastIsoDay')).diff(@get('firstIsoDay'), 'days')
  ).property('firstIsoDay', 'lastIsoDay')


DatePickerDay = Ember.Object.extend
  date:        Ember.required()
  day:         Ember.computed.momentFormat('date', 'D')
  month:       Ember.computed.momentFormat('date', 'M')
  startMonth:  Ember.computed.momentFormat('datePicker.monthStart', 'M')
  selected:    Ember.computed.isEqual('date', 'datePicker.value')
  isThisMonth: Ember.computed.isEqual('month', 'startMonth')
  isToday: ( ->
    moment().startOf('day').isSame(moment(@get('date')))
  ).property('date')
