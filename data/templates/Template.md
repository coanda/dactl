## Templates

The plugin templates have been written using Jinja2 as the engine with Python
used to develop any scripts that generate the output.

### Types

There are three plugin types that templates are provided for:

 * Backend
 * Device
 * Plugin

### Variables

This lists some of the variables used to develop the templates. All variables are listed using dot notation, Jinja2 allows for array notation as well, for example `project.version` is the same as `project["version"]`.

#### Project

_\*\*\* This should really be 'Package', planning to change later \*\*\*_

 * `project`

   > The dictionary containing all variables.

 * `project.name`

   > Convenience variable to avoid namespace issues when switching to DCS.

 * `project.version`

   > The project version to target.

#### Plugin

 * `plugin`

   > The dictionary containing all variables.

 * `plugin.id`

   > An ID value to use in the plugin configuration.

 * `plugin.namespace`

   > The namespace to use in the plugin configuration.

 * `plugin.type`

   > The plugin type, eg. _device_.

 * `plugin.type|title`

   > The capitalized plugin type, eg. _Device_.

 * `plugin.name`

   > The lowercase hyphenated plugin name, eg. _my-device_.

 * `plugin.name|title|replace("-", "")`

   > The UpperCamelCase plugin name, eg. _MyDevice_.

 * `plugin.name|replace("-", "_")`

   > The lowercase underscore separated plugin name, eg. _my_device_.

 * `plugin.name|upper|replace("-", "_")`

   > The uppercase underscore separated plugin name, eg. _MY_DEVICE_.
