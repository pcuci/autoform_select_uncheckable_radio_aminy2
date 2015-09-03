AutoForm.addInputType "select-uncheckable-radio",
  template: "afUncheckableRadioGroup"
  valueOut: ->
    console.log("VALUE OUT ------------ VALUE OUT, this", @)
    console.log("VALUE OUT ------------ VALUE OUT", @find("input[type=radio]:checked").val())
    @find("input[type=radio]:checked").val()
  contextAdjust: (context) ->
    console.log("context", context)
    console.log("this.data", Template.currentData())
    ss = AutoForm.getFormSchema()
    console.log("ss", ss._schema[context.name].label)

    label = ss._schema[context.name].label
    # Split on new lines to 3 different lines
    lines = label.split("\n")
    context.firstLine = if lines[0] then lines[0] else ""
    context.firstSubLine = if lines[1] then lines[1] else ""
    context.secondSubLine = if lines[2] then lines[2] else ""
    itemAtts = _.omit(context.atts)
    console.log("itemAtts", itemAtts)

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
    console.log("this.selected", this)
    atts = Utility.helpers.itemAttsWithUniqId(@atts)
    atts = Utility.helpers.attsToggleInvalidClass(atts)
    Utility.helpers.attsCheckSelected(atts, @selected)
  active: ->
    if Template.currentData().currentValue?.get()
      'active'
    else
      ''
  isActive: ->
    console.log("isActive")
    if Template.currentData().currentValue?.get()
      true
    else
      false
  higherSelected: ->
    Template.instance().toggleHigherSelectedCheck.depend()
    higherSelected = ''

    items = Template.parentData().items
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

# Template.afUncheckableRadioGroupActiveRadio.update = ->
#   # Updateing selection
#   console.log("in update! in update! in update! in update! in update! ")
#   if Template.currentData().currentValue?.get()
#     Template.currentData().items[0].selected = true
#     $('input[value=' + Template.currentData().items[0].value + ']').prop('checked', true)


Template.afUncheckableRadioGroup.created = ->
  @data.currentValue = new ReactiveVar(@data.value)
  @toggleHigherSelectedCheck = new Tracker.Dependency

Template.afUncheckableRadioGroup.rendered = ->
  console.log("@", Template.currentData().currentValue)
  @autorun(->
    if Template.currentData().currentValue?.get()
      console.log("currentValue", Template.currentData().currentValue.get())
      console.log('input[value=' + Template.currentData().currentValue.get() + ']')
      $('input[value=' + Template.currentData().currentValue.get() + ']').prop('checked', true)
      Template.instance().toggleHigherSelectedCheck.changed()
  )
  addAutoFormHooks(AutoForm.getFormId())

addAutoFormHooks = (formId) ->
  AutoForm.addHooks formId,
    before:
      update: (doc) ->
        console.log("                       --- before updateDOC", doc)
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
#Template.afUncheckableRadioGroupActiveRadios.copyAs('afUncheckableRadioGroupActiveRadios_materialize');
#Template.afUncheckableRadioGroupActiveRadio.copyAs('afUncheckableRadioGroupActiveRadio_materialize');


Template.autoForm.onRendered(->
  # console.log("in autoform rendered")
  # spans = $('span.spanText')
  # console.log("span.spanTexts", spans)
  # console.log(".parentNode.parentNode.parentNode.clientWidth", spans[3].parentNode.parentNode.parentNode.clientWidth)
  # console.log(".parentNode.parentNode.offsetLeft", spans[3].parentNode.parentNode.offsetLeft)
  # offset = spans[3].parentNode.parentNode.parentNode.clientWidth - spans[3].clientWidth
  # console.log('parent:', $(spans[3].parentNode.parentNode.parentNode))
  # $(spans[3]).offset({left: (-1 * offset)})
)
