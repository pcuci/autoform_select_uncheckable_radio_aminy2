AutoForm.addInputType "select-uncheckable-radio",
  template: "afUncheckableRadioGroup"
  valueOut: ->
    @find("input[type=radio]:checked").val()
  contextAdjust: (context) ->
    ss = AutoForm.getFormSchema()

    label = ss._schema[context.name].label
    # Split on new lines to 3 different lines
    lines = label.split("\n")
    context.firstLine = if lines[0] then lines[0] else ""
    context.firstSubLine = if lines[1] then lines[1] else ""
    context.secondSubLine = if lines[2] then lines[2] else ""
    itemAtts = _.omit(context.atts)

    context.items = []
    console.log("context", context)
    # Add all defined options
    firstPass = true
    _.each context.selectOptions, (opt) ->
      lines = opt.label.split("\n")
      firstLine = if lines[0] then lines[0] else ""
      firstSubLine = if lines[1] then lines[1] else ""
      secondSubLine = if lines[2] then lines[2] else ""
      context.items.push
        name: context.name
        firstLine: firstLine
        firstSubLine: firstSubLine
        secondSubLine: secondSubLine
        value: opt.value

        # _id must be included because it is a special property that
        # #each uses to track unique list items when adding and removing them
        # See https://github.com/meteor/meteor/issues/2174
        _id: opt.value
        selected: (opt.value is context.value)
        atts: itemAtts
    context

Template.afUncheckableRadioGroup.helpers
  dsk: Utility.helpers.dsk
  itemAtts: ->
    atts = Utility.helpers.itemAttsWithUniqId(@atts)
    atts = Utility.helpers.attsToggleInvalidClass(atts)
    Utility.helpers.attsCheckSelected(atts, @selected)
  active: ->
    if Template.currentData().currentValue?.get()
      'active'
    else
      ''
  isActive: ->
    if Template.currentData().currentValue?.get()
      true
    else
      false
  higherSelected: ->
    Template.instance().toggleHigherSelectedCheck.depend()
    higherSelected = ''

    items = Template.parentData().items

    # Apply style to all left of selected
    foundSelf = false
    passedSelected = false
    _.each(_.clone(items).reverse(), (item) ->
      if passedSelected and (item.value is Template.currentData().value)
        foundSelf = true
      if item.value is Template.parentData().currentValue.get() # Template.instance().currentValue
        passedSelected = true
      if foundSelf and passedSelected
        higherSelected = "higherSelected"
    )
    higherSelected
  selectedFirstLine: ->
    firstLine = ''
    _.each(Template.parentData().items, (item) ->
      if item.value is Template.parentData().currentValue.get()
        firstLine = item.firstLine
    )
    firstLine
  selectedFirstSubLine: ->
    firstSubLine = ''
    _.each(Template.parentData().items, (item) ->
      if item.value is Template.parentData().currentValue.get()
        firstSubLine = item.firstSubLine
    )
    firstSubLine
  selectedSecondSubLine: ->
    secondSubLine = ''
    _.each(Template.parentData().items, (item) ->
      if item.value is Template.parentData().currentValue.get()
        secondSubLine = item.secondSubLine
    )
    secondSubLine

Template.afUncheckableRadioGroup.events
  'click .active input + label': (event, template) ->
    event.preventDefault()
    lastValue = template.data.currentValue.get()

    selected = $(event.currentTarget.parentNode).children('input')

    template.data.currentValue.set(undefined) # Force autorun for same value
    if lastValue isnt selected.val()
      template.data.currentValue.set(selected.val())
  'click p.fieldLabel label': (event, template) ->
    template.data.currentValue.set(undefined)
    template.data.currentValue.set(template.data.items[0].value)
    _.each(template.data.items, (item) ->
      item.selected = false
    )
    template.data.items[0].selected = true

Template.afUncheckableRadioGroup.created = ->
  @data.currentValue = new ReactiveVar(@data.value)
  @toggleHigherSelectedCheck = new Tracker.Dependency

Template.afUncheckableRadioGroup.rendered = ->
  @autorun(->
    if Template.currentData().currentValue?.get()
      $('.af-uncheck-radio-group[data-schema-key=' + Template.currentData().name + '] input[value=' + Template.currentData().currentValue.get() + ']').prop('checked', true)
      Template.instance().toggleHigherSelectedCheck.changed()
  )
  addAutoFormHooks(AutoForm.getFormId())

addAutoFormHooks = (formId) ->
  AutoForm.addHooks formId,
    before:
      update: (doc) ->
        # Need to unset fields that have previously been set
        ss = AutoForm.getFormSchema(formId)
        uncheckableRadioFieldKeys = []
        # Find all fields of type select-uncheckable-radio
        _.each(ss._schemaKeys, (key) ->
          if ss._schema[key].autoform?.type is "select-uncheckable-radio"
            uncheckableRadioFieldKeys.push(key)
        )
        doc.$unset = {}
        _.each(uncheckableRadioFieldKeys, (key) ->
          # Only unset undefined fields, i.e.: select-uncheckable-radio types which have just been unselected
          if not doc.$set[key]
            doc.$unset[key] = ""
        )
        @.result(doc)

Template.afUncheckableRadioGroup.copyAs('afUncheckableRadioGroup_materialize');

Template.autoForm.onRendered(->
  # this.autorun( ->
  #   console.log("window width", rwindow.innerWidth())
  #   spans = $('span.firstLine')
  #   console.log("spans", spans)
  #   console.log(".parentNode.parentNode.parentNode.clientWidth", $(spans[3].parentNode.parentNode.parentNode).offset().left)
  #   console.log(".parentNode.parentNode.offsetLeft", spans[3].parentNode.parentNode.offsetLeft)
  #   offsetLeft = spans[3].parentNode.parentNode.offsetLeft
  #   offsetLeftR = -offsetLeft
  #   console.log("offsetLeft", offsetLeftR)
  #   console.log('parent:', $(spans[3].parentNode.parentNode.parentNode))
  #   #$(spans[3]).offset({left: 0})
  #   console.log(".parentNode.parentNode.position", $(spans[3].parentNode.parentNode).position())
  #   padding = parseInt($(spans[3].parentNode.parentNode.parentNode).children().first().find('label').css('padding-left').replace(/px/,""))
  #   console.log('padding', padding)
  #   offsetSpan = $(spans[3].parentNode.parentNode.parentNode).offset().left
  #   console.log('padding', offsetSpan + padding)
  #   console.log("off", {left: offsetSpan})
  #   $(spans[3]).offset({left: offsetSpan + padding})
  # )
)
