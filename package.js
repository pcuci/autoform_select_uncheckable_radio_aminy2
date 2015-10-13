'use strict';

Package.describe({
    name: 'pcuci:autoform-select-uncheckable-radio-aminy2',
    summary: 'Materialize based radio buttons that can be unselected for Aminy',
    version: '0.0.5',
    github: 'https://github.com/pcuci/autoform_select_uncheckable_radio_aminy2.git'
});

Package.onUse(function(api) {
    api.versionsFrom('1.1.0.3');

    api.use('templating');
    api.use('aldeed:autoform@5.4.1');
    api.use('aldeed:template-extension@3.4.3');
    api.use('reactive-var');

    api.use([
      'underscore',
      'coffeescript'
    ], 'client');

    api.addFiles([
      'utility.js',
      'autoform_select_uncheckable_radio_aminy.html',
      'autoform_select_uncheckable_radio_aminy.coffee'
    ], 'client');
});
