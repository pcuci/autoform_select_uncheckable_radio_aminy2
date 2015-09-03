Utility = {};
Utility.initializeSelect = function() {
  var template = this
  var select = template.$('select')
  select.material_select()

  var initialize = _.debounce(function () {
    select.material_select()
  }, 500)

  template.autorun(function () {
    // reinitialize select when data changes
    Template.currentData()
    initialize()
  })
}

Utility.toggleInvalidClass = function(atts) {
  var context, formId, isInvalid, ss;
  formId = AutoForm.getFormId();
  ss = AutoForm.getFormSchema();
  context = ss.namedContext(formId);
  isInvalid = context.keyIsInvalid(atts.name);
  if (isInvalid) {
    atts = AutoForm.Utility.addClass(atts, "invalid");
  } else {
    atts = removeClass(atts, "invalid");
  }
  return atts;
};

function removeClass(atts, klass) {
  if (typeof atts["class"] === "string") {
    atts["class"].replace(klass, '');
  }
  return atts;
};

Utility.helpers = {};

Utility.helpers.attsAddClass = function(atts) {
  var result;
  result = _.clone(atts);
  result = AutoForm.Utility.addClass(atts, 'btn waves-effect waves-light');
  return result;
};

Utility.helpers.attsCheckSelected = function(atts, selected) {
    var result = _.clone(atts);
    if (selected) {
        result.checked = '';
    }
    return result;
};

Utility.helpers.attsToggleInvalidClass = function(atts) {
  var result = _.clone(atts);
  result = Utility.toggleInvalidClass(result);
  return result;
};

Utility.helpers.dsk = function() {
  return {
    'data-schema-key': this.atts['data-schema-key']
  };
};

Utility.helpers.itemAttsWithUniqId = function(atts) {
  var result;
  result = _.clone(atts);
  result.id = result.id + "_" + this._id;
  delete result['data-schema-key'];
  return result;
}

Utility.helpers.optionAtts = function() {
    var atts = {
        value: this.value
    };

    if (this.selected) {
        atts.selected = '';
    }
    return atts;
};
