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
    if Template.instance().get("currentValue")?.get()
      'active'
    else
      ''
  isActive: ->
    if Template.instance().get("currentValue")?.get()
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
      if item.value is Template.instance().get("currentValue").get()
        passedSelected = true
      if foundSelf and passedSelected
        higherSelected = "higherSelected"
    )
    higherSelected
  selectedFirstLine: ->
    firstLine = ''
    _.each(Template.parentData().items, (item) ->
      if item.value is Template.instance().get("currentValue").get()
        firstLine = item.firstLine
    )
    firstLine
  selectedFirstSubLine: ->
    firstSubLine = ''
    _.each(Template.parentData().items, (item) ->
      if item.value is Template.instance().get("currentValue").get()
        firstSubLine = item.firstSubLine
    )
    firstSubLine
  selectedSecondSubLine: ->
    secondSubLine = ''
    _.each(Template.parentData().items, (item) ->
      if item.value is Template.instance().get("currentValue").get()
        secondSubLine = item.secondSubLine
    )
    secondSubLine

Template.afUncheckableRadioGroup.events
  'click .active input + label': (event, template) ->
    event.preventDefault()
    lastValue = template.get("currentValue").get()

    selected = $(event.currentTarget.parentNode).children('input')

    template.get("currentValue").set(undefined) # Force autorun for same value
    if lastValue isnt selected.val()
      template.get("currentValue").set(selected.val())
  'click p.fieldLabel label': (event, template) ->
    console.log('template', template.get("currentValue"))
    template.get("currentValue").set(undefined)
    template.get("currentValue").set(template.data.items[0].value)
    _.each(template.data.items, (item) ->
      item.selected = false
    )
    template.data.items[0].selected = true

Template.afUncheckableRadioGroup.created = ->
  @currentValue = new ReactiveVar(@data.value)
  @toggleHigherSelectedCheck = new Tracker.Dependency

Template.afUncheckableRadioGroup.rendered = ->
  @autorun(->
    if Template.instance().get("currentValue").get()
      $('.af-uncheck-radio-group[data-schema-key=' + Template.currentData().name + '] input[value=' + Template.instance().get("currentValue").get() + ']').prop('checked', true)
      Template.instance().toggleHigherSelectedCheck.changed()
  )
  addAutoFormHooks(AutoForm.getFormId())

addAutoFormHooks = (formId) ->
  AutoForm.addHooks formId,
    before:
      update: (doc) ->
        console.log("AutoForm.addHooks @", @)
        console.log("doc", doc)
        console.log("@currentDoc", @currentDoc)
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
          console.log("key", key)
          # Unset undefined fields only, i.e.: select-uncheckable-radio types which have just been unselected
          unless doc.$set[key]
            doc.$unset[key] = ""
        )
        @.result(doc)

Template.afUncheckableRadioGroup.copyAs('afUncheckableRadioGroup_materialize');
